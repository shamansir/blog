---
layout: post.html
title: Восстановление пароля в клиенте Psi (Python)
datetime: 06 Apr 2010 02:14
tags: [ psi, python ]
---

Часто требуется восстановить пароль от аккаунта в клиенте Psi. Для этого можно использовать любой язык программирования, см. [статью](http://blogmal.42.org/rev-eng/psi-password.story).

В случае выбора Python, надо (подставьте нужный номер в `/a<n>/` если у вас несколько аккаунтов):

    $ xpath -e '/accounts/accounts/a0/jid' ~/.psi/profiles/default/accounts.xml
    $ xpath -e '/accounts/accounts/a0/password' ~/.psi/profiles/default/accounts.xml

Найденное сопоставить и записать, например: `user@jabber.server 000100020003007e`, затем набросать питоновый скрипт:

    $ vim ./psi-recover.py

Вот такой:

``` python

import sys
u,p=sys.argv[1:3]
print "".join([chr(ord(u[x]) ^ eval("0x%s"%(p[4*x:4*x + 4]))) for x in xrange(len(p)/4)])

```

И запустить с этими параметрами:

    $ python ./psi-recover.py user@jabber.server 000100020003007e

That's all
