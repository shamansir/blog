---
layout: post.html
title: JavaScript — как не оступиться. Пара фокусов.
datetime: 16 Nov 2011 11:55
tags: [ javascript ]
---

JavaScript — How not to Stumble. Few Tricks.

Хотел назвать эту статью "Как не попутать рамсы", но версия "не оступиться", вроде бы, больше поддерживает дзен-тематику [предыдущей статьи][1]... Да, я заметил, что в последнее время зачастил с "евангелическими" статьями, но опыт — штука бесконечная и я просто вынужден отмечать в нём важные точки: хотя бы сам для себя. В большей степени эта статья логически продолжает мой доклад о [Правильном Javascript][2] и знакомит вас с секретами этой религии.

At first, I've decided to name this article like "how not to screw up", however the current title version, seems, supports the zen-theme of the [previous one (ru)][1]... Yes, I do see that my last articles are at most evangelic ones, but the experience is the infinite thing and I really need to mark important points among its duration: at least for myself. In fact, this article is the logical extension of my [JavaScript — The Right One (ru)][2] lecture and it introduces you some secrects of this religion.

( I am not an English native — I am Russian, that is worse, because I am impudent in trying to make jokes (I hear you imitate my accent — please stop) — but I really want this article to read fluently, please send me corrections to [shaman.sir@gmail.com][email] or feel free to write them below in comments, if there is a block for them. )

Итак, вы писали на Java, PHP, Python, C++, Ruby ..., починяли небольшие скрипты на JQuery, может даже после этого подумали, как я, что хоть чуточку профессиональны в JS (как я), но вдруг посмотрели правде в глаза и решили взглянуть на JavaScript всерьёз. Большая часть ваших друзей и книг сетуют: "в JS нет классов, придётся тебе их самому добавить", однако в интернете вы замечаете всё шире разрастающиеся группы анархистов, плюющихся на аббревиатуру "ООП" по соседству с упоминанием JavaScript. Во всё это вмешиваются некие модули, монады, миксины и множество вещей, которые для вас просто удивительно видеть в языке, созданном более 10 лет назад. В реальности в стане таких анархистов постоянно прибывает и уже вот-вот их количество достигнет трети всех знающих JavaScript (это не аналитика, мне просто так кажется). И этому анархизму хорошо способствует [node.js][3], воистину гениальное изобретение.

So, you've written some code with Java, PHP, Python, C++, Ruby ..., you do constructed some tiny scripts in JQuery, may be you even think, like me, after that, that you are a bit proficient in JS (like me), but sooner or later you realize that you need to take a serious look at JavaScript. Most of your friends and books complain like "there are no classes in JS, you'll need to add them yourself", however you see the wider growing parties of anarchists who spit when they read "OOP" abbreviation near to the mention of JS. These occasions are often mixed with referring to the terms like modules, monads, mixins and other freshy modern things, which you are wondering to see in the language developed more that 10 years ago. In reality, these parties size is now near to the third part of JavaScript developers (it is not the analytics, it just seems to me so). And [node.js][3], a truly ingenious thing, really helps it to go on.

Эта статья не только о таком анархизме. Эта статья намерена помочь вам с первого раза взглянуть на язык с "верной" точки зрения и по возможности пропустить неосторожно насаждаемые заблуждения (это не аналитика, мне просто кажется, что это заблуждения). Маленькая такая версия "Thinking in JavaScript", без введения в лексику. Если вы хотите быстрее переступить через шаг "новичка", то эта статья для вас. Если вы хотите думать на JS современно, то и для вас тоже. Даже если вы пишете на [node.js][3], его использование в большинстве случаев вынуждает вас думать правильно, но и в этом случае иногда возникают вопросы вроде "на кой чёрт эта лестница из коллбэков, как же бесит!" — это статья для тебя, мой друг. Эта статья поможет вам использовать некоторые возможности ECMAScript 1.8 -> Harmony уже сейчас, но при этом поможет отказаться от ожидания некоторых не таких нужных нововведений.

This article is not only about that anarchism. This article is dedicated to help you treat the language from the "right" angle at a glance and lets you miss some inadvertently encouraged delusions (it is not the analytics, it just seems to me that they are, in fact, delusions). Its a little version of "Thinking in JavaScript", with no introduction to lexis. If you want to step over "Novice" rank as soon as possible, this is the article you need. If you want to think of JS in modern way, this is the article you need. Even if you write in [node.js][3], where most of its applications often lead you to think right, but in some cases you anyway ask "why the duck this ladder of callbacks watches at me now, it misses me off!" — this article is for you, my friend. This article will help you to use some of EcmaScript 1.8 -> Harmony features now, but also will help you to decline from waiting for some not-so-required innovations.

Вы видели [исходный код CodeMirror2][8], редактора разнообразнейшего кода, написанного на JS? Того самого, который используется в JSFiddle, JSBin, Light Table IDE — да блин, вообще почти везде. А ещё лучше — [исходник одного из его модулей][9]? Вот пример кода без библиотек и лишних объектов, на который стоит ориентироваться!

Have you ever seen [CodeMirror2 source][8], the editor of the any code, which is itself was written in JS? The one that is used in JSFiddle, JSBin, LightTable IDE and, oh Buddah, almost everywhere. The even better thing to look at — [the source for one of its modules][9]? _This_ is the sample code, free of any libraries and devoid of unnecessary objects, you should focus on and take as a great example!

> И нет, я не буду упоминать CoffeeScript в этой статье. Объясню мой принцип коаном. Представьте, что CoffeeScript — это орех каштана на вашем пути — лучше не трогать, если не знаете как он работает изнутри. Его плод полезен, но вы должны понимать, что он чужой для сложного и самодостаточного (я докажу это) организма JavaScript. Если же он лежит без оболочки, то без должной внимательности, вы можете — эй-эй, нет, не наступай!.. опа! — подскользнуться. Впрочем, если правда всё-всё осознаёте, то пробуйте — он правда хорош и сэкономит ваше драгоценное время. Но что тогда вы делаете здесь?).

> And no, I will not mention CoffeeScript in this article. I'd explain it with a koan. Imagine CoffeeScript to be a chestnut on your way — better not to touch it, if you don't know the way it works from the inside. Its core is beneficial, but you need to understand that it is an alien for a complex and all-sufficient (I'll prove it) JavaScript organism. However, if it lies on the road with no burr, you may — oh no, don't step!.. oops! — slip over it. But — if you really-really truly do understand everything, please feel free to taste it — CoffeeScript is pretty and saves you some valuable time. But if you do, why are you here?)

И ещё.

And the last thing.

> _Отказ от обвинений._ Если я в каком-то абзаце неосторожно отметил, что считаю себя профессионалом — это лишь значит, что я считаю, что имею достаточно опыта, чтобы иметь свой взгляд на написание кода на JavaScript, _Правильного JavaScript_. Не больше и не меньше. Этот вгляд может не оказаться каноническим, утверждённым, безгреховным или каким-либо ещё инновационным и суперстарским. Это мой личный путь — разве проблема, если нужно кого-то подбросить?

> Как и в боевых искусствах, у разных учителей разный стиль при единой теоретической базе, так и в JS. Меняет ситуацию то, что где-то среди нас тусуют сами создатели языка, помогают развивать его и, наверное, удивляются, что мы такого с ним творим, или злятся, что мы не понимаем что делаем. Но на мой взгляд, случается, что хорошо сделанное дело продолжает жить и развиваться, теряя тесную связь с создателем, например как дети уходят из дома родителей — мы уже взращиваем JS всем веб-программистким миром и у каждого своя дорога, но она всегда будет ровнее, если учитывать советы и ошибки соседей, примеряя каждый на себя. В любом случае, я ничего не навязываю.

