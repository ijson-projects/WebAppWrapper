# WebApp Wrapper

A lightweight native macOS tool to wrap any website into a standalone desktop application.

[中文文档](README_CN.md)

## Features

- **Native Swift** - 10x faster than Electron, using native WKWebView
- **Lightweight** - 1/10 memory usage compared to Electron
- **Customizable** - Custom website URL and app name
- **Easy to Use** - GUI configuration, no coding required
- **Open Source** - MIT License, completely free
- **Menu Bar** - Quick access, no Dock space needed
- **Keyboard Shortcuts** - Full keyboard support
- **Privacy** - All data stored locally

## Quick Start

### Download Pre-built App (Recommended)

1. Download the latest `WebAppWrapper_v1.0.0.dmg` from [Releases](https://github.com/ijson-projects/WebAppWrapper/releases)
2. Open the DMG file
3. Drag `WebAppWrapper.app` to the Applications folder
4. Right-click the app and select "Open" (first time only)
5. Click the gear icon ⚙️ to configure your website

### Build from Source

**Requirements**: macOS 15.6+, Xcode 17.0+

```bash
# Clone repository
git clone https://github.com/ijson-projects/WebAppWrapper.git
cd WebAppWrapper

# Build application
chmod +x package.sh
./package.sh

# Create DMG (optional)
chmod +x create_dmg.sh
./create_dmg.sh
```

## Usage

### Configure Website

1. Click the gear icon in the toolbar
2. Enter website URL (e.g., `https://www.ijson.com`)
3. Enter application name
4. Click "Save"

### Keyboard Shortcuts

- `⌘ + [` - Back
- `⌘ + ]` - Forward
- `⌘ + R` - Reload
- `⌘ + +` / `⌘ + -` - Zoom
- `⌘ + ,` - Settings
- `⌘ + ⌥ + I` - Developer Tools

## Custom Icons

Place your icon files in `custom_icons/`:

- `AppIcon.png` - 1024x1024 (color)
- `StatusBarIcon.png` - 1024x1024 (black & white)

See [custom_icons/README.md](custom_icons/README.md) for details.

## Comparison

| Feature | WebApp Wrapper | Nativefier | Electron Apps |
|---------|---------------|------------|---------------|
| Technology | Native Swift | Electron | Electron |
| Memory | ~50MB | ~200MB | ~200MB |
| Startup | Fast | Slow | Slow |
| Package Size | ~5MB | ~100MB | ~100MB |
| Native Experience | ✅ | ❌ | ❌ |

## License

MIT License - See [LICENSE](LICENSE) file

## Disclaimer

This is a general-purpose tool for learning and research. Users are responsible for their own use.

## Credits

- Thanks to Apple for the WKWebView framework
- Inspired by Nativefier, Fluid, and similar tools

---

If this helps you, please give it a Star!

