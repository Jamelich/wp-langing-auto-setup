# WordPress Auto-Setup Script

**Версия скрипта:** 2.3-ALL-PLUGINS  
**Репозиторий:** https://github.com/Jamelich/wp-langing-auto-setup

Автоматический скрипт для быстрого развёртывания чистого WordPress, установки необходимых плагинов и темы прямо на хостинг.

## Что делает этот скрипт

Одной командой подготавливает полностью рабочую среду для нового сайта на WordPress:

1.  **Устанавливает свежий WordPress** — скачивает и распаковывает последнюю стабильную версию с wordpress.org.
2.  **Устанавливает набор плагинов** — предустановленный список часто используемых плагинов.
3.  **Устанавливает Carbon Fields** — загружает популярный фреймворк полей напрямую с GitHub.
4.  **Устанавливает шаблонную тему** — загружает вашу тему esalanding через архив (без необходимости в Git).

## Быстрый старт

**Внимание!** Скрипт полностью очищает текущую папку перед установкой. Запускайте в пустой или предназначенной для этого папке.

Чтобы установить WordPress с плагинами и темой, выполните команду в терминале (например, в WinSCP):

```
rm -f setup.sh && wget -q https://raw.githubusercontent.com/Jamelich/wp-langing-auto-setup/main/setup.sh?$(date +%s) -O setup.sh && bash setup.sh
```

## Установленные плагины

Из официального репозитория WordPress:
- Yoast SEO (wordpress-seo)
- Contact Form 7 (contact-form-7)
- Classic Editor (classic-editor)
- Classic Widgets (classic-widgets)
- Cyr-To-Lat (cyr2lat)
- Favicon by RealFaviconGenerator (favicon-by-realfavicongenerator)
- Яндекс Метрика (yandex-metrica)

С GitHub:
- Carbon Fields — фреймворк кастомных полей

## Настройка под свои нужды

Чтобы изменить список плагинов, отредактируйте массив PLUGINS в файле setup.sh:

```
PLUGINS=(
    "wordpress-seo"
    "contact-form-7"
    "classic-editor"
    "classic-widgets"
    "cyr2lat"
    "favicon-by-realfavicongenerator"
    "yandex-metrica"
    # Добавьте или удалите слаги плагинов здесь
)
```

---

**Одна команда — готовый сайт с вашим набором инструментов!**
