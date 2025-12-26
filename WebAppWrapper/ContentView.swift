//
//  ContentView.swift
//  WebAppWrapper
//
//  Created by 崔永旭 on 22/12/2025.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @StateObject private var webViewModel = WebViewModel.shared
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            HStack(spacing: 12) {
                // 后退按钮
                Button(action: {
                    webViewModel.goBack()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                }
                .disabled(!webViewModel.canGoBack)
                .buttonStyle(.plain)
                .help("后退")

                // 前进按钮
                Button(action: {
                    webViewModel.goForward()
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                }
                .disabled(!webViewModel.canGoForward)
                .buttonStyle(.plain)
                .help("前进")

                // 刷新按钮
                Button(action: {
                    webViewModel.reload()
                }) {
                    Image(systemName: webViewModel.isLoading ? "stop.circle" : "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.plain)
                .help(webViewModel.isLoading ? "停止" : "刷新")

                // 地址栏（显示完整 URL）
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.green)

                    Text(webViewModel.currentURL)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(6)

                Spacer()

                // 设置按钮
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.plain)
                .help("设置")

                // 加载进度指示器
                if webViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // WebView 内容区域
            WebView(viewModel: webViewModel)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleDevTools"))) { _ in
            webViewModel.toggleDevTools()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowSettings"))) { _ in
            showSettings = true
        }
        .focusedSceneValue(\.webViewModel, webViewModel)
    }
}

// 快捷键支持
extension FocusedValues {
    struct WebViewModelKey: FocusedValueKey {
        typealias Value = WebViewModel
    }

    var webViewModel: WebViewModel? {
        get { self[WebViewModelKey.self] }
        set { self[WebViewModelKey.self] = newValue }
    }
}

#Preview {
    ContentView()
}
