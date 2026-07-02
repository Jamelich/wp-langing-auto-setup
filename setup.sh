#!/bin/bash
# ============================================
# АВТОМАТИЧЕСКАЯ УСТАНОВКА WORDPRESS
# Версия скрипта: 3.0-FINAL
# ============================================

set -e

echo "🚀 Начинаю автоматическую установку WordPress..."
echo "============================================="
echo "Текущая директория: $(pwd)"
echo ""

# 1. ОЧИСТКА ПАПКИ
echo "🧹 Очищаю рабочую папку от старых файлов..."
find . -maxdepth 1 ! -name 'setup.sh' ! -name '.' ! -name '..' -exec rm -rf {} + 2>/dev/null || true
echo "✅ Папка очищена"
echo ""

# 2. УСТАНОВКА WORDPRESS
echo "📦 Скачиваю и распаковываю WordPress..."
wget -q --timeout=30 https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz --strip-components=1
rm -f latest.tar.gz
echo "✅ WordPress установлен"
echo ""

# 3. УСТАНОВКА ПЛАГИНОВ
echo "🔌 Устанавливаю плагины..."
cd wp-content/plugins/ || exit 1

PLUGINS=(
    "wordpress-seo"
    "contact-form-7"
    "classic-editor"
    "classic-widgets"
    "cyr2lat"
    "cookie-law-info"
)

for plugin in "${PLUGINS[@]}"; do
    echo "   📥 Загружаю ${plugin}..."
    wget -q --timeout=30 "https://downloads.wordpress.org/plugin/${plugin}.latest-stable.zip"
    if [ -f "${plugin}.latest-stable.zip" ]; then
        unzip -q "${plugin}.latest-stable.zip"
        rm -f "${plugin}.latest-stable.zip"
        echo "   ✅ ${plugin} установлен"
    else
        echo "   ⚠️ Не удалось скачать ${plugin}"
    fi
done

echo "✅ Плагины установлены"
echo ""

# 4. УСТАНОВКА ТЕМЫ
echo "🎨 Устанавливаю тему esalanding..."
cd ../themes/ || exit 1

rm -rf esalanding esalanding-main
wget -q --timeout=30 "https://github.com/Jamelich/esalanding/archive/refs/heads/main.zip" -O esalanding.zip

if [ ! -f "esalanding.zip" ]; then
    echo "❌ Не удалось скачать тему"
    exit 1
fi

unzip -q esalanding.zip
rm -f esalanding.zip

if [ -d "esalanding-main" ]; then
    mv esalanding-main esalanding
fi
echo "✅ Тема esalanding установлена"
echo ""

# 5. УСТАНОВКА CARBON FIELDS
echo "⚙️ Устанавливаю Carbon Fields..."

if [ ! -d "esalanding" ]; then
    echo "❌ Папка темы не найдена"
    exit 1
fi

mkdir -p esalanding/inc
cd esalanding/inc || exit 1

rm -rf vendor composer.json composer.lock

# Проверяем composer
if ! command -v composer &> /dev/null; then
    echo "   ⚠️ Composer не установлен, устанавливаю..."
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --quiet
    php -r "unlink('composer-setup.php');"
    COMPOSER_CMD="php composer.phar"
else
    COMPOSER_CMD="composer"
fi

echo "   📥 Устанавливаю htmlburger/carbon-fields..."
$COMPOSER_CMD require htmlburger/carbon-fields --no-dev --no-interaction --no-scripts --prefer-dist

if [ -d "vendor" ] && [ -f "vendor/autoload.php" ]; then
    echo "   ✅ Carbon Fields установлен"
    chmod -R 755 vendor/
else
    echo "   ❌ Ошибка установки Carbon Fields"
    exit 1
fi

# Создаём файл подключения
cat > carbon-fields.php << 'EOF'
<?php
if (!defined('ABSPATH')) {
    exit;
}

$autoloader = __DIR__ . '/vendor/autoload.php';

if (file_exists($autoloader)) {
    require_once $autoloader;
    add_action('after_setup_theme', function() {
        \Carbon_Fields\Carbon_Fields::boot();
    });
}
EOF

echo "   ✅ Файл carbon-fields.php создан"
echo ""

# 6. НАСТРОЙКА ПРАВ
echo "🔐 Настраиваю права доступа..."
cd ../../../ || exit 1
find . -type d -exec chmod 755 {} \; 2>/dev/null
find . -type f -exec chmod 644 {} \; 2>/dev/null
echo "✅ Права настроены"
echo ""

# 7. ФИНАЛЬНЫЙ ВЫВОД
echo "============================================="
echo "✨ УСТАНОВКА ЗАВЕРШЕНА!"
echo "============================================="
echo ""
echo "📂 WordPress установлен в: $(pwd)"
echo "📂 Тема: wp-content/themes/esalanding/"
echo "📂 Carbon Fields: wp-content/themes/esalanding/inc/vendor/"
echo ""
echo "📝 Для подключения Carbon Fields добавьте в functions.php:"
echo "   require_once get_template_directory() . '/inc/carbon-fields.php';"
echo ""
echo "============================================="
