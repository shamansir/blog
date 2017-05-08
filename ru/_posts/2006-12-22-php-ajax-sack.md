---
layout: post.html
title: PHP + AJAX = SACK
datetime: 22 Dec 2006 12:27
tags: [ php, ajax, sack, javascript ]
---

Понадобилось тут… Но лень было писать свою фунцкцию, чтобы там в зависимости от браузера и бла-бла-бла (тем более, насколько я помню, есть уже более прогрессивные методы :) ). Хотел было прикрутить [JsHttpRequest с dklab.ru](http://dklab.ru/lib/JsHttpRequest/), да чего-то полезли какие-то хитрые ошибки и вообще все там у мистера Д. Котероff как-то для меня хитро :), благо в `PHP` я еще не спец. Поэтому я взял [другой пакетик](http://www.twilightuniverse.com/projects/sack/), под названием `SACK` -- Simple AJAX Code-Kit. Там действительно все просто и банально -- мне больше и не было надо.

Я делал банальную формочку, которая выплывала бы по ссылке, спрашивала вопрос и записывала бы вопрос в базу данных, не перегружая страницу (удивительно, но это было _не мое_ извращенное желание).

Никаких особых красивостей и ООП-скриптов, потому что это было нужно на коленке (при этом ничего не мешает использовать пакетик красиво).

Единственный (и то -- мой :) ) баг -- `auto-suggestion` в Firefox, который начинает выпадать когда содержимое полей начинает повторяться (если вы задали один вопрос, то вы этого и не заметите). Но я точно помню что его можно было отключить и, кажется, через `meta`-теги.

Для использования нам нужен _всего один файл_ [из пакетика http://www.twilightuniverse.com/downloads/sack/tw-sack.zip]: `tw-sack.js`.

Я сразу покажу результат, а потом подробнее рассмотрю тонкие моменты (если они вообще тут есть - имхо все прозрачно :) ) :

`HTML`-страница:

> (для корректной подсветки я разбил код на пять блоков, которые по сути просто идут друг за другом: если их выделить подряд и скопировать -- всё будет верно)

``` html

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
                      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Блах</title>

    <style type="text/css">

```

``` css

        /**/.invisible {
            display: none;
        }

        .visible {
            display: block;
        }

        body {
            margin: 25px;
            font-size: 16px;
            font-family: Times New Roman, Georgia, serif;
        }

        div#question-box {
            position: absolute;
            left: 5%;
            margin-top: 5px;
            width: 300px;
            height: 245px;
            border: 1px solid #000;
            background-color: #ffc;
            font-family: Tahoma, Arial, Helvetica, sans-serif;
        }

        div#question-box label {
            font-size: 11px;
        }

        div#question-box span#qbox-label {
            display: block;
            position: relative;
            top: 0;
            left: 0;
            height: 10px;
            padding: 5px;
            font-size: 11px;
            font-weight: bold;
            text-align: center;
            background-color: #ff9;
        }

        div#question-box form {
            padding: 5px 15px;
        }

        form#question-form * {
            color: #333;
            display: block;
            width: 98%;
        }

        form#question-form input,
        form#question-form textarea {
            margin: 3px 0;
            border: 1px solid #333;
        }

        form#question-form input[type="button"] {
            margin-top: 10px;
        }

        form label {
            font-weight: bold;
        }

        div#status-box span.message,
        div#status-box span.error,
        div#status-box span.warning {
            display: block;
            width: 100%;
            font-weight: bold;
            padding: 5px;
        }

        span.message {
            color: #fff;
        }

        span.error {
            background-color: #f00;
            color: #fff;
        }

        span.warning {
            color: #660;
        }

        form textarea[name="question"] {
            height: 60px;
        }

        div#question-box div#status-box {
            display: block;
            width: 100%;
            height: 20px;
            background-color: #003;
            font-size: 11px;
            color: #fff;
            padding: 0;
        }

```

``` html

    </style>

    <script type="text/javascript" src="./scripts/tw-sack.js"></script>
    <script language="JavaScript" type="text/javascript">
    <!--

```

