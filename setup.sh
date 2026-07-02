#!/bin/bash
# ============================================
# АВТОМАТИЧЕСКАЯ УСТАНОВКА WORDPRESS
# Версия скрипта: 3.0-LATEST
# ============================================

echo "🚀 Начинаю автоматическую установку WordPress..."
echo "============================================="

# ОЧИСТКА ПАПКИ
echo "🧹 Очищаю рабочую папку от старых файлов..."
find . -maxdepth 1 ! -name 'setup.sh' ! -name '.' ! -name '..' -exec rm -rf {} + 2>/dev/null || true
echo "✅ Папка очищена"

# 1. УСТАНОВКА WORDPRESS (ВСЕГДА СВЕЖАЯ ВЕРСИЯ)
echo "📦 Скачиваю и распаковываю WordPress (последняя версия)..."
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz --strip-components=1
rm -f latest.tar.gz
echo "✅ WordPress установлен"

# 2. УСТАНОВКА ПЛАГИНОВ (ВСЕГДА СВЕЖИЕ ВЕРСИИ)
echo "🔌 Устанавливаю плагины (последние версии)..."
cd wp-content/plugins/

PLUGINS=(
    "wordpress-seo"
    "contact-form-7"
    "classic-editor"
    "classic-widgets"
    "cyr2lat"
    "cookie-law-info"
    "yandex-metrica"
)

for plugin in "${PLUGINS[@]}"; do
    echo "   📥 Загружаю ${plugin} (последняя версия)..."
    wget -q "https://downloads.wordpress.org/plugin/${plugin}.latest-stable.zip"
    unzip -q "${plugin}.latest-stable.zip"
    rm -f "${plugin}.latest-stable.zip"
done

echo "✅ Плагины установлены"

# 3. УСТАНОВКА ТЕМЫ (СВЕЖАЯ С GITHUB)
cd ../../
echo "🎨 Устанавливаю тему esalanding (последняя версия с GitHub)..."
cd wp-content/themes/

wget -q "https://github.com/Jamelich/esalanding/archive/refs/heads/main.zip" -O esalanding.zip
unzip -q esalanding.zip
rm -f esalanding.zip

if [ -d "esalanding-main" ]; then
    mv esalanding-main esalanding
fi
echo "✅ Тема esalanding установлена"

# 4. УСТАНОВКА CARBON FIELDS (СВЕЖАЯ ВЕРСИЯ ЧЕРЕЗ COMPOSER)
echo "⚙️ Устанавливаю Carbon Fields (последняя версия через composer)..."

# Создаём папку inc
mkdir -p esalanding/inc

# Переходим в папку inc
cd esalanding/inc

# Удаляем старый vendor, если есть
rm -rf vendor composer.json composer.lock

# СОЗДАЁМ composer.json БЕЗ ОГРАНИЧЕНИЙ ПО ВЕРСИИ (всегда свежая)
echo '{
    "require": {
        "htmlburger/carbon-fields": "*"
    },
    "minimum-stability": "dev",
    "prefer-stable": true
}' > composer.json

# Устанавливаем carbon-fields (всегда свежая версия)
composer require htmlburger/carbon-fields:* --no-interaction

# Проверяем результат
if [ -d "vendor" ] && [ -f "vendor/autoload.php" ]; then
    echo "✅ Carbon Fields установлен (последняя версия)"
    echo "   Текущая версия:"
    composer show htmlburger/carbon-fields 2>/dev/null | grep versions || echo "   ✅ Установлено"
else
    echo "❌ Ошибка: папка vendor или autoload.php не созданы"
    exit 1
fi

# Возвращаемся в корень
cd ../../../

# 5. ФИНАЛЬНЫЙ ВЫВОД
echo ""
echo "============================================="
echo "✨ УСТАНОВКА ЗАВЕРШЕНА!"
echo "============================================="
echo ""
echo "📂 Все компоненты установлены в свежих версиях:"
echo "   ✅ WordPress - последняя стабильная"
echo "   ✅ Плагины - последние стабильные"
echo "   ✅ Тема esalanding - последняя с GitHub"
echo "   ✅ Carbon Fields - последняя версия"
echo ""
echo "📂 Carbon Fields установлен в:"
echo "   wp-content/themes/esalanding/inc/vendor/"
echo ""
echo "============================================="
