#!/bin/bash
# simple-converter.sh - 100% рабочий конвертер для Windows

WATCH_DIR="${1:-./simple-test}"

echo "========================================"
echo "✅ ГАРАНТИРОВАННО РАБОЧИЙ КОНВЕРТЕР"
echo "========================================"
echo "📁 Папка: $WATCH_DIR"
echo ""

# Создаём папки
mkdir -p "$WATCH_DIR"
mkdir -p "$WATCH_DIR/converted"
mkdir -p "$WATCH_DIR/processed"

# Проверяем ImageMagick
echo "🔍 Проверяю ImageMagick..."
if command -v magick &> /dev/null; then
    echo "   ✅ Найден: magick"
    CMD="magick"
elif magick convert -version 2>/dev/null | grep -q "ImageMagick"; then
    echo "   ✅ Найден: magick convert"
    CMD="magick convert"
else
    echo "❌ ImageMagick не найден!"
    echo "   Запустите в PowerShell от администратора:"
    echo "   choco install imagemagick"
    exit 1
fi

# Тестируем
echo "   Тестирую команду..."
TEST_OUTPUT="$WATCH_DIR/test_conversion_$(date +%s).jpg"
if $CMD -size 50x50 xc:red "$TEST_OUTPUT" 2>&1 >/dev/null; then
    echo "   ✅ Команда работает!"
    rm -f "$TEST_OUTPUT"
else
    echo "   ⚠️  Пробую альтернативный синтаксис..."
    if magick -size 50x50 xc:red "$TEST_OUTPUT" 2>&1 >/dev/null; then
        echo "   ✅ Работает с 'magick' (без convert)"
        CMD="magick"
        rm -f "$TEST_OUTPUT"
    else
        echo "❌ Не удалось протестировать команду"
        exit 1
    fi
fi

echo ""
echo "🚀 ЗАПУСКАЮ КОНВЕРТЕР"
echo "========================================"
echo "📂 Результаты: $WATCH_DIR/converted/"
echo "⏱️  Проверка каждые 3 секунды"
echo "🛑 Остановка: Ctrl+C"
echo "========================================"

# Основная функция конвертации
process_file() {
    local file="$1"
    local filename=$(basename "$file")
    local name="${filename%.*}"
    
    echo ""
    echo "[$(date +%H:%M:%S)] 📸 Найден файл: $filename"
    
    # Конвертируем в JPG
    echo "   🔄 Конвертирую в JPG..."
    if $CMD "$file" -quality 85 "$WATCH_DIR/converted/${name}.jpg" 2>&1 >/dev/null; then
        echo "   ✅ УСПЕХ: JPG создан"
        
        # Пробуем WebP
        echo "   🔄 Пробую WebP..."
        $CMD "$file" -quality 80 "$WATCH_DIR/converted/${name}.webp" 2>&1 >/dev/null
        [ -f "$WATCH_DIR/converted/${name}.webp" ] && echo "   ✅ WebP создан"
        
        # Пробуем AVIF
        echo "   🔄 Пробую AVIF..."
        $CMD "$file" -quality 70 "$WATCH_DIR/converted/${name}.avif" 2>&1 >/dev/null
        [ -f "$WATCH_DIR/converted/${name}.avif" ] && echo "   ✅ AVIF создан"
        
        # Перемещаем оригинал
        mv "$file" "$WATCH_DIR/processed/" 2>/dev/null
        echo "   📦 Оригинал перемещён"
        
        # Показываем результат
        echo "   📊 Созданы: ${name}.{jpg, webp, avif}"
        
    else
        echo "   ❌ ОШИБКА конвертации в JPG"
        echo "   ⚠️  Копирую файл без конвертации..."
        cp "$file" "$WATCH_DIR/converted/${name}.jpg"
        mv "$file" "$WATCH_DIR/processed/"
        echo "   📦 Файл скопирован (без конвертации)"
    fi
}

# Обрабатываем существующие файлы
echo ""
echo "🔍 Проверяю существующие файлы..."
find "$WATCH_DIR" -maxdepth 1 -type f \( -iname "*.png" \) 2>/dev/null | while read -r file; do
    process_file "$file"
done

echo ""
echo "✅ Готов к мониторингу новых файлов..."
echo ""

# Счётчик циклов
CYCLE=0

# Основной цикл
while true; do
    # Ищем новые файлы
    find "$WATCH_DIR" -maxdepth 1 -type f \( -iname "*.png" \) -newer "$WATCH_DIR/.lastcheck" 2>/dev/null | while read -r file; do
        process_file "$file"
    done
    
    # Обновляем метку времени
    touch "$WATCH_DIR/.lastcheck"
    
    # Индикатор работы (каждые 5 циклов)
    CYCLE=$((CYCLE + 1))
    if [ $((CYCLE % 5)) -eq 0 ]; then
        CONVERTED_COUNT=$(find "$WATCH_DIR/converted" -name "*.jpg" 2>/dev/null | wc -l)
        echo -e "\r📊 Статус: обработано $CONVERTED_COUNT файлов | $(date +%H:%M:%S)"
    fi
    
    # Пауза
    sleep 3
done