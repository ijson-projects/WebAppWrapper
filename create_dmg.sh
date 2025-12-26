#!/bin/bash

# 生成 DMG 安装包

echo "📦 开始制作 DMG 安装包..."

# 查找应用
APP_PATH="build/Release/WebAppWrapper.app"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ 未找到应用，请先运行 ./package.sh"
    exit 1
fi

# DMG 配置
DMG_NAME="WebAppWrapper"
VERSION="1.0.0"
DMG_TEMP="${DMG_NAME}_temp.dmg"
DMG_FILE="${DMG_NAME}_v${VERSION}.dmg"
VOLUME_NAME="${DMG_NAME}"

# 创建临时目录
TMP_DIR=$(mktemp -d)
echo "📁 创建临时目录: $TMP_DIR"

# 复制应用到临时目录
cp -R "$APP_PATH" "$TMP_DIR/"

# 创建 Applications 快捷方式
ln -s /Applications "$TMP_DIR/Applications"

# 生成 DMG 卷图标（从 AppIcon 或自定义图标）
echo "🎨 生成 DMG 卷图标..."
if [ -f "custom_icons/AppIcon.png" ]; then
    echo "   ✓ 找到 custom_icons/AppIcon.png"
    # 从自定义图标生成 .icns 文件
    mkdir -p "$TMP_DIR/.VolumeIcon.iconset"
    sips -z 16 16 custom_icons/AppIcon.png --out "$TMP_DIR/.VolumeIcon.iconset/icon_16x16.png" > /dev/null 2>&1
    sips -z 32 32 custom_icons/AppIcon.png --out "$TMP_DIR/.VolumeIcon.iconset/icon_16x16@2x.png" > /dev/null 2>&1
    sips -z 32 32 custom_icons/AppIcon.png --out "$TMP_DIR/.VolumeIcon.iconset/icon_32x32.png" > /dev/null 2>&1
    sips -z 64 64 custom_icons/AppIcon.png --out "$TMP_DIR/.VolumeIcon.iconset/icon_32x32@2x.png" > /dev/null 2>&1
    sips -z 128 128 custom_icons/AppIcon.png --out "$TMP_DIR/.VolumeIcon.iconset/icon_128x128.png" > /dev/null 2>&1
    sips -z 256 256 custom_icons/AppIcon.png --out "$TMP_DIR/.VolumeIcon.iconset/icon_128x128@2x.png" > /dev/null 2>&1
    sips -z 256 256 custom_icons/AppIcon.png --out "$TMP_DIR/.VolumeIcon.iconset/icon_256x256.png" > /dev/null 2>&1
    sips -z 512 512 custom_icons/AppIcon.png --out "$TMP_DIR/.VolumeIcon.iconset/icon_256x256@2x.png" > /dev/null 2>&1
    sips -z 512 512 custom_icons/AppIcon.png --out "$TMP_DIR/.VolumeIcon.iconset/icon_512x512.png" > /dev/null 2>&1
    sips -z 1024 1024 custom_icons/AppIcon.png --out "$TMP_DIR/.VolumeIcon.iconset/icon_512x512@2x.png" > /dev/null 2>&1

    echo "   ✓ 正在生成 .icns 文件..."
    iconutil -c icns "$TMP_DIR/.VolumeIcon.iconset" -o "$TMP_DIR/.VolumeIcon.icns"

    if [ -f "$TMP_DIR/.VolumeIcon.icns" ]; then
        echo "   ✓ 成功生成 .VolumeIcon.icns ($(du -h "$TMP_DIR/.VolumeIcon.icns" | cut -f1))"
        HAS_ICON=true
    else
        echo "   ✗ 生成 .icns 失败"
        HAS_ICON=false
    fi

    rm -rf "$TMP_DIR/.VolumeIcon.iconset"
elif [ -f "dmg_resources/volume_icon.icns" ]; then
    echo "   ✓ 使用 dmg_resources/volume_icon.icns"
    cp "dmg_resources/volume_icon.icns" "$TMP_DIR/.VolumeIcon.icns"
    HAS_ICON=true
else
    echo "   ⚠️  未找到图标文件"
    HAS_ICON=false
fi

# 如果有背景图，复制到临时目录
if [ -f "dmg_resources/background.png" ]; then
    mkdir -p "$TMP_DIR/.background"
    cp "dmg_resources/background.png" "$TMP_DIR/.background/"
    HAS_BACKGROUND=true
