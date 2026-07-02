#!/bin/bash
# ============================================
# АВТОМАТИЧЕСКАЯ УСТАНОВКА WORDPRESS
# Версия скрипта: 2.7-CRB-COMPOSER-DIAG
# ============================================

# ДИАГНОСТИКА - включаем вывод всех ошибок
set -x
exec 2>&1

echo "🚀 Начинаю автоматическую установку WordPress..."
echo "============================================="
echo "Текущая директория: $(pwd)"
echo "Пользователь: $(whoami)"
echo "Дата: $(date)"
echo "============================================="

# ОЧИСТКА ПАПКИ
echo "🧹 Очищаю рабочую папку от старых файлов..."
find . -maxdepth 1 ! -name 'setup.sh' ! -name '.' ! -name '..' -exec rm -rf {} + 2>/dev/null || true
echo "✅ Папка очищена"

# 1. УСТАНОВКА WORDPRESS
echo "📦 Скачиваю и распаковываю WordPress..."
wget -q https://wordpress.org/latest.tar.gz
if [ $? -ne 0 ]; then
    echo "❌ ОШИБКА: Не удалось скачать WordPress"
    exit 1
fi
tar -xzf latest.tar.gz --strip-components=1
if [ $? -ne 0 ]; then
    echo "❌ ОШИБКА: Не удалось распаковать WordPress"
    exit 1
fi
rm -f latest.tar.gz
echo "✅ WordPress установлен"

# 2. УСТАНОВКА ПЛАГИНОВ
echo "🔌 Устанавливаю плагины..."
cd wp-content/plugins/
if [ $? -ne 0 ]; then
    echo "❌ ОШИБКА: Не могу перейти в папку wp-content/plugins/"
    exit 1
fi
echo "   Текущая директория: $(pwd)"

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
cd ../../
echo "🎨 Устанавливаю тему esalanding..."
cd wp-content/themes/
if [ $? -ne 0 ]; then
    echo "❌ ОШИБКА: Не могу перейти в папку wp-content/themes/"
    exit 1
fi
echo "   Текущая директория: $(pwd)"

wget -q "https://github.com/Jamelich/esalanding/archive/refs/heads/main.zip" -O esalanding.zip
if [ $? -ne 0 ] || [ ! -f "esalanding.zip" ]; then
    echo "❌ ОШИБКА: Не удалось скачать тему"
    exit 1
fi
unzip -q esalanding.zip
rm -f esalanding.zip

if [ -d "esalanding-main" ]; then
    mv esalanding-main esalanding
fi
echo "✅ Тема esalanding установлена"

# 4. УСТАНОВКА CARBON FIELDS ЧЕРЕЗ COMPOSER В ПАПКУ inc
echo "⚙️ Устанавливаю Carbon Fields в папку inc через composer..."

# Создаём папку inc
mkdir -p esalanding/inc
if [ $? -ne 0 ]; then
    echo "❌ ОШИБКА: Не могу создать папку esalanding/inc"
    exit 1
fi

# Переходим в папку inc
cd esalanding/inc
if [ $? -ne 0 ]; then
    echo "❌ ОШИБКА: Не могу перейти в папку esalanding/inc"
    exit 1
fi
echo "   Текущая директория: $(pwd)"

# Удаляем старый vendor, если есть
rm -rf vendor composer.json composer.lock

# Проверяем наличие composer
echo "   Проверяю наличие composer..."
which composer
composer --version
if [ $? -ne 0 ]; then
    echo "❌ ОШИБКА: Composer не установлен!"
    echo "   Попробуйте установить: apt-get install composer"
    exit 1
fi

# Устанавливаем carbon-fields через composer
echo "   Запускаю: composer require htmlburger/carbon-fields"
composer require htmlburger/carbon-fields

# Проверяем результат
if [ -d "vendor" ] && [ -f "vendor/autoload.php" ]; then
    echo "✅ Carbon Fields установлен, папка vendor есть, autoload.php есть"
    echo "   Содержимое vendor:"
    ls -la vendor/
else
    echo "❌ ОШИБКА: папка vendor или autoload.php не созданы"
    echo "   Содержимое папки $(pwd):"
    ls -la
    exit 1
fi

# Возвращаемся в корень
cd ../../../
if [ $? -ne 0 ]; then
    echo "❌ ОШИБКА: Не могу вернуться в корневую папку"
    exit 1
fi

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

# Отключаем диагностику
set +x
