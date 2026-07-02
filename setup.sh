#!/bin/bash
# ============================================
# АВТОМАТИЧЕСКАЯ УСТАНОВКА WORDPRESS
# Версия скрипта: 3.0-BEGET-FIX
# ============================================

echo "🚀 Начинаю автоматическую установку WordPress..."
echo "============================================="

# ПРИНУДИТЕЛЬНО ИСПОЛЬЗУЕМ PHP 8.3 (ДЛЯ BEGET)
PHP_BIN=""
if [ -f "/usr/local/php/cgi/8.3" ]; then
    PHP_BIN="/usr/local/php/cgi/8.3"
    echo "✅ Использую PHP 8.3: $PHP_BIN"
elif [ -f "/usr/local/php/cgi/8.2" ]; then
    PHP_BIN="/usr/local/php/cgi/8.2"
    echo "✅ Использую PHP 8.2: $PHP_BIN"
elif [ -f "/usr/local/php/cgi/8.1" ]; then
    PHP_BIN="/usr/local/php/cgi/8.1"
    echo "✅ Использую PHP 8.1: $PHP_BIN"
elif [ -f "/usr/local/php/cgi/8.0" ]; then
    PHP_BIN="/usr/local/php/cgi/8.0"
    echo "✅ Использую PHP 8.0: $PHP_BIN"
elif [ -f "/usr/local/php/cgi/7.4" ]; then
    PHP_BIN="/usr/local/php/cgi/7.4"
    echo "✅ Использую PHP 7.4: $PHP_BIN"
else
    PHP_BIN="php"
    echo "⚠️ Использую системный PHP: $(php -v | head -1)"
fi

# ПРОВЕРКА ВЕРСИИ PHP
echo "🔍 Проверяю версию PHP..."
PHP_VERSION=$($PHP_BIN -v | head -1 | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "   Версия PHP: $PHP_VERSION"

if [ -z "$PHP_VERSION" ]; then
    echo "❌ ОШИБКА: PHP не найден!"
    exit 1
fi

# Сравниваем с минимальной версией (7.4)
MIN_VERSION="7.4"
if [ "$(printf '%s\n' "$MIN_VERSION" "$PHP_VERSION" | sort -V | head -n1)" != "$MIN_VERSION" ]; then
    echo "❌ ОШИБКА: Версия PHP $PHP_VERSION слишком старая!"
    echo "   Требуется PHP $MIN_VERSION или выше"
    exit 1
fi

echo "✅ Версия PHP подходит"
echo "============================================="

# ОЧИСТКА ПАПКИ
echo "🧹 Очищаю рабочую папку от старых файлов..."
find . -maxdepth 1 ! -name 'setup.sh' ! -name '.' ! -name '..' -exec rm -rf {} + 2>/dev/null || true
echo "✅ Папка очищена"

# 1. УСТАНОВКА WORDPRESS
echo "📦 Скачиваю и распаковываю WordPress..."
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz --strip-components=1
rm -f latest.tar.gz
echo "✅ WordPress установлен"

# 2. УСТАНОВКА ПЛАГИНОВ
echo "🔌 Устанавливаю плагины..."
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
    echo "   📥 Загружаю ${plugin}..."
    wget -q "https://downloads.wordpress.org/plugin/${plugin}.latest-stable.zip"
    unzip -q "${plugin}.latest-stable.zip"
    rm -f "${plugin}.latest-stable.zip"
done

echo "✅ Плагины установлены"

# 3. УСТАНОВКА ТЕМЫ
cd ../../
echo "🎨 Устанавливаю тему esalanding..."
cd wp-content/themes/

wget -q "https://github.com/Jamelich/esalanding/archive/refs/heads/main.zip" -O esalanding.zip
unzip -q esalanding.zip
rm -f esalanding.zip

if [ -d "esalanding-main" ]; then
    mv esalanding-main esalanding
fi
echo "✅ Тема esalanding установлена"

# 4. УСТАНОВКА CARBON FIELDS
echo "⚙️ Устанавливаю Carbon Fields в папку inc через composer..."

# Создаём папку inc
mkdir -p esalanding/inc

# Переходим в папку inc
cd esalanding/inc

# Удаляем старый vendor, если есть
rm -rf vendor composer.json composer.lock

# Проверяем наличие composer
if ! command -v composer &> /dev/null; then
    echo "❌ ОШИБКА: Composer не установлен!"
    exit 1
fi

# Устанавливаем carbon-fields через composer
echo "   📥 Устанавливаю htmlburger/carbon-fields (с PHP $PHP_VERSION)..."
composer require htmlburger/carbon-fields

# Проверяем результат
if [ -d "vendor" ] && [ -f "vendor/autoload.php" ]; then
    echo "✅ Carbon Fields установлен, папка vendor есть, autoload.php есть"
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
echo "📂 Carbon Fields установлен в:"
echo "   wp-content/themes/esalanding/inc/vendor/"
echo ""
echo "📂 Используется PHP: $PHP_VERSION"
echo ""
echo "============================================="
