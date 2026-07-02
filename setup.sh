#!/bin/bash
# ============================================
# АВТОМАТИЧЕСКАЯ УСТАНОВКА WORDPRESS
# Версия скрипта: 3.1-COMPOSER-FIX
# ============================================

echo "🚀 Начинаю автоматическую установку WordPress..."
echo "============================================="

# ОЧИСТКА ПАПКИ
echo "🧹 Очищаю рабочую папку от старых файлов..."
find . -maxdepth 1 ! -name 'setup.sh' ! -name '.' ! -name '..' -exec rm -rf {} + 2>/dev/null || true
echo "✅ Папка очищена"

# 1. УСТАНОВКА WORDPRESS
echo "📦 Скачиваю и распаковываю WordPress (последняя версия)..."
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz --strip-components=1
rm -f latest.tar.gz
echo "✅ WordPress установлен"

# 2. УСТАНОВКА ПЛАГИНОВ
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

# 3. УСТАНОВКА ТЕМЫ
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

# 4. УСТАНОВКА CARBON FIELDS (ПРАВИЛЬНАЯ)
echo "⚙️ Устанавливаю Carbon Fields (последняя версия через composer)..."

# Создаём папку inc
mkdir -p esalanding/inc

# Переходим в папку inc
cd esalanding/inc

# Удаляем старый vendor, если есть
rm -rf vendor composer.json composer.lock

# ПРИНУДИТЕЛЬНО СОЗДАЁМ composer.json
cat > composer.json << 'EOF'
{
    "require": {
        "htmlburger/carbon-fields": "dev-master"
    }
}
EOF

# Проверяем, что файл создался
if [ ! -f "composer.json" ]; then
    echo "❌ Ошибка: composer.json не создан"
    exit 1
fi

echo "   ✅ composer.json создан"
echo "   Содержимое:"
cat composer.json

# Устанавливаем carbon-fields
echo "   📥 Устанавливаю htmlburger/carbon-fields..."
composer require htmlburger/carbon-fields:dev-master --no-interaction --no-scripts

# Проверяем результат
if [ -d "vendor" ] && [ -f "vendor/autoload.php" ]; then
    echo "✅ Carbon Fields установлен (последняя версия dev-master)"
else
    echo "❌ Ошибка: папка vendor или autoload.php не созданы"
    echo "   Содержимое папки $(pwd):"
    ls -la
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
echo "============================================="
