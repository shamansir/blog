---
layout: post.html
title: "Trac + Subversion + Ubuntu: интересная забава на день"
datetime: 16 Dec 2006 01:47
tags: [ trac, subversion, ubuntu ]
---

Приветствую всех заинтересованных. Ведь вас, наверняка, не очень много :).

> **Upd.**: Более структурированное и последовательное (правда менее повествовательное) руководство для [Ubuntu Feisty](http://ubuntuguide.org/wiki/Ubuntu:Feisty Ubuntu 7.04) находится [здесь](./trac-subersion-ubuntu-revisited)

Ну а я, в свою очередь, славлюсь среди знающих меня извращенными подходами к простым вещам, так что и в этот раз решил не ломать традиций :).

Предыстория статьи такова:

Автор находится на испытательном сроке в некой фирме и по прибытию туда обнаруживает, что единственный коллега кроме начальника пишет Систему Управления Проектами (не путать с блоггерскими захватчиками - СУПом) на PHP сроком на две недели (правда, за эти две недели начальник разумно (имхо) требует лишь на-коленочного-статуса). Автор присматривается к требованиям, удивляется и сообщает начальнику, что есть уже такая система, бесплатная, расширяемая и все-в-одном-что-вам-нужно - [Trac](http://trac.edgewall.org) - система, которой он с радостью и удовольствием пользовался на прошлой работе. Благо начальник знает что такое SVN, про его замечательную поддержку было упомянуто тоже. Ну и конечно за свои слова пришлось отвечать - за это автору было заказано установить эту хитрую систему (как некоторые пишут, один из самых сложных пакетов для установки).

В свою очередь, в связи с извращенскими посылами автора, он умолчал о непредназначенности для Trac’а такой заботливой-о-пользователе-системы как Ubuntu, да еще и поставил это дело для демонстрации a) на vmWare (что, собственно, сути не меняет) (далее - “твари”) с опцией `Host-Only` и б) на `apache2`. Это потому что a) другого нового Unix’а у автора под рукой не было, а устанавливать его основной ОС было делом неперспективным и б) руководства в инете для Trac + Ubuntu почему-то именно про `apache2`.

Соответственно, действующие лица aka Оперируемые:

_Ubuntu 6.06 TLS_ (руссская, хе-хе :) ), _Trac 0.10.3_, Subversion _1.4.2_ в роли _Subversion 1.3.1_ (почему - смотрите ниже), _Python 2.4.3_ (побоялся ставить на 2.5).

Более поздний P.S. В скором времени я, вероятно, буду ставить всю эту компанию (более злободневные версии) на Ubuntu 7.04 с Python 2.5, и статья, ввиду опыта нескольких установок, будет чуть пограмотнее…

Система устанавливалась прямиком с LiveCD, без каких-либо хитрых настроек, вот как есть - шесть пунктов установки и ничего больше. Вы, конечно же, можете все сделать хитрее - думаю на процессе это отразится не сильно (в отличие, например, от подстановки другой ОС :) ).

Итак, второй апач и 2.4-ый питон нашлись в русских архивах Ubuntu (вернее Python уже был установлен, но я немного привру :) ), поэтому здесь все было просто:

    sudo apt-get install apache2 python2.4

> **Upd.**: Если вы используете английскую юбунту и апача, например, не нашлось, делаем следующее:
>
>     sudo vi /etc/apt/sources.list
>
> Добавляем (`Insert`):
>
>     deb http://ru.archive.ubuntu.com/ubuntu dapper universe main restricted multiverse
>     deb-src http://ru.archive.ubuntu.com/ubuntu dapper universe
>
> Если нужно, снимаем комменты со строк с `http://**.archive.ubuntu.com` и делаем:
>
>     sudo apt-get update

