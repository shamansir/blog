---
layout: post.html
title: "Trac + Subversion @ Ubuntu: Revisited"
datetime: 17 Mar 2008 03:12
tags: [ trac, subversion, ubuntu ]
---

### Задача

Установить на только что инсталлированный Ubuntu последнюю версию Trac, создать репозитории для нескольких проектов и настроить окружение соответственно. Структура проектов должна быть полностью корректной, установка максимально быстрой при минимальном количестве пакетов. Авторизация в репозитории и окружения Trac может быть общей, но позволяющей индивидуальную настройку для каждого проекта. Также, установка должна быть максимально независима от версий.

### Дано

**Upd.** _(12.11.2009)_ Сценарий работает и для новых версий Ubuntu/Debian, Python, Trac - заменив версии в ссылках на более новые, можно оставить всё остальное как есть. Устанавливать SQLite из исходников не обязательно, подойдёт и обычная установка через `sudo apt-get install sqlite3`.

* Ubuntu 7.04 _Feisty Fawn Herd_
* Trac 0.11b2
* Subversion 1.4.3
* Два пользователя: `user1` и `user2`
* Два проекта: `Some Project` и `Another Project`
* Требуется доступ в Trac и репозиторий по адресам `<host>/localProjects` и `<host>/svn` соотвественно

### Решение

#### Пункт 1. Установка базовых дистрибутивов, доступных в пакетах.

