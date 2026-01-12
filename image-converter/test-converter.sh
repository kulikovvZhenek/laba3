#!/bin/bash
# test-converter.sh - Создание тестовых изображений для Windows

echo "🧪 Тестирование Image Converter для Windows"
echo "=========================================="

# Создаем тестовую папку
TEST_DIR="./test-images"
mkdir -p "$TEST_DIR"

echo "📁 Тестовая папка: $TEST_DIR"

# Проверяем ImageMagick
if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick не установлен!"
    echo "   Установите: https://imagemagick.org/script/download.php"
    exit 1
fi

echo ""
echo "🎨 Создаю тестовые PNG изображения..."

# Определяем команду ImageMagick
if command -v magick &> /dev/null; then
    IMG_CMD="magick"
else
    IMG_CMD="convert"
fi

echo "   Используемая команда: $IMG_CMD"

# 1. Красный квадрат (исправленный синтаксис для Windows)
echo -n "   Создаю red-square.png... "
$IMG_CMD -size 300x300 xc:red \
    -fill white -draw "rectangle 50,50 250,250" \
    -fill blue -draw "circle 150,150 150,50" \
    "$TEST_DIR/red-square.png" 2>/dev/null && echo "✅" || echo "❌"

# 2. Градиент
echo -n "   Создаю gradient.png... "
$IMG_CMD -size 400x200 gradient:blue-red \
    -fill white -pointsize 30 -draw "text 30,100 'Gradient Test'" \
    "$TEST_DIR/gradient.png" 2>/dev/null && echo "✅" || echo "❌"

# 3. Простой текст
echo -n "   Создаю text-image.png... "
$IMG_CMD -size 500x150 xc:lightgray \
    -fill black -pointsize 40 -draw "text 50,80 'Image Converter Test'" \
    -fill darkblue -draw "line 50,90 450,90" \
    "$TEST_DIR/text-image.png" 2>/dev/null && echo "✅" || echo "❌"

echo ""
echo "📋 Проверяем созданные файлы:"
if ls "$TEST_DIR"/*.png 1> /dev/null 2>&1; then
    echo "✅ PNG файлы созданы успешно!"
    ls -la "$TEST_DIR"/*.png
else
    echo "❌ Не удалось создать PNG файлы. Попробуем альтернативный метод..."
    
    # Альтернативный метод - создаем через PowerShell
    echo "   Использую PowerShell для создания тестовых файлов..."
    powershell -Command "Add-Type -AssemblyName System.Drawing; "`
                "\$bmp = New-Object System.Drawing.Bitmap(100, 100); "`
                "\$g = [System.Drawing.Graphics]::FromImage(\$bmp); "`
                "\$g.Clear([System.Drawing.Color]::Red); "`
                "\$bmp.Save('$TEST_DIR/test1.png', [System.Drawing.Imaging.ImageFormat]::Png); "`
                "\$bmp.Dispose()" 2>/dev/null
    
    if [ -f "$TEST_DIR/test1.png" ]; then
        echo "   ✅ Создан test1.png через PowerShell"
    else
        echo "   ❌ Не удалось создать тестовые файлы"
        echo "   Вручную скопируйте PNG файлы в папку $TEST_DIR"
    fi
fi

echo ""
echo "🚀 Инструкция для тестирования:"
echo ""
echo "1. ОТКРОЙТЕ НОВОЕ ОКНО GIT BASH (важно!)"
echo ""
echo "2. В новом окне запустите мониторинг:"
echo "   cd $(pwd)"
echo "   ./image-watchdog.sh '$TEST_DIR'"
echo ""
echo "3. В ЭТОМ окне добавляйте PNG файлы:"
echo "   cp новые-файлы.png '$TEST_DIR/'"
echo ""
echo "4. Или используйте готовые тестовые файлы:"
echo "   ls '$TEST_DIR/'"
echo ""
echo "📊 Что произойдет:"
echo "   • Создастся папка '$TEST_DIR/converted/' с JPG, WEBP, AVIF"
echo "   • Папка '$TEST_DIR/processed/' с оригинальными PNG"
echo "   • Файл '$TEST_DIR/image-converter.log' с логами"
echo ""
echo "🛑 Для остановки мониторинга: нажмите Ctrl+C в том окне"

echo ""
echo "=========================================="
echo "📝 КРАТКАЯ ИНСТРУКЦИЯ ДЛЯ САМОГО ПРОСТОГО ТЕСТА:"
echo "=========================================="
echo "1. Найдите любой PNG файл на компьютере"
echo "2. Скопируйте его в папку: $(pwd)/test-images/"
echo "3. Запустите в новом окне: ./image-watchdog.sh ./test-images"
echo "4. Наблюдайте за конвертацией в реальном времени!"
echo "=========================================="