> _Disclaimer._ If I occasionally mentioned somewhere that I treat myself to be professional — it means the only thing. It means that I believe that I have enough experience to have my own view on writing JavaScript code, _the Right One_. No more, no less. This view may appear not to be canonic, approved, sinless or somewhat like innovative or superstarish. This is the my own way — is it a problem if someone needs to be picked up?

> As well as in martial arts, different masters have different style, when theory base is the same. What changes the situation is that the very creators of the language are hanging out among ourselves, they help us develop it, and may be they are wondering why we do so much of strange stuff with it, or may be they are even angry that we do not realize what we do. But, as I see the problem, it happens, when some business, greatly and ingeniously done, detaches itself from its creator and continues to live and prosper without remembering of its germaneness, like children leave their parents' houses when they grow up. Now we are, the whole web-developers world, who cultivate the language. Each of us has his own way, but this way will become more secure, while one will consider the advice and mistakes of his neighbors, trying on with himself. Anyway, I do not impose.

Ну, пора прекращать распинаться. Меньше слов, больше дела.

Oh, come on, fewer words, more action.

### План

### Plan

* **Функции** — внутренняя мощь JavaScript;
* **Модули** — особый паттерн использования функций, позволят вам завести пространства имён и ограничить доступ к переменным;
* **Объекты** — коллекции данных и операций над ними — всегда помогут вам, если вы не будете требовать от них лишнего;

* **Function** — the inner force of JavaScript;
* **Modules** — a special pattern of functions usage, they let you introduce namespaces and construct a private scopes;
* **Objects** — collections of data and operations with it, they are always willing to help, especially if you don't claim them to do excessive things;

Из-за того, что эти понятия сильно пересекаются, некоторые темы будут повторяться, и это неизбежно. В любом случае, повторение — мать учения. Надеюсь, вы так считаете.

Due to the fact that these definitions do hardly intersect, some of the subjects will repeat others through this article, and this can't be avoided. Repetion is the mother of science, anyway. I hope you think so.

### Функции

### Functions

Функции — это сила JavaScript. И функции — это швейцарский нож в JavaScript. С помощью функции можно сделать всё. Они — жёлтый кирпич на вашем пути к исполнению желаний (никто, кстати, не помнит, чем закончилась та история?). С другой стороны, вы правы — все эти утверждения не в меньшей степени верны и для других языков с явно выраженной функциональностью. Но в JS, например, никто не требует от вас соблюдения их чистоты, и в этом ваша свобода. Я не хочу, однако, проводить прямые аналогии с другими подходами — это замутит ваш взор, а вы должны быть готовы увидеть всё сами. Пусть о других языках вам расскажывают в других статьях — и прочитав их вы почуствуете разницу. Я же постараюсь провести вас от _местных_ элементарных вещей к _местным_ профессиональным трюкам всего за одну малюсенькую главу. Это вообще могла быть единственная глава в этой статье, но, к сожалению оказалось, что две оставшихся тоже требуют отдельных пояснений.

Functions are the power of JavaScript. And functions are the swiss knife of JavaScript. You may do anything only with the help of functions. They are the yellow bricks on your way to the place where wishes come true (by the way, do anyone remembers please how this story ended?). On the other hand, you are right — all of these statements are pretty appliable to other languages with the dominance of functional approach. In JS, however, noone requires you to keep their purity, for example, and it is your freedom, what you get then. But I don't want to build here any direct analogies to attitudes of the other. Let other articles describe their own languages, so you may analyse the difference just when you finish reading them. I am the one who will try to lead you from _local_ elementary things to _local_ professional tricks trough this tiny section. This section was even cosidered to be the single one this article, but, unfortunately, I discovered that other two sections also need some separate comments.

Очевидно, что не все функциональные подходы есть в JS из коробки, но многие из них можно эмулировать через две-три строчки кода, даже не используя библиотек. Но, сначала немного об основах.

For sure, not all of the functional approaches are there in JS from the box, but you may emulate most of them with only several lines of code, even without using any third-party libraries. But let's start with basics.

#### Основы

##### arguments. I.

Вот как выглядит в JavaScript обычная функция:

Here is the way the standard function in JavaScript looks like:

    function my_function(arg1, arg2) {
        console.log(arguments); // волшебная переменная
        console.log(arg1, arg2);
        return undefined; // необязательная строка
    }
    my_function('foo', 'bar');
    // > ["foo", "bar"]
    // > foo bar
    // < undefined

`arguments` — один из многих секретов функций в JS, он хранит список переданных в функцию аргументов. Разве он не кажется вам соседом `*args` из Python? Вы даже можете эмулировать `**kwargs` (именованные аргументы и значения по умолчанию) при должном желании, и мы сделаем это чуть позже! Это первый пример, и он скучен только потому, что пока нигде не применялся.

##### return. I.

Если в функции не указано оператора `return ...;`, она возвращает `undefined`. То что `undefined`, как и `null`, как и `0`, как и пустая строка, считается ложью, позволяет вам определять "неудачу" операции, если функция ничего не вернула

> но не в случае арифметических операций: если только у вас нет пунктика, который позволяет вам считать нулевой результат неудачным независимо от обстоятельств.

    function has_coffee() {
        // какой-то сложный код, который подключается к мейнфрейму
        // умного дома и спрашивает, может ли тот приготовить кофе:
        // достаточно ли у него зёрен и прочистил ли он лоханку.
        // some tricky code to connect Smart Home mainframe
        // and ask it if it may make some coffee
        if (!...) return true;
        if (...) {
            if (...) {  return true };
            switch(...) {
                case ...:
                case ...:
                case ...: return true;
            }
            ...
        }
        // неявный return undefined;
    }
    if (has_coffee()) { // не забудьте круглые скобки!
        // запрос на приготовление кофе
    }

Как и в любом языке, если вы хотите что-то вернуть, вы можете вернуть из любого места функции всё, что угодно:

    return '$500'; // вернуть долг
    return [ 'crap', 'stuff', 'buzz' ]; // массив
    return { 'engine': 'v8', 'tyres': 'michelin', ...  }; // объект
    return false; // явно вернуть false
    return 42; // и снова смотреть мультик

##### Функция — это объект. I.

Если вы всё же намеренно забудете скобки, то таким образом вы проверите переменную `has_coffee` на существование и неравенство `null`, `0`, и что там дальше по списку. Прикол в том, что переменная `has_coffee` существует: и без скобок тело блока `if (has_coffee) { ... }` будет выполняться _всегда_! Почему `has_coffee` существует? Да потому что функция с таким именем определена — и это объект. Это ещё один секрет, который даёт вам огромную массу возможностей. Смотрите, эти два выражения эквивалентны:

    // первое
    function has_coffee() { ... }
    // второе
    var has_coffee = function() { ... }

Надеюсь, вы ясно видите из второго выражения, что функция — это полноценная переменная, ничем не отличающаяся от других. Будьте чуточку нетолерантны, и вы сможете передавать её в другие функции как аргумент, откладывать её вызов, обманывать её, подсовывая "чужой" контекст, вызывать рекурсивно через раз и делать прочие, услаждающие вашу властность, вещи.

##### return. II.

Однако, давайте пока не будем потирать руки и ещё поиграемся c проверками результатов выполнения функций, вот вам небольшой паттерн:

    function file_exists(file_name) {
        var files = ls_laf(); // < массив
        var i = files.length;
        while (i--) {
            // мы сравниваем строку со строкой,
            // так что приведение типов нас не пугает
            if (files[i].name == file_name) {
                // сразу возвращает значение из функции
                return files[i];
            }
        }
        // неявный return undefined;
    }
    var file;
    if (file = file_exists('my_file')) {
        // выполняется только если файл существует
        file.read(..);
    }