На интернациональных (читай англоязычных) порталах (конечно же можно действительно, как подсказал `@cyberskunk`, раскомментить их в `/etc/apt/sources.list`) мог бы отыскаться и Trac, но в русской ОС его не нашлось, поэтому я решил сделать его установку ручками, благо это лишь пара лишних команд:

> **Upd.:** Здесь и далее все адреса из ссылок «взять» и «забрать» можно использовать как параметры для команды `wget <ссылка>`, при этом надо находится в каталоге `~/distr` - по статье все файлы скачиваются туда.

Надо [взять](http://ftp.edgewall.com/pub/trac/trac-0.10.3.tar.gz) его [с официального сайта](http://trac.edgewall.org/wiki/TracDownload) и положить куда-нибудь, например в папку `distr` в домашней директории и затем, собственно, инсталлировать (установленных пакетов вам должно хватить и все должно обойтись без зависимостей):

> (все-все дистрибутивы я складывал в `~/distr`, что и вам советую, дабы не запутаться)

    cd /home/some-user/distr
    tar xvfz trac-0.10.3.tar.gz
    cd ./trac-0.10.3
    sudo python ./setup.py install

Далее, создадим каталог, куда будем складывать окружения (aka environments - гм…. проектов?) trac:

    sudo mkdir /var/trac

Этот каталог должен быть доступен апачу:

    sudo chown www-data:www-data /var/trac

Теперь необходимо настроить доступ апача к trac’у:

    sudo vi /etc/apache2/sites-available/trac

Содержимое этого файла должно выглядеть так:

``` { apache }

<VirtualHost *>
    ServerAdmin webmaster@localhost
    ServerName trac.example.com
    DocumentRoot /usr/share/trac/cgi-bin
    <Directory /usr/share/trac/cgi-bin>
        Options Indexes FollowSymLinks MultiViews ExecCGI
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>
    Alias /trac "/usr/share/trac/htdocs"

    <Location /trac.cgi>
        SetEnv TRAC_ENV_PARENT_DIR "/var/trac"
    </Location>

    DirectoryIndex trac.cgi
    ErrorLog /var/log/apache2/error.trac.log
    CustomLog /var/log/apache2/access.trac.log combined
</VirtualHost>

```

Если кратко, мы настраиваем виртуальный хост, устанавливаеваем корневой каталог для [CGI](http://en.wikipedia.org/wiki/Common_Gateway_Interface Common Gateway Interface)-скриптов и документов в `/usr/share/trac/cgi-bin/`, а адрес `http://localhost/trac` привязываем к пути `/usr/share/trac/htdocs` - там лежат всяческие веб-документы. Для доступа к проектам для запросов на `http://localhost/trac.cgi` устанавливается корневой каталог для окружений trac’а - `/var/trac`. В принципе,знающему английский все должно быть понятно :).

Теперь следует включить обработку `cgi`-скриптов:

    sudo vi /etc/apache2/apache2.conf

В этом файле раскомментируйте строку `AddHandler cgi-script .cgi`.

Переключим apache на сайт trac’а в качестве основного:

    sudo a2dissite default
    sudo a2ensite trac

> (проверьте, является ли теперь `/etc/apache2/sites-enabled/trac` ссылкой на `/etc/apache2/sites-available/trac`)

Так что пусть апач перечитает настройки:

    sudo /etc/init.d/apache2 reload

> **Upd.:** Теперь можно проверить, все ли в порядке - если в браузере вы набираете `http://localhost/trac.cgi/BlahBlah` и видите строку “`Environment not found`” - значит все в порядке. Также `http://localhost/trac` должен открывать каталог `/usr/share/trac/htdocs`, а `http://localhost/trac.cgi` говорить, что нет `Clearsilver`’a. Не забудьте кстати потом настроить апачевские права доступа, если надо -- это выходит за рамки статьи, в отличие от траковских :).

Настало время взяться за установку `Subversion`. Его тоже не оказалось в `apt-cache`, поэтому я его [забрал](http://subversion.tigris.org/downloads/subversion-1.4.2.tar.gz) последний на тот момент (1.4.2) [отсюда](http://subversion.tigris.org/servlets/ProjectDocumentList?folderID=260&expandFolder=260&folderID=7495) и, также, положил в каталог `~/distr`, там распаковал, установил необходимые зависимости, собрал и установил, вот так (**Upd.:** Обратите внимание, пакет называется `zlib**1**g-dev`, а не `zlib**l**g-dev`):

    cd /home/some-user/distr/
    tar xvfz subversion-1.4.2.tar.gz
    sudo apt-get install gcc
    sudo apt-get install libtool
    sudo apt-get install libapr0-dev
    sudo apt-get install zlib1g-dev
    sudo apt-get install make
    cd ./subversion-1.4.2
    ./configure
    make
    sudo make install

Затем установим модуль `svn` для `apache`, утановим `swig` и установим через пакет `subversion` версию `swig` для `python` (текущий каталог - `/home/some-user/distr/subversion-1.4.2`).

    sudo apt-get install libapache2-svn
    sudo apt-get install swig
    sudo apt-get install python-dev
    ./configure
    sudo make swig-py
    sudo make install-swig-py

> **Upd.:** По возможности не обращайте внимания на warning’и при установке - насчет redefin’ов - на них установлена пауза дабы вы с ними ознакомились, но она кончается :))