``` javascript

        function showElement(elementId) {
            element = document.getElementById(elementId);
            element.className = 'visible';
                // element.style.display = 'block';
        }

        function hideElement(elementId) {
            element = document.getElementById(elementId);
            element.className = 'invisible';
                // element.style.display = 'none';
        }

        function clearFormFields() {
            // optimize for any form then....
            var form = document.getElementById('question-form');
            form.heading.value = '';
            form.sender.value = '';
            form.question.value = '';
        };

        var ajax = new sack();

        function whenLoading(){
            var e = document.getElementById('status-box');
            e.innerHTML = "Отсылаю данные...";
        }

        function whenLoaded(){
            var e = document.getElementById('status-box');
            e.innerHTML = "Данные отосланы...";
        }

        function whenInteractive(){
            var e = document.getElementById('status-box');
            e.innerHTML = "Получаю данные...";
        }

        function whenCompleted(){
        }

        function sendQuestion(){
            var form = document.getElementById('question-form');
            ajax.setVar("heading", form.heading.value);
                // recomended method of setting data to be parsed.
            ajax.setVar("sender", form.sender.value);
            ajax.setVar("question", form.question.value);
            ajax.requestFile = "q.php";
            ajax.method = 'POST';
            ajax.element = 'status-box';
            ajax.onLoading = whenLoading;
            ajax.onLoaded = whenLoaded;
            ajax.onInteractive = whenInteractive;
            ajax.onCompletion = whenCompleted;
            ajax.runAJAX();
        }

```

``` html

        //-->
    </script>
</head>

<body>
    <p><a href="./q.php" onmouseover="showElement('question-box');">
                 отправить вопрос</a>.</p>
    <div id="question-box" class="invisible"
                 onmouseover="showElement('question-box');"
                 onmouseout="hideElement('question-box');">
        <span id="qbox-label">Ваш вопрос: </span>
        <div id="status-box"></div>
        <form id="question-form" name="question-form"
                         method="post" action="./q.php">
            <label for="heading">Заголовок:</label>
                <input type="text" name="heading" id="q-heading"
                                             maxlength="80" />
            <label for="sender">Отправитель (e-mail) (*):</label>
                <input type="text" name="sender" id="q-sender"
                                             maxlength="60" />
            <label for="question">Вопрос (255 символов):</label>
                <textarea name="question" rows="5" cols="25"
                         id="q-body"></textarea>
            <input type="button" name="post_question" value="Задать"
                onclick="sendQuestion(); clearFormFields();
                         return false;"
                ondblclick="sendQuestion(); return false;" />
        </form>
    </div>
</body>
</html>

```

И принимающий скрипт -- `q.php` (_Обратите внимание_ -- он на `utf-8`, дабы совпадать в кодировке со страницей):

``` php

<?php
ob_start();
print_r($_POST);
$postdata = ob_get_clean();

$heading = substr($_POST['heading'], 0, 80);
$sender = substr($_POST['sender'], 0, 60);
$question = substr($_POST['question'], 0, 255);

if (isset($question) && ('' != $question)) {
    if (isset($sender) && ('' != $sender)) {

        /* connect to DB */

        $conn = mysql_connect("localhost", "****","*******")
                or die("Could not connect");
        if( !$conn ) die( mysql_error() );

        mysql_select_db("*****") and
            mysql_query("set names utf8") and
            mysql_query("SET collation_connection = 'utf8_general_ci'");

        /* insert question */

        $sql = "INSERT INTO questions SET
                    heading='".mysql_escape_string($heading)."',
                    sender='".mysql_escape_string($sender)."',
                    question='".mysql_escape_string($question)."',
                    post_date=SYSDATE()";
        $result = mysql_query($sql);

        if (!$result) $responce_str = "<span class='error'>Не удалось
                добавить вопрос $heading в базу данных</span>";
        else $responce_str = "<span class='message'>Ваш вопрос
                отправлен!</span>";

        mysql_close($conn);

    } else {
        $responce_str = "<span class='warning'>E-mail
                отправителя нужно указать обязательно</span>";
    }
} else {
    $responce_str = "<span class='warning'>Пожалуйста,
                        укажите ваш вопрос</span>";
}

echo $responce_str;

```

В `HTML`-коде большую часть даже занимает `CSS` :).

В `JavaScript` после строки `var ajax = new sack();` идет собственно код для `Sack`’а. Пара функций-event-handler’ов и небольшая, очевидная, функция, которая все это собирает. В `PHP` от `SACK`’а - ничего. Только привычное забирание значений из `$_POST` (тут уж как вы решите). Все.

Имхо - великолепно.

Не знаю как насчет пересылки массивов в `SACK`, но судя по демо, которое есть в пакетике - и с этим все в порядке.