Вы заметили, что можно сохранять результат функции прямо из условия (`if (file = ...)`) и использовать его в дальнейшем коде? Это часто сэкономит вам пару строчек. К сожалению, нельзя написать буквально `if (var file = ...)`, но это вполне терпимая издержка, всё равно всегда есть блок переменных, куда можно незаметно подсунуть вашу.

> Видите, даже через основы я продолжаю показывать вам небольшие трюки. Обратите внимание на итерацию по массиву `files` через `while (i--)`: это быстрый вариант прохода циклом по массиву, когда для вас не имеет значения то, что проход начинается с конца до начала.

> [Один мой друг][nek] пишет ещё более волшебно: `while (i -- > 0) {`, как будто `i` стремится к нулю, два лишних символа, но какой прекрасный образ. Иероглифы не столь прекрасны, как это выражение.

> Ещё один, оптимизированный, и на этот раз упорядоченный, довольно популярный, проход циклом по массиву выглядит так:

>    var my_array = [ 0, 16, 24, 2, 17 ];
>    for (var i = 0, il = my_array.length; i < il; i++) {
>        console.log(my_array[i]);
>    }
>    // > 0
>    // > 16
>    // > ...

> "Оптимизаторство" здесь в том, что, в отличие от академической формы (`for (var i = 0; i < my_array.length; i++)`), мы заранее сохраняем значение длины массива и не вычисляем его на каждой итерации. Здесь нам помогает другой секрет — **["оператор запятая"][4]**. Обязательно прочтите статью по ссылке, она самодостаточна и подробно описывает все возможности этого маленького и бесконечно прекрасного создания: если бы такой статьи не было, пришлось бы добавлять в ту, которую вы читаете, целый дополнительный раздел. Потому что это прелестное создание используется в статье повсеместно.

##### Арифметика опасносте.

Наконец, чтобы предостеречь вас от будущих неожиданностей касательно функций, обращу ваше внимание на ещё один момент с возвращением `undefined` — беда с приведением типов.

Посмотрим, что будет, если мы будем неосторожно баловаться с арифметикой (пожалуйста, не используйте для подсчёта зарплат). Вот два варианта фунции, с нестрогим (первое) и строгим сравнением (второе):

    function is_0(num) {
        if (num == 0) return true;
        // неявный return undefined;
    }
    function is_0_safe(num) {
        // === не приведёт строку '0' к 0
        // и не будет вести себя опасно
        if (num === 0) return true;
        // неявный return undefined;
    }

Попробуем запустить их с разными значениями:

    is_0(null); // < undefined
    is_0(0);    // < true
    is_0('');   // < true
    is_0('0');  // < true
    is_0(5);    // < undefined
    is_0([]);   // < true
    is_0_safe(null); // < undefined
    is_0_safe(0);    // < true
    is_0_safe('');   // < undefined
    is_0_safe('0');  // < undefined
    is_0_safe(5);    // < undefined
    is_0_safe([]);   // < undefined

Если бы вы указали явный `return undefined` или `return null`, то для оператора `if` без сравнения (`if (is_0(...))`, `if (is_0_safe(...))`) ничего бы не изменилось. На самом деле вернее эту функцию записать так — коротко, _действительно_ надёжно и мудро:

    function is_0(num) {
        // всегда будет возвращать true или false
        return (num === 0);
    }

Тонкости преобразования типов описаны [в JavaScript Гарден][js-garden-types], я не буду на них останавливаться — JS Гарден ничуть не менее необходим к прочтению, хоть и отдаёт иногда истеричностью. Все описанные там вещи нужно знать: многое из того, что кажется странным на первый взгляд, даёт вам ту самую "швейцарскую" свободу — равно как и то, что вы исправно платите налоги.

Что ж, теперь вернёмся к серьёзным вещам и, теперь уже, настоящим фокусам.

#### Серьёзные вещи

##### Функция — это объект. II.

То, что функция — объект, позволяет вам обращаться с ней как с обычной переменной (не слишком усердствуйте с унижениями, пожалуйста!). Вы можете передавать её в другие функции и вызывать прямо оттуда, без тени стеснения:

    function having(value)  { return "I got the " + value; };
    function require(value) { return "I need some " + value; };
    function say(manner, first, second) {
        // выводит в консоль результат вызова функции
        // с первым значением в качестве параметра
        console.log(manner(first));
        // выводит в консоль результат вызова функции
        // со вторым значением в качестве параметра
        console.log(manner(second));
    }
    say(having, 'poison', 'remedy');
    > "I got the poison"
    > "I got the remedy"
    say(require, 'love', 'affection');
    > "I need some love"
    > "I need some affection"

