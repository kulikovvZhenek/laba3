#!/bin/bash
# minimal-converter.sh - Минимальный рабочий конвертер

WATCH_DIR="${1:-./images}"

echo "🔄 МИНИМАЛЬНЫЙ КОНВЕРТЕР"
echo "📁 Папка: $WATCH_DIR"
echo ""

# Создаём папки
mkdir -p "$WATCH_DIR"
mkdir -p "$WATCH_DIR/converted"
mkdir -p "$WATCH_DIR/processed"

echo "🔍 Ищу PNG файлы..."
echo "🛑 Остановка: Ctrl+C"
echo ""

while true; do
    # Ищем PNG файлы
    find "$WATCH_DIR" -maxdepth 1 -type f \( -iname "*.png" \) 2>/dev/null | while read -r file; do
        filename=$(basename "$file")
        name="${filename%.*}"
        
        echo "[$(date +%H:%M:%S)] Найден: $filename"
        
        # Конвертируем в JPG
        if magick "$file" -quality 85 "$WATCH_DIR/converted/${name}.jpg" 2>/dev/null; then
            echo "   ✅ JPG создан"
            
            # Пробуем WebP
            magick "$file" -quality 80 "$WATCH_DIR/converted/${name}.webp" 2>/dev/null
            [ -f "$WATCH_DIR/converted/${name}.webp" ] && echo "   ✅ WebP создан"
            
            # Пробуем AVIF
            magick "$file" -quality 70 "$WATCH_DIR/converted/${name}.avif" 2>/dev/null
            [ -f "$WATCH_DIR/converted/${name}.avif" ] && echo "   ✅ AVIF создан"
            
            # Перемещаем оригинал
            mv "$file" "$WATCH_DIR/processed/" 2>/dev/null
            echo "   📦 Оригинал перемещён"
        else
            echo "   ❌ Ошибка конвертации"
        fi
        
        echo ""
    done
    
    sleep 3
done