---
layout: post.html
title: Eric IDE 4.0.1 in Ubuntu 7.04
datetime: 22 Jul 2007 18:05
tags: [ eric-ide, python, ubuntu ]
---

[Eric](http://www.die-offenbachs.de/eric/index.html) – is very good IDE for [Python](http://www.python.org/). And [just yesterday](http://www.die-offenbachs.de/eric/eric-news.html) the new [4.0.1](http://sourceforge.net/project/showfiles.php?group_id=119070&package_id=233329) version was released, but in repositories the last version for the moment is 3.9, and I found myself missing those good old times when I've compiled packages form sources recently. So I am presenting you a listing of things to be done just in case, to prevent you from meeting the errors that visited me through the process of compilation. Something from this stuff is oriented on new versions :). Just because it was installed on clean Ubuntu - everything must be adequate... If I missed something, please report.

_What is used:_

* [eric](http://www.die-offenbachs.de/eric/index.html) 4.0.0.1
* [Python](http://www.python.org/) 2.5.1
* [Qt](http://trolltech.com/products/qt) 4.2.3 + [PyQt](http://www.riverbankcomputing.co.uk/pyqt/index.php) v4.1 + [QScintilla](http://www.riverbankcomputing.co.uk/qscintilla/index.php) 2
* [SIP](http://www.riverbankcomputing.co.uk/sip/index.php) 4.6
* [G++](http://gcc.gnu.org/) 3.4 (I almost sure you may take the latest one)

so, let's go into some catalogue for compilation and start:

    $ cd ~/distr-temp/

using [sources](http://sourceforge.net/project/showfiles.php?group_id=119070&package_id=233329) from sourceforge:

    $ wget http://mesh.dl.sourceforge.net/sourceforge/eric-ide/eric4-4.0.1.tar.gz

we will install different libraries for [PyQt](http://www.riverbankcomputing.co.uk/pyqt/index.php) (depending of `apt-get` settings you may need an install CD):

    $ sudo apt-get install python2.5-dev
    $ sudo apt-get install python-qt4
    $ sudo apt-get install libqt4-dev
    $ sudo apt-get install python-qt4-dev

then we'll install `g++` compiler and make a `/usr/bin/g++` link:

    $ sudo apt-get install g++-3.4
    $ sudo ln -s /usr/bin/g++-3.4 /usr/bin/g++

then download and install the last current version of  [SIP](http://www.riverbankcomputing.co.uk/sip/index.php) – it allows the libraries written C[++] to act themselves as [Python](http://www.python.org/) modules:

    $ wget http://www.riverbankcomputing.com/Downloads/sip4/sip-4.6.tar.gz
    $ tar -xvzf ./sip-4.6.tar.gz
    $ cd ./sip-4.6.tar.gz
    $ python ./configure.py
    $ make
    $ sudo make install
    $ cd ..

then download and install the last current version of [QScintilla](http://www.riverbankcomputing.co.uk/qscintilla/index.php) – Qt-port for source code editor component (version is for Qt4):

    $ wget http://www.riverbankcomputing.com/Downloads/ \
      Snapshots/QScintilla2/QScintilla-gpl-2-snapshot-20070709.tar.gz
    $ tar -xvzf ./QScintilla-gpl-2-snapshot-20070709.tar.gz
    $ cd ./QScintilla-gpl-2-snapshot-20070709/Qt4
    $ qmake qscintilla.pro
    $ sudo make
    $ sudo make install

now we need to install bindings of [QScintilla](http://www.riverbankcomputing.co.uk/qscintilla/index.php) for [Python](http://www.python.org/) – they are placed in `Python` directory:

    $ cd ../Python
    $ python ./configure.py
    $ make
    $ sudo make install

and finally the [eric](http://www.die-offenbachs.de/eric/index.html)'s turn:

    $ cd ../../eric4-4.0.1/
    $ sudo python install.py

when installing, you need to specify the directory where Qt lies: `/usr/share/qt4`.

Well, actually that's all. You can type `eric4` and make fun, if you want :).