Установим ссылки на установленные модули так, чтобы они были видны питону.

    cd /usr/local/lib/python2.4/site-packages
    sudo ln -s /usr/local/lib/svn-python/libsvn
    sudo ln -s /usr/local/lib/svn-python/svn

Установим модуль `pysqlite`, чтобы `trac` мог работать со своей базой данных.

    sudo apt-get install python-pysqlite2

Ввиду новых изменений переустановим `trac`.

    cd /home/some-user/distr/trac-0.10.3
    sudo python setup.py install

Теперь нужно установить `clearsilver` - чтобы `trac` мог использовать шаблоны для страниц. Этот пакет тоже пришлось [забирать](http://www.clearsilver.net/downloads/clearsilver-0.10.4.tar.gz) [из сети](http://www.clearsilver.net/downloads/) и собирать тут же.

    cd /home/some-user/distr
    tar xvfz clearsilver_0.10.3.orig.tar.gz
    cd ./clearsilver_0.10.3.orig
    ./configure
    make
    sudo make install

Наконец, создадим каталог для репозитория `subversion` и базовую структуру для него в каталоге `/tmp`.

    sudo mkdir /var/svn
    cd /tmp
    sudo rm -rfR *
    sudo rm -rfR .*
    sudo mkdir /tmp/trunk
    sudo mkdir /tmp/tags
    sudo mkdir /tmp/branches

А теперь начинаются вещи, которые чаще всего генерируют проблемы. Будьте внимательны - в командах я еще мог ошибиться, но мои пояснения верны просто потому что пол-дня были потрачены именно на их решение, а потом еще меня проконсультировал действующий админ и друг (за что ему, конечно же, благодарность и которого, конечно же, я мог понять неверно и переврать :) ).

Более того, вся настройка ниже имеет условие - “используется только один репозиторий для создаваемого проекта”. Пояснения - ниже. (_а еще лучше - по поводу нескольких репозиториев - см. в **Upd.** внизу - тут тоже я, в принципе, не вру - но там об этом корректнее_).

Используя `svnadmin` инициализируем репозиторий в соответствующей папке. Опция `–pre-1.4-compatible` необходима, если при установке без нее `apache` стал выдавать в логах нечто вроде “_в `/var/svn/SomeTracProject/format` ожидалась версия 3, а обнаружена была версия 5_″. Это конфликт разных версий модуля для Если вы используете точно такую же систему что и я (а именно если вы не исправляли ничего в `/etc/apt/sources.conf` и никто не выкладывал со времени моего поста новых версий пакетов :) ) и в точности следуете моим командам - то если вы не установите эту опцию - точно так и получится. В остальных случаях бросьте монету, протестируйте - пересоздать репозиторий никогда не поздно (закоммитить удаленно в неработающий все равно не получится :) ). Только потом, если вы уже создали окружение для trac - не забудьте потом сделать `sudo trac-admin /var/trac/SomeTracProject resync`

