# WebApp Wrapper - 轻量级 macOS Web 应用封装工具

一个简单、轻量级的原生 macOS 工具，可以将任何网站封装成独立的桌面应用。

[English](README.md)

## ✨ 特性

- 🚀 **原生 Swift** - 使用原生 WKWebView，比 Electron 快 10 倍
- 💾 **轻量级** - 内存占用仅 Electron 的 1/10
- 🎨 **可自定义** - 支持自定义网站 URL 和应用名称
- 🔧 **简单易用** - 图形界面配置，无需编程
- 📦 **开源免费** - MIT 许可证，完全免费
- 🎯 **菜单栏常驻** - 快速访问，不占用 Dock 空间
- ⌨️ **快捷键支持** - 完整的键盘快捷键
- 🔒 **隐私保护** - 所有数据本地存储

## 🚀 快速开始

### 环境要求

- macOS 15.6+
- Xcode 17.0+

### 从源码构建

```bash
# 克隆仓库
git clone https://github.com/yourusername/webapp-wrapper.git
cd webapp-wrapper

# 构建应用
chmod +x package.sh
./package.sh

# 创建 DMG（可选）
chmod +x create_dmg.sh
./create_dmg.sh
```

## 📖 使用说明

### 配置网站

1. 点击工具栏的齿轮图标 ⚙️
2. 输入网站地址（如 `https://www.ijson.com`）
3. 输入应用名称
4. 点击"保存"

### 快捷键

- `⌘ + [` - 后退
- `⌘ + ]` - 前进
- `⌘ + R` - 刷新
- `⌘ + +` / `⌘ + -` - 缩放
- `⌘ + ,` - 设置
- `⌘ + ⌥ + I` - 开发者工具

## 🎨 自定义图标

将图标文件放在 `custom_icons/` 目录：

- `AppIcon.png` - 1024x1024（彩色）
- `StatusBarIcon.png` - 1024x1024（黑白）

详见 [custom_icons/README_CN.md](custom_icons/README_CN.md)

## 🆚 与其他工具对比

| 特性 | WebApp Wrapper | Nativefier | Electron Apps |
|------|---------------|------------|---------------|
| 技术栈 | 原生 Swift | Electron | Electron |
| 内存占用 | ~50MB | ~200MB | ~200MB |
| 启动速度 | 快 | 慢 | 慢 |
| 包大小 | ~5MB | ~100MB | ~100MB |
| 原生体验 | ✅ | ❌ | ❌ |

## 📝 许可证

MIT License - 查看 [LICENSE](LICENSE) 文件

## ⚠️ 免责声明

本项目是通用工具，用于学习研究。用户需自行承担使用责任。

## 🙏 致谢

- 感谢 Apple 提供的 WKWebView 框架
- 灵感来自 Nativefier、Fluid 等工具

---

⭐ 如果有帮助，请给个 Star！

