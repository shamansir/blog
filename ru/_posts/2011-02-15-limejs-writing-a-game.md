---
layout: post.html
title: "LimeJS: Пишем кроссплатформенную игру на HTML5 с поддержкой прикосновений"
datetime: 15 Feb 2011 22:10
tags: [ html5, javascript, limejs ]
---

[LimeJS](http://www.limejs.com) - 2D Open Source HTML5 движок для написания игр с поддержкой прикосновений и работающий (по описанию) на большинстве мобильных платформ. Я наткнулся на него не сам, мне прислали письмо с просьбой рассказать о нём сообществу и я решил, раз так - что уж мелочиться, надо попробовать его в деле. Кроме того, я заранее договорился с авторами движка, что буду честен - буду рассказывать и о достоинствах и о недостатках, так что надеюсь убрать из статьи ореол рекламы (хотя какая реклама может быть связана с open source)..?

_Open Source_, _кроссплатформенность_ и _HTML5_ - это то, что я люблю - инновации и свобода :). И ещё, сам движок написан на [Closure](http://code.google.com/closure/) и поддерживает _chaining_, это вносит дополнительные яркие цвета в свойства движка и программирование с его использованием. Конечно, необходимо ещё и удобство разработки игр само по себе, на что мы и испытаем LimeJS вместе с вами в этой статье. Движок преподносится как кроссплатформенный, на iPad'е представленные на сайте игры вполне себе работают, немного медленно, но вполне играбельно, ну а на моём Hero/Android2.1 (HTML5, наверное, неполный) они естественно подтормаживают и глючат - то есть буквально, играть в эти игры нельзя. Впрочем, практически все объекты в играх даже на смартфоне отображаются и действуют корректно, так что будем надеяться что с последующуей оптимизацией всё будет отлично даже на хилых смартфонах типа моего.

Движок, кстати, позиционируется как замена Flash-технологий в играх. Это болезненная тема для многих среди нас в связи с общим гноблением флэша, но при этом существующими и даже создающимися на нём отличными играми. (И, как я лично считаю, удобство самого механизма создания анимации в Flash пока ещё не повторено ни для HTML5/SVG ни для альтернатив). Так вот, может быть у этого движка действительно есть шанс завоевать любовь разработчиков на Flash и привить им любовь к HTML5. Решать им и вам. _Главное отличие_ [LimeJS](http://www.limejs.com) от, допустим, [ProcessingJS](http://processingjs.org/) - ориентировка не на машину состояний, не на обновление в каждом кадре, а на "таймлайн" - _событийность_ в сценарии игры.

Кстати, вот пример кода: [`javascript`](http://paste.pocoo.org/show/336927/) и [`html`](http://paste.pocoo.org/show/336929/) - чтобы вы могли сразу сделать какой-то вывод, а то я изначально относился к движку довольно скептически, а вот сейчас думаю, что наверняка зря.

### Что получится

В течении прочтения статьи мы напишем очень упрощённую версию пинг-понга на LimeJS. Вот так будет выглядеть результат:

![Мужчины в синих шортах на футбольном поле с детским мячиком]({{ get_figure(slug, 'stage-designed.png') }})

В конце статьи видео с демонстрацией написанной игры на iPad, iPhone и Android.

### Подготовка к разработке

У движка есть небольшой CLI, Command Line Interface. Он написан на Python и скачивает нужные пакеты с помощью `git`, поэтому для работы с движком нужно установить [Python](http://python.org/download/), [`git`](http://git-scm.com/download) и [`git-svn`](http://www.kernel.org/pub/software/scm/git/docs/git-svn.html) соответственно, если вдруг они не установлены (разработчикам с Windows видимо [придётся помучиться](http://stackoverflow.com/questions/350907/git-svn-on-windows-where-to-get-binaries)). Затем берём исходники [из github](http://github.com/digitalfruit/limejs) или [скачиваем zip](https://github.com/digitalfruit/limejs/zipball/master) и распаковываем. На Ubuntu это будет выглядеть примерно так:

    $ sudo apt-get install python git-core git-svn
    $ wget https://github.com/digitalfruit/limejs/zipball/master -no-check-certificate
    $ unzip ./master ./digitalfruit-limejs
    $ cd ./digitalfruit-limejs

Чтобы автоматически установить другие нужные для разработки пакеты (включая Closure), запускаем:

    $ ./bin/lime.py init

### Начинаем наш проект

    $ ./bin/lime.py create pingpong

Да, пусть это будет пинг-понг, подобный тому, который показывает Dominic в руководстве по [созданию игры на Impact HTML5 Engine](http://vimeo.com/17161851). Я потом обнаружил, что в [демо-исходниках](https://github.com/digitalfruit/limejs/tree/master/lime/demos/pong) есть что-то похожее, но пусть у нас будет намного более простой вариант.

В каталоге `pingpong` будут созданы файлы `pingpong.html` и `pingpong.js`. Откройте `.html` файл в браузере, он уже довольно интересен - в центре вы увидите симпатичный круг, который можно таскать по странице мышкой или пальцем. В `.js`-файле тоже много полезного - показано как создаётся сцена и видно, как организовывается слежение за событиями. Код остаётся при этом вполне понятным и читаемым. Я не буду разбирать его подробно, это всё-таки просто пример-заглушка, а ссылки по которым можно посмотреть его "нутро" я привёл в начале статьи.

### Основные классы и концепции

Краткое резюме [Programming guide](http://www.limejs.com/0-getting-started):

 * `Director` - это _режиссёр_ игры, он управляет переходами между сценами (включая анимацию переходов) и содержит основные настройки игры;
 * `Scene` - это сцена, отдельный _экран_ в игре, на него добавляются дочерние объекты и слои;
 * `Layer` - это _слой_, участки экрана удобно разделять/распределять на слои  и слои тоже могут быть контейнерами дочерних объектов. При этом они вполне могут перекрываться, как в фотошопе;
 * `ScheduleManager` - _планировщик_, помогает запускать определённые функции либо в каждом кадре, либо по прошествию указанного времени;
 * `Node` - любая _сущность_ в игре, имеет свою позицию, локальную систему координат и размер, может перемещаться, вращаться, масштабироваться и анимироваться;
 * `Sprite` - наследник `Node`, имеет все его свойства/способности и может представлять собой _изображение_ и/или _геометрический объект_ (от круга до любого полигона); спрайты можно отрезать друг от друга с использованием масок, заполнять градиентами и проверять на коллизии методом `hitTest`;

----

 - Движок ориентируется на таймлайн, а не на то что должно отображаться в текущем кадре;
 - Всё разнообразные события, связанные с контроллерами обрабатываются через механизмы Closure;
 - Анимации - переместить, масштабировать, вращать, пропасть - могут применяться и к одному объекту и к нескольким сразу и могут объединяться в цепочки (последовательные, одновременные, циклические);
 - Поддерживается `DOM`- и `Canvas`-рендеринг. `WebGL`-реднеринг планируется;
 - Если анимация применяется к DOM-эелемнту, она транслируется в CSS3-свойство;
 - Скрипты на выходе можно оптимизировать;
 - Есть класс `Audio` для проигрывания звука;

### Строим сцену

Оставим из переданной нам от разработчиков функции `pingpong.start` только несколько строк:

``` javascript

// entrypoint
pingpong.start = function(){

    var director = new lime.Director(document.body),
        scene = new lime.Scene();

    director.makeMobileWebAppCapable();

    // set current scene active
    director.replaceScene(scene);

}

```

Не забудьте убрать ненужные строки `goog.require`. Я не буду напоминать про это в дальнейшем, как должен будет выглядеть заголовок файла вы всегда сможете посмотреть в конце статьи. Добавим в сцену три слоя - фон `floor_`, стены `walls_` и доску, на которой будет происходить всё действие - `board_`:

``` javascript

var director = new lime.Director(document.body),
    scene = new lime.Scene(),

    floor_ = new lime.Layer().setPosition(0,0),
    walls_ = new lime.Layer().setPosition(0,0),
    board_ = new lime.Layer().setPosition(0,0);

scene.appendChild(floor_);
scene.appendChild(walls_);
scene.appendChild(board_);

. . .

```

#### Заготовка игрока

В отдельном файле `player.js` опишем класс игрока - это будет полигон в форме скейтборда (чтобы хорошо проверить как работают коллизии):

``` javascript

goog.provide('pingpong.Player');

goog.require('lime.Polygon');

pingpong.Player = function() {
    goog.base(this);

    // ... собираем полигон
}
goog.inherits(pingpong.Player, lime.Polygon);

```

На месте комментария опишем точки полигона и зальём полупрозрачным синим. Так будет выглядеть игрок (в руководстве для координат полигона используются дробные числа от -1 до 1, но в текущей версии они у меня не заработали):

``` javascript

// -1,-2.5, 0,-3.5, 1,-2.5, 1,2.5, 0,3.5, -1,2.5, 0,1.5, 0,-1.5
this.addPoints(-50,-125, 0,-175, 50,-125, 50,125, 0,175, -50,125, 0,75, 0,-75)
    .setFill(0,0,210,.7)
    .setScale(.4);

```

![Игрок]({{ get_figure(slug, 'player.png') }})

Красной точкой на рисунке помечена так называемая `anchorPoint`, для полигона она рассчитывается автоматически. Это точка отсчёта локальной системы координат спрайта - от неё высчитываются все относительные размеры и расстояния, к нему относящиеся.

Пока что код равноценен вызову:

``` javascript

var playerOne = new lime.Polygon().addPoints(...).setFill(...);

```

Но позже мы добавим поведение к игроку и будет очевидно, что выделить класс было разумным. Давайте проверим, корректно ли отображается игрок в сцене - вернёмся к файлу `pingpong.js`... впрочем, что уж тянуть, давайте добавим сразу обоих игроков и отразим первого, чтобы они стояли лицом к лицу:

``` javascript

. . .
goog.require('pingpong.Player');

. . .
    board_ = new lime.Layer().setPosition(0,0),

    playerOne = new pingpong.Player().setPosition(50,150).setRotation(180),
    playerTwo = new pingpong.Player().setPosition(400,150);

board_.appendChild(playerOne);
board_.appendChild(playerTwo);

. . .

```

Перед запуском в браузере, нужно произвести ещё одно мановение - обновить зависимости Closure (за счёт этого в `.html` могут быть включены только `base.js` и `pingpong.js`, а остальные внешние файлы подгружаются автоматически через `goog.require`). При этом в текущей версии библиотеки есть небольшой баг - при создании имя проекта не добавляется в файл `./bin/projects`. Поэтому прежде нужно добавить строку `pingpong` в `./bin.projects`, а потом обновить зависимости:

    $ vim ./bin/projects   # add `pingpong` line
    $ ./bin/lime.py update

Итак, вот что сейчас на экране:

![Пляжники в синих плавках]({{ get_figure(slug, 'stage1.png') }})

#### Заготовка мячика

Создадим файл `ball.js` с таким содержимым:

``` javascript

goog.provide('pingpong.Ball');

goog.require('lime.Circle');

pingpong.Ball = function() {
    goog.base(this);

    this.setFill(255,0,0,.7)
        .setSize(20,20);
}
goog.inherits(pingpong.Ball, lime.Circle);

```

Обновим зависимости:

    $ ./bin/lime.py update

И добавим мячик на доску в `pingpong.js`:

``` javascript

. . .
goog.require('pingpong.Ball');
. . .

    playerOne = new pingpong.Player().setPosition(50,150).setRotation(180),
    playerTwo = new pingpong.Player().setPosition(400,150),
    ball = new pingpong.Ball().setPosition(275,150);

board_.appendChild(playerOne);
board_.appendChild(playerTwo);
board_.appendChild(ball);

```

![Пляжники в синих плавках с мячиком]({{ get_figure(slug, 'stage2.png') }})

#### Фон

Давайте зададим фон на поле с игроками, для каждого игрока половина поля своего цвета. Добавим к `Director` параметры размеров экрана игры:

``` javascript

var director = new lime.Director(document.body,600,480),

```

Эти размеры никак не соотносятся с какими-либо пикселями - полотно игры автоматически масштабируется или разворачивается на весь экран при необходимости, но эти размеры позволяют задавать относительное положение элементов на полотне. Поправим позиции мяча и игроков в соответствии с ними:

``` javascript

playerOne = new pingpong.Player().setPosition(40,240).setRotation(180),
playerTwo = new pingpong.Player().setPosition(600,240),
ball = new pingpong.Ball().setPosition(320,240);

```

При изменении размеров окна так, чтобы поле было меньше чем указанные размеры, логика может сбиваться - хотя скорее всего, это я при тестированиях указал в каком-то месте координаты не так, как нужно было.

Теперь, наконец, фон. Это будут просто два спрайта, разделяющие экран пополам - никакой побочной логики.

``` javascript

floor_.appendChild(new lime.Sprite().setPosition(160,240)
                                    .setSize(320,480)
                                    .setFill(100,100,100));
floor_.appendChild(new lime.Sprite().setPosition(480,240)
                                    .setSize(320,480)
                                    .setFill(200,200,200));

board_.appendChild(...);
. . .

```

![Пляжники в синих плавках с мячиком на асфальте]({{ get_figure(slug, 'stage3.png') }})

#### Заготовка стен

У стен будет совсем немного логики, но тем не менее тоже выделим их в отдельный класс. Стены будут размером 20x20. Создадим файл `wall.js` с таким содержимым:

``` javascript

goog.provide('pingpong.Wall');

goog.require('lime.Sprite');

pingpong.Wall = function() {
    goog.base(this);

    this.setFill(255,255,0)
        .setSize(20,20);
}
goog.inherits(pingpong.Wall, lime.Sprite);

```

Обновим зависимости:

    $ ./bin/lime.py update

И расставим стены вдоль краёв полотна в `pingpong.js`:

``` javascript

. . .
goog.require('pingpong.Wall');
. . .

floor_.appendChild(...);

// horizontal walls
for (x = 10; x <= 630; x += 20) {
    walls_.appendChild(new pingpong.Wall().setPosition(x, 10));
    walls_.appendChild(new pingpong.Wall().setPosition(x, 470));
}
// vertical walls
for (y = 30; y <= 450; y += 20) {
    walls_.appendChild(new pingpong.Wall().setPosition(10, y));
    walls_.appendChild(new pingpong.Wall().setPosition(630, y));
}

board_.appendChild(...);

```

Всё, поле наконец готово - можно приступать к логике!

![Пляжники в синих плавках с мячиком на серых квадратах, окружённые жёлтыми ящиками]({{ get_figure(slug, 'stage4.png') }})

#### Логика игроков

Спрайт игрока должен постепенно двигаться по вертикали к точке, в которую нажали мышью или пальцем, при этом не врезаясь в стены. Движение делается просто:

``` javascript

. . .

director.makeMobileWebAppCapable();

goog.events.listen(floor_,['mousedown','touchstart'],function(e){
    var player_ = (e.position.x <= 320) ? playerOne : playerTwo;
    player_.runAction(
            new lime.animation.MoveTo(
                        player_.alignBounds(player_.getPosition().x,
                                            e.position.y))
                              .setDuration(1));
});

director.replaceScene(scene);

```

Но при таком поведении игроки проходят сквозь стены. Не будем сохранять экзепляры каждой стены, чтобы тестировать на столкновение с игроками, просто позволим программисту задать за какие границы игроку нельзя попадать - добавим два метода в конец `player.js`:

``` javascript

pingpong.Player.prototype.setMovementBounds = function(top,right,bottom,left) {
    this._moveBounds = new goog.math.Box(top,right,bottom,left);
    return this;
}

pingpong.Player.prototype.alignBounds = function(x, y) {
    if (this._moveBounds === undefined) return new goog.math.Coordinate(x, y);
    var size_ = new goog.math.Size(this.getSize().width * this.getScale().x,
                                   this.getSize().height * this.getScale().y);
    var newX = x, newY = y;
    if (x < (this._moveBounds.left + (size_.width / 2)))
                  newX = this._moveBounds.left + (size_.width / 2);
    if (x > (this._moveBounds.right - (size_.width / 2)))
                  newX = this._moveBounds.right - (size_.width / 2);
    if (y < (this._moveBounds.top + (size_.height / 2)))
                  newY = this._moveBounds.top + (size_.height / 2);
    if (y > (this._moveBounds.bottom - (size_.height / 2)))
                  newY = this._moveBounds.bottom - (size_.height / 2);
    return new goog.math.Coordinate(newX, newY);
}

```

Первый позволяет устанавливать прямоугольные границы для игрока, а второй - вернуть выровненную относительно этих границ позицию. Заметьте, что при расчётах учитывается вектор масштабирования.

Теперь в `pingpong.js` обновим определение игроков:

``` javascript

playerOne = new pingpong.Player().setPosition(40,240)
                                 .setRotation(180)
                                 .setMovementBounds(20,620,460,20),
playerTwo = new pingpong.Player().setPosition(600,240)
                                 .setMovementBounds(20,620,460,20),

```

И исправим событие, их перемещающее:

``` javascript

goog.events.listen(floor_,['mousedown','touchstart'],function(e){
    var player_ = (e.position.x <= 320) ? playerOne : playerTwo;
    player_.runAction(
            new lime.animation.MoveTo(
                    player_.alignBounds(player_.getPosition().x,
                                        e.screenPosition.y))
                              .setDuration(2));
});

```

#### Логика мяча

Для мяча понадобится несколько дополнительных функций. Одна позволяет ограничивать движение прямоугольным регионом, так же как и у и игрока, другая устанавливает скорость движения мяча, третья сбрасывает его положение в начальную точку (`ball.js`):

``` javascript

pingpong.Ball = function() {
    goog.base(this);

    this.setFill(255,0,0,.7)
        .setSize(20,20);

    this._xCoef = 1;
    this._yCoef = 1;

    this._resetPos = new goog.math.Coordinate(0, 0);
    this._velocity = 2;
}
goog.inherits(pingpong.Ball,lime.Circle);

pingpong.Ball.prototype.setMovementBounds = function(top,right,bottom,left) {
    this._moveBounds = new goog.math.Box(top,right,bottom,left);
    return this;
}

pingpong.Ball.prototype.setVelocity = function(velocity) {
    if (velocity) this._velocity = velocity;
    return this;
}

pingpong.Ball.prototype.setResetPosition = function(x, y) {
    this._resetPos = new goog.math.Coordinate(x, y);
    return this;
}

```

Туда же допишем основную функцию проверки, поймал ли один из игроков мяч и сброса позиции мяча, если нет. Если произошёл удар о вертикальную стенку, функция возвращает позицию удара, чтобы внешняя функция смогла определить, кто из игроков виноват, рассудив по их расположению.

``` javascript

pingpong.Ball.prototype.updateAndCheckHit = function(dt,playerOne,playerTwo) {
    var newPos_ = this.getPosition();
    var size_ = new goog.math.Size(this.getSize().width * this.getScale().x,
                                   this.getSize().height * this.getScale().y);
    newPos_.x += this._xCoef * this._velocity * dt;
    newPos_.y += this._yCoef * this._velocity * dt;
    var hitVBounds_ = false; // vertical bounds were hit
    if (this._moveBounds !== undefined) {
        if (newPos_.x <= (this._moveBounds.left + (size_.width / 2)))
                         { this._xCoef = 1; hitVBounds_ = true; }
        if (newPos_.x >= (this._moveBounds.right - (size_.width / 2)))
                         { this._xCoef = -1; hitVBounds_ = true; }
        if (newPos_.y <= (this._moveBounds.top + (size_.height / 2)))
                         this._yCoef = 1;
        if (newPos_.y >= (this._moveBounds.bottom - (size_.height / 2)))
                         this._yCoef = -1;
    }
    var p1catched_ = playerOne.catched(this.getParent().localToScreen(newPos_));
    var p2catched_ = playerTwo.catched(this.getParent().localToScreen(newPos_));
    if (hitVBounds_ && !p1catched_ && !p2catched_) {
        this.setPosition(this._resetPos.x,this._resetPos.y);
        return newPos_;
    } else if (p1catched_) { this.xCoef = 1; return null; }
      else if (p2catched_) { this.xCoef = -1; return null; }
    this.setPosition(newPos_.x, newPos_.y);
    return null;
}

```

> В подобных функциях требуется внимательно следить за координатной системой, с которой вы
работаете в данный момент и правильно их конвертировать при необходимости. В данном случае `parent`  - это слой, на котором располагается мяч и позиция мяча - это позиция относительно системы координат слоя. Таким образом, мы переводим координату позиции мяча в системе координат слоя в экранную систему координат перед передачей, а в методе `catched`, описанном ниже, переводим переданную позицию из экранной системы координат в локальную систему координат игрока.

В `player.js` добавим использующуйся в предыдущей функции метод `catched`. Он, учитывая координаты всех точек полигона игрока + масштаб и поворот, возвращает попала ли переданная позиция в область полигона или нет:

``` javascript

pingpong.Player.prototype.catched = function(pos) {
    var p = this.getPoints(),
        s = this.getScale(),
        r = this.getRotation(),
        plen = p.length,
        coord = this.screenToLocal(pos),
        inPoly = false;

    var rsin = Math.sin(r * Math.PI / 180),
        rcos = Math.cos(r * Math.PI / 180),
        csx = coord.x * s.x,
        csy = coord.y * s.y,
        crx = (csx * rcos) - (csy * rsin),
        cry = (csx * rsin) + (csy * rcos);
        crx = coord.x, cry = coord.y;

    if (plen > 2) {
        var i, j, c = 0;

        for (i = 0, j = plen - 1; i < plen; j = i++) {
            var pix_ = p[i].x, piy_ = p[i].y,
                pjx_ = p[j].x, pjy_ = p[j].y;

            if (((piy_ > cry) != (pjy_ > cry)) &&
                (crx < (pjx_ - pix_) * (cry - piy_) /
                    (pjy_ - piy_) + pix_)) {
                    inPoly = !inPoly;
                }
        }
    }

    return inPoly;
}

```

Установим все необходимые настройки при инициализации мяча в `pingpong.js`:

``` javascript

ball = new pingpong.Ball().setPosition(320,240)
                          .setMovementBounds(20,620,460,20)
                          .setVelocity(.2)
                          .setResetPosition(320,240);

```

И, самое главное, проверка событий, произошедших с мячом. Для этого мы используем метод `schedule` из `sheduleManager`, он вызывает переданную функцию в каждом кадре, сообщая о прошедшем с предыдущего кадра времени. Пока будем хаять проигравшего в консоли, а в следущей подглаве сделаем для этого `Label`:

``` javascript

goog.events.listen(. . .);

var hitPos_;
lime.scheduleManager.schedule(function(dt){
    if (hitPos_ = ball.updateAndCheckHit(dt, playerOne, playerTwo)) {
       console.log('player',(hitPos_.x <= 320) ? 1 : 2,'is a loser');
    };
},ball);

director.replaceScene(scene);

```

#### Сообщение о проигрыше

Теперь добавим лэйбл, который будет сообщать о проигравшем игроке. Не будем сильно заморачиваться отсчитывая очки, просто напишем кто пропустил мяч:

``` javascript

ball = . . .
       .setResetPosition(320,240),

label = new lime.Label().setPosition(280,30)
                        .setText('').setFontFamily('Verdana')
                        .setFontColor('#c00').setFontSize(18)
                        .setFontWeight('bold').setSize(150,30);

```

Не забудем добавить лейбл на слой с доской:

``` javascript

board_.appendChild(ball);
board_.appendChild(label);

```

И, исправим вывод текста о проигрыше на лейбл вместо консоли:

``` javascript

goog.events.listen(. . .);

var hitPos_ = null, defDelay_ = 500, delay_ = defDelay_;
lime.scheduleManager.schedule(function(dt){
    delay_ -= dt;
    if (delay_ <= 0) label.setText('');
    if (hitPos_ = ball.updateAndCheckHit(dt, playerOne, playerTwo)) {
       label.setText('player ' + ((hitPos_.x <= 320) ? 1 : 2) + ' is a loser');
       delay_ = defDelay_;
    };
},ball);

director.replaceScene(scene);

```

Всё, мячик летается по полю, отбивается от игроков, пропустивший наказывается страшной красной надписью - для демонстрационной игры, я считаю, достаточно.

#### Марафет

Отлично, теперь давайте наведём небольшой марафет, чтобы продемонстрировать работу с градиентами и текстурами.

Сделаем фон приятного зелёно-травяного цвета - поменяем инициализацию фоновых спрайтов в `pingpong.js`:

``` javascript

floor_.appendChild(new lime.Sprite().setPosition(160,240)
                                    .setSize(321,480)
                                    .setFill(new lime.fill.LinearGradient()
                                                     .setDirection(0,1,1,0)
                                                     .addColorStop(0,0,92,0,1)
                                                     .addColorStop(1,134,200,105,1)));
floor_.appendChild(new lime.Sprite().setPosition(480,240)
                                    .setSize(320,480)
                                    .setFill(new lime.fill.LinearGradient()
                                                     .setDirection(1,1,0,0)
                                                     .addColorStop(0,0,92,0,1)
                                                     .addColorStop(1,134,200,105,1)));

```

Сделаем игрокам (`player.js`) немного прозрачный синий морской градиент:

``` javascript

this.addPoints(-50,-125, 0,-175, 50,-125, 50,125, 0,175, -50,125, 0,75, 0,-75)
    .setFill(new lime.fill.LinearGradient()
                          .setDirection(0,1,1,0)
                          .addColorStop(0,0,0,210,.7)
                          .addColorStop(1,0,0,105,.7))
    .setScale(.4);

```

Мячу (`ball.js`) поставим текстуру с мячиком:

``` javascript

this.setFill('./ball.png')
    .setSize(20,20);

```

Стену (`wall.js`) раскрасим в бетонно-синий цвет и отнаследуем от `RoundedRect`:

``` javascript

pingpong.Wall = function() {
    goog.base(this);

    this.setFill(109,122,181)
        .setSize(20,20)
        .setRadius(3);
}
goog.inherits(pingpong.Wall, lime.RoundedRect);

```

Вот, теперь у нас всё выглядит много симпатичнее:

![Мужчины в синих шортах на футбольном поле с детским мячиком]({{ get_figure(slug, 'stage-designed.png') }})

#### Компиляция

Итак, демонстрационная игра готова. Исходники, которые получились у меня:

[`pingpong.js`](http://paste.pocoo.org/show/338943/) | [`player.js`](http://paste.pocoo.org/show/338944/) | [`ball.js`](http://paste.pocoo.org/show/338945/) | [`wall.js`](http://paste.pocoo.org/show/338946/) | [`ball.png`](http://dl.dropbox.com/u/928694/test-pingpong/ball.png) | [`pingpong.html`](http://paste.pocoo.org/show/338948/)

Теперь перепроверьте все `goog.require` - уберите неиспользуемые вызовы, затем обновите зависимости и соберите всё в один скрипт:

    $ ./bin/lime.py update
    $ ./bin/lime.py build pingpong -o pingpong/compiled/pp.js

Теперь в папку `compiled` можно скопировать `pingpong.html` и в заголовке поменять
вызовы JavaScript:

``` html

<!DOCTYPE HTML>

<html>
<head>
    <title>pingpong</title>
    <script type="text/javascript" src="pp.js"></script>
</head>

<body onload="pingpong.start()"></body>

</html>

```

### Резюме

Сначала я относился к движку немного скептически, представленные на сайте две (всего) игры чересчур каузальны, я не очень это люблю. Мало примеров и подробностей в документации и многовато всего нужно для установки. И ещё очень кислотный незамысловатый квадратик в `favicon`... :)

Но потом я поиграл в игру с числами и она оказалась довольно-таки захватывающей (похожа на `Super 7 HD` для iPad - попроще конечно, раз демка). А потом, когда потренировался при написании игры из статьи, всё оказалось довольно удобно, продумано и даже минималистично. Есть мелкие сырости и неосвещённые в документации вещи, но если код forward-compatible, то почему-бы и нет - ребята прямо сейчас исправляют все эти вещи.

Главное - это действительно не state-machine, которые сейчас модно делать - здесь можно отталкиваться от сценария игры, привязываясь к событиям, а не ко времени или текущему кадру, вам не надо думать как оптимизировать отрисовку многих объектов в следующем кадре - да, почти что Flash, жаль что без редактора.

### Видео

<iframe src="http://player.vimeo.com/video/19973495" width="400" height="300" frameborder="0"></iframe><p><a href="http://vimeo.com/19973495">LimeJS Engine demonstation on iPhone - PingPong game</a> from <a href="http://vimeo.com/shamansir">Ulric Wilfred</a> on <a href="http://vimeo.com">Vimeo</a>.</p>
<iframe src="http://player.vimeo.com/video/19973601" width="400" height="706" frameborder="0"></iframe><p><a href="http://vimeo.com/19973601">LimeJS Engine demonstation on Android - PingPong game</a> from <a href="http://vimeo.com/shamansir">Ulric Wilfred</a> on <a href="http://vimeo.com">Vimeo</a>.</p>
<iframe src="http://player.vimeo.com/video/19973167" width="400" height="225" frameborder="0"></iframe><p><a href="http://vimeo.com/19973167">LimeJS Engine demonstation on iPad - PingPong game</a> from <a href="http://vimeo.com/shamansir">Ulric Wilfred</a> on <a href="http://vimeo.com">Vimeo</a>.</p>

(Видео записаны с помощью авторов движка)

### Поиграть

[Здесь можно попробовать поиграть](http://shamansir.madfire.net/_pingpong/pingpong.html) (может глючить, потому что это очень упрощённая версия, сравнивайте пожалуйста ожидания работы на вашей платформе с приведёнными выше видео)

![QRCode]({{ get_figure(slug, 'qrcode.png') }})

P.S. Отдельное спасибо [lazio_od](http://www.lazio.com.ua/), он помогал мне в тестировании одновременно с авторами движка.
