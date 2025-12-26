//
//  WebAppWrapperApp.swift
//  WebAppWrapper
//
//  Created by 崔永旭 on 22/12/2025.
//

import SwiftUI
import AppKit

@main
struct WebAppWrapperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("appName") private var appName = "Web App"

    var body: some Scene {
        Window(appName, id: "main") {
            ContentView()
        }
        .defaultSize(width: 1200, height: 800)
        .commands {
            // 开发者工具
            CommandGroup(after: .toolbar) {
                Button("开发者工具") {
                    NotificationCenter.default.post(name: NSNotification.Name("ToggleDevTools"), object: nil)
                }
                .keyboardShortcut("i", modifiers: [.command, .option])
            }

            // 导航命令
            CommandGroup(replacing: .textEditing) {
                Button("后退") {
                    WebViewModel.shared.goBack()
                }
                .keyboardShortcut("[", modifiers: .command)

                Button("前进") {
                    WebViewModel.shared.goForward()
                }
                .keyboardShortcut("]", modifiers: .command)

                Button("刷新") {
                    WebViewModel.shared.reload()
                }
                .keyboardShortcut("r", modifiers: .command)

                Divider()

                Button("放大") {
                    WebViewModel.shared.zoomIn()
                }
                .keyboardShortcut("+", modifiers: .command)

                Button("缩小") {
                    WebViewModel.shared.zoomOut()
                }
                .keyboardShortcut("-", modifiers: .command)

                Button("实际大小") {
                    WebViewModel.shared.resetZoom()
                }
                .keyboardShortcut("0", modifiers: .command)

                Divider()

                Button("设置...") {
                    NotificationCenter.default.post(name: NSNotification.Name("ShowSettings"), object: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        window = NSApplication.shared.windows.first
        window?.setFrameAutosaveName("MainWindow")

        // 创建菜单栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            // 使用自定义图标
            if let icon = NSImage(named: "StatusBarIcon") {
                icon.isTemplate = true  // 自动适配深色/浅色模式
                button.image = icon
            } else {
                // 如果没有自定义图标，使用系统图标
                button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: "Web App")
            }
            button.action = #selector(toggleWindow)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // 创建右键菜单
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "显示/隐藏", action: #selector(toggleWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "设置...", action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu

        // 隐藏 Dock 图标
        NSApp.setActivationPolicy(.accessory)
    }

    @objc func toggleWindow() {
        if window?.isVisible == true {
            window?.orderOut(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            window?.makeKeyAndOrderFront(nil)
        }
    }

    @objc func showSettings() {
        NotificationCenter.default.post(name: NSNotification.Name("ShowSettings"), object: nil)
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        window?.makeKeyAndOrderFront(nil)
        return true
    }
}
