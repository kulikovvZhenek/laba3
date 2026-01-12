#!/bin/bash
# test-minimal.sh - Минимальный тест конвертации

echo "🧪 МИНИМАЛЬНЫЙ ТЕСТ КОНВЕРТАЦИИ"
echo "==============================="

# Создаём тестовую папку
TEST_DIR="./minimal-test"
mkdir -p "$TEST_DIR"

echo "1. Создаю тестовый PNG файл..."

# Создаём PNG через PowerShell (гарантированно работает в Windows)
powershell -Command "
    Add-Type -AssemblyName System.Drawing;
    \$bmp = New-Object System.Drawing.Bitmap(100, 100);
    \$g = [System.Drawing.Graphics]::FromImage(\$bmp);
    \$g.Clear([System.Drawing.Color]::FromArgb(255, 255, 0, 0));  # Красный
    \$g.FillEllipse([System.Drawing.Brushes]::Blue, 20, 20, 60, 60);
    \$bmp.Save('$TEST_DIR/test-image.png', [System.Drawing.Imaging.ImageFormat]::Png);
    \$bmp.Dispose();
    Write-Host 'Файл создан: test-image.png'
"

echo ""
echo "2. Проверяю файл..."
if [ -f "$TEST_DIR/test-image.png" ]; then
    echo "   ✅ PNG файл создан: $TEST_DIR/test-image.png"
    ls -la "$TEST_DIR/test-image.png"
else
    echo "   ❌ Не удалось создать PNG"
    exit 1
fi

echo ""
echo "3. Тестирую ImageMagick..."
if command -v magick &> /dev/null; then
    echo "   Команда: magick"
    CMD="magick"
elif convert -version 2>/dev/null | grep -q "ImageMagick"; then
    echo "   Команда: convert"
    CMD="convert"
else
    echo "   ❌ ImageMagick не найден"
    exit 1
fi

echo ""
echo "4. Пробую сконвертировать..."
echo "   Метод 1: Стандартный"
$CMD "$TEST_DIR/test-image.png" -quality 85 "$TEST_DIR/test-output.jpg" 2>&1

if [ -f "$TEST_DIR/test-output.jpg" ]; then
    echo "   ✅ УСПЕХ: JPG создан!"
    ls -la "$TEST_DIR/test-output.jpg"
    echo ""
    echo "🎉 ТЕСТ ПРОЙДЕН! ImageMagick работает."
    echo ""
    echo "🚀 Теперь запустите основной скрипт:"
    echo "   ./image-watchdog.sh '$TEST_DIR'"
else
    echo "   ❌ Стандартный метод не сработал"
    echo ""
    echo "   Пробую метод 2: С явным форматом..."
    $CMD "$TEST_DIR/test-image.png" -quality 85 "jpg:$TEST_DIR/test-output2.jpg" 2>&1
    
    if [ -f "$TEST_DIR/test-output2.jpg" ]; then
        echo "   ✅ УСПЕХ: Работает с синтаксисом 'jpg:'"
        echo ""
        echo "⚠️  Используйте скрипт simple-converter.sh"
        echo "   Он поддерживает этот синтаксис"
    else
        echo "   ❌ Оба метода не сработали"
        echo ""
        echo "🔧 Решение: Переустановите ImageMagick"
        echo "   https://imagemagick.org/script/download.php"
    fi
fi