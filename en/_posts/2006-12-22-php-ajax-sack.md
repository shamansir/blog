---
layout: post.html
title: PHP + AJAX = SACK
datetime: 22 Dec 2006 12:27
tags: [ php, ajax, sack, javascript ]
---

Occasionally, I've got a task to... But I was too lazy to write my own function, to check the browser and blah-blah-blah (the more, as I remember, there are more progressive methods exist already :) ) ... Tried to attach [JsHttpRequest from dklab.ru](http://dklab.ru/lib/JsHttpRequest/), but 've got different tricky errors and everything from Mr. D. Koteroff is a little bit misty for me :), 'cause I am not a prof in `PHP` still. So I've taken [another sack](http://www.twilightuniverse.com/projects/sack/), named  `SACK` -- Simple AJAX Code-Kit. And in this sack everything is so simple and trivial for real -- I haven't needed anything more.

I was making a primitive form to pop out above the hyperlink, to ask a question and to write it in DB, while not refreshing the page (it is strange, bit it was _not mine_ crazy decision).

No beauties and OOP-scripts, because it was required something written on the knee (but nothing prevents you from beautiful usage of this p... sackage).

The single mine bug is in `auto-suggestion` in Firefox that pops down when the content of the fields starts to repeat (if you've asked one question, you'll never notice it). But I surely remember that there is an option to turn it off, seems through `meta`-tags

To use it we need _just a single file_ [from sackage](http://www.twilightuniverse.com/downloads/sack/tw-sack.zip): `tw-sack.js`.

I'll show you the result and will give a description on hard moments (if they are exist, everything seems transparent :) ) :

`HTML`-page:

> (to make highlighting correct I've splitted the code in five blocks, they just go one by one, following each other: if you just select them all and copy - everything will work ok)

``` html

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
                      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Blah</title>

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
            e.innerHTML = "Sending data...";
        }

        function whenLoaded(){
            var e = document.getElementById('status-box');
            e.innerHTML = "Data sent...";
        }

        function whenInteractive(){
            var e = document.getElementById('status-box');
            e.innerHTML = "Getting data...";
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
     <span id="qbox-label">Your question: </span>
     <div id="status-box"></div>
     <form id="question-form" name="question-form"
                     method="post" action="./q.php">
         <label for="heading">Title:</label>
             <input type="text" name="heading" id="q-heading"
                                         maxlength="80" />
         <label for="sender">Sender (e-mail) (*):</label>
             <input type="text" name="sender" id="q-sender"
                                         maxlength="60" />
         <label for="question">Question (255 chars):</label>
             <textarea name="question" rows="5" cols="25"
                     id="q-body"></textarea>
         <input type="button" name="post_question" value="Ask"
             onclick="sendQuestion(); clearFormFields();
                     return false;"
             ondblclick="sendQuestion(); return false;" />
     </form>
 </div>
</body>
</html>

```

And the receiving script - `q.php` (_pay attention_ - it is in `utf-8`, to conform with the page in encoding):

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

        if (!$result) $responce_str = "<span class='error'>Failed to add
            your question to database</span>";
        else $responce_str = "<span class='message'>Your question is
            sent!</span>";

        mysql_close($conn);

    } else {
        $responce_str = "<span class='warning'>Sender`s e-mail
                is required</span>";
    }
} else {
    $responce_str = "<span class='warning'>Please,
                        specify your question</span>";
}

echo $responce_str;
?>

```

It is even `CSS` is a greatest part of the `HTML`-page :).

In `JavaScript`, after the `var ajax = new sack();` line, the `Sack`-related code goes on. Some event-hadling functions and a small trivial function that collects the data. In `PHP` there is nothing of `SACK`. Just an usual getting-values-from-`$_POST` (as you set it, of course). That's all.

I think - that is great.

Dunno about arrays in `SACK`, but if you'll watch the demo that exist in the sackage - this problem is also perfectly solved.