Как замечательно, ну-ка споём старую добрую D.I.S.C.O.:

    function loud_and_solid(value) { return value.toUpperCase() + '.'; }
    say(loud_and_solid, 'd', 'i', .... // :(

Стоп. Однако, выходит, что наша функция ограничена всего двумя возможными параметрами и наша песня под угрозой срыва. Хотелось бы использовать `arguments` как-нибудь так, чтобы можно было передать неограниченное число объектов и со спокойной душой отдаться после этого танцу...

> Безусловно, существует пара вариантов решения на данный конкретный случай, которые можно было бы предложить вам прямо на месте — например, передать строку одним аргументом и разбить её на символы. Но тогда бы в статье вовсе не было драматического момента — и как бы, тогда, скажите пожалуйста, я подвёл вас к следующим главам? Как настоящий учитель, оставлю вам это на домашнее задание.

Но для этого придётся погрузиться в другие внутренности функций JS.

##### Анонимные функции.

Как вы наверное знаете, объекты в JS в нынешнее время можно создавать через конструкцию `new Object(...)`. Боюсь, вы никогда не использовали этот способ — создавать объект явно и тут же передавать его куда-то, в виде `{ 'tom': 'boy', 'jenny': 'girl', ... }` значительно легче. Так вот, иногда и функцию тоже намного легче создать явно, без имени, чем заводить для неё лишнюю переменную:

    say(function(value) { return "Don't " + value + "!"; }, 'Bark', 'Bite');
    > "Don't Bark!"
    > "Don't Bite!"

    say(function(value) { return value + "!"; }, 'Mutter', 'Mutter');
    > "Mutter!"
    > "Mutter!"

Эта форма должна быть вам знакома, поскольку часто используется вместе с `setTimeout` и `$.each`. Когда вы передаёте куда-то функцию без имени, она создаётся прямо в этом месте и пересылается в собранном виде куда нужно:

    function setTimeout(function() {
        // выполняется через секунду
        console.log('Finally, they called me! Wuf!');
    }, 1000);

    $('.foo').each(function(elm) {
        // выполняется для каждого элемента
        $(elm).text('bar');
    });

Да, это та самая лямбда. Некоторых почему-то коробит синтаксис написания, требующий `function`, будто это сильно больше чем `lambda` в Python (но в Хаскеле, я слышал, правда сильно короче). Я встречал целые библиотеки, которые "укорачивали синтаксис" JS-варианта лябмды. Эй, может в вашем редакторе не поддерживаются сниппеты, если вам так сложно напечетать пару букв, которые только сработают на читабельность? Может Хаскель — это не здесь, АА?!!.. АА?!!.. Зачем вы принесли свой самовар сюда?!.. Простите, задел сам себя за живое, пойду-ка сделаю пару сеппуку и вернусь — пожалуйста, никуда не уходите.

. . .

Вспомните:

    // второе
    var has_coffee = function() { ... }

Здесь справа вы видите ту же самую анонимную функцию, а имя ей назначается уже по факту присвоения переменной. Можно, кстати, смело считать формат `function has_coffee() { ... }` краткой записью такого выражения.

А теперь (та-дам-тыщ) затаите дыхание, и посмотрите на это:

    for (var i = 0, next = function(i) { return i + 1; },
         less_than = function(i, max) { return i < max; };
         less_than(i, 3); i = next(i)) {
        console.log(i);
    }
    > 0
    > 1
    > 2

Выглядит мощно, да? Пока что это просто беспричинно усложнённый цикл for, полностью сохранивший функциональность. Тем не менее просто попробуйте представить, какую безграничную свободу вам может дать злоупотребление функциями:

    for (var i = 2, total = 30 - i, vals = [0, 1],
         next = function(i) { return vals[i - 2] + vals[i - 1] },
         log = function(val) { console.log(val); };
         total--; vals.push(next(i)), log(vals), i++ ) { }

Вы пробовали показывать на каком-нибудь собеседовании ряд Фибоначчи, записанный оператором `for` без тела? Разве не похож этот код на улитку, томно взбирающуюся пропорционально увеличивающимися ползками на Эверест? Правда, будем честными, эта улитка просто-напросто выглядит эффектно — в реальной жизни таким баловаться не стоит.

Теперь вы правда готовы к безумию настолько, что даже можете создать массив из функций и вызывать их по очереди (пока не знаю, правда, зачем):

    var disco = [
        function() { return "D."; },
        function() { return "I."; },
        function() { return "S."; }
    ];
    disco.push(function() { return "C."; });
    disco.push(function() { return "O."; });
    for (var di = 0, dl = disco.length; di < dl; di++)  {
        disco[di]();
    }

Когда функции входят в вашу жизнь, она расцветает потаёнными возможностями — вы начинаете осознавать, что их можно комбинировать, пересекать, выстраивать в круги, заставлять их танцевать схватившись за возвращаемые значения и щекотать их, чтобы они пробегали друг под другом. Становится возможно всё! Хм, я увлёкся, а ведь это ведь вовсе ещё не конец статьи, и самое интересное впереди.

##### Функции, которые возвращают функции.

Очень удобно возвращать из одних функции другие функции — засчёт этого можно генерировать очень хитрые вещи, ограждая пользователя от передачи лишних параметров. Например, давайте-ка создадим простейший итератор:

    function iter(list) {
        var ll = list.length,
            li = 0;
        return function() {
            if (li === ll) return false;
            return list[li++];
        }
    }

И пройдёмся им по списку:

    var list = [7, 16, 24, 5];
    var next = iter(list);
    var n;
    while (n = next()) {
        console.log(n);
    }
    // > 7
    // > 16
    // > 24
    // > 5

Если вы вдруг сейчас скажете, что итераторы уже есть в JS 1.7, то я добродушно поясню, что статья вовсе не вынуждает вас их переписывать на нашу реализацию. Подобные примеры присутствуют в этой статье лишь для того, чтобы вы заметили, что стоит чаще задумываться, как JS работает изнутри — возможно это происходит вовсе не так сложно, как кажется (если не углубляться в ненужные вам дебри). Почему? Потому что это поможет вам писать красивый код. И кроме этого, все эти примеры должны запускаться в любом современном браузере, иначе мои читатели будут злы.

Так что попробуем пример посложнее.

<!-- TODO: ещё пример -->

##### Вызов на месте a.k.a. Замыкания.

Ещё одно прекрасное свойство анонимных функций — то, что их можно вызывать прямо там, где они были созданы. Чаще всего вы встречали этот метод, когда пытались избавиться от странностей JavaScript:

    var buttons = $("button");
    for (var i = 0; i < 10; i++) {
        buttons.onclick = function() { window.alert(i) };
    }
    // как мы все знаем, на всех alert'ах будет написано "10"

    for (var i = 0; i < 10; i++) {
        buttons.onclick = (function(i) {
            return function() { window.alert(i) };
        })(i);
    }
    // теперь всё в порядке

С первого раза сложно запомнить эту конструкцию, знаю по себе; но как только вы разберёте его на части сверху вниз, в вашей голове всё сразу уложится на свои места:

    имя_функции(параметры вызова); // вызов обычной функции по имени

    (тело функции)(параметры вызова); // вызов анонимной функции

    (тело функции, которую нужно вызвать прямо сейчас)(параметры текущего вызова);

    (function(аргументы текущего вызова) {
        при вызове вернуть отложенную функцию;
    })(параметры текущего вызова);

    (function(аргументы текущего вызова) {
        return function(аргументы отложенной функции) { тело отложенной функции };
    })(параметры текущего вызова);

На самом деле возвращение другой функции — это только частный случай вызова анонимной функции. Из анонимной функции, как и из любой другой, вы можете вернуть объект или вообще ничего не возвращать. Зачем вызывать анонимную функцию, которая ничего не возвращает? С первого взгляда кажется, что смысла особого нет, но вы можете это сделать, например, ради изолирования блоков кода: любая функция скрывает в себе все внутренние переменные. Эти переменные никто не сможет получить извне и они "закреплены" внутри.

Непосредственный вызов функции сразу после её объявления:

    var my_func = function() {
        var hidden1, hidden2;
        function hidden_function1() { /* ... */ };
        function hidden_function2() { /* ... */ };
    };
    my_func();

Вызов анонимной функции: тот же по результату действия вариант, но без создания лишней переменной:

    (function() {
        var hidden1, hidden2;
        function hidden_function1() { /* ... */ };
        function hidden_function2() { /* ... */ };
    })();

Если возвращать из такой функции объект — то получится вполне такой себе паттерн Фасад. Используя анонимную функцию вы просто совмещаете два действия в одном — конструирование объекта фасада и его возвращение наружу, ничего больше. При этом в неё можно передать внешние переменные и манипулировать ими как захочется.

    var re_pool = (function(opts) {

        var cur_re = null;

        function _tokenize() { /* ... */ };
        function _greedy_find() { /* ... */ };
        function _find_group() { /* ... */ };

        function use(re_str) { cur_re = re_str; };
        function match() { /* ... */ }
        function replace() { /* ... */ }

        return {
            'use': use,
            'current': cur_re,
            'match': match,
            'replace': replace
        }

    })(opts || {});

##### Рекурсия.

Конечно же, в JS есть рекурсия. Она ничем не отличается от соседних языков, так что достаточно простого примера. Функция, которая рассчитывает точки для рисования звезды:

    function makeStar(opts, points, p) {
        if (!opts) return [];
        var points = points || [];
        if (points.length >= opts.beams*2) return points;
        var i = Math.floor(points.length / 2),
            p = (Math.PI * 2) / opts.beams;
        var oang = -p/4+(i*p),
            iang = p/4+(i*p);
        return makeStar(opts, // рекурсивный вызов
            points.concat([
                [ opts.orad * Math.cos(oang),
                  opts.orad * Math.sin(oang) ],
                [ opts.irad * Math.cos(iang),
                  opts.irad * Math.sin(iang) ]
            ]));
    };
    makeStar({ beams: 5, // кол-во лучей
               orad: 60, // внешний радиус
               irad: 30 // внутренний радиус
             });

##### this.

Настало время подробнее разобраться с `this`.

Если смотреть на объекты с позиции функций, то те окажутся не более чем хешами со строками-ключами; внутри них часть, а иногда даже все, значения могут быть функциями, но пока дело не доходит до вызовов, внешним функциям плевать и на это. Но всё равно всё, как всегда, чуточку глубже. Скажите, в чём принципиальная разница между этими тремя объектами `a_j`? Первый:

    var a_j = { 'age': 15, 'hair': 'black', 'voice': 'soprano',
                // знакомая анонимная функция
                'getToeLength': function() { return this.age * 0.3; } };
    a_j.getToeLength();
    // > 4.5

Второй:

    var a_j = new Object();
    a_j.age = 15;
    a_j.hair = 'black';
    a_j.voice = 'soprano';
    a_j.getToeLength = function() { return this.age * 0.3; };
    a_j.getToeLength();
    // > 4.5

Третий:

    function Human(age, hair, voice) {
        this.age = age;
        this.hair = hair;
        this.voice = voice;
    }
    Human.prototype.getToeLength = function() { return this.age * 0.3; }
    var a_j = new Human(15, 'black', 'soprano');
    a_j.getToeLength();
    // > 4.5

На самом деле ни в чём, кроме того, что с помощью функции `Human` мы теперь может штамповать людей с различными свойствами и методами по одному шаблону. Кстати, инициализатор этого шаблона ("конструктор") тоже, как вы, наверняка, заметили, определяется через функцию... Ух ты! Функция-шаблон, напичканная другими значениями и функциями, ничего себе! А что вы хотели, это вам не классы ;)