Для начала можно установить дистрибутивы, доступные в репозиториях Ubuntu в поддерживаемых версиях -- на данный момент это [Apache](http://apache.org/) 2.2.3, [Python](http://python.org/) 2.5.1 (необходим для работы trac), [Subversion](http://subversion.tigris.org/) 1.4.3 и [g++](http://gcc.gnu.org/) 4.1.2 (необходим для сборки sqlite). Установим, предварительно обновив данные о пакетах:

    sudo apt-get update
    sudo apt-get install python
    sudo apt-get install apache2
    sudo apt-get install subversion
    sudo apt-get install g++

#### Пункт 2. Установка sqlite.

Теперь необходимо собрать sqlite (легковесная база данных, в котрой будут хранится внутренние данные trac) — версия, находящая в репозитории (3.3.13) на данный момент меньше требуемой (3.3.4). Создадим каталог для временного хранения дистрибутивов и перейдём в него:

    mkdir ~/distr
    cd ~/distr

Скачаем [последнюю версию](http://www.sqlite.org/download.html) sqlite и установим:

    wget http://www.sqlite.org/sqlite-3.5.6.tar.gz
    tar -xvzf ./sqlite-3.5.6.tar.gz
    mv ./sqlite-3.5.6 ./sqlite # чтобы следовать букве README-руководства
    mkdir ./bld # временный каталог для скомпилированных файлов
    cd ./bld
    ../sqlite/configure
    make
    sudo make install
    cd ..
    rm -r ./bld

#### Пункт 3. Установка trac-related пакетов через easy_install.

Для Python существует утилита, облегчающая установку python-пакетов, называемых также _яйцами_ (они имеют расширение *.egg). Установим её:

    wget http://peak.telecommunity.com/dist/ez_setup.py
    sudo python ./ez_setup.py

И посредством неё установим последние версии [Pygments](http://pygments.org/) (0.9) (инструмент для подсветки программного кода на Python), [Genshi](http://genshi.edgewall.org/) (0.4.4) (механизм шаблонов от создателей trac) и собственно самого [trac](http://trac.edgewall.org/) (0.11b2):

    sudo easy_install Pygments
    sudo easy_install Genshi
    sudo easy_install Trac

Можно установить также `docutils` и `pytz`

#### Пункт 4. Создание репозиториев.

Создадим репозитории для наших проектов и сделаем первые коммиты, содержащие отправные точки для их структур. Все репозитории будут находиться в каталоге `/var/svn`, полностью доступном для сервера, каждый в своём подкаталоге -- такой метод удобен при наличии нескольких проектов и это будет заметно в следующем пункте, на этапе настройки авторизации.

    sudo mkdir /var/svn
    sudo mkdir /var/svn/someProject
    sudo mkdir /var/svn/anotherProject
    cd /tmp
    sudo rm -Rf * # удалить все обычные файлы
    sudo rm -Rf .* # удалить все скрытые/системные файлы
    sudo mkdir /tmp/someProject
    sudo mkdir /tmp/someProject/trunk
    sudo mkdir /tmp/someProject/tags
    sudo mkdir /tmp/someProject/branches
    sudo mkdir /tmp/anotherProject
    sudo mkdir /tmp/anotherProject/trunk
    sudo mkdir /tmp/anotherProject/tags
    sudo mkdir /tmp/anotherProject/branches
    sudo svnadmin create /var/svn/someProject
    sudo svn import ./someProject file:///var/svn/someProject \
        -m "Initial import"
    sudo svnadmin create /var/svn/anotherProject
    sudo svn import ./anotherProject file:///var/svn/anotherProject \
        -m "Initinal import"
    sudo chown -R www-data:www-data /var/svn

#### Пункт 5. Связывание apache и subversion.

Необходимо настроить доступ извне для созданных репозиториев. Для этого нужно установить модуль `dav_svn` для `apache2` и заодно, раз мы работаем с subversion, установим связку subversion c Python, для корректной работы trac с репозиториями:

    sudo apt-get install libapache2-svn
    sudo apt-get install python-subversion
    sudo /etc/init.d/apache2 restart

Теперь нужно настроить установленный модуль (при установки он автоматически включается для `apache`, если нет — используйте `a2enmod dav_svn` по завершению настройки):

    sudo cp /etc/apache2/mods-available/dav_svn.conf /etc/apache2/mods-available/dav_svn.conf.bak
    sudo vi /etc/apache2/mods-available/dav_svn.conf

Ниже приведено точное содержимое конфигурационного файла. При обращении на путь `<host>/svn/...` модуль авторизации apache будет обращаться к файлу `/etc/apache2/dav_svn.passwd` за списком пользователей, а затем давать права на доступ к соответствующему проекту из файла `/etc/apache2/dav_svn.authz`. Обратите также внимание на использование `SVNParentPath` вместо `SVNPath` -- таким образом subversion-модуль поймёт, что мы используем мультипроектную структуру и будет обрабатывать путь не как один общий репозиторий, а как несколько внутренних:

``` apache

<Location /svn>
    DAV svn
    SVNParentPath /var/svn
    AuthType Basic
    AuthName "Subversion Repository"
    AuthUserFile /etc/apache2/dav_svn.passwd
    AuthzSVNAccessFile /etc/apache2/dav_svn.authz
    Require valid-user
</Location>

```

Создадим соответствующих пользователей в файлах авторизации. Используйте пароли попроще для проверки и не забудьте их потом поменять:

    sudo htpasswd -c /etc/apache2/dav_svn.passwd user1
    sudo htpasswd /etc/apache2/dav_svn.passwd user2

Создадим файл аутентификации:

    sudo vi /etc/apache2/dav_svn.authz

В открытым файле опишем права доступа (на чтение -- “`r`” и на запись -- “`w`“) пользователей в соответствующие репозитории:

``` ini

[/]
user1=r
user2=r

[/someProject]
user1=rw
user2=r

[/anotherProject]
user1=r
user2=rw

```

#### Пункт 6. Создание окружений trac.

Создадим каталог, в котором будут находиться окружения для соответствующих проектов.

    sudo mkdir /var/trac
    cd /var/trac

Теперь создадим для каждого из них, по очереди, окружение:

    sudo trac-admin someProject initenv
    sudo trac-admin anotherProject initenv

Имена проектов остаются на ваше усмотрение, тип репозиториев -- по умолчанию `svn` (просто нажать Enter), путь к базе общий, по умолчанию (`sqlite:db/trac.db`, аналогично), пути к репозиториям: `/var/svn/someProject` и `/var/svn/anotherProject` соответственно.

Дадим права apache пользоваться этим каталогом.

    sudo chown -R www-data:www-data /var/trac

#### Пункт 7. Связывание apache и trac.

Есть несколько вариантов такого связывания, мы остановимся на быстром, но надёжном способе -- через `mod_python` ([описания способов](http://trac.edgewall.org/wiki/TracInstall#WebServer) на сайте trac). Для этого модуль нужно установить (также, если он не включился после установки, по завершению настройки используйте `a2enmod mod_python`):

    sudo apt-get install libapache2-mod-python

Настроим доступ к окружениям trac:

    sudo vi /etc/apache2/sites-available/trac

Эта настройка специфична для использования `mod_python` ([руководство](http://trac.edgewall.org/wiki/TracModPython) на сайте trac, см. [описания](http://trac.edgewall.org/wiki/TracInstall#WebServer), если необходимы другие способы настройки). Обработчиком обращений по адресу `<host>/localProjects` выступит модуль, он будет рассматривать каталог `/var/trac/` как корень нескольких проектов и содаст страницу с их списком (редактируемый шаблон можно найти внутри исходников trac), аналогично принципам `SVNParentPath`, `URI` передаётся в код trac. Запросы на вход будут обрабатываться по пользователям из того же `passwd` файла, из которого берёт их список subversion, а их права на действия в окружениях trac раздаются через `trac-admin` или в GUI-версии TracAdmin, доступной для аминистраторов окружений (будьте внимательны, пользователи создаваемые через интерфейс также добавляются в этот файл и доступны к использованию для настройки авторизации в subversion через `authz`-файл (по умолчанию у них нет никаких прав)) .

``` apache

<Location /localProjects>
   SetHandler mod_python
   PythonInterpreter main_interpreter
   PythonHandler trac.web.modpython_frontend
   PythonOption TracEnvParentDir /var/trac
   PythonOption TracUriRoot /localProjects
</Location>

<LocationMatch /localProjects/[^/]+/login>
   AuthType Basic
   AuthName “Local Projects”
   AuthUserFile /etc/apache2/dav_svn.passwd
   Require valid-user
</LocationMatch>

```

Теперь заменим сайт по умолчанию для apache на сайт trac:

    sudo a2dissite default
    sudo a2ensite trac

Дадим пользователям права администратов в окружениях trac, в соотвествии с правами на репозиторий, теперь у них, у каждого в своём проекте, будет веб-интерфейс для полной настройки trac.

    sudo trac-admin someProject permission add user1 TRAC_ADMIN
    sudo trac-admin anotherProject permission add user2 TRAC_ADMIN

### Заключение.

Осталось перезагрузить сервер, (принудительная перезагрузка настроек: `force-reload`) и проверить адреса `<host>/localProjects`, `<host>/svn/someProject` и `<host>/svn/anotherProject`, попробовав авторизироваться разными пользователями.

    sudo /etc/init.d/apache2 restart

Если при установке появились какие-либо проблемы и ничего не помогает, попробуйте ознакомиться с [предыдущей статьёй](?trac-subversion-ubuntu-initial) (но она несколько более сумбурна и менее структурирована) или опишите проблему(-мы) по почте -- постараюсь реагировать быстро.

### Примечания

#### Примечание A. О добавлении проектов.

Добавление проектов в будущем требует лишь нескольких шагов -- создание базовой структуры первым коммитом в какой-либо подкаталог `/var/svn`, опциональное добавление новых пользователей в `htpasswd`-файл, настройка прав доступа в `authz`-файле, создание окружения trac в соответствующем подкталоге `/var/trac` через `trac initenv`, опциональная выдача trac-прав новым пользователям и проверка, что apache имеет доступ к созданным каталогам.

#### Примечание Б. SSL и виртуальные хосты

Для работы с SSL достаточно включить модуль `ssl` для `apache`:

    sudo a2enmod ssl

Для того, чтобы закрыть доступ в `svn` по `http`, нужно обратно закомментировать все строки в `/etc/apache2/mods-available/dav_svn.conf` или вернуть забекапленную версию:

    sudo cp -f /etc/apache2/mods-available/dav_svn.conf.bak /etc/apache2/mods-available/dav_svn.conf

Теперь настроим виртуальные хосты для `subversion` и `trac`:

    sudo vi /etc/apache2/sites-available/svn

В нём:

``` apache

<VirtualHost acme.org:796>
    ServerName svn.acme.org
    <Location />
        DAV svn
        SVNParentPath /var/svn
        AuthType Basic
        AuthName "Subversion Repository"
        AuthUserFile /etc/apache2/dav_svn.passwd
        AuthzSVNAccessFile /etc/apache2/dav_svn.authz
        Require valid-user
    </Location>
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
</VirtualHost>

```

Trac:

    sudo vi /etc/apache2/sites-available/trac

В нём:

``` apache

<VirtualHost acme.org:967>
    ServerName trac.acme.org

    <Location />
        SetHandler mod_python
        PythonInterpreter main_intepreter
        PythonHandler trac.web.modpython_frontend
        PythonOption TracEnvParentDir /var/trac
        PythonOption TracUriRoot /
    </Location>

    <LocationMatch /[^/]+/login>
        AuthType Basic
        AuthName "Local Projects"
        AuthUserFile /etc/apache2/dav_svn.passwd
        Require valid-user
    </LocationMatch>
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
</VirtualHost>

```

Замените `acme.org` на имя вашего хоста, `796` и `967` на необходимый вам порт для `svn` и `trac` соответственно, и при необходимости укажите свой собственный сертификат/ключ.

Указанные вами порты необходимо добавить в `/etc/apache2/ports.conf`:

    sudo vi /etc/apache2/ports.conf

``` apache

...
NameVirtualHost *:80
Listen 80
Listen 443
# svn.acme.org
Listen 796
# trac.acme.org
Listen 967

```

Наступило время включить модуль `svn` и перезапустить `apache`:

    sudo a2ensite svn
    sudo /etc/init.d/apache2 restart

Теперь по адресам `https://svn.acme.org:796` и `https://trac.acme.org:967` должны быть доступны ваши `svn` и `trac`. Всё.

**Upd.** По мотивам этой статьи пользователь `MaroonOrg` создал [другую](http://maroonorg.wikidot.com/trac), где описал свою конфигурацию.
