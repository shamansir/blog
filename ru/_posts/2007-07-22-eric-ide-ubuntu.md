---
layout: post.html
title: Eric IDE 4.0.1 на Ubuntu 7.04
datetime: 22 Jul 2007 18:05
tags: [ eric-ide, python, ubuntu ]
---

[Eric](http://www.die-offenbachs.de/eric/index.html) – очень даже хорошее IDE под [Python](http://www.python.org/). И [не далее как вчера](http://www.die-offenbachs.de/eric/eric-news.html) вышла версия [4.0.1](http://sourceforge.net/project/showfiles.php?group_id=119070&package_id=233329), в репозиториях же на данный момент лежит версия 3.9. и захотелось мне вспомнить старые добрые времена и собрать этот пакет. Представляю вам на всякий случай листинг того, что делать – чтобы не возвращаться обратно, выясняя что нужно поставить еще что-то или разбираясь в ошибках компиляции, которые меня посещали :). Кое-где – ориентировка на последние версии :). Так как устанавливалось на чистой практически убунте – все должно быть адекватно… если что-то упустил – прошу сообщать.

_Используется:_

* [eric](http://www.die-offenbachs.de/eric/index.html) 4.0.0.1
* [Python](http://www.python.org/) 2.5.1
* [Qt](http://trolltech.com/products/qt) 4.2.3 + [PyQt](http://www.riverbankcomputing.co.uk/pyqt/index.php) v4.1 + [QScintilla](http://www.riverbankcomputing.co.uk/qscintilla/index.php) 2
* [SIP](http://www.riverbankcomputing.co.uk/sip/index.php) 4.6
* [G++](http://gcc.gnu.org/) 3.4 (наверняка можно взять и поздний)

итак, переходим в какой-нибудь каталог для сборки и приступаем:

    $ cd ~/distr-temp/

берем [сурсы](http://sourceforge.net/project/showfiles.php?group_id=119070&package_id=233329) с sourceforge‘a:

    $ wget http://mesh.dl.sourceforge.net/sourceforge/eric-ide/eric4-4.0.1.tar.gz

устанавливаем всяческие библиотеки для связки [PyQt](http://www.riverbankcomputing.co.uk/pyqt/index.php) (в зависимости от настроек `apt-get`‘а может понадобиться установочный CD):

    $ sudo apt-get install python2.5-dev
    $ sudo apt-get install python-qt4
    $ sudo apt-get install libqt4-dev
    $ sudo apt-get install python-qt4-dev

устанавливаем компилятор `g++` и делаем на него ссылку `/usr/bin/g++`:

    $ sudo apt-get install g++-3.4
    $ sudo ln -s /usr/bin/g++-3.4 /usr/bin/g++

скачиваем и устанавливаем последнюю на данный момент версию [SIP](http://www.riverbankcomputing.co.uk/sip/index.php) – он позволяет библиотекам, написанным на C[++] вести себя как модули [Python](http://www.python.org/):

    $ wget http://www.riverbankcomputing.com/Downloads/sip4/sip-4.6.tar.gz
    $ tar -xvzf ./sip-4.6.tar.gz
    $ cd ./sip-4.6.tar.gz
    $ python ./configure.py
    $ make
    $ sudo make install
    $ cd ..

скачиваем и устанавливаем последнюю на данный момент версию [QScintilla](http://www.riverbankcomputing.co.uk/qscintilla/index.php) – Qt-порт компонента для редактирования исходных кодов (устанавливаем версию для Qt4):

    $ wget http://www.riverbankcomputing.com/Downloads/Snapshots/QScintilla2/QScintilla-gpl-2-snapshot-20070709.tar.gz
    $ tar -xvzf ./QScintilla-gpl-2-snapshot-20070709.tar.gz
    $ cd ./QScintilla-gpl-2-snapshot-20070709/Qt4
    $ qmake qscintilla.pro
    $ sudo make
    $ sudo make install

теперь нужно установить связи на [QScintilla](http://www.riverbankcomputing.co.uk/qscintilla/index.php) для [Python](http://www.python.org/) – они находятся собственно в директории Python:

    $ cd ../Python
    $ python ./configure.py
    $ make
    $ sudo make install

ну а теперь очередь собственно [eric](http://www.die-offenbachs.de/eric/index.html):

    $ cd ../../eric4-4.0.1/
    $ sudo python install.py

при установке нужно сказать ему директорию где лежит Qt: `/usr/share/qt4`.

Ну вот собственно и все. Набираем `eric4` и, если хочется, радуемся :).