А вы заметили ключевое слово `this` в методе `getToeLength()`?

Скорее всего вам уже говорили, что наш `this` не такой, как в других языках. Тсс, это ещё один секрет. (И снова я отошлю вас за совсем уж истеричными подробностями [в JS Гарден][js-garden-this].) Нам лишь важно знать, что если функция "висит в воздухе", не привязана к какому-либо объекту, то `this` внутри такой функции будет указывать на область, в которой она описана (с оговорками, о них в примере ниже). Если такой области нет, то это будет глобальная область видимости — например, `window`. Но как компилятор JS видит, что функция каким-то образом привязана к объекту? Ведь столько способов их связать! На самом деле просто происходит позднее связывание, то есть `this` устанавливается во время фактического вызова такой функции, а не на этапе компиляции. Типа компилятор JS говорит ей: "Да-да, я тебя запомнил, дорогая функция, но кто твой виз-а-ви, родная, ты узнаешь непосредственно при встрече, уж прости. Не исключено, что придётся перепопробовать несколько партнёров различных национальностей."

Приведу небольшой листинг с доказательством этой теоремы. Возьмём какую-то обычную функцию:

    function some_func() {
        console.log(this.foo);
    }

Проверим, что будет, если положить её в объект, а потом вызвать отдельно:

    var obj = { 'foo': 42, 'some_func': some_func };
    some_func(); // вызов без привязки к объекту
    // > undefined
    obj.some_func(); // вызов с привязкой к объекту
    // > 42

Сработало позднее связывание, и на момент вызова `obj.some_func()`, `this` превратился в ссылку на `obj`. Впрочем, это всё слишком просто, нужно что-то более хитрое. Давайте-ка подсунем её в прототип какого-нибудь свободного конструктора. Какого? Ну а почему бы и не её самой.

    some_func.prototype.some_func = some_func; // вы чувствуете власть?
    var another_obj = new some_func(); // что-то не так? ;)
    // > undefined // мы "случайно" вызвали функцию
    another_obj.foo = 34;
    another_obj.some_func();
    // > 34
    obj.some_func();
    // > 42

> Я честно очень долго пытался сделать так, чтобы подглавы шли последовательно и, например, прототипы не упоминались раньше их собственной подглавы, а глава `this` шла после главы про прототипы (хоть `this` и не ). Но тогда терялась полностью терялась последовательность и фабула примеров. Если вы уже не в первый раз видите фразу "а об этом я расскажу позже", значит эту проблему я так и не решил. Но будьте уверены, я правда подробно расскажу о конструкторах и прототипах чуть ниже. Просто если вы не знаете, что это или чувствуете себя неуверенно, то не беспокойтесь и продолжайте читать и не забудьте вернуться сюда, когда дойдёте до нужной главы.

Теперь попробуем проверить, что будет, если описать анонимную функцию внури метода экземпляра (`another_obj` — экземпляр `some_func`, не забудьте):

    another_obj.method = function() {
        console.log(this.foo);
        function foo_inner() {
            console.log(this.foo);
        }
        foo_inner();
    }
    another_obj.method();
    // > 34
    // > undefined // из функции foo_inner

Вот видите, `this` у нас украли. Попробуем вернуть его через замыкание:

    another_obj.method_2 = function() {
        console.log(this.foo);
        var foo_inner = (function(me) {
            return function() {
                console.log(me.foo);
            }
        })(this); // "замыкание"
        foo_inner();
    }
    another_obj.method_2();
    // > 34
    // > 34 // из функции foo_inner
    another_obj.foo = 53;
    another_obj.method_2();
    // > 53
    // > 53 // из функции foo_inner

Осталось проверить ещё один момент:

    this.foo = 63; // а что, вне функций у нас тоже есть `this`
    console.log(this.foo);
    // > 63
    some_func();
    // > 63

Почему последние две строчки действуют не так, как такой же, кажется, код внутри `another_obj.method`? Здесь важно не смотреть на описание функции, а на вызов. Помните, я говорил про позднее связывание? На самом деле мы находимся <s>в матрице</s> _(зачёркнуто)_ внутри невидимого глобального объекта (в браузере это `window`), и все функции, вызывающиеся без прямого указания на объект, которому по умолчанию принадлежат (через `something[.something]*.func(...)`), по умолчанию привязываются к нему. Можете считать, что написать `some_func(...)` эквивалентно `this.some_func(...)`, где `this` указывает на Его Величество. Этот глобальный объект довольно аггресивен и изначально беспардонно считает все свободно валяющися функции своими личными. Для него не имеет ни малейшего значения, что функция объявлена внутри метода, потому что внутри него мерещится незанятый `this`, источающий питательные флюиды. Видите, детки, как опасно разжечь его аппетит? Попробуйте теперь вызвать `another_obj.method`:

    another_obj.method();
    // > 53
    // > 63 // захавал, скотина!

Подведём итог.

Нам помогло замыкание. Но оно помогло лишь потому, что мы запомнили указатель на оборачивающий объект и стали использовать его вместо `this`. Да, это способ, но это не самый красивый способ для данного случая — профессионал увидит из такого кода, что вы забыли про позднее связывание.

Чтобы знать, чему будет равен `this` абсолютно не нужно видеть, каким образом и в каком месте объявлена функция — `this` не определён на момент объявления. Имеет значение лишь строка вызова: именно при вызове вы сами говорите, чему будет равен `this`.

    obj.method(); // this внутри метода будет ссылаться на `obj`
    some_function(); // откуда бы вы не вызвали таким образом функцию, `this` в ней будет ссылаться на глобальный объект
    new Foo().bar(); // `this` ссылается на экземпляр `Foo`
    Foo.prototype.bar(); // `this` ссылается на объект `Foo.prototype`
    ({}).hasOwnProperty('foo') // `this` ссылается на экземпляр `{}`

На самом деле эта проблема решается по-другому — даже самый злобный тролль растает, если его очень хорошо попросить (или показать ему сиськи), и об этом следующая подглава.

##### Манипуляции с this посредством call и apply.

Немного перепишем несработавший метод:

    another_obj.method = function() {
        console.log(this.foo);
        function foo_inner() {
            console.log(this.foo);
        }
        foo_inner.call(this);
    }
    another_obj.method();
    // > 53
    // > 53 // мы спасли его!

Вызывая функцию через `call` мы явно передаём ей ссылку на тот `this`, с которым её необходимо вызвать: то есть собственноручно выполняем позднее связывание. Видите, JS с трепетом доверяет вам даже свои внутренние органы?