Затем импортируем структуру из `/tmp` в репозиторий `svn` и допускаем туда `apache`...

    sudo svnadmin create –pre-1.4-compatible /var/svn/SomeTracProject
    cd /tmp
    sudo svn import . file:///var/svn/SomeTracProject -m “Initial import”
    sudo chown -R www-data:www-data /var/svn/SomeTracProject

Как вариант, можно создать репозиторий в файловой системе FSFS, тогда делайте: `sudo svnadmin create -pre-1.4-compatible -fs-type=fsfs /var/svn/SomeTracProject`.

Настало время инициировать окружение Trac. Отвечайте на вопросы честно, если не знаете ответа -- по умолчанию. На вопрос про тип системы контроля версий ответьте ’`svn`’, а на вопрос про положение репозитория - ‘`/var/svn/SomeTracProject`’.

    sudo trac-admin SomeTracProject initenv

И в этот каталог `apache` тоже должен иметь доступ.

    sudo chown -R www-data /var/trac/SomeTracProject

Каким образом - апачу нужно объяснить:

    sudo vi /etc/apache2/sites-available/trac

Вставьте в этот файл следующий текст (после последнего `</Location>`):

``` { apache }

<Location /trac.cgi/*/login>
    AuthType Basic
    AuthName "Trac"
    AuthUserFile /etc/apache2/dav_svn.passwd
    Require valid-user
</Location>

```

Кратко - это настройка аутентификации для страницы логина. В качестве источника пользователей и `md5`-хешей-паролей используется файл `/etc/apache2/dav_svn.passw`, который мы создадим попозже.

А пока - настроим удаленный доступ к репозиторию. Здесь надо остановиться и вдохнуть. Будьте внимательны.

    sudo vi /etc/apache2/mods-available/dav_svn.conf

Ниже приведена конфигурация для доступа к одному репозиторию, если он подразумевается как единственный!

Если вы хотите настроить доступ к нескольким репозитроиям, все происходит совсем по-другому. Во-первых можно выделить как `<Location>` сам каталог `/svn`, тогда для него надо задать - ‘`SVNPath /var/svn`’ и настраивать корректно аутентификацию в `authz`-файле (смотрите ниже). Если же вы настраиваете `Location`‘ы для репозиториев со своими (отдельными) файлами авторизации (только тогда это оправдано), для ‘`Location /svn`’ следует указать вместо ‘`SVNPath`’ - ‘`SVNParentPath /var/svn`’, а для `Location`‘ов репозиториев указывать относительные пути, например: ‘`SVNPath /SomeTracProject`’. _(подробнее см. в **Upd.** ниже)_.

В любом случае, если у вас в логах вылезают ошибки типа ‘`Unknown/Incorrect SVN FileSystem`’ - ошибку следует искать именно здесь, конкретно в `SVN[Parent]Path`. Причины же неожиданных `Forbidden`, конечно, кроются в неверных `Location`‘ах и, соответственно, аутентификации. Отключайте ее, проверяйте `Location`. Потом авторизацию. Впрочем, если вы осознали (а я хорошо объяснил) предыдущий абзац, то этих ошибок у вас вылезти не должно. Поговорив с я бы уже сделал все немного по-другому (смотрите ниже описание аутентификации), но в этом варианте уже все проверено и работает, а наугад писать опасно.

``` { apache }

<Location /svn>
    DAV svn
    SVNPath /var/svn/SomeTracProject
    AuthType Basic
    AuthName "Subversion Repository"
    AuthUserFile /etc/apache2/dav_svn.passwd
    #AuthSVNAccessFile /etc/apache2/dav_svn.authz
    Require valid-user
</Location>

```

