#!/bin/bash
# ============================================
# АВТОМАТИЧЕСКАЯ УСТАНОВКА WORDPRESS
# Версия скрипта: 2.8-CRB-COMPOSER-FIX
# ============================================

set -e  # Остановка при любой ошибке

echo "🚀 Начинаю автоматическую установку WordPress..."
echo "============================================="

# Получаем путь к текущей директории
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📁 Рабочая директория: $SCRIPT_DIR"

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
cd wp-content/plugins/ || exit 1

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
    if [ -f "${plugin}.latest-stable.zip" ]; then
        unzip -q "${plugin}.latest-stable.zip"
        rm -f "${plugin}.latest-stable.zip"
        echo "   ✅ ${plugin} установлен"
    else
        echo "   ⚠️ Не удалось скачать ${plugin}"
    fi
done

echo "✅ Плагины установлены"

# 3. УСТАНОВКА ТЕМЫ
echo "🎨 Устанавливаю тему esalanding..."
cd ../themes/ || exit 1

# Удаляем старую тему, если есть
rm -rf esalanding esalanding-main

wget -q "https://github.com/Jamelich/esalanding/archive/refs/heads/main.zip" -O esalanding.zip
if [ -f "esalanding.zip" ]; then
    unzip -q esalanding.zip
    rm -f esalanding.zip
    
    if [ -d "esalanding-main" ]; then
        mv esalanding-main esalanding
    fi
    echo "✅ Тема esalanding установлена"
else
    echo "❌ Ошибка: не удалось скачать тему"
    exit 1
fi

# 4. УСТАНОВКА CARBON FIELDS ЧЕРЕЗ COMPOSER В ПАПКУ inc
echo "⚙️ Устанавливаю Carbon Fields в папку inc через composer..."

# Проверяем наличие темы
if [ ! -d "esalanding" ]; then
    echo "❌ Ошибка: папка темы esalanding не найдена"
    exit 1
fi

# Создаём папку inc
mkdir -p esalanding/inc

# Переходим в папку inc
cd esalanding/inc || exit 1

# Удаляем старый vendor, если есть
rm -rf vendor composer.json composer.lock

# Проверяем наличие composer
if ! command -v composer &> /dev/null; then
    echo "❌ Composer не установлен! Устанавливаю..."
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
fi

# Устанавливаем carbon-fields через composer с правильными правами
echo "   📥 Устанавливаю htmlburger/carbon-fields..."
composer require htmlburger/carbon-fields --no-dev --no-interaction --no-scripts

# Проверяем результат
if [ -d "vendor" ] && [ -f "vendor/autoload.php" ]; then
    echo "✅ Carbon Fields установлен успешно"
    echo "   📂 Путь: $(pwd)/vendor/"
else
    echo "❌ Ошибка: папка vendor или autoload.php не созданы"
    echo "   🔍 Содержимое папки:"
    ls -la
    exit 1
fi

# Устанавливаем правильные права
chmod -R 755 vendor/

# Создаём файл для подключения Carbon Fields
echo "📝 Создаю файл подключения carbon-fields.php..."
cat > carbon-fields.php << 'EOF'
<?php
/**
 * Подключение Carbon Fields
 * 
 * @package esalanding
 */

// Проверяем, что файл вызывается из WordPress
if (!defined('ABSPATH')) {
    exit;
}

// Путь к автозагрузчику
$autoloader = __DIR__ . '/vendor/autoload.php';

if (file_exists($autoloader)) {
    require_once $autoloader;
    
    // Инициализация Carbon Fields
    add_action('after_setup_theme', function() {
        \Carbon_Fields\Carbon_Fields::boot();
    });
    
    // Загрузка полей
    add_action('carbon_fields_register_fields', function() {
        // Здесь будут регистрироваться поля
        // require_once get_template_directory() . '/inc/fields.php';
    });
    
    echo "✅ Carbon Fields подключен\n";
} else {
    echo "⚠️ Автозагрузчик не найден: $autoloader\n";
}
EOF

echo "✅ Файл carbon-fields.php создан"

# Возвращаемся в корень
cd "$SCRIPT_DIR" || exit 1

# 5. ФИНАЛЬНЫЙ ВЫВОД
echo ""
echo "============================================="
echo "✨ УСТАНОВКА ЗАВЕРШЕНА!"
echo "============================================="
echo ""
echo "📂 Carbon Fields установлен в:"
echo "   wp-content/themes/esalanding/inc/vendor/"
echo ""
echo "📂 Структура:"
echo "   esalanding/inc/"
echo "   ├── vendor/"
echo "   │   ├── autoload.php"
echo "   │   └── htmlburger/carbon-fields/"
echo "   ├── composer.json"
echo "   ├── composer.lock"
echo "   └── carbon-fields.php ← файл подключения"
echo ""
echo "📝 Для использования Carbon Fields в теме:"
echo "   1. Добавьте в functions.php:"
echo "      require_once get_template_directory() . '/inc/carbon-fields.php';"
echo ""
echo "   2. Создайте файл inc/fields.php для регистрации полей"
echo ""
echo "============================================="