else
    HAS_BACKGROUND=false
fi

# 删除旧的 DMG
rm -f "$DMG_TEMP" "$DMG_FILE"

# 创建临时 DMG
echo "🔨 创建临时 DMG..."
echo "   临时目录内容："
ls -la "$TMP_DIR" | grep -E "VolumeIcon|WebAppWrapper|Applications"

hdiutil create -volname "$VOLUME_NAME" \
    -srcfolder "$TMP_DIR" \
    -ov -format UDRW \
    -size 200m \
    "$DMG_TEMP"

# 挂载 DMG
echo "📂 挂载 DMG..."
MOUNT_DIR=$(hdiutil attach -readwrite -noverify -noautoopen "$DMG_TEMP" | grep "/Volumes/${VOLUME_NAME}" | awk '{print $3}')

if [ -z "$MOUNT_DIR" ]; then
    echo "❌ 挂载失败"
    exit 1
fi

echo "✅ 已挂载到: $MOUNT_DIR"

# 复制卷图标到挂载的 DMG
if [ "$HAS_ICON" = true ] && [ -f "$TMP_DIR/.VolumeIcon.icns" ]; then
    echo "🎨 复制卷图标到 DMG..."
    cp "$TMP_DIR/.VolumeIcon.icns" "$MOUNT_DIR/.VolumeIcon.icns"
    if [ -f "$MOUNT_DIR/.VolumeIcon.icns" ]; then
        echo "   ✓ 卷图标已复制"
        # 设置自定义图标属性
        SetFile -a C "$MOUNT_DIR" 2>/dev/null && echo "   ✓ 卷图标属性已设置" || echo "   ⚠️  卷图标属性设置失败（可忽略）"
    else
        echo "   ✗ 卷图标复制失败"
    fi
fi

# 设置窗口样式
echo "🎨 设置窗口样式..."

if [ "$HAS_BACKGROUND" = true ]; then
    # 有背景图
    osascript <<EOF
tell application "Finder"
    tell disk "${VOLUME_NAME}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 1000, 500}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 128
        set background picture of viewOptions to file ".background:background.png"
        set position of item "WebAppWrapper.app" of container window to {150, 200}
        set position of item "Applications" of container window to {450, 200}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF
else
    # 无背景图
    osascript <<EOF
tell application "Finder"
    tell disk "${VOLUME_NAME}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 1000, 500}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 128
        set position of item "WebAppWrapper.app" of container window to {150, 200}
        set position of item "Applications" of container window to {450, 200}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF
fi

sleep 2

# 设置卷图标（已在挂载时处理）

# 卸载 DMG
echo "💾 卸载 DMG..."
# 等待 Finder 完成操作
sleep 3
hdiutil detach "$MOUNT_DIR" -force 2>/dev/null
# 等待文件系统完全释放
echo "   等待文件系统释放..."
sleep 5

# 转换为压缩格式
echo "🗜️  压缩 DMG..."
# 确保临时 DMG 文件存在且可访问
if [ ! -f "$DMG_TEMP" ]; then
    echo "❌ 临时 DMG 文件不存在"
    exit 1
fi

# 多次尝试转换（防止资源占用）
for i in {1..3}; do
    if hdiutil convert "$DMG_TEMP" -format UDZO -o "$DMG_FILE" 2>/dev/null; then
        break
    else
        echo "   尝试 $i/3 失败，等待 3 秒后重试..."
        sleep 3
    fi
done

# 清理
rm -f "$DMG_TEMP"
rm -rf "$TMP_DIR"

echo ""
echo "   ⚠️  注意：由于 macOS 限制，压缩后的 DMG 卷图标可能无法显示"
echo "   ✓  但应用图标和 DMG 内容都是正确的"

if [ -f "$DMG_FILE" ]; then
    echo ""
    echo "✅ DMG 创建成功！"
    echo "📦 文件: $(pwd)/$DMG_FILE"
    echo "📏 大小: $(du -h "$DMG_FILE" | cut -f1)"
    echo ""
    echo "🚀 可以上传到 GitHub Release 了！"

    # 打开 Finder
    open .
else
    echo "❌ DMG 创建失败"
    exit 1
fi

