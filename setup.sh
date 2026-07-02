#!/bin/bash
# ============================================
# АВТОМАТИЧЕСКАЯ УСТАНОВКА WORDPRESS
# Версия скрипта: 2.8-PHP-CHECK
# ============================================

echo "🚀 Начинаю автоматическую установку WordPress..."
echo "============================================="

# ПРОВЕРКА ВЕРСИИ PHP
echo "🔍 Проверяю версию PHP..."
PHP_VERSION=$(php -v | head -1 | cut -d' ' -f2 | cut -d'.' -f1,2)

if [ -z "$PHP_VERSION" ]; then
    echo "❌ ОШИБКА: PHP не найден!"
    exit 1
fi

echo "   Версия PHP: $PHP_VERSION"

# Сравниваем с минимальной версией (7.4)
MIN_VERSION="7.4"
if [ "$(printf '%s\n' "$MIN_VERSION" "$PHP_VERSION" | sort -V | head -n1)" != "$MIN_VERSION" ]; then
    echo "❌ ОШИБКА: Версия PHP $PHP_VERSION слишком старая!"
    echo "   Требуется PHP $MIN_VERSION или выше"
    echo "   Установите PHP 7.4+ в панели хостинга"
    exit 1
fi

# Дополнительная проверка на слишком новую версию (максимум 8.3)
MAX_VERSION="8.3"
if [ "$(printf '%s\n' "$MAX_VERSION" "$PHP_VERSION" | sort -V | head -n1)" != "$PHP_VERSION" ]; then
    echo "⚠️ ПРЕДУПРЕЖДЕНИЕ: Версия PHP $PHP_VERSION очень новая"
    echo "   Рекомендуется PHP 8.2 или 8.3"
    echo "   Если возникнут ошибки, понизьте версию PHP"
    echo ""
    read -p "   Продолжить установку? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "✅ Версия PHP подходит для установки"
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
    echo "   Установите Composer: https://getcomposer.org/"
    exit 1
fi

# Устанавливаем carbon-fields через composer
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
echo "📂 Структура:"
echo "   esalanding/inc/"
echo "   ├── vendor/"
echo "   │   ├── autoload.php"
echo "   │   └── htmlburger/carbon-fields"
echo "   ├── composer.json"
echo "   └── composer.lock"
echo ""
echo "============================================="