`call` и `apply` различаются только в способе передачи параметров в метод: если у вас есть подготовленный массив готовых параметров, используйте `apply`, если нет — `call`. Представим себе двух милых собеседниц. У них будет стандартный набор ответов на стандартные фразы при разговоре по телефону:

    var Josie = {
        'hi': 'Wee!',
        'how_are_you': 'Oh, great, sweetie!',
        'some_news': 'I want a dress!',
        'how_much': 'Why are you asking?',
        'bye': 'OK, I\'ll buy.'
    };
    var Minnie = {
        'hi': 'Good morning, Mickey!',
        'how_are_you': 'Sweet, Mickey!',
        'some_news': 'No news at all, Mickey! (am I mad?)',
        'i_am_not_mickey': 'And who are you then, Mickey?',
        'how_much': '1 bazillion, Mickey!',
        'bye': 'Kisses, Mickey!'
    };

Напишем функцию, которая умеет "звонить" и отвечать поочерёдно на три фразы звонящего. Она рассчитывает, что на поднявшего трубку собеседника указывает `this`:

    function phone(phrase1, phrase2, phrase3) {
        if (phrase1) console.log(phrase1, '->', this[phrase1]);
        if (phrase2) console.log(phrase2, '->', this[phrase2]);
        if (phrase3) console.log(phrase3, '->', this[phrase3]);
    }

Позвоним Жози, используя `call`:

    phone.call(Josie, 'how_are_you', 'some_news', 'bye');
    // > how_are_you -> Oh, great, sweetie!
    // > some_news -> I want a dress!
    // > bye -> OK, I'll buy.

Позвоним Минни, используя `apply` с подготовленным массивом:

    var standard_talk = [ 'hi', 'how_are_you', 'bye' ];
    phone.apply(Minnie, standard_talk);
    // > hi -> Good morning, Mickey!
    // > how_are_you -> Sweet, Mickey!
    // > bye -> Kisses, Mickey!

Позвоним по случайному телефону.

    phone.apply({'hi', 'Shhh...', 'what': 'Shhh...'},
                ['hi', 'what']);
    // > hi -> Shhh...
    // > what -> Shhh...

Позвоним по массиву.

    phone.apply(['11001', '001010', '00110'],
                [1, 0, 1]);
    // > hi -> Shhh...
    // > what -> Shhh...

Теперь я ещё раз повторюсь, что используя `call` или `apply` можно обмануть метод любого объекта, подставив ему ссылку на что угодно:

    another_obj.method.call({ 'foo': 40 });
    // > 40
    // > 40
    Human.prototype.getToeLength.call({ 'age': 40 });
    // > 12

А сейчас мы используем `call` в по-настоящему дерзких целях. Вы готовы? **Держитесь за стул**:

    var stooge = { length: 14 };
    Array.prototype.push.call(stooge, 'a');
    console.log(stooge);
    // > { 'length': 15, '14': 'a' };

Обычно `[].push` работает так:

    [ 'a', 'b' ].push('c');
    // > [ 'a', 'b', 'c' ];

Но мы сделали с вами сделали вид, что мы — утка. Будучи на самом деле объектом, мы подло прикинулись массивом, подставив ложное свойство `length` и доверчивый JS принял всё на веру. Обещал же я вам фокусы? Обещал же?). Если нужно, секрет этого фокуса я раскрою через пару глав.

##### Вызов на месте. II.

<!-- TODO -->

Если вы вспомните проблему `alert(i)`, зная теперь о позднем связывании, то сможете понять причину, почему `i` всегда становился десяткой.

<!-- TODO -->

.call

#### Функции, которые возвращают объекты.

Если возращать из функции объект, то можно упростить или наоборот улучшить ещё множество вещей. Например итератор, черновик которого мы писали пару подглав назад, будет ещё больше похож на "правильный":

    function iter(list) {
        return {
            __pos: 0,
            hasNext: function() {
                return this.__pos < list.length;
            },
            next: funtion() {
                return list[this.__pos++];
            }
        }
    }

    var list = [7, 16, 24, 5];
    var my_iter = iter(list);
    while (my_iter.hasNext()) {
        console.log(l_iter.next());
    }
    // > 7
    // > 16
    // > 24
    // > 5


##### Прототипы. I.

Не могу не вставить пару слов о прототипах, иначе нельзя будет совсем уже нельзя продолжать дальше.

Если существует функция-конструктор (или функция — "фабрика клонов")...

    // сейчас она ничем не отличается от обычной функции,
    // вы просто решили, что быть ей в этой жизни конструктором
    function Clone() { /* ... */ }

...то она может хранить в себе "прототип": поименованную таблицу (хэш) свойств и функций, ссылки на которые будут храниться в каждом новом экземляре, созданном в этой фабрике. Именно _ссылки_ — то есть если изменить/подменить эти свойства или функции в прототипе, то они изменятся у всех созданных экземпляров. При этом всё, что присваивается `this` в конструкторе, индивидуально создаётся для каждого нового экземпляра:

    function Robot(name) {
        // новые для каждого нового экземпляра
        this.name = name;
        this.sayName = function() { console.log(this.name) };
    }
    // ссылка в каждом экземпляре
    Robot.prototype.killHuman = function() { throw new Error('Restricted!'); }
    Robot.prototype.antenna = '9inches';

    var robots_to_construct = 50;
    var robots = [];
    while (robots_to_construct -- > 0) {
        robots.push(new Robot('TX-'+robots_to_construct));
    }

    robots[22].name = 'Bender Rodríguez';
    robots[11].sayName();
    // > 'TX-38' // не изменилось
    robots[22].antenna = '12inches';
    console.log(robots[11].antenna);
    // > '9inches' // не изменилось, просто перезаписалась ссылка
    robots[22].sayName = function() { console.log('Kiss-My-You-Know-What!'); }
    robots[11].sayName();
    // > 'TX-38' // не изменилось, просто перезаписалась ссылка
    robots[22].killHuman();
    // > Error: Restricted!
    robots[22].killHuman = function() { try { } catch(e) { console.log('Roger That!'); } }
    robots[11].killHuman();
    // > 'Roger That!' // НЕТ!
    robots[17].killHuman();
    // > 'Roger That!' // НЕЕТ!
    robots[21].killHuman();
    // > 'Roger That!' // НЕЕЕЕЕТ!

<!-- FIXME: ЭТО НЕПРАВДА! -->

Это похуже ошибки 2000!

Именно поэтому в конструкторе стараются устанавливать только свойства — их значения должны быть новыми для каждого нового экземпляраж а в прототипе хранят методы, поскольку функции работают с любым экземпляром и их не нужно пересоздавать.

На самом деле это всё. Это вся проблема прототипов, в двух словах.

##### Duck typing.

Лёкгость проверки на существование переменной даёт нам ещё один подход в программировании на JS. Если вы вдруг не знаете про принцип "если эта фигня крякает, то она — утка", то я вкратце объясню. При работе с абстрактным объектом внутри функции вам, чаще всего, от него нужны только конкретные вещи, остальные его "способности" вас не волнуют. Если вам нужен компонент, на который можно кликнуть (чтобы сэмулировать клик или назначить CSS-класс, например), то вам всё равно, кнопка это или чекбокс. В других языках со статической типизацией типа Java для этого нагромождаются интерфейсы: чтобы сказать "вот этот объект, который можно нажать":

    public interface HasATail {
        public void pull();
    }

    public interface MayScream {
        public void scream();
    }

    public class Tortoise extends Animal implements HasATail {
        . . .
    }

    public class Cat extends Animal implements HasATail, MayScream {
        . . .
    }

    public List<HasATail> findAllAnimalsHavingTail() {
        . . .
        for (Animal animal: zoo) {
            if (animal instanceof HasATail) {
                tailHavers.add(animal);
            }
        }
        return tailHavers;
    }

