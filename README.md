# WordPress Auto-Setup Script

Скрипт для автоматической установки чистого WordPress, базовых плагинов и темы esalanding.

## Что делает скрипт
1.  Устанавливает свежий WordPress
2.  Устанавливает плагины:
    *   Yoast SEO
    *   Contact Form 7
3.  Клонирует тему [esalanding](https://github.com/Jamelich/esalanding)

## Использование
Выполните в терминале на вашем хостинге (в папке будущего сайта):

```bash
wget -q https://raw.githubusercontent.com/Jamelich/wp-landing-auto-setup/main/setup.sh && bash setup.sh
