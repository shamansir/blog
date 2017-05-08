---
layout: post.html
title: Fluxus — Прототипирование OpenGL графики и игр on-the-fly (добавить Scheme по вкусу)
datetime: 10 Jul 2010 13:10
tags: [ fluxus, opengl, scheme, racket, functional-programming ]
---

Интернет для программиста интересующегося трёхмерной графикой уже несколько лет полнится видео, в котором на лету программируют визуалайзеры для музыки, сложные цветоморфированные эффекты или даже намного более хитрые вещи, работающие на стыке интерактива и трёхмерной графики - буквально, человек пишет код и где-то на фоне он тут же компилируется, выполняется и отображается результат, это называется _livecoding_. Чаще всего такие программы пишутся на языках из Lisp-семейства, подобный редактор есть для ProcessingJS, он тут же рендерит результат выполнения графического кода в браузере, но речь не о нём.

[**Fluxus**](http://www.pawfal.org/fluxus/) - это одновременно кроссплатформенный open-source 3D-движок для игр на принципах [livecoding](http://www.toplap.org) и инструмент для прототипирования трёхмерной графики и интерактива в собственном трёхмерном пространстве. И при этом он не обделён [достаточно подробной документацией](http://www.pawfal.org/fluxus/documentation). Язык программирования - расширенный графическими командами PLT Scheme.

Впрочем, [смотрите сами](http://www.youtube.com/watch?v=aTt8r3LhCFM):

<object width="480" height="385"><param name="movie" value="http://www.youtube.com/v/aTt8r3LhCFM?fs=1&amp;hl=en_US"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/aTt8r3LhCFM?fs=1&amp;hl=en_US" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="480" height="385"></embed></object>

Когда приложение запускается, оно запускается в режиме интерпретатора. Чтобы переключиться в режим написания полной программы, который показан на большинстве видео, нажмите Ctrl+1. Чтобы запустить рендеринг описанной сцены - нажмите F5.

Вот, например, две вращающиеся меняющие цвет сферы:

``` scheme

(define (animate)
    (let* ((t (* (time) 2))
           (x (sin t))
           (y (cos t)))

    (with-state
        (translate (vector x y 0))
        (colour (vector (+ 1.5 (sin (time))) 0 0))
        (draw-sphere))

    (with-state
        (translate (vmul (vector x y 0) 3))
        (colour (vector 0 0 (- 1.5 (sin (time)))))
        (draw-sphere))))

(every-frame (animate))

```
