---
layout: post.html
title: "Sandwitch: Тема для Tumblr"
datetime: 2 Dec 2010 19:31
tags: [ tumblr ]
---

Сделал [тему для Tumblr](http://www.tumblr.com/theme/18012) под названием [Sandwitch](http://uncyclopedia.wikia.com/wiki/Sandwitch). Хотел чтобы tumblr-блог был похож стилем на тот, который я сделал для движка [showdown blog](http://code.google.com/p/showdown-blog/), а получилось даже лучше!

![Скриншот]({{ get_figure(slug, 'screen.png') }})

В настройках темы можно включить трансляцию последних твитов, прикрутить [Disqus](http://disqus.com) и даже организовать подсветку кода в постах.

Для подсветки нужно чтобы первой строкой в блоках кода было что-нибудь вроде `!#xml`, поэтому советую создавать посты в `Markdown`-редакторе (включается в [настройках профиля](http://www.tumblr.com/preferences)). Для подсветки используется [SHJS](http://shjs.sourceforge.net/), выложенный на сервер `static.tumblr`. Кроме галочки "Highlight code" надо в поле "Supported langs" прописать список языков программирования, которые используются в блоге в виде `['html','css','xml','javascript','java','python','sh']`. Вот какие языки можно указать: `html` (HTML), `xml` (XML), `css` (CSS), `javascript` (JavaScript), `python` (Python), `java` (Java), `ruby` (Ruby), `sql` (SQL), `sh` (Unix Shell), `php` (PHP), `cpp` (C++), `csharp` (C#).

Для трансляции твитов пропишите в [настройках темы](http://www.tumblr.com/customize) "Twitter username".

Для того чтобы включить [Disqus](http://disqus.com), укажите в [тех же настройках](http://www.tumblr.com/customize) "Disqus shortname" вашего блога.
