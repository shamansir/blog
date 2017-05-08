---
layout: post.html
title: SATA, DMA and Ubuntu strange things
datetime: 24 Jan 2007 19:52
tags: [ sata, dma, ubuntu ]
---

Today we've made an installation of [Ubuntu 6.06 LTS](http://ubuntuguide.org/wiki/Ubuntu:Edgy) to `SATA` hard drive. And it have failed in angriness, so strange. `Live CD` tried to mount this HD eventually long and finally mounted it, seems, but in the end, while running the kernel, it started spitting out with `buffer I/O Read Error` and so on.

The decision was found when I've combined the advices from two forums:

In `BIOS`, the _way of working with `SATA`_ I've set to `Enhanced` (it is something messed with `SATA`/`PATA`, and try to play with channels if something will go wrong; at the worst, if you have two `SATA`-harddrives, disable one for a try)

And then in the boot screen of `Live CD` I've pressed `Escape` button (that switches to text mode) and typed

    boot: live pci ide=nodma ide=reverse

(without taking into account the fact that I've tried a lot of different commands)

Now Ubuntu works as a cute one. Except...

