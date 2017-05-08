---
layout: post.html
title: PHP и UTF-8 (Unicode) - Неинтересная забава на полдня
datetime: 22 Dec 2006 12:48
tags: [ php, unicode, mysql ]
---

Это [не мой совет](http://live.julik.nl/2005/03/unicode-php) (я разместил объяву :) ), но уж очень неимоверно он мне помог.

Я хотел добиться того, чтобы мои страницы были в кодировке `UTF-8`, но и с базой бы все было нормально.

Всего-навсего сочетание этого совета и одной строки в `PHP` при коннекте к базе данных.

`MySQL` + `Apache` + `PHP` + `mb_string` :)

В мускуле, судя по `PHPMyAdmin`’у все было поставлено в `utf-8`. Тем не менее мне пришлось исправить в коннекте к базе строчку:

    mysql_select_db("****") and mysql_query("set names utf8") and
    mysql_query("SET collation_connection = 'utf8_general_ci'");

Затем я добавил в `.htaccess` всех `html`/`php` каталогов (почему и о чем это я - [в том самом совете](http://live.julik.nl/2005/03/unicode-php)) следующее:

``` apache

# unicode support
AddDefaultCharset utf-8
<IfModule mod_charset.c>
   CharsetDisable on
   CharsetRecodeMultipartForms Off
</IfModule>

php_value       mbstring.func_overload  7
php_value       default_charset         UTF-8
php_value       mbstring.language       Russian

php_value       mbstring.internal_encoding      UTF-8
php_flag        mbstring.encoding_translation   on
php_value       mbstring.http_input     "UTF-8,KOI8-R,CP1251"
php_value       mbstring.http_output    UTF-8
php_value       mbstring.detect_order   "UTF-8,KOI8-R,CP1251"
# end

```

И, конечно же, перекодировал все свои страницы и `php`-файлы в `UTF-8` (юзал [PSPad](http://www.pspad.com/)).

В `HTML`-ках на всякий случай указал вот это:

``` html

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>

```

И все заработало! (этот метод использовался и при сборке кода из предыдущего поста)
