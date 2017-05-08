---
layout: post.html
title: Неожиданный баг Textpattern
datetime: 23 Jul 2007 02:14
tags: [ php, textpattern ]
---

Пока игрался с [textpattern](http://textpattern.org/) на [шаредкоде](http://sharedcode.info/), обнаружил сей баг, который потенциально может затронуть тех, кто собственно [textpattern](http://textpattern.org/) пользует.

Испугало то, что отключалось (правильнее сказать истекало) комментирование в статьях, с постинга которых прошло много времени. излазил все настройки – нету ничего такого – хотя видно, что должно ведь быть по разумению. И ведь хорошо что погуглил. наткнулся на [пост](http://hari.literaryforums.org/2007/04/22/textpattern-review/), а из него -- по комментам -- на [статью FAQ](http://textpattern.com/faq/257/comment-preferences-are-missing).

Суть состоит в том, что если в _Admin_ -> _Preferences_ -> _Basic_ для раздела _Comments_ вы наблюдаете только два пункта (и у вас версия 4.0.4 и нет желания/возможности пока апдейтить) – эта заметка для вас.

Сделать надо всего лишь два действия. Раз – забрать с вашего хостинга файл `./textpattern/include/txp_prefs.php`, найти в нем строку 89:

``` php
$evt_list = safe_column('event', 'txp_prefs',
     "type = 0 and prefs_id = 1 group by 'event' order by event desc");
```

и удалить из нее кавычки вокруг event (чтобы она совпадала с [этим вариантом](http://dev.textpattern.com/browser/development/4.0/textpattern/include/txp_prefs.php?rev=2156#L89)):

``` php
$evt_list = safe_column('event', 'txp_prefs',
     "type = 0 and prefs_id = 1 group by event order by event desc");
```

два -- залить файл обратно. Финита ля комедия -- добро пожаловать в настройки, в пункт _Comments:Disabled after_.