А если надо найти всех, у кого одновременно есть хвост и кто может кричать (ну, чтобы дёрнуть), так это надо заводить новый интерфейс `HasATailAndMayScream` или возвращать `List<Animal>`, что тоже как-то не ок.

Смотрите, насколько изящнее это же делается в JavaScript, всего лишь одна функция, которая ищет хвостатых и нежных жертв, чтобы над ними поиздеваться: она принимает массив из абсолютно любых объектов и накапливает из них тех, у кого есть хвост и они могут издавать звуки

    function find_victims(zoo) {
        var victims = [];
        var i = zoo.length,
            animal;
        while (animal = zoo[--i], i) { // i должен быть последним,
                                       // чтобы while проверял его значение,
                                       // а не значение animal
                                       // см. статью про оператор запятую
            if (animal.tail && animal.scream) victims.push(animal);
        }
        return victims;
    }

Теперь упростим задачу создания животных. Эти конструкции вобще не касаются функции `find_victims`, ни за что не подумайте. Вы сами ниже увидите, как она отлично справляется без них.

    function WithTailAndMayScream() {
        this.tail = true; this.scream = function() {};
    }
    function SilentButHasTail() {
        this.tail = true; this.scream = null;
    }

Так-с, теперь сами животные на подходе:

    var Cat = WithTailAndMayScream,
        Elephant = WithTailAndMayScream,
        TinyBird = WithTailAndMayScream,
        Lion = WithTailAndMayScream,
        Bear = WithTailAndMayScream; // Всегда будьте осторожны с запятыми,
                                 // одна точка с запятой в неверном месте
                                 // и глобальный scope загажен. Но JSHint
                                 // вам поможет. Просто будьте ответственны.
    var Tortoise = SilentButHasTail;

Наконец, используем её.

    find_victims([
        {},              // не жертва
        function() {},   // не жертва
        53,              // не жертва
        // не жертва
        { 'scream': function() {} },
        // не жертва
        { 'tail': false, 'scream': function() {} },
        // тоже не жертва
        { 'tail': true, 'scream': null },
        // ну наконец-то, хоть и непонятно кто!
        // (я же говорил, конструкторы необязательны)
        { 'tail': true, 'scream': function() {}, 'foo': 42 },
        // подходит!
        new Cat(),
        // и этот пойдёт!
        new Elephant(),
        // птичка-невеличка
        new TinyBird(),
        // немая, не пройдёт
        new Tortoise(),
        // хм...
        new Lion(),
        // чёрт...
        new Bear()
    ]);

Теперь вы понимаете как сработал трюк с `Array.prototype.push.call` — если прикинуть, то встроенный метод массива `push` выглядит, скорее всего, как-то так:

    Array.prototype.push = function(what) {
        this[this.length++] = what;
    }

Никто не проверяет, является ли `this` массивом. Мы взяли, да подставили вместо `this` объект с подставным свойством `length` — и вуаля! На самом деле через эту подлость раскрывается очень серъёзный момент, _дзен JS_:

> Если вы пишете на JS — делайте так же, как и сам язык ведёт себя с вами — _доверяйте тому, кто будет ваш код использовать_. Кришна! Впрочем, этот принцип доверия можно перефразировать и по-другому, не меняя его актуальности: "Если пользователь подсунул вам фигню, значит он сам этого хотел". И если пользователь не дал вам того, что вы хотели — вместо того, просить пытаться обезопасить его, словно близкий родственник, обходя все возможные ситуации, лучше честно выкиньте ему какую-нибудь прямую и понятную ошибку.

Что было бы, если бы просто вызвали `animal.scream()` в какой-нибудь функции...

    function scream_with(animal) { animal.scream(); }

А пользователь бы дал ей что-то совсем не то?

    scream_with(15);
    // TypeError: Object 15 has no method 'scream'

Прекрасно, как видите, движок языка сам проверил за вас всё что нужно и дал пользователю прямой и чёткий совет, как поступить. Вспомните, мы же сами любим именно такую заботу.

Если вы очень много писали на Java, то знаете, что такое "быть слабоватым на паттерны". Если вы поищете примеры паттернов на Питоне или JS, то вы очень удивитесь, насколько они компактнее выглядят, и в основном выигрыш идёт за счёт duck typing. Насколько компактнее? Да в десятки раз! ([Вот][13] одна хорошая книжка по JS-паттернам, я бы не назвал приведённые там примеры оптимальными, да и сама она размером как-то крупновата для такой темы (кто бы говорил, скажете вы), но тем не менее; [А вот][14] сборник паттернов, собранных по сусекам интернета и, честно говоря, многие тамошние реализации мне претят значительно больше, чем варианты из книги (хотя там есть парочка и из неё самой) — явно, авторы читали мою статью, очень похожий стиль — возможно даже украли парочку примеров; я шучу, конечно же, не подумали же вы что я промолчу и не подам на них в суд; P.S. если что, то я всё ещё шучу, чмоки-чмоки).

Поэтому:

> _Не преумножайте сущности сверх необходимого_. Дружите с утками.

##### arguments. II.

Чёрт, я же совсем забыл, у нас же так и висит нерешённая проблема! Теперь, впрочем, мы знаем достаточно всего, чтобы с ней разобраться.

Настало время раскрыть правду и признаться, что `arguments` — это не массив. Да ну бросьте, вы и сами это знали! Это довольно хитрый объект и не время сейчас вдаваться в его тонкости (о которых, кстати, тоже написано [в JS Гарден][js-garden-args]), главное, что большую часть времени он действует как массив.

    var __s = Array.prototype.slice; // видите, мы просто сохранили функцию в переменной
    function got(value)  { return "I've got a " + value; };
    function need(value) { return "I need some " + value; };
    function say(func, val1, val2) { var args = __s.call(arguments),
                                         func = args[0],
                                         to_display = args.;
                                     console.log(func(val1));
                                     console.log(func(val2)); }

#### Прототипы. II. Клонирование.

Заметили ли вы разделе "`this`", как мы применяли два способа определения методов:

    function Mom(name) {
        this.name = name;
    }
    Mom.prototype.cook = function() {
        /* ... */ // вкусно!
    }

    function Dad(name) {
        this.name = name;
    }
    Dad.prototype.punish = function(son, way) {
        /* ... */ // даже не пытайтесь представить
    }

    var my_mom = new Mom('Violetta');
    // замените на dontWorryIamPregnant, если вы девушка
    my_mom.dontWorryMyGirlIsPregnant = function(baby_name) {
        /* ... */ // ей можно рассказать!
    }
    var my_dad = new Dad('Judith'); // ну, бывают такие имена
    my_dad.giveMeSomeMoney = function(howMuch) {
        return howMuch / 2000;
    }

В чём отличие между методом `cook` и методом `dontWorryMyGirlIsPregnant`? Готовить умеют все мамы (ну, почти), а вот спокойно отреагировать на раннюю беременность может не каждая — возможно, только ваша. Дать хоть сколько-нибудь денег, если хорошо попросить, тоже может отнюдь не каждый папа. В этом основное различие "прототипа", шаблона среднестатистической мамы, от конкретного экземпляра: спокойной мамы Виолетты.

В этом причина классовой ненависти у разработчиков JavaScript. Ваш объект (экземпляр) вовсе не обязан иметь шаблон, хотя и может. Если вам во всём проекте нужно работать только с одним индивидуальным объектом, Виолеттой, то зачем вам описывать каких-то призрачных среднестатистических мам?

    // правильный путь
    var my_mom = { name: 'Violetta' };
    my_mom.cook = function() { /* ... */ }
    my_mom.dontWorryMyGirlIsPregnant = function() { /* ... */ }

И только если вам вдруг понадобилось более трёх-четырёх мам (например, вы делаете сайт для сериала про трудное детство современной английской молодёжи), вы можете создать шаблон и наштамповать их столько, сколько вы хотите.

