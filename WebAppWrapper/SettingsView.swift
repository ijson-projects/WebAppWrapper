//
//  SettingsView.swift
//  WebAppWrapper
//
//  Created by 崔永旭 on 25/12/2025.
//

import SwiftUI

/// 设置界面
struct SettingsView: View {
    @AppStorage("webAppURL") private var webAppURL = "https://www.ijson.com"
    @AppStorage("appName") private var appName = "Web App"
    @State private var urlInput = ""
    @State private var nameInput = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("设置")
                .font(.title)
                .padding(.top)
            
            Form {
                // 应用名称
                Section {
                    TextField("应用名称", text: $nameInput)
                        .textFieldStyle(.roundedBorder)
                } header: {
                    Text("应用名称")
                        .font(.headline)
                } footer: {
                    Text("设置应用的显示名称")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 网站 URL
                Section {
                    TextField("https://www.ijson.com", text: $urlInput)
                        .textFieldStyle(.roundedBorder)
                } header: {
                    Text("网站地址")
                        .font(.headline)
                } footer: {
                    Text("输入要打开的网站完整地址（包含 https://）")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 预设网站
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("快速选择：")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 10) {
                            presetButton("Apple", url: "https://www.apple.com")
                            presetButton("Google", url: "https://www.google.com")
                            presetButton("GitHub", url: "https://github.com")
                            presetButton("ShareCRM", url: "https://www.fxiaoke.com")
                        }
                    }
                } header: {
                    Text("预设网站")
                        .font(.headline)
                }
            }
            .formStyle(.grouped)
            
            // 按钮
            HStack(spacing: 15) {
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Button("保存") {
                    saveSettings()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
            .padding(.bottom)
        }
        .frame(width: 500, height: 450)
        .onAppear {
            urlInput = webAppURL
            nameInput = appName
        }
        .alert("提示", isPresented: $showAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func presetButton(_ title: String, url: String) -> some View {
        Button(title) {
            urlInput = url
        }
        .buttonStyle(.bordered)
    }
    
    private func saveSettings() {
        // 验证 URL
        guard !urlInput.isEmpty else {
            alertMessage = "请输入网站地址"
            showAlert = true
            return
        }
        
        guard urlInput.hasPrefix("http://") || urlInput.hasPrefix("https://") else {
            alertMessage = "网站地址必须以 http:// 或 https:// 开头"
            showAlert = true
            return
        }
        
        guard URL(string: urlInput) != nil else {
            alertMessage = "网站地址格式不正确"
            showAlert = true
            return
        }
        
        // 验证名称
        guard !nameInput.isEmpty else {
            alertMessage = "请输入应用名称"
            showAlert = true
            return
        }
        
        // 保存设置
        webAppURL = urlInput
        appName = nameInput
        
        // 加载新 URL
        WebViewModel.shared.loadURL(urlInput)
        
        // 关闭窗口
        dismiss()
    }
}

#Preview {
    SettingsView()
}

