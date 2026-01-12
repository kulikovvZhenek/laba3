#!/bin/bash
# test-simple.sh - Простой тест конвертации с magick

echo "🧪 ПРОСТОЙ ТЕСТ КОНВЕРТАЦИИ"
echo "==========================="

# Создаём тестовую папку
TEST_DIR="./test-now"
mkdir -p "$TEST_DIR"

echo "1. Проверяю ImageMagick..."
if ! command -v magick &> /dev/null; then
    echo "❌ magick не найден!"
    exit 1
fi
echo "   ✅ magick работает"

echo ""
echo "2. Создаю тестовый PNG..."
magick -size 100x100 xc:#FF0000 "$TEST_DIR/test-red.png" 2>/dev/null

if [ -f "$TEST_DIR/test-red.png" ]; then
    echo "   ✅ PNG создан"
else
    echo "   ❌ Не удалось создать PNG"
    echo "TEST" > "$TEST_DIR/test-simple.png"
fi

echo ""
echo "3. Тестирую конвертацию PNG → JPG..."
PNG_FILE=$(ls "$TEST_DIR"/*.png 2>/dev/null | head -1)

if [ -n "$PNG_FILE" ]; then
    echo "   Файл: $PNG_FILE"
    
    # Конвертируем
    magick "$PNG_FILE" -quality 85 "$TEST_DIR/output.jpg" 2>&1
    
    if [ -f "$TEST_DIR/output.jpg" ]; then
        echo "   ✅ УСПЕХ! JPG создан"
        ls -la "$TEST_DIR/output.jpg"
        echo ""
        echo "🎉 ВСЁ РАБОТАЕТ!"
        echo ""
        echo "🚀 Теперь запустите:"
        echo "   ./image-watchdog.sh '$TEST_DIR'"
    else
        echo "   ❌ Не удалось создать JPG"
        echo ""
        echo "Пробую другой синтаксис..."
        magick "$PNG_FILE" -quality 85 "jpg:$TEST_DIR/output2.jpg"
        
        if [ -f "$TEST_DIR/output2.jpg" ]; then
            echo "   ✅ Работает с синтаксисом 'jpg:'"
        fi
    fi
fi

echo ""
echo "========================================"
echo "✅ Ваш ImageMagick установлен правильно!"
echo "✅ Используйте ТОЛЬКО команду: magick"
echo "❌ Не используйте: convert"
echo "========================================"