---
layout: post.html
title: "Mastering Functional JavaScript Lecture Slides"
datetime: 16 Feb 2011 22:23
tags: [ javascript, lecture, web-dev, functions ]
---

In JavaScript, like, say, in Python, functions are also objects. It gives developer the opportunity to write pure (or not so, since there are no native monads support ;) ) functional code. Most people among us do easily forget about this fact, but it is still true and, what's truly great, it was true from the start.

These slides are supposed to re-introduce to you the mighty power of functions in JS. No _map_ / _filter_, since they're trivial, but it's more about _deferring_, _queueing_ and _composing_ functions with few-lined chunks of code, plus some general tricks with them, and also what profit you may take out of all of this stuff. No techniques that will only come in new versions or, instead, just were introduced: totally plain old [good] JavaScript.

However, a bit of basics at the start are also there, of course. 

OK, Here we go:

[![Slides]({{ get_figure(slug, 'first_slide.png') }})](https://speakerdeck.com/shamansir/mastering-functional-javascript)

### Links

Links to the examples:

* Deferred functions: 
    * [http://codepen.io/shamansir/pen/HskmE]()
    * [http://codepen.io/shamansir/pen/kBzJe]()
* Partial applications: 
    * [http://codepen.io/shamansir/pen/xCrgz]() 
* Queues of functions: 
    * [http://codepen.io/shamansir/pen/AaHqy]()
* Composed functions: 
    * [http://codepen.io/shamansir/pen/Funwt]()

Lyfe.js: [http://bitbucket.org/balpha/lyfe]()<br/>
Article on lyfe.js: [http://balpha.de/2011/06/introducing-lyfe-yield-in-javascript]()


