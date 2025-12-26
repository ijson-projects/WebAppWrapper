//
//  WebView.swift
//  WebAppWrapper
//
//  Created by 崔永旭 on 22/12/2025.
//

import SwiftUI
import WebKit
import Combine

/// WebView 封装 - 用于在 SwiftUI 中显示 WKWebView
struct WebView: NSViewRepresentable {
    @ObservedObject var viewModel: WebViewModel
    
    func makeNSView(context: Context) -> WKWebView {
        return viewModel.webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // 不需要更新，WebView 由 ViewModel 管理
    }
}

/// WebView 的 ViewModel - 管理 WebView 的状态和行为
class WebViewModel: NSObject, ObservableObject {
    // MARK: - Singleton
    static let shared = WebViewModel()

    // MARK: - Published Properties
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var isLoading: Bool = false
    @Published var currentURL: String = ""

    private var hasLoadedInitialURL = false

    // 用户设置
    private let defaults = UserDefaults.standard
    private let urlKey = "webAppURL"
    private let defaultURL = "https://www.apple.com"
    
    // MARK: - WebView Configuration
    lazy var webView: WKWebView = {
        // 配置 WebView
        let configuration = WKWebViewConfiguration()

        // 启用持久化存储（保存 Cookie 和登录状态）
        configuration.websiteDataStore = .default()

        // 配置媒体播放策略 - 允许自动播放，隐藏菜单栏音频图标
        configuration.mediaTypesRequiringUserActionForPlayback = []

        // 创建 WebView
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self

        // 允许后退手势
        webView.allowsBackForwardNavigationGestures = true

        // 允许放大缩小
        webView.allowsMagnification = true

        return webView
    }()
    
    // MARK: - Initialization
    override init() {
        super.init()
        loadWebsite()
    }

    // MARK: - Public Methods

    /// 加载网站（仅首次）
    func loadWebsite() {
        guard !hasLoadedInitialURL else { return }
        hasLoadedInitialURL = true

        let urlString = defaults.string(forKey: urlKey) ?? defaultURL
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    /// 加载指定 URL
    func loadURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)

        // 保存到设置
        defaults.set(urlString, forKey: urlKey)
    }

    /// 获取当前设置的 URL
    func getSavedURL() -> String {
        return defaults.string(forKey: urlKey) ?? defaultURL
    }
    
    /// 后退
    func goBack() {
        webView.goBack()
    }
    
    /// 前进
    func goForward() {
        webView.goForward()
    }
    
    /// 刷新
    func reload() {
        if isLoading {
            webView.stopLoading()
        } else {
            webView.reload()
        }
    }

    /// 清理内存（可选）
    func clearMemory() {
        let dataStore = WKWebsiteDataStore.default()
        let dataTypes = Set([WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = Date(timeIntervalSince1970: 0)
        dataStore.removeData(ofTypes: dataTypes, modifiedSince: date) { }
    }

    /// 开发者工具
    func toggleDevTools() {
        #if DEBUG
        if webView.configuration.preferences.value(forKey: "developerExtrasEnabled") as? Bool == true {
            webView.configuration.preferences.setValue(false, forKey: "developerExtrasEnabled")
        } else {
            webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        }
        #else
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif
    }

    /// 缩放
    func zoomIn() {
        webView.pageZoom += 0.1
    }

    func zoomOut() {
        webView.pageZoom -= 0.1
    }

    func resetZoom() {
        webView.pageZoom = 1.0
    }
    
    /// 更新导航状态
    private func updateNavigationState() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.canGoBack = self.webView.canGoBack
            self.canGoForward = self.webView.canGoForward
        }
    }
    
    /// 更新当前 URL 显示
    private func updateCurrentURL() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let url = self.webView.url {
                self.currentURL = url.absoluteString
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension WebViewModel: WKNavigationDelegate {
    /// 决定是否允许导航
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // 拦截 about:blank 和空链接
        if url.absoluteString == "about:blank" || url.absoluteString.isEmpty {
            decisionHandler(.cancel)
            return
        }

        // 允许所有导航
        decisionHandler(.allow)
    }

    /// 开始加载
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
        }
        updateCurrentURL()
    }
    
    /// 加载完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
        }
        updateNavigationState()
        updateCurrentURL()
    }
    
    /// 加载失败
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
        }
        updateNavigationState()
    }
    
    /// 接收服务器重定向
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        updateCurrentURL()
    }
}

// MARK: - WKUIDelegate
extension WebViewModel: WKUIDelegate {
    /// 处理新窗口打开请求
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }

        // 拦截 about:blank
        if url.absoluteString == "about:blank" || url.absoluteString.isEmpty {
            return nil
        }

        // 在当前窗口打开
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }

        return nil
    }
}

