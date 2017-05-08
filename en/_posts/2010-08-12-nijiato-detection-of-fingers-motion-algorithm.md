---
layout: post.html
title: "Way of the Rainbow: Fingers Motion Detection Algorythm Based on a Colors Differentiation (Driven by LISP)"
datetime: 12 Aug 2010 15:38
tags: [ lisp, computer-vision, functional-programming ]
---

I am crazy a little bit, so in my spare time I've started to study Lisp and, to make my studying more interesting, I've tried to make a realization of my own algorithm. "Algorythm", for sure, is spoken too loudly, it has no matrix multiplication, no arrays sorting, no bubbles and no hard work in optimization (even no colors calibration, I sorry myself with the fact that this version if for learning). And yes, there are a lot of pictures in the article, and in the end there even will be a video.

[Link to the sources, in advance](http://code.google.com/p/nijiato)

The goal is simple: Detect the positions of all ten finger in 2D-space (position coordinates and the tilt angle of each in discrete moment), translate these data through `stdout` or using socket to another application, so the last will have a possibility to make assumptions about "gestures" which user do and react appropriately in user interface. The inspiration for me was in the [John Underkoffler talk about future interfaces](http://www.ted.com/talks/lang/eng/john_underkoffler_drive_3d_data_with_a_gesture.html) and the fact that [video4linux bindings for Common Lisp](http://www.cliki.net/CL-V4L2) by Vitaly Mayatskih were caught by the arm and they could not have come at a better time. Here I present you only the first part - a program that detects coordinates and pinch of fingers. I dont't know if I'll make myself implement the other parts and make an enterprise condition of this part, if no-one will be interested.

The distinctive feature of this way is that it, with the proper courage, can be reproduced in the home conditions. To detect fingers positions in space no sensors or euristic algorithms or pattern-matching like in OpenCV is used. What is used:

* Linux
* Lisp-interpreter, SBCL is preferred
* [A bunch of Common-Lisp packages](http://code.google.com/p/nijiato/wiki/RequiredCLpackages) (but may be you already have installed lot of them if you are working with Lisp)
* video4linux driver (`v4l2convert.so`) and GTK support
* Any web-camera compatible with video4linux (mine is Genius iSlim 300)
* Ten slips of paper which you can put on fingers: two of red, two of orange, two of yellow, two of green and two of blue.

These slips are the base of this crazy-little-algorithm, you can implement it without other parts in any programming language and in eny environment. [Algorythm source code is located here](http://code.google.com/p/nijiato/source/browse/nijiato-recognition.lisp), you can follow the code and the description simultaneously. Lisp is considered self-documenting language so I hope everything will be clear :).

### Koo. Initial data

In the beginning we need to define which colors a program will discover and understand that _possibly_ there is a finger located in this place. There is no sence to make them exact, we need to determine some delta, a small span of possible values to get both areas, a lighter and a darker one, approximately one color, in our "suspicious" region. I gave the own delta for each color, just because each of them usually behaves diffrently in respect of other ones. All my values are "hardcoded" - I found them through several experiments for concrete illumination and for concrete time of the day (a program works good in my house with the lights turned on from 8PM to the late night with the default camera brightness - it matches the most times and conditions when I have returned back from work). Let we consider it the learning version and that will excuse me. We may add some pre-calibration or general frame illumination analysis and make a colors correction in accordance with this value, but the everyones' slips themselves will be differently shaded anyway, if just we dont start the mass production of them with identical colors inoculated to tomorrow.

So, let us put the slips on our fingers.

![Color values]({{ get_figure(slug, 'colors.png') }})

The RGB-components on a picture are presented in the range from 0 to 1, the overflow when adding/subtracting is ignored. More of that, this colors are individual for my case, that's whay they look like not ideal.

### Koo. First pass. Detecting possible fingers' locations areas.

The main array in the program is `*fingers-values*` which length is (frame width * frame height). Its every cell corresponds to concrete frame pixel and will contain the number in range from `0` to `200`. This array is re-filled with new values (calculated using pixels' RGB-components) in every next frame.

So, while the algorithm cycle goes on, the `*fingers-values*` array will contain values like these:

* `0` value - pixel does not match any color plus-minus
* Values in range from `1` to `49` - these values are for expected areas of left hand fingers locations, with `9-10` per every finger
* Values in range from `50` tо `99` - these values are for expected areas of right hand fingers locations, with `10` per every finger
* Values greater than `100` and less than `200` - the exact location of the according finger, to discover which one - subtract `100`.

No let's get back to the algorithm, we're running first pass, analysing current video frame pixel by pixel.

If pixel does not filled with any color defined before plus-minus delta, we write `0` to the corresponding `*fingers-values*` array cell. If here is _may be_ some concrete finger (color of pixel matches to one of predefined colors plus-minus delta), we write the correnponding number to the corresponding cell - `1-9` for thumb, `10-19` for index, `20-29` for middle, `30-39` for ring-finger and `40-49` for little one. Currently I write only `9`,`19`, `29`, `39`, `49` values in the cells - I expected to make an additional gradation depending on how close was the value to the "middle" color, but this proved unnecessary (but ranges of `10` are making great help in future). It is expected that fingers of left hand are found by default. The number of detected areas of same color are not controlled or regulated any way at this step.

![Сorrespondence of colors and fingers]({{ get_figure(slug, 'values.png') }})

That's all, the frame was scanned, but it is just a first step: _there are values less than `50` in our array_.

### Koo. Second pass. Detecting coordinates and angles.

Before second pass over the frame the temporary array of 10 booleans named `hits` is created. We control what fingers are already detected with this array. No we are going over every cell of main `*fingers-values*` array, one by one. If the value of current cell is greater than zero and less than `100` then we check if that finger was already detected, if was- we skip this cell, if not - we're trying to make decision on what hand can it be using the `x` coodinate for this cell. If the same finger for left hand was found and its `x` coordinate was greater than current (but not too close to current, I check if no closer than `80px`) so we, seems, got the right hand - so we add `50` to current value and work with already updated one.

![Distance between fingers]({{ get_figure(slug, 'distance.png') }})

Now we now which hand it is and the estimated finger location area, it is left to detect its coordinates. So we save `x` and `y` of current pixel and then in cycle through angles from `0` to `pi` with a `pi / 20` step (for example) we calculate the pixels' coords for each beam with the corresponding angle which extends from the saved point (in a non-learning version we can make a cache for relative values of these), the beams length is set to the predefined value, in my case it is `31px` (including current pixel, 15 to the end and 15 to the start), and their center is located in current point.

![Angles detection algorithm]({{ get_figure(slug, 'angles.png') }})

The pixels' coordinates of each beam are uniquely correspond with indexes of neigbour cells in `*fingers-values*` array. While staying in current point with cursor we count pixel-by-pixel for every beam the number of matched values (those whos value between `1` and `50`, adding `50` if the current hand is right) and if this number is acceptable for this length (I grant it to have error in 4 pixels, so for minimum 27 pixels of 31 must match) then bingo - **we have detected the angle and finger position**: finger coordinates (relative) - it is the start and end points of the beam and the finger pinch is the angle of matched beam. We can write to `*hits*` that finger is found and pass this data to the screen (or to `stdout`).

![Smile]({{ get_figure(slug, 'smile.png') }})

### Koo. Possible applications.

When we know fingers coordinates and their tilt angles, we can identify almost any gesture. But the analysator need to have the ability of "prediction" of fingers position using the previous states - if the finger was suddenly lost in the center of frame so may be a hand was tightened into a fist or else, if it was lost at the edge of the frame, may be it was a fast outward movement. There is a solvable problem about detecting the hand that owns a single finger - it can be solved using additional markers for palms (if marker is not seen and a fingers are in back order on the frame - it is the backside), there are navy blue and violet colors left (I've added them to pictures for clarity). Or it even may be ignored what hand it is for gestures if there is insuffiecient amount of data (only two fingers are visible from camera). These gestures may be used to manipulate interfaces (as in the [mentioned video](http://www.ted.com/talks/lang/eng/john_underkoffler_drive_3d_data_with_a_gesture.html) - to move windows, watching images in albums, making all like in Minority Report, and there's only web-camera and psychological barrier overcome (to put the colored slips or the similar controllers on the fingers) required). Currently it is cheaper than densors and more funny than current applications of Microsoft Kinect :).

**Upd.** The people gave me [this video](http://blog.makezine.com/archive/2010/07/gestural_interface_via_flamboyant_g.html), the idea seems similar but my version is more attic anyway :). And time had passed and Microsoft Kinect does much more iterensting thing now, so sorry me, Microsoft Kinect :)

### Koo. What to improve

* Add calibration, detect illumination/brightness level, make "Nijiato, colored slip of paper" a mass production item.
* Detect what hand we see in camera with more intelligent way, using additional marker on a hand, for example)
* Much of optimization:
  * relative coordinates of the beams may be cached
  * calculations may be threaded
  * we may scan not every frame but every tenth and to presume fast movements using gestures data
  * ...

### Koo. README

Currently it is required to install Linux packages named `libv4l-dev` and `libgtkglext` and register in ADSF the CLisp packages from [this list](http://code.google.com/p/nijiato/source/browse/requirements) (the repositories and required commands are indicated). Also you can install `rlwrap` to make yor work with interpretor easier. If you have 64bit system, you need to remove a hack from CL-V4L2 bindings, it is also described in [requirements](http://code.google.com/p/nijiato/source/browse/requirements).

Whene these operations are done, the launch is simple as that:

    $ LD_PRELOAD=/usr/lib/libv4l/v4l2convert.so [rlwrap] sbcl
    * (load "nijiato-demo-load.lisp")

(`.so`-file may be placed somewhere else depending on a bitness and structure of your OS)

The program in fact is the hardly revised demo-example from `CL-V4L2` that shows GTK-window and projects an OpenGL-texture with camera image in it and also allows to get current pixels in every frame. FASL-version can fail to start, I am fighting with this problem. (**Upd.** No way, I've forgot)

### Koo. Video

And finally a video that show program in work. It loads a lot of libraries at start, you can skip first 30 seconds approximately. "Detected" positions of fingers are shown with slim 1-pixel black line (those matched beams) and shown in the console in readable form. In the middle of video two thumbs of both hands are not detected, that is because the distance between them is less than 80 pixels that I have set to be minimal width between hands. The window from camera is intentionally small to ease the calculations for a program :).

[![Link to Vimeo video]({{ get_figure(slug, 'vimeo-video-frame.png') }})](http://vimeo.com/14073181)

**P.S.** Some (not a lot of) phrases in this article are related to the Russian epic sci-fi movie named [Kin-dza-dza](http://www.imdb.com/title/tt0091341/), so I promote it with this article :)
