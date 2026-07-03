#!/bin/bash
# ============================================
# АВТОМАТИЧЕСКАЯ УСТАНОВКА WORDPRESS
# Версия скрипта: 3.1-ALL-IN-ONE
# ============================================

echo "🚀 Начинаю автоматическую установку WordPress..."
echo "============================================="

# ПРОВЕРКА PHP
PHP_BIN=""
if [ -f "/usr/local/php/cgi/8.3/bin/php" ]; then
    PHP_BIN="/usr/local/php/cgi/8.3/bin/php"
    echo "✅ Использую PHP 8.3"
elif [ -f "/usr/local/php/cgi/8.2/bin/php" ]; then
    PHP_BIN="/usr/local/php/cgi/8.2/bin/php"
    echo "✅ Использую PHP 8.2"
elif [ -f "/usr/local/php/cgi/8.1/bin/php" ]; then
    PHP_BIN="/usr/local/php/cgi/8.1/bin/php"
    echo "✅ Использую PHP 8.1"
else
    PHP_BIN="php"
    echo "⚠️ Использую системный PHP"
fi

# ПРОВЕРКА ВЕРСИИ
PHP_VERSION=$($PHP_BIN -v | head -1 | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "   Версия PHP: $PHP_VERSION"

if [ "$(printf '%s\n' "7.4" "$PHP_VERSION" | sort -V | head -n1)" != "7.4" ]; then
    echo "❌ ОШИБКА: Нужен PHP 7.4+"
    exit 1
fi

echo "============================================="

# ОЧИСТКА
echo "🧹 Очищаю папку..."
find . -maxdepth 1 ! -name 'setup.sh' ! -name '.' ! -name '..' -exec rm -rf {} + 2>/dev/null || true

# 1. WORDPRESS
echo "📦 Устанавливаю WordPress..."
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz --strip-components=1
rm -f latest.tar.gz

# 2. ПЛАГИНЫ
echo "🔌 Устанавливаю плагины..."
cd wp-content/plugins/ || exit 1
PLUGINS=("wordpress-seo" "contact-form-7" "classic-editor" "classic-widgets" "cyr2lat" "cookie-law-info" "wp-yandex-metrika")
for plugin in "${PLUGINS[@]}"; do
    echo "   📥 $plugin..."
    wget -q "https://downloads.wordpress.org/plugin/${plugin}.latest-stable.zip"
    unzip -q "${plugin}.latest-stable.zip"
    rm -f "${plugin}.latest-stable.zip"
done

# 3. ТЕМА
cd ../../
echo "🎨 Устанавливаю тему..."
cd wp-content/themes/ || exit 1
wget -q "https://github.com/Jamelich/esalanding/archive/refs/heads/main.zip" -O esalanding.zip
unzip -q esalanding.zip
rm -f esalanding.zip
[ -d "esalanding-main" ] && mv esalanding-main esalanding

# 4. CARBON FIELDS (С ЛОКАЛЬНЫМ COMPOSER)
echo "⚙️ Устанавливаю Carbon Fields..."
mkdir -p esalanding/inc
cd esalanding/inc || exit 1
rm -rf vendor composer.json composer.lock composer.phar

# Скачиваем и ставим Composer локально
echo "   📥 Устанавливаю Composer локально..."
$PHP_BIN -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
$PHP_BIN composer-setup.php --quiet
$PHP_BIN -r "unlink('composer-setup.php');"

# Ставим Carbon Fields через локальный Composer
echo "   📥 Устанавливаю Carbon Fields..."
$PHP_BIN composer.phar require htmlburger/carbon-fields --no-interaction --quiet

# Проверяем
if [ -d "vendor" ] && [ -f "vendor/autoload.php" ]; then
    echo "   ✅ Carbon Fields установлен"
else
    echo "   ❌ Ошибка установки Carbon Fields"
    exit 1
fi

cd ../../../

# 5. ГОТОВО
echo ""
echo "============================================="
echo "✨ УСТАНОВКА ЗАВЕРШЕНА!"
echo "============================================="
echo "📂 Carbon Fields: wp-content/themes/esalanding/inc/vendor/"
echo "============================================="
