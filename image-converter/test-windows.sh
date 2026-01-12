#!/bin/bash
# test-windows.sh - Тест для Windows с правильным синтаксисом

echo "🧪 ТЕСТ ДЛЯ WINDOWS С ПРАВИЛЬНЫМ СИНТАКСИСОМ"
echo "=========================================="

# Создаём тестовую папку
TEST_DIR="./windows-test"
mkdir -p "$TEST_DIR"

echo "1. Проверяю ImageMagick..."
if command -v magick &> /dev/null; then
    echo "   ✅ magick найден"
    CMD="magick"
elif magick convert -version 2>/dev/null | grep -q "ImageMagick"; then
    echo "   ✅ magick convert найден"
    CMD="magick convert"
else
    echo "❌ ImageMagick не найден!"
    echo ""
    echo "РЕШЕНИЕ:"
    echo "1. Переустановите ImageMagick"
    echo "2. При установке отметьте: 'Add to PATH'"
    echo "3. Перезапустите Git Bash"
    echo "4. Проверьте: magick --version"
    exit 1
fi

echo ""
echo "2. Создаю тестовый PNG..."
# Создаём через ImageMagick
$CMD -size 100x100 xc:#FF0000 \
    -fill blue -draw "circle 50,50 50,20" \
    -fill white -draw "text 30,60 'TEST'" \
    "$TEST_DIR/test-red.png" 2>/dev/null

if [ ! -f "$TEST_DIR/test-red.png" ]; then
    echo "   ⚠️  Не удалось создать через ImageMagick"
    echo "   Создаю простой файл..."
    echo "TEST" > "$TEST_DIR/test-simple.png"
fi

echo "   ✅ Файл создан: $(ls $TEST_DIR/*.png 2>/dev/null | head -1)"

echo ""
echo "3. Тестирую конвертацию PNG → JPG..."
echo "   Команда: $CMD файл.png -quality 85 файл.jpg"

TEST_PNG=$(ls $TEST_DIR/*.png 2>/dev/null | head -1)
if [ -n "$TEST_PNG" ]; then
    $CMD "$TEST_PNG" -quality 85 "$TEST_DIR/output-test.jpg" 2>&1
    
    if [ -f "$TEST_DIR/output-test.jpg" ]; then
        echo "   ✅ УСПЕХ! JPG создан:"
        ls -la "$TEST_DIR/output-test.jpg"
        echo ""
        echo "🎉 ВСЁ РАБОТАЕТ КОРРЕКТНО!"
        echo ""
        echo "🚀 Теперь запустите:"
        echo "   ./image-watchdog.sh '$TEST_DIR'"
        echo "   Или"
        echo "   ./simple-converter.sh '$TEST_DIR'"
    else
        echo "   ❌ Не удалось создать JPG"
        echo ""
        echo "🔧 Альтернативные команды для теста:"
        echo "   magick convert \"$TEST_PNG\" -quality 85 \"$TEST_DIR/test2.jpg\""
        echo "   magick \"$TEST_PNG\" \"$TEST_DIR/test3.jpg\""
    fi
else
    echo "   ❌ Нет PNG файла для теста"
fi

echo ""
echo "=========================================="
echo "📝 Если тест не проходит:"
echo "1. Проверьте: magick --version"
echo "2. Если ошибка: переустановите ImageMagick"
echo "3. Используйте Chocolatey: choco install imagemagick"
echo "=========================================="