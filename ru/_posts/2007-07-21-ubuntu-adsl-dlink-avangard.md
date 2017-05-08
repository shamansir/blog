---
layout: post.html
title: Ubuntu 7.04, Пыхтерский Авангард-ADSL, модем D-Link
datetime: 21 Jul 2007 18:44
tags: [ avangard, d-link, ubuntu ]
---

Вот она, первая статья о невечном :)

На самом деле статей в сети на эту тему много (ну либо они повествуют о настройке для веб-плюса – она схожа) – но результаты у всех разные – поэтому расскажу свою историю.

подопытные:

* [Ubuntu 7.40 Feisty Fawn](http://releases.ubuntu.com/7.04/)
* USB-модем [D-Link DSL-200 Generation III](http://eciadsl.flashtux.org/modems.php?modem=86)

дополнительные ссылки:

* [Как Starl1te настраивал Веб-плюс](http://starl1te.wordpress.com/%D0%A3%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0-%D0%BC%D0%BE%D0%B4%D0%B5%D0%BC%D0%B0-d-link-dsl-200/)
* [Беседа с человеком у которого однажды это всё-таки получилось](http://forum.ubuntu.ru/index.php?topic=8712.45)
* [Основной источник файлов](http://eciadsl.flashtux.org/)
* [Как это делают в Gentoo](http://ru.gentoo-wiki.com/ADSL_%D0%BC%D0%BE%D0%B4%D0%B5%D0%BC%D1%8B_%D0%BD%D0%B0_%D1%87%D0%B8%D0%BF%D0%B0%D1%85_GlobeSpan_(D-Link_DSL200))

> (дополнительные ссылки также есть в конце статьи)

Итак, Live/Install CD [был скачан](http://releases.ubuntu.com/7.04/) из интернета, прожжен на болванку и установлен буквально за 10-15 минут, чем Ubuntu и славится. практически все что нужно обнаружилось и отдетектилось сразу, за исключением собственно интернета :). сразу говорю, четких рекомендаций как не было так и нет, насколько я понял у большинства все “_как-то вышло_” и вполне может быть так, что мой или чей-то способ может не подойти. у меня, например, интернет пока что подключается раза с пятого, но хотя бы уже до отключения руками, поэтому я стараюсь не перезагружаться :). если я найду способы улучшения ситуации – я напишу.

Впрочем, меньше прелюдий – беремся за терминал. Вернее, лучше заранее достать где-нибудь интернет и скачать вот эту пару файлов: :).

* [ECI-ADSL с патчем синхронизации](http://eciadsl.flashtux.org/download/debian/etch/eciadsl-usermode_0.11-1_i386_with_synch_patch.deb ) (**Upd.** [альтернативная ссылка](http://shaman-sir.by.ru/files/eciadsl-usermode_0.11-1_i386_with_synch_patch.deb))
* [утилита PPPoE](http://debian.charite.de/ubuntu/pool/universe/r/rp-pppoe/pppoe_3.8-1.1_i386.deb) (или [тут](http://ftp.cica.es/debian/pool/main/r/rp-pppoe/pppoe_3.8-1.1_i386.deb))
* [файлы синхронизации](http://eciadsl.flashtux.org/download/eciadsl-synch_bin.tar.bz2 ) (**Upd.** [альтернативная ссылка](http://shaman-sir.by.ru/files/eciadsl-usermode-0.11-synch-patch.tar.bz2))

С этого момента мы считаем что вы находитесь в той директории, куда вы положили эти файлы, например `~/Downloads`:

    $ cd ~/Downloads

Одно магическое действие, которое вам скорее всего понадобится для корректной работы `eciadsl` – смена среды. Честно говоря я не успел посмотреть что там было до этого, потому что в `bash` я не сомневаюсь(лся?), но вероятнее всего на то, как было, если вам будет надо – можно будет запросто вернуть командой `sudo ln -sf /bin/dash /bin/sh`:

    $ sudo ln sf /bin/bash /bin/sh

устанавливаем пакеты:

    $ sudo dpkg -i ./pppoe_3.8-1.1_i386.deb
    $ sudo dpkg -i ./eciadsl-usermode_0.11-1_i386_with_sync_patch.deb

распаковываем дополнительные файлы синхронизации и переносим их в каталог `eciadsl`:

    $ bzip2 -d ./eciadsl-synch_bin.tar.bz2
    $ tar -xvf ./eciadsl-synch_bin.tar
    $ sudo mv ./eciadsl-synch_bin/*.bin /etc/eciadsl/
    $ rm -Rf ./eciadsl-synch_bin

далее, нужно проверить выгружен ли модуль `dabusb`, который по идее и не должен быть загружен – в ранних версиях он приводил к ошибкам.

    $ sudo lsmod | grep dabusb

и если он все-таки найдется – надо его убить, вот так: :)

    $ sudo modprobe -r dabsusb

теперь включаем нужные модули:

    $ sudo modprobe tun
    $ sudo lsmod | grep tun
    $ sudo modprobe n_hdlc
    $ sudo lsmod | grep n_hdlc

сейчас нам нужно узнать _VID/PID_ нашего момеда (насколько я себе представил –- это код USB-порта на материнской плате, но истинным знанием я временно не обладаю).

    $ lsusb

там должно быть либо _D-Link_ либо _GlobeSpan_, либо какой-то еще вариант (если что можно выяснить отключив модем, выполнив `lsusb` и подключив снова) –- у меня мой модем был в этой строчке:

`Bus 004 Device 006: ID` _`0915:8104`_ `GlobeSpan, Inc.`

выделенные курсивом числа – и есть _VID:PID_ – запомните их. Настало время приступить к конфигурации. можно запустить текстовую версию и следовать указаниям (пояснения ниже):

    $ sudo eciadsl-config-text

для Авангард-ADSL настройки (примерно :) ) таковы (номера пунктов могут отличаться):

* (1) configure all settings
* _юзернейм/пароль_: _ptn_/_ptn_
* _provider_: (58) Other
* _DNS1_: `213.158.0.6`
* _DNS2_: `213.48.193.36` (на июль 2007 они таковы, в будущем могут потенциально поменяться – следите за новостями Авангарда)
* _VPI_: `0`
* _VCI_: `35`
* _modem_: (16) D-Link DSL200 B1 (засисит от модели вашего модема, но у меня кажется не B и работает и я побаиваюсь пока все нестабильно но работает тестировать другие варианты :) )
* _VID1_: `__0915__` (первое число из двух, которые показала команда `lsusb`)
* _PID1_: `__8104__` (второе число из двух, которые показала команда `lsusb`)
* _VID2_: `__0915__` (первое число из двух, которые показала команда `lsusb`)
* _PID2_: `__8104__` (второе число из двух, которые показала команда `lsusb`)
* _chipset_: (3) `GS7470`
* _SYNCH_: `0` (этот пункт и следующий пункты люди часто ставят наугад, я тоже пишу как работает у меня и не знаю почему я это ставил :) )
* _PPPOECI_: `4`
* _`.bin`_ `file`: (18) `/etc/eciadsl/gs7470_synch20.bin` (очень важный пункт, на сайте Авангарда пишут использовать именно этот файл , но если у вас все еще будут проблемы с синхронизацией – нужно будет перебрать все по одному а в самом худшем случае – собирать свой)
* _PPP Mode_: (5) `LLC_SNAP_RFC1483_BRIDGED_ETH_NO_FCS` (еще используют `LLC_RFC1483_ROUTED_IP`)
* _DHCP_: no
* __Static IP_: no (по дефолту у Авангарда динамический IP, но если у вас статический за денюжку то наверное стоит поставить yes :) )

ниже я приведу сам файл `/etc/eciadsl/eciadsl.conf`, который и изменяет эта утилита –- в том состоянии, в каком он у меня.

далее –- запускаем собственно синхронизацию:

    $ sudo eciadsl-start

тут могут обнаружиться самые обидные проблемы – если будут ошибки про _interrupt_ы – значит вместо первого файла установлена версия без патча синхронизации и вы меня не слушаетесь :). В моем случае тоже не всё гладко - первые разы после удачной синхронизации гаснут обе лампочки на модеме, а среди карт/интерфейсов отстутствует `tap0`:

    $ ifconfig

но раз на пятый-десятый лампочки все-таки не гаснут и тогда хорошо. По этим причинам я поставил скрипт на автозагрузку, но о нем - ниже. Если уж совсем много раз не выходит –- что-то не чисто –- проверять настройки и файлы синхронизации. Вам нужно добиться чтобы лампочки не гасли :). После этого - набрать:

    $ sudo pppoeconf

это собственно конфигурация `PPPoE`. Утилита должна найти инет на интерфейсе `tap0` и задавать диалогами вопросы и просьбы, среди которых попросят ввести пароль/юзернейм снова, а на все остальные - отвечать разумно, чаще всего – “да” :).

после этого можно попытаться подключиться:

    $ sudo pppoe-start

и если не `TIMED OUT` а `CONNECT OK` то все замечательно :).
желаю чтобы у вас так и было :).

_P.S. Статья будет исправляться и дополняться_

#### Пояснения: ####

теперь по поводу гаснущих лампочек. я взял [скрипт starl1t‘а](http://starl1te.wordpress.com/%D0%A3%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0-%D0%BC%D0%BE%D0%B4%D0%B5%D0%BC%D0%B0-d-link-dsl-200/#comment-52), чуток исправил, добавив `pppoe-start` и выставил его в автозагрузку:

``` bash

#!/bin/bash

# This is an improved eciadsl launch script, which
# tries to connect after failures until success.
# Feel free to share and modify
# by Starlite

case "$1" in
	start)
		sudo eciadsl-start
		result=$?
		#echo 'exit code:' $result
		until [ $result -eq 0 ]
		do
			echo ‘Error: connection failed’
			sudo eciadsl-stop
			sudo eciadsl-start
			result=$?
		#	echo ‘exit code:’ $result
		done
		echo ‘connection established’
		sudo pppoe-start
		exit $?
		;;
	stop)
		sudo eciadsl-stop
		exit $?
		;;
	restart|force-reload)
		$0 stop && $0 start
		exit $?
		;;
	*)
		echo ‘Usage: eciadsl {start|stop|restart}’
		exit 1
		;;
esac
exit 0

```

потом - ставим его на автозагрузку:

    $ sudo chmod +x /etc/init.d/eciadsl
    $ update-rc.d eciadsl defaults

если нужно - можно запускать его самостоятельно:

    $ sudo /etc/init.d/eciadsl restart

#### Тексты: ####

##### /etc/eciadsl/eciadsl.conf #####

```

VID1=0915
PID1=8104
VID2=0915
PID2=8104
#MODE=LLC_RFC1483_ROUTED_IP
MODE=LLC_SNAP_RFC1483_BRIDGED_ETH_NO_FCS
VCI=35
VPI=0
FIRMWARE=/etc/eciadsl/firmware00.bin
SYNCH=/etc/eciadsl/gs7470_synch20.bin
PPPD_USER=ptn
PPPD_PASSWD=
USE_DHCP=no
USE_STATICIP=no
STATICIP=
GATEWAY=
MODEM=D-Link DSL200 rev B1
MODEM_CHIPSET=GS7470
SYNCH_ALTIFACE=0
PPPOECI_ALTIFACE=1
PROVIDER=Other
DNS1=213.158.0.6
DNS2=213.18.193.36

```

##### /etc/ppp/pppoe.conf #####

```

ETH='tap0'
USER='ptn'
DEMAND=no
#DEMAND=300
DNSTYPE=SERVER
PEERDNS=yes
DNS1=
DNS2=
DEFAULTROUTE=yes
CONNECT_TIMEOUT=30
CONNECT_POLL=2
ACNAME=
SERVICENAME=
PING="."
CF_BASE=`basename $CONFIG`
PIDFILE="/var/run/$CF_BASE-pppoe.pid"
SYNCHRONOUS=no
#SYNCHRONOUS=yes
CLAMPMSS=1412
#CLAMPMSS=100
#CLAMPMSS=no
LCP_INTERVAL=20
LCP_FAILURE=3
#LCP_FAILURE=30
PPPOE_TIMEOUT=80
FIREWALL=NONE
LINUX_PLUGIN=
PPPOE_EXTRA=""
PPPD_EXTRA=""

```

#### Примечания: ####

----

_от человека, настраивавшего модем ZTE ZXDSL 852, добавляю:_

> Для модема ZTE ZXDSL 852 нужно еще (кроме драйвера `cxacru.ko`) втыкать мост `ATM` <-> `ETHERNET` (`PPPoA` <-> `PPPoE`), а для этого ставить драйвер `br2648.ko` и настраивать через контрольную утилиту `br2684ctl` (должна входить в пакет `linux-atm-lib` - если нет - можно взять с [linux-atm.sourceforge.net](http://linux-atm.sourceforge.net/)).

К сожалению ссылка на руководство по сборке файла синхронизации руками -- периодически умирает :( , если так произошло -- эту статью можно [найти](http://www.linuxup.ru/index.php?id=99) на [LinuxUp.Ru](http://www.linuxup.ru) ([версия для печати](http://www.linuxup.ru/print.php?id=99) и [первая часть статьи](http://www.linuxup.ru/index.php?id=100)) или, в [pdf-версии](http://linux.yaroslavl.ru/docs/conf/hardware/FlashCode.pdf) на [linux.yaroslavl.ru](http://linux.yaroslavl.ru) ([HTML-версия](http://64.233.183.104/search?q=cache:CIYtpkx9cj0J:linux.yaroslavl.ru/docs/conf/hardware/FlashCode.pdf+%D0%A0%D1%83%D0%BA%D0%BE%D0%B2%D0%BE%D0%B4%D1%81%D1%82%D0%B2%D0%BE+%D0%BF%D0%BE+%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B5+EciAdsl+%D0%B4%D1%80%D0%B0%D0%B9%D0%B2%D0%B5%D1%80%D0%B0&hl=ru&ct=clnk&cd=1&gl=ru)).

И, нашлась еще одна очень неплохая ссылка на [настройку этого дела в Gentoo](http://www.gentoo.ru/?q=node/807), с использованием ATM. (И еще [вот](http://ru.gentoo-wiki.com/ADSL_%D0%BC%D0%BE%D0%B4%D0%B5%D0%BC%D1%8B_%D0%BD%D0%B0_%D1%87%D0%B8%D0%BF%D0%B0%D1%85_GlobeSpan_(D-Link_DSL200)) -- о том же но по-другому). И, плюс - [ADSL@Ubuntu & модем ACORP](http://f0x.ru/wiki/29/249_%CD%E0%F1%F2%F0%EE%E9%EA%E0_Acorp_Sprinter@ADSL_USB_%EF%EE%E4_Ubuntu).

----

Для полноты картины нужно на [установку Acorp Sprinter](http://forum.runtu.org/index.php?topic=260.0) дать ссылку. Там разобрались по-своему.

----

Будьте внимательны!

На сайте [eciadsl](http://eciadsl.flashtux.org/) убрали версию с патчем синхронизации. Временно я выложил ее [на rapidshare.com](http://rapidshare.com/files/67709667/eciadsl-synch_bin.tar.html) и на на [rapidshare.ru](http://www.rapidshare.ru/456097). Также могу выслать по почте. Если есть информация, работает ли схема с новой версией (по слухам - не работает и других схем нет) - прошу поделиться :) .

**Upd.** [Здесь](http://forum.ubuntu.ru/index.php?topic=14502.0) у человека возникла проблема с новым драйвером eciadsl 0.12 на ubuntu 7.10.

И вообще - с опытом выясняется, что модемы D-Link-200 - из ряда тех вещей, которые если уж достались - то лучше их сразу поменять.

----

А [вот тут](http://forum.ubuntu.ru/index.php?topic=14502.msg112057#msg112057) - про дружбу Ubuntu 7.10 на AMD64, DLink-модема и Авангард ADSL.

----

Ещё раз выкладываю eciadsl-0.11, (в том комменте зачем-то выложил файлы синхронизации):[.tar.bz2](http://rapidshare.com/files/77521022/eciadsl-usermode-0.11-synch-patch.tar.bz2.html), [.deb](http://rapidshare.com/files/77521743/eciadsl-usermode_0.11-1_i386_with_synch_patch.deb.html)

[Здесь](http://forum.stream.uz/index.php?s=&showtopic=5085&view=findpost&p=340627) человек настроил всё на 7.10/eciadsl0.10 и довольно подробно описывает (и там же раньше подробное описание [для Gentoo](http://forum.stream.uz/index.php?s=&showtopic=5085&view=findpost&p=230190) + решения некоторых проблем).

Сейчас работаю над установкой на 7.04 с ADSL-модемом ZyXEL omni P-630S EE и eciadsl 0.12.

Отметки:

- действительно, дефолтовый шелл -- `dash`
- утилита конфигурации `eliadsl-config-text` для 0.11 почему-то вылетала на вводе логина/пароля ошибку скрипта, поэтому повесил 0.12.
- 0.12 выпадает с ошибкой `double free or courruption` на этапе синхронизации, теоретические решения из инета: поставить 0.10 из сурсов, скомпилить 0.12 из сурсов, [использовать патч](http://eciadsl.flashtux.org/forum/viewtopic.php?t=3344 ) (логин/пароль: `eciadsl`/`eciadsl`), [выбрать `RFC_2364`](http://eciadsl.flashtux.org/forum/viewtopic.php?t=3358), проверить все файлы синхронизации…

----

_от Анонима:_

Поясню
VID - vendor id
PID - product id

alt интерфейсы сейчас указаны на flashtux для каждого модема
