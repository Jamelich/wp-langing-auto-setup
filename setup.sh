#!/bin/bash
# ============================================
# АВТОМАТИЧЕСКАЯ УСТАНОВКА WORDPRESS
# Версия скрипта: 2.5-CRB-ONLY-DOWNLOAD
# ============================================

echo "🚀 Начинаю автоматическую установку WordPress..."
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

# 4. СКАЧИВАНИЕ CARBON FIELDS В ПАПКУ inc (ПРОСТО СКАЧАТЬ, БЕЗ КОМПОЗЕРА)
echo "⚙️ Скачиваю Carbon Fields в папку inc темы..."

# Создаём папку inc
mkdir -p esalanding/inc

# Переходим в папку inc
cd esalanding/inc

# Просто скачиваем архив и распаковываем
wget -q "https://github.com/htmlburger/carbon-fields/archive/refs/heads/master.zip" -O carbon-fields.zip
unzip -q carbon-fields.zip

# Перемещаем содержимое из carbon-fields-master в текущую папку
if [ -d "carbon-fields-master" ]; then
    mv carbon-fields-master/* ./
    rm -rf carbon-fields-master
fi

# Удаляем архив
rm -f carbon-fields.zip

echo "✅ Carbon Fields скачан в wp-content/themes/esalanding/inc/"

# Возвращаемся в корень
cd ../../../

# 5. ФИНАЛЬНЫЙ ВЫВОД
echo ""
echo "============================================="
echo "✨ УСТАНОВКА ЗАВЕРШЕНА!"
echo "============================================="
echo ""
echo "📂 Carbon Fields лежит тут:"
echo "   wp-content/themes/esalanding/inc/"
echo ""
echo "📌 Дальше сами: подключайте в functions.php через vendor/autoload.php"
echo ""
echo "============================================="