Создадим файл паролей и добавим туда пользователей (внимание: опция `-c` не нужна во втором случае - она создает/перезаписывает файл без предупреждения)

    sudo htpasswd2 -c /etc/apache2/dav_svn.passwd user1
    sudo htpasswd2 /etc/apache2/dav_svn.passwd user2

Установим первому пользователю права администратора в Trac’е.

    sudo trac-admin /var/trac/SomeTracProject permission add user1 TRAC_ADMIN

Чтобы прочувствовать эти права на себе, можно поставить плагин [TracWebAdmin](http://trac.edgewall.org/wiki/WebAdmin) - он добавляет удобную админскую GUI-страничку в Trac:

    wget http://peak.telecommunity.com/dist/ez_setup.py
    sudo python ez_setup.py
    wget http://trac.edgewall.org/attachment/wiki/WebAdmin/TracWebAdmin-0.1.2dev_r4240 py2.4.egg.zip?format=raw
    mv TracWebAdmin-0.1.2dev_r4240-py2.4.egg.zip\?format\=raw TracWebAdmin.egg
    sudo easy_install TracWebAdmin.egg

В конфигурации проекта включите этот плагин.

    sudo vi /var/trac/SomeTracProject/conf/trac.ini

Вставьте:

    [components]
    webadmin.*=enabled

Теперь добавим авторизацию для проектов в subversion.

    sudo vi /etc/apache2/mods-available/dav_svn.conf

Раскомментируйте ‘`AuthSVNAccessFile /etc/apache2/dav_svn.authz`’.

Структура файла авторизации проста: пути, пользователи и права (`r` - чтение, `w` - запись):

    sudo vi /etc/apache2/dav_svn.authz

Вставьте:

    [/]
    user1 = rw
    user2 = r

Если бы вы указали в файле `/etc/apache2/mods-enabled/dav_svn.conf` ‘`SVNParentPath /var/svn`’, то файл аутентификации должен бы был выглядеть как-нибудь так (и это верный вариант для репозиториев с несколькими проектами):

    [/SomeTracProject]
    user1 = rw
    user2 = r

    [/AnotherTracProject]
    user1 = rw
    user2 = r

Ну и наконец перезапустим сервер (а если что-нибудь до сих пор не работает - машину :)) )

    sudo /etc/init.d/apache2 restart

…На следующей неделе я буду устанавливать `Timing` для Trac’а (тикет получает такое понятие как `estimation` + фактическое время за которое он был сделан, `milestone` позволяет сложить все это время в часы, в комментах к ревизиям можно писать за сколько времени был выполнен тикет (часть тикета) и время автоматически просуммируется) - и если будет возможность и все пройдет удачно (это `diff` для версии 0.10), опишу здесь и этот процесс.

> **Upd.:**

> _Первое._ По поводу нескольких окружений и связанных с ними репозиториях. Легче всего - забить на отдельные репозитории для окружений и сделать (кстати имхо это и для одного проекта неплохой вариант)

> `sudo svnadmin create –pre-1.4-compatible /var/svn/` (опция `compatible` обязательна есть только у вас апач ругается на формат в файле `/var/svn/FORMAT`)

> Затем в `/tmp/` (очистив его предварительно :) ) `mkdir`-ом построить структуру “по одному каталогу для каждого проекта”. А в каждом из этих каталогов сделать, соответственно, свои `trunk`-`tags`-`branches`. Затем сделать

>     cd /tmp
>     sudo svn import . file:///var/svn/ -m “Initial import”

> В `/etc/apache2/mods-enabled/dav_svn.conf` указать:

>     <Location /svn>
>         DAV svn
>         SVNPath /var/svn/
>         AuthType Basic
>         AuthName "Subversion Repository"
>         AuthUserFile /etc/apache2/dav_svn.passwd
>         AuthSVNAccessFile /etc/apache2/dav_svn.authz
>         Require valid-user
>     </Location>