> _Не преумножайте сущности сверх необходимого_. Дружите с мамами.

##### Про библиотеки. Лирическое отступление.

Я сторонник такого подхода: Если мне нужна простая "штука", а её нет под рукой, то: Если она не вынуждает меня дублировать или визуально портить код, то я просто откажусь от неё и поищу способ ещё проще; Иначе я напишу её сам. Если я не использую JS 1.8, в котором [есть итераторы и генераторы][12], то я не возьму стороннюю библиотеку только ради того, чтобы их добавить — даже если вспомнить об отличных MooTools, которые можно распределять по группам фич и брать по отдельности, я не возьму другую библиотеку. Если я вдруг увижу, что без генераторов мне не обойтись, то я напишу свою личную локальную, достаточную для меня, реализацию на не более чем 10 строк, в худших случаях 15. Я возьму библиотеку и/или плагин только если точно знаю, что буду использовать минимум 65-70% её возможностей. И поскольку с описанным подходом таких utils-функций у меня оказывается в среднем по три-пять штук на проект, не больше — я уже давно такого не делал.

Это не потому, что я не люблю чужие библиотеки и/или чужой код, я их очень люблю и часто подсматриваю их код в гугле. Я просто всегда помню, что одна моя функция добавит в код загружаемой вами страницы 500 байт, а библиотека — 2500. Это было бы паранойей во многих языках, но я не считаю это паранойей в JS — в тех случаях, когда важен Load Time. В других языках меньше библиотек "на все случаи жизни", чаще модули там чётко разделены, а не зависят друг от друга длинными цепочками. И эти модули добавляют не 60 странных функций, из которых нужны 10, за счёт которых можно сделать 80 других. Для многих языков вариант взять библиотеку предпочтительнее ещё потому, что она отлажена и написана несколькими людьми (ещё лучше, если она написана с использованием нативных функций), которые знают свой язык. С JS же исторически сложившаяся ситуация такова, что всё смешалось в большую кучу, кони и люди. Язык обновляется, но кое-где всегда различается, в нём нет стабильности версий, в нём слишком много свободы, которой не все умеют пользоваться. Знать тонкости языка не входит в привычку

Конечно, если нужна библиотека виджетов типа ExtJS или просто необходима генерация по шаблонам, то глупо писать это всё самому. И я не называю "библиотеками" файлы на 300-500 строк. Но самому, на чистом JS, всегда можно написать простую галерею строк на 100, несложный виджет на строк 200 или механику обработки событий на те же 100. Просто не надо входить, распахнув дверь, сея классами и иерархиями направо и налево.

Эта статья здесь в основном как раз для того, чтобы показать вам, насколько компактный, простой и при этом понятный код можно писать на JS, если смотреть на него по-функциональному. И я стараюсь давать такой код, который заработает в любом современном JS-окружении, итераторы и генераторы, к сожалению, пока есть не в каждом.

Просто _не преумножайте сущности сверх необходимости_. Пожалуйста.

> И всё сказанное _не_ относится к node.js, конечно же. Язык тот же, но подход к библиотекам и версиям в node.js совсем не такой деревенский, и там взять один-другой модуль меня никогда не смущало и скорее всего не будет. Авторы внесли ограничения в свободы языка, поэтому мало у кого тянутся руки развернуться на мегабайты кода.

##### Функциональщина.

<!-- TODO --> (Каррирование?)

##### Чистые функции.

<!-- TODO -->

##### Монада state.

<!-- TODO -->

##### deferred a.k.a. bind.

<!-- TODO -->

##### Полноценные очереди.

<!-- TODO -->

##### Генераторы.

<!-- TODO -->

##### Хождения по древу.

<!-- TODO -->

##### Именованные аргументы

<!-- TODO -->

#### Области видимости.

<!-- TODO -->

#### Модули.

    (function() {})( /* ... */ )

    ModuleFactory = { 'modules': [] };
    ModuleFactory.update = function(name, func) {
       var scope = (this.modules[name]) || {};
       func.call(scope);
       this.modules[name] = scope;
       return scope;
    }

### Модули

И всё-таки, после всего, я осознал, что уже рассказал вам обо всём, что мог, в кратком первом разделе. Кстати, пока я кропел над этой статьёй, я встретил в сети другую, [про функциональное программирование в Ruby][10], и там было хорошо сказано: "Всё — это функция". "Объект — это функция". "Модуль — это функция". "Миксин — это функция". И я понял — воистину так. Загадка разгадана. Бог — это функция. Эта статья — это функция. Надо возвращаться к бюрократическим языкам, в которых всё — это список. Может они ещё не знают про функции?

Надеюсь, у вас не осталось от прочтения статьи "кухонного" ощущения, потому что у меня осталось. Будто бы я повар в ресторане, а вы пришли ко мне учиться, и я быстро прошёлся по рецептам и блюдам, перепрыгивая с одного на другое, и оставил вас барахтаться в кипе информации. Но я ничего уже не могу поделать. Пожалуйста, сконцентрируйтесь на общем запахе этих блюд. А потом возвращайтесь, если понадобится, и я постараюсь рассказать вам только в рамках нужной вам кулинарной темы.

И ещё, если вы добрались до сюда, то отмечу, что больше не планирую писать больших и теоретических статей по JS, это последняя. Маленькие и практические — возможно, а такие — хватит, устал.

### Объекты

#### Duck Typing vs. instanceof

<!-- TODO -->

### Литература

* [Доклад «Правильный JavaScript»][2] ([слайды][5], [видео][6], [литература][7])
* [«JavaScript Гарден»][js-garden]
* [«Путь асинхронного самурая»][1]
* [«Оператор запятая»][4]
* ["Adventures in Functional Programming With Ruby"][10] (наткнулся на схожую по духу статью пока писал эту)
* ["Can Your Programming Language Do This?"][11] от Джоэля Спольски
* ["JavaScript Patterns Collection"][14]
* ["Learning JavaScript Design Patterns"][13]
* [Examples of beautiful Javascript @ SO][15]

[1]: ../the-way-of-asynchronous-samurai
[2]: ../javascript-the-right-one-announce
[3]: http://nodejs.org
[4]: http://habrahabr.ru/post/116827/
     http://javascriptweblog.wordpress.com/2011/04/04/the-javascript-comma-operator/
[5]: http://shamansir.github.com/js-lecture-wsd
[6]: https://vimeo.com/33393795
[7]: https://github.com/shamansir/js-lecture-wsd/blob/master/LITERATURE.md
[8]: https://github.com/marijnh/CodeMirror2/blob/master/lib/codemirror.js#files
[9]: https://github.com/marijnh/CodeMirror2/blob/master/mode/javascript/javascript.js#files
[10]: http://www.naildrivin5.com/blog/2012/07/17/adventures-in-functional-programming-with-ruby.html
[11]: http://www.joelonsoftware.com/items/2006/08/01.html
[12]: https://developer.mozilla.org/en/JavaScript/Guide/Iterators_and_Generators
[13]: http://addyosmani.com/resources/essentialjsdesignpatterns/book/
[14]: http://shichuan.github.com/javascript-patterns/
[15]: http://stackoverflow.com/q/3894895/167262

[email]: mailto://shaman.sir@gmail.com
[js-garden]: http://bonsaiden.github.com/JavaScript-Garden/ru/
[js-garden-args]: http://bonsaiden.github.com/JavaScript-Garden/ru/#function.arguments
[js-garden-types]: http://bonsaiden.github.com/JavaScript-Garden/ru/#types.equality
[js-garden-this]: http://bonsaiden.github.com/JavaScript-Garden/ru/#function.this
[nek]: https://github.com/Nek