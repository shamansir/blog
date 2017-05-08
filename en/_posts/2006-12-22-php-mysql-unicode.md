---
layout: post.html
title: PHP and UTF-8 (Unicode) - A funny thing for a half of a day
datetime: 22 Dec 2006 12:48
tags: [ php, unicode, mysql ]
---

It is [not the advice of mine](http://live.julik.nl/2005/03/unicode-php), but it helped me enormously.

I've to accomplish the state when all of my pages are in `UTF-8` encoding, but the DB is also OK.

That's what helped me - combining this advice with one line in `PHP` code while connecting to the DB

`MySQL` + `Apache` + `PHP` + `mb_string` :)

In mysql, following to `PHPMyAdmin` everything was set to `utf-8`. But I had to correct this line in database connection line:

``` php

mysql_select_db("****") and mysql_query("set names utf8") and
mysql_query("SET collation_connection = 'utf8_general_ci'");

```

Then I've added inside all `.htaccess` files of all `html`/`php` folders (why I am doing these strange things - [in that advise](http://live.julik.nl/2005/03/unicode-php)) the next lines:

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

And, of course, I've re-encoded all my pages and `php`-files in `UTF-8` (used [PSPad](http://www.pspad.com/)).

And in `HTML`-pages I've added this, just be on the safe side:

``` html

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>

```

And everything started to work great and in `UTF-8`! (this method was used in next post)