> и убрать ненужные `Location`’ы (подкаталоги `svn`’а), если они там есть.

> А вот уже в файле аутентификации `/etc/apache2/dav_svn.authz` мы прописываем права на проекты:

>     [/]
>     megaroot = rw
>
>     [/SomeProject]
>     user1 = rw
>     user2 = r

>     [/AnotherProject]
>     user1 = rw
>     user2 = r

> При создании окружений в `trac-admin`, мы в пути к репозиторию, соответственно, указываем `/var/svn/SomeProject`

> Теперь можно возвращаться и читать про `htpasswd` и `TracWebAdmin`. Больше ничего не надо. А, хотя нет - потом вернитесь и прочитайте пункт ///Треть/е. Я расскажу про то, что делать, когда уже все поставлено.

> _Второе._ [Timing](http://trac.edgewall.org/wiki/TimeTracking) устанавливается точно так, как указано в рководстве, так что пояснений я делать не буду :). Остальные основные плагины ([авторизация формой/аккаунты](http://trac-hacks.org/wiki/AccountManagerPlugin), [форумы](http://trac-hacks.org/wiki/DiscussionPlugin) и [бла-бла-бла](http://trac-hacks.org/wiki/WikiGoodiesPlugin)) прикручиваются еще легче -- сборкой

>     python setup.py bdist_egg

> из распакованных сурсов, взятием из каталога `dist` результирующего яйца (`.egg`, прошу не обижаться - это почти что питоновский почти что аналог почти что `.jar`-ов) и укладкой его в каталог `plugins` окружения `trac`’a (не забываем про права `www-data`) (+ прописывание плагина в `trac.ini` окружения, как указано в описании или включение его в админке) . (для плагина с авторизацией в `/etc/apache2/sites-enabled/trac` надо закомментить весь `Location trac.cgi/*/login`, выключить траковский `LoginModule` и включить `LoginModule` из этого плагина, указать ему на `/etc/apache/dav_svn.passwd` и затем рестартовать апач).

> Сложнее с плагином [Graphviz](http://trac-hacks.org/wiki/GraphvizPlugin), так что если он действительно нужен и никак его не поставить - пишите мне. Но думаю если вы справились со всем предыдущим - у вас и здесь все пройдет на ура :).

> _Третье._ Когда нужно создать новый проект уже после того как все поставлено (а то и через некоторое время) - все просто. Пользователю `megaroot` (см. `/etc/apache2/dav_svn.authz`) закоммитить в `/var/svn/` каталог с этим проектом (+ `trunk`-`tags`-`branches`).

> Затем:

> `sudo trac-admin /var/trac/NewProject initenv` (в пути к subversion указываем `/var/svn/NewProject`)

>     sudo chown -R www-data:www-data /var/trac/NewProject

> Теперь надо настроить аутентификацию, делаем:

>     sudo vi /etc/apache2/dav_svn.authz

>     Жмем `Insert` и вставляем в конец файла:

>     [/NewProject]
>     user1 = rw
>     user2 = r
>     megaroot = rw

> делаем `Esc/:wq` и…. все. Вот так - если все правильно настроено - делать нужно минимум.

> Насчет добавления пользователя. Добавлять его нужно только в `/etc/apache2/dav_svn.passwd` и никуда больше:

>     sudo htpasswd /etc/apache2/dav_svn.passwd new_user

> И если у вас все правильно настроено - примет его корректно и trac, и subversion.

> Ах, ну да, для subversion его нужно еще пустить в проект :):

>     sudo vi /etc/apache2/dav_svn.authz

> Вставляем в нужный проект:

>     [/SomeProject]
>     user1 = rw
>     user2 = r
>     megaroot = rw
>     new_user = rw

Вот теперь точно все. Успехов :)

