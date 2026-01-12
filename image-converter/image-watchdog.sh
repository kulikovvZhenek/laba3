#!/bin/bash
# image-watchdog.sh - Конвертер PNG → JPG, WEBP, AVIF для Windows
# Использует ТОЛЬКО magick (не convert)

# ========== КОНФИГУРАЦИЯ ==========
CONFIG_FILE="image-converter.conf"

# Загрузка конфигурации
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        # Читаем настройки из файла
        source <(grep -E '^[A-Z_]+=' "$CONFIG_FILE" 2>/dev/null)
        echo "✅ Загружена конфигурация из $CONFIG_FILE"
    else
        # Значения по умолчанию
        CHECK_INTERVAL=3
        JPG_QUALITY=85
        WEBP_QUALITY=80
        AVIF_QUALITY=70
        WATCH_DIR="./images"
        LOG_LEVEL="INFO"
        echo "⚠️  Конфигурационный файл не найден, использую значения по умолчанию"
    fi
}

# Загружаем конфигурацию
load_config
# ===============================

# Проверка аргументов
if [ $# -eq 0 ]; then
    echo "❌ Ошибка: Не указана папка для отслеживания."
    echo ""
    echo "📌 Использование:"
    echo "   ./image-watchdog.sh /путь/к/папке"
    echo ""
    echo "📌 Пример:"
    echo "   ./image-watchdog.sh ./simple-test"
    exit 1
fi

WATCH_DIR="$1"

# Проверка существования папки
if [ ! -d "$WATCH_DIR" ]; then
    echo "❌ Ошибка: Папка '$WATCH_DIR' не существует."
    mkdir -p "$WATCH_DIR"
    echo "✅ Папка создана."
fi

# Проверка ImageMagick
echo "🔍 Проверка ImageMagick..."
if command -v magick &> /dev/null; then
    echo "   ✅ ImageMagick найден: magick"
    IMG_CMD="magick"
else
    echo "❌ ImageMagick не найден!"
    echo "   Установите: https://imagemagick.org"
    exit 1
fi

echo ""
echo "========================================"
echo "🖼️  IMAGE WATCHDOG для Windows"
echo "========================================"
echo "📁 Папка: $WATCH_DIR"
echo "⚙️  Команда: $IMG_CMD"
echo "⏱️  Интервал: $CHECK_INTERVAL сек"
echo "🎨 Качество: JPG=$JPG_QUALITY%, WebP=$WEBP_QUALITY%, AVIF=$AVIF_QUALITY%"
echo "========================================"

# Создаём подпапки
CONVERTED_DIR="$WATCH_DIR/converted"
PROCESSED_DIR="$WATCH_DIR/processed"
LOG_FILE="$WATCH_DIR/image-converter.log"

mkdir -p "$CONVERTED_DIR"
mkdir -p "$PROCESSED_DIR"

# Функция конвертации
convert_to_jpg() {
    local input="$1"
    local output="$2"
    
    magick "$input" -quality $JPG_QUALITY "$output" 2>/dev/null && return 0
    
    # Альтернативный синтаксис если первый не работает
    magick "$input" -quality $JPG_QUALITY "jpg:$output" 2>/dev/null && return 0
    
    return 1
}

convert_to_webp() {
    local input="$1"
    local output="$2"
    
    # Пробуем cwebp если есть
    if command -v cwebp &> /dev/null; then
        cwebp -quiet -q $WEBP_QUALITY "$input" -o "$output" 2>/dev/null && return 0
    fi
    
    # Через ImageMagick
    magick "$input" -quality $WEBP_QUALITY "webp:$output" 2>/dev/null && return 0
    
    return 1
}

convert_to_avif() {
    local input="$1"
    local output="$2"
    
    # Пробуем avifenc если есть
    if command -v avifenc &> /dev/null; then
        avifenc --min 0 --max 63 "$input" "$output" 2>/dev/null && return 0
    fi
    
    # Через ImageMagick
    magick "$input" -quality $AVIF_QUALITY "avif:$output" 2>/dev/null && return 0
    
    return 1
}

# Основная функция конвертации
convert_image() {
    local input_file="$1"
    local filename=$(basename "$input_file")
    local name_no_ext="${filename%.*}"
    local timestamp=$(date +"%H:%M:%S")
    
    echo "[$timestamp] 🔄 Конвертирую: $filename"
    
    # Логируем
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Начало: $filename" >> "$LOG_FILE"
    
    # Конвертируем в JPG
    if convert_to_jpg "$input_file" "$CONVERTED_DIR/${name_no_ext}.jpg"; then
        echo "   ✅ JPG создан"
        echo "   ✅ JPG создан" >> "$LOG_FILE"
        
        # Конвертируем в WebP
        if convert_to_webp "$input_file" "$CONVERTED_DIR/${name_no_ext}.webp"; then
            echo "   ✅ WebP создан"
        else
            echo "   ⚠️  WebP пропущен"
        fi
        
        # Конвертируем в AVIF
        if convert_to_avif "$input_file" "$CONVERTED_DIR/${name_no_ext}.avif"; then
            echo "   ✅ AVIF создан"
        else
            echo "   ⚠️  AVIF пропущен"
        fi
        
    else
        echo "   ❌ Ошибка JPG"
        echo "   Пробую альтернативный метод..."
        
        # Просто копируем файл
        cp "$input_file" "$CONVERTED_DIR/${name_no_ext}.jpg" 2>/dev/null
        echo "   ⚠️  Файл скопирован (без конвертации)"
    fi
    
    # Перемещаем оригинал
    mv "$input_file" "$PROCESSED_DIR/" 2>/dev/null
    echo "   📦 Оригинал перемещён"
    echo ""
}

echo ""
echo "🚀 Начинаю мониторинг..."
echo "🛑 Остановка: Ctrl+C"
echo ""

# Обрабатываем существующие файлы
echo "🔍 Проверяю существующие PNG файлы..."
for pattern in "*.png" "*.PNG"; do
    for file in "$WATCH_DIR"/$pattern; do
        [ -f "$file" ] && convert_image "$file"
    done
done

echo "✅ Начинаю мониторинг новых файлов..."
echo ""
# Выводим текущие настройки
echo "⚙️  Текущие настройки:"
echo "   Интервал: $CHECK_INTERVAL сек"
echo "   Качество: JPG=$JPG_QUALITY%, WebP=$WEBP_QUALITY%, AVIF=$AVIF_QUALITY%"
echo "   Папка: $WATCH_DIR"
echo "   Уровень логов: $LOG_LEVEL"
echo ""

# Основной цикл
while true; do
    # Ищем новые файлы
    for pattern in "*.png" "*.PNG"; do
        for file in "$WATCH_DIR"/$pattern; do
            [ -f "$file" ] && convert_image "$file"
        done
    done
    
    # Пауза
    sleep $CHECK_INTERVAL
done
