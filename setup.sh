#!/bin/bash
# ============================================
# АВТОМАТИЧЕСКАЯ УСТАНОВКА WORDPRESS
# Версия скрипта: 2.3-ALL-PLUGINS
# Репозиторий: https://github.com/Jamelich/wp-langing-auto-setup
# ============================================

echo "🚀 Начинаю автоматическую установку WordPress..."
echo "============================================="

# КРИТИЧЕСКИЙ БЛОК: Полная очистка папки (кроме самого скрипта)
echo "🧹 Очищаю рабочую папку от старых файлов..."
find . -maxdepth 1 ! -name 'setup.sh' ! -name '.' ! -name '..' -exec rm -rf {} + 2>/dev/null || true
echo "✅ Папка очищена"

# 1. УСТАНОВКА WORDPRESS
echo "📦 Скачиваю и распаковываю WordPress..."
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz --strip-components=1
rm -f latest.tar.gz
echo "✅ WordPress установлен"

# 2. УСТАНОВКА ВСЕХ ПЛАГИНОВ
echo "🔌 Устанавливаю плагины..."
cd wp-content/plugins/
echo "   📂 Рабочая папка: $(pwd)"

# ПОЛНЫЙ СПИСОК ВСЕХ ПЛАГИНОВ (старые + новые)
PLUGINS=(
    "wordpress-seo"                   # Yoast SEO (ВЕРНУЛ!)
    "contact-form-7"                  # Contact Form 7 (ВЕРНУЛ!)
    "classic-editor"                  # Classic Editor
    "classic-widgets"                 # Classic Widgets
    "cyr2lat"                         # Cyr-To-Lat
    "cookie-law-info" # cookie-law-info
    "yandex-metrica"                  # Яндекс Метрика
)
ERRORS=0

for plugin in "${PLUGINS[@]}"; do
    echo "   📥 Загружаю ${plugin}..."
    if wget -q "https://downloads.wordpress.org/plugin/${plugin}.latest-stable.zip"; then
        echo "   ✅ Успешно"
    else
        echo "   ❌ Ошибка загрузки"
        ERRORS=$((ERRORS+1))
    fi
done

ZIP_FILES=$(ls *.zip 2>/dev/null | wc -l)
if [ "$ZIP_FILES" -gt 0 ]; then
    echo "   📦 Распаковываю архивы ($ZIP_FILES файл(ов))..."
    unzip -q "*.zip"
    rm -f *.zip
    echo "✅ Основные плагины установлены"
else
    echo "⚠️  ВНИМАНИЕ: Не найдено архивов для распаковки"
fi

# 3. УСТАНОВКА CARBON FIELDS С GITHUB
echo "⚙️  Устанавливаю Carbon Fields (с GitHub)..."
if wget -q "https://github.com/htmlburger/carbon-fields/archive/refs/heads/master.zip" -O carbon-fields.zip; then
    unzip -q carbon-fields.zip
    mv carbon-fields-master carbon-fields
    rm -f carbon-fields.zip
    echo "✅ Carbon Fields установлен"
else
    echo "⚠️  Не удалось скачать Carbon Fields"
fi

if [ "$ERRORS" -gt 0 ]; then
    echo "⚠️  Некоторые плагины не были загружены ($ERRORS ошибок)"
fi

# 4. УСТАНОВКА ТЕМЫ (через архив, а не git)
echo "🎨 Устанавливаю тему esalanding (через архив GitHub)..."
cd ../../
if [ ! -d "wp-content/themes" ]; then
    mkdir -p wp-content/themes
fi
cd wp-content/themes/
if wget -q "https://github.com/Jamelich/esalanding/archive/refs/heads/main.zip" -O esalanding.zip; then
    unzip -q esalanding.zip
    mv esalanding-main esalanding
    rm -f esalanding.zip
    echo "✅ Тема esalanding установлена"
else
    echo "❌ ФАТАЛЬНАЯ ОШИБКА: Не удалось скачать тему!"
    exit 1
fi

# 5. ФИНАЛЬНАЯ ПРОВЕРКА
echo ""
echo "============================================="
echo "✨ УСТАНОВКА ЗАВЕРШЕНА!"
echo "============================================="
cd ../../
echo "Установленные плагины:"
ls -1 wp-content/plugins/
echo ""
echo "Установленные темы:"
ls -1 wp-content/themes/
echo ""
echo "Следующие шаги:"
echo "1. 📂 Создайте базу данных MySQL"
echo "2. 🌐 Перейдите по адресу сайта"
echo "3. 🔧 Завершите установку WordPress"
echo "4. ⚙️  Активируйте плагины и тему 'esalanding'"
echo ""
echo "Скрипт v2.3-ALL-PLUGINS | Разработан для Jamelich"
echo "============================================="
