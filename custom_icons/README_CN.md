# 自定义图标说明

[English](README.md)

## 需要的文件

将以下 2 个图标文件放在此目录：

### 1. AppIcon.png
- **尺寸**：1024x1024 像素
- **格式**：PNG（彩色，透明或纯色背景）
- **用途**：应用图标（Dock、启动台、Finder）

### 2. StatusBarIcon.png
- **尺寸**：1024x1024 像素
- **格式**：PNG（黑白单色，透明背景）
- **用途**：菜单栏图标（屏幕右上角）

## 使用方法

```bash
# 1. 放置图标文件
custom_icons/
├── AppIcon.png          (1024x1024，彩色)
└── StatusBarIcon.png    (1024x1024，黑白)

# 2. 打包应用
./package.sh

# 3. 创建 DMG（可选）
./create_dmg.sh
```

脚本会自动生成所有需要的尺寸（应用图标 10 个，菜单栏图标 3 个）。

## 设计建议

**AppIcon（应用图标）**
- 颜色鲜明，易于识别
- 避免过于复杂的细节
- 可以使用渐变和阴影

**StatusBarIcon（菜单栏图标）**
- 简单的线条图标
- 黑白单色（系统自动适配深色/浅色模式）
- 线条粗细 1-2 像素

## 图标资源

- [SF Symbols](https://developer.apple.com/sf-symbols/) - Apple 官方
- [Iconoir](https://iconoir.com/) - 开源（MIT）
- [Heroicons](https://heroicons.com/) - MIT 许可证
- [Feather Icons](https://feathericons.com/) - MIT 许可证

## 注意

如果不提供自定义图标，应用将使用系统默认图标 🌐。

