---
layout: post.html
title: Fluxus — Prototyping OpenGL graphics and games on-the-fly (add Scheme to taste)
datetime: 10 Jul 2010 13:10
tags: [ fluxus, opengl, scheme, racket, functional-programming ]
---

The internet for a programmer who insterested in 3D-graphics for several years is full of videos where people programming music visualizers, complex color-morphing effects or even more tricky things working at the intersection of technology - literally the author writes code and somewhere on background it is compiled and executed and the author sees the result - this process named _livecoding_. Most recently the programs like these are written in lisp-family languages, the similar editor exists for ProcessingJS, it renders code immediately in browser, but its not about it.

[**Fluxus**](http://www.pawfal.org/fluxus/) - it is a cross-platform 3D-engine for games drafts based on [livecoding](http://www.toplap.org) principles and simultaneously the prototyping tool for 3D-graphics and interactive things. And there is [pretty detailed documentation exist](http://www.pawfal.org/fluxus/documentation). Programming language is extended with graphic functions []PLT Scheme](http://racket-lang.org).

However, [see for yourself](http://www.youtube.com/watch?v=aTt8r3LhCFM):

<object width="480" height="385"><param name="movie" value="http://www.youtube.com/v/aTt8r3LhCFM?fs=1&amp;hl=en_US"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/aTt8r3LhCFM?fs=1&amp;hl=en_US" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="480" height="385"></embed></object>

When application launched, it is started in interpretor mode. To switch to code editor mode, which is used in the most of the videos, press `Ctrl+1`. To render current defined scene - press `F5`.

Hereis, for example, two rotating spheres that change their colors through time:

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
