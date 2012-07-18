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

Have you seen [CodeMirror2 source][8], the editor of the any code, which is itself writen in JS? The one that is used in JSFiddle, JSBin, LightTable IDE and, oh Buddah, almost everywhere. The better case — [the source of one of its modules][9]? _This_ is the sample code, free of any libraries and devoid of unnecessary objects, you should focus on and take as a great example!

> И нет, я не буду упоминать CoffeeScript в этой статье. Объясню мой принцип коаном. Представьте, что CoffeeScript — это орех каштана на вашем пути — лучше не трогать, если не знаете как он работает изнутри. Его плод полезен, но вы должны понимать, что он чужой для сложного и самодостаточного (я докажу это) организма JavaScript. Если же он лежит без оболочки, то без должной внимательности, вы можете — эй-эй, нет, не наступай!.. опа! — подскользнуться. Впрочем, если правда всё-всё осознаёте, то пробуйте — он правда хорош и сэкономит ваше драгоценное время. Но что тогда вы делаете здесь?). 

> And no, I will not mention CoffeeScript in this article. I'd explain it with a koan. Imagine CoffeeScript to be a chestnut on your way — better not to touch it, if you don't know the way it works from the inside. Its core is beneficial, but you need to understand that it is an alien for a complex and all-sufficient (I'll prove it) JavaScript organism. However, if it lies on the road with no burr, you may — oh no, don't step!.. oops! — slip over it. But — if you really-really truly do understand everything, please feel free to taste it — CoffeeScript is pretty and saves you some valuable time. But if you do, why are you here?)

И ещё.

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

Функции — это сила JavaScript. И функции — это швейцарский нож в JavaScript. С помощью функции можно сделать всё. Это ваш жёлтый кирпич на пути к волшебству (мамочки, как же пошло!). С другой стороны, вы правы, эти утверждения не менее верны и для разных других языков с явно выраженной функциональностью — но в JS вы можете относиться к функциям значительно проще, никто не требует от вас полной их чистоты, и в этом ваша свобода. Я постараюсь провести вас от элементарных вещей к профессиональным трюкам всего за одну малюсенькую главу. Это вообще могла быть единственная глава в этой статье, но две оставшихся требуют пары отдельных пояснений.

Functions are the power of JavaScript. And functions are the swiss knife of JavaScript.

Не все функциональные подходы есть в JS из коробки, но многие из них можно эмулировать через две-три строчки кода, даже не используя библиотек. Но, сначала немного об основах.

#### Основы

##### arguments

Вот как выглядит в JavaScript обычная функция:

    function my_function(arg1, arg2) {
        console.log(arguments); // волшебная переменная
        console.log(arg1, arg2);
        return undefined; // необязательная строка
    }
    my_function('foo', 'bar');
    // > ["foo", "bar"]
    // > foo bar
    // < undefined

`arguments` — один из многих секретов функций в JS, он хранит список переданных в функцию аргументов. Разве он не кажется вам соседом `*args` из Python? Вы даже можете эмулировать `**kwargs` (именованные аргументы и значения по умолчанию) при должном желании! Этот первый пример, но и он скучен только потому, что пока нигде не привлекался.

##### return

Если в функции не указано оператора `return ...;`, она возвращает `undefined`. То что `undefined`, как и `null`, как и `0`, как и пустая строка, считается ложью, позволяет вам определять "неудачу" операции, если функция ничего не вернула

> но не в случае арифметических операций: если только у вас нет пунктика, благодаря которому вы всегда считаете нулевой результат неудачным.

    function has_coffee() {
        // какой-то сложный код, который подключается к мейнфрейму
        // умного дома и спрашивает, может ли тот приготовить кофе,
        // достаточно ли у него зёрен и прочистил ли он лоханку
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

##### Функция — это объект

Если вы всё же намеренно забудете скобки, то таким образом вы проверите переменную `has_coffee` на существование и неравенство `null`, `0`, и что там дальше по списку. Прикол в том, что переменная `has_coffee` существует: и без скобок `if (has_coffee) { ... }` будет выполняться _всегда_! Почему `has_coffee` существует? Да потому что функция с таким именем определена — и это объект. Это ещё один секрет, который даёт вам огромную массу возможностей. Смотрите, эти два выражения эквивалентны:

    // первое
    function has_coffee() { ... }
    // второе
    var has_coffee = function() { ... }

Надеюсь, вы ясно видите из второго выражения, что функция — это полноценная переменная, ничем не отличающаяся от других. Будьте толерантны, и вы сможете передавать её в другие функции как аргумент, откладывать её вызов, обманывать её, подсовывая "чужой" контекст, вызывать рекурсивно через раз и делать прочие, услаждающие вашу властность, вещи.

##### Снова return

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

> Ещё один, оптимизированный, и на этот раз упорядоченный, проход циклом по массиву выглядит так:

>    var my_array = [ 0, 16, 24, 2, 17 ];
>    for (var i = 0, il = my_array.length; i < il; i++) {
>        console.log(my_array[i]);
>    }
>    // > 0
>    // > 16
>    // > ...

> "Оптимизаторство" здесь в том, что, в отличие от академической формы (`for (var i = 0; i < my_array.length; i++)`), мы заранее сохраняем значение длины массива и не вычисляем его на каждой итерации. Здесь нам помогает другой секрет — ["оператор запятая"][4]. Обязательно прочтите статью по ссылке, она самодостаточна и подробно описывает все возможности этого маленького и бесконечно прекрасного создания: если бы такой статьи не было, пришлось бы добавлять в ту, которую вы читаете, целый дополнительный раздел. Потому что это маленькое создание используется в статье повсеместно.

##### Арифметика опасносте

Наконец, чтобы предостеречь вас от неожиданностей, обращу ваше внимание на ещё один момент с возвращением `undefined` — беда с приведением типов.

Посмотрим, что будет, если мы будем неосторожно баловаться с арифметикой (пожалуйста, не используйте для подсчёта зарплат):

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

##### Снова функция — это объект

То, что функция — объект, позволяет вам обращаться с ней как с обычной переменной (не усердствуйте с унижениями, пожалуйста!). Вы можете передавать её в другие функции и вызывать прямо оттуда, без тени стеснения:

    function got(value)  { return "I got the " + value; };
    function need(value) { return "I need some " + value; };
    function say(manner, first, second) { 
        // выводит в консоль результат вызова функции
        // с первым значением в качестве параметра
        console.log(manner(first));
        // выводит в консоль результат вызова функции
        // со вторым значением в качестве параметра
        console.log(manner(second)); 
    }
    say(got, 'poison', 'remedy');
    > "I got the poison" 
    > "I got the remedy"
    say(need, 'love', 'affection');
    > "I need some love" 
    > "I need some affection"

Как замечательно, ну-ка споём старую добрую D.I.S.C.O.:

    function pronounce_letter(value) { return value.toUpperCase() + '.'; }
    say(pronounce_letter, 'd', 'i', .... // :(

Стоп. Однако, выходит, что наша функция ограничена всего двумя возможными параметрами и наша песня под угрозой срыва. Хотелось бы использовать `arguments` как-нибудь так, чтобы можно было передать неограниченное число объектов и начать дискотеку...

> Есть, безусловно, пара вариантов решения на данный конкретный случай, которые можно было бы предложить вам прямо на месте — например, передать строку одним аргументом и разбить её на символы. Но тогда бы в статье вовсе не было драматического момента — и как бы, тогда, скажите пожалуйста, я подвёл вас к следующим главам? Как настоящий учитель, оставлю вам это на домашнее задание.

Но для этого придётся погрузиться во внутренности функций в JS.

##### Анонимные функции

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

Да, это та самая лямбда. Некоторых почему-то коробит синтаксис написания, требующий `function`, будто это сильно больше чем `lambda` в Python (но в Хаскеле правда сильно короче). Я встречал целые библиотеки, которые "укорачивали синтаксис" JS-варианта лябмды. Эй, может в вашем редакторе не поддерживаются сниппеты, если вам так сложно напечетать пару букв, которые только сработают на читабельность? Может Хаскель — это не здесь, АА?!!.. АА?!!.. Зачем вы принесли свой самовар?.. Простите, задел сам себя за живое, пойду-ка сделаю пару сеппуку и вернусь — пожалуйста, никуда не уходите.

. . .

Вспомните:

    // второе
    var has_coffee = function() { ... }

Здесь справа вы видите ту же самую анонимную функцию, а имя ей назначается уже по факту присвоения переменной. Можно, кстати, считать формат `function has_coffee() { ... }` краткой записью этого эе самого выражения.

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

Вы пробовали показывать на каком-нибудь собеседовании ряд Фибоначчи, записанный оператором `for` без тела? Разве не похож этот код на улитку, томно взбирающуюся пропорционально увеличивающимися ползками на Эверест? Правда, будем честными, эта улитка просто-напросто выглядит эффектно — в реальной жизни таким злоупотреблять не стоит.

Теперь вы правда готовы к безумию настолько, что можете создать массив из функций и вызывать их по очереди:

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

Когда функции входят в вашу жизнь, она расцветает потаёнными возможностями — вы начинаете осознавать, что их можно комбинировать, пересекать, выстраивать в круги, заставлять их танцевать схватившись за возвращаемые значения и щекотать их, чтобы они пробегали друг под другом. Становится возможно всё! Ох, я увлёкся, а ведь это ведь вовсе ещё не конец статьи, и самое интересное впереди.

##### Функции, которые возвращают функции

Очень удобно возвращать из одних функции другие функции — засчёт этого можно генерировать очень хитрые вещи. Например, давайте-ка создадим простейший итератор:

    function iter(list) {
        var ll = list.length,
            li = 0;
        return function() {
            if (li === ll) return false;
            return list[li++];
        }
    }
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

<!-- TODO: ещё пример -->

##### Вызов на месте

<!-- TODO -->

##### Замыкания

<!-- TODO -->

##### Рекурсия

Конечно же, в JS есть рекурсия. Она ничем не отличается от соседних языков, так что достаточно простого примера:

    // функция. которая рассчитывает точки для 
    // рисования звезды
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

##### this

Если смотреть на объекты с позиции функци, те окажутся не более чем хешами со строками-ключами; внутри них часть, или даже все, значений могут быть функциями, но пока дело не доходит до вызовов, внешним функциям плевать и на это. Но всё равно всё, как всегда, чуточку глубже. Скажите, в чём принципиальная разница между этими тремя объектами?:

    var a_j = { 'age': 15, 'hair': 'black', 'voice': 'soprano', 
                // знакомая анонимная функция
                'getToeLength': function() { return this.age * 0.3; } };
    a_j.getToeLength();
    // > 4.5

    var a_j = new Object();
    a_j.age = 15;
    a_j.hair = 'black'; 
    a_j.voice = 'soprano';
    a_j.getToeLength = function() { return this.age * 0.3; };
    a_j.getToeLength();
    // > 4.5

    function Human(age, hair, voice) {
        this.age = age;
        this.hair = hair;
        this.voice = voice;
    }
    Human.prototype.getToeLength = function() { return this.age * 0.3; }
    var a_j = new Human(15, 'black', 'soprano');
    a_j.getToeLength();
    // > 4.5

Ни в чём, кроме того, что с помощью функции `Human` мы теперь может штамповать людей с различными свойствами и методами по одному шаблону. Кстати, этот шаблон ("прототип") тоже определяется через функцию... Ух ты! Функция-шаблон, напичканная значениями и функциями, ничего себе! Это вам не классы ;)

А вы заметили ключевое слово `this` в методе `getToeLength()`?

Скорее всего вам уже говорили, что этот `this` не такой, как в других языках. Тсс, это ещё один секрет. И снова я отошлю вас за истеричными подробностями [в JS Гарден][js-garden-this]. Нам лишь важно знать, что если функция "висит в воздухе", не привязана к какому-либо объекту, то `this` внутри такой функции будет указывать на область, в которой она описана (с оговорками, о них в примере ниже). Если такой области нет, то это будет глобальная область видимости — например, `window`. Но как компилятор JS видит, что функция каким-то образом привязана к объекту? Ведь столько способов их связать! На самом деле просто происходит позднее связывание, то есть `this` устанавливается во время фактического вызова такой функции, а не на этапе компиляции. Типа JS говорит ей: "Да-да, я тебя запомнил, дорогая функция, но кто твой виз-а-ви, родная, ты узнаешь непосредственно при встрече, уж прости. Не исключено, что придётся перепопробовать несколько партнёров."

Приведу небольшой листинг с доказательством этой теоремы:

    // функция, с которой мы будем играть
    function some_func() {
        console.log(this.foo);
    }

    var obj = { 'foo': 42, 'some_func': some_func };
    some_func(); // вызов без привязки к объекту
    // > undefined
    obj.some_func(); // вызов с привязкой к объекту
    // > 42

    some_func.prototype.some_func = some_func; // вы чувствуете власть?
    var another_obj = new some_func(); // что-то не так?
    // > undefined // мы "случайно" вызвали функцию
    another_obj.foo = 34;
    another_obj.some_func();
    // > 34
    obj.some_func();
    // > 42

    // попробуем позабавляться с методами

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

    this.foo = 63; // а что, вне функций у нас тоже есть `this`
    some_func();
    // > 63

> В этом примере есть небольшая разница в объявлении методов, если вы заметили. Не переживайте, мы вернёмся к ней, когда будем говорить о клонировании в главе Объекты.

Почему последние две строчки действуют не так, как такой же, кажется, код внутри `another_obj.method`? На самом деле мы находимся <s>в матрице</s> _(зачёркнуто)_ внутри невидимого глобального объекта (в браузере это `Window`), и все объявленные функции становятся его методами, то есть написать `some_func() {...}` эквивалентно `this.some_func = function() { ... }` вне каких либо функций, где `this` указывает на его величество. Этот глобальный объект довольно аггресивен и считает все свободно валяющися `this` своими личными. Для него не имеет ни малейшего значения, что функция объявлена внутри метода, если внутри него мерещится незанятый `this`, источающий питательные флюиды. Именно поэтому не рекомендуется ему давать много лишнего — только подумайте, детки, как опасно разжечь его аппетит. Попробуйте теперь вызвать `another_obj.method`:

    another_obj.method();
    // > 53
    // > 63 // захавал, скотина!

На самом деле эта проблема решается ещё легче, и об этом следующая подглава.

##### Манипуляция функциями через call и apply

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

`call` и `apply` различаются только в способе передачи параметров в метод: если у вас есть подготовленный массив готовых параметров, используйте `apply`, если нет — `call`:

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

    function phone(phrase1, phrase2, phrase3) {
        if (phrase1) console.log(phrase1, '->', this[phrase1]);
        if (phrase2) console.log(phrase2, '->', this[phrase2]);
        if (phrase3) console.log(phrase3, '->', this[phrase3]);
    }

    phone.call(Josie, 'how_are_you', 'some_news', 'bye');
    // > how_are_you -> Oh, great, sweetie!
    // > some_news -> I want a dress!
    // > bye -> OK, I'll buy.

    var standard_talk = [ 'hi', 'how_are_you', 'bye' ];    
    phone.apply(Minnie, standard_talk);
    // > hi -> Good morning, Mickey!
    // > how_are_you -> Sweet, Mickey!
    // > bye -> Kisses, Mickey!

    phone.apply({'hi', 'Shhh...', 'what': 'Shhh...'},
                ['hi', 'what']);
    // > hi -> Shhh...
    // > what -> Shhh...

Ещё раз повторюсь, что используя `call` или `apply` можно обмануть метод любого объекта, подставив ему ссылку на что угодно:

    another_obj.method.call({ 'foo': 40 });
    // > 40
    // > 40
    Human.prototype.getToeLength.call({ 'age': 40 });
    // > 12

    // держитесь за стул:
    var stooge = { length: 14 };
    Array.prototype.push.call(stooge, 'a');
    console.log(stooge);
    // > { 'length': 15, '14': 'a' };

Обычно `[].push` работает так:

    [ 'a', 'b' ].push('c');
    // > [ 'a', 'b', 'c' ];

Но мы сделали с вами сделали вид, что мы — утка. Будучи на самом деле объектом, мы подло прикинулись массивом, подставив ложное свойство `length` и доверчивый JS принял всё на веру. Обещал же я вам фокусы? Обещал же?). Секрет фокуса с уткой-шпионом я раскрою через главу.

#### Функции, которые возвращают объекты

Если возращать объект, итератор, черновик которого мы писали пару подглав назад, будет ещё больше похож на "правильный":

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
    var l_iter = iter(list);
    while (l_iter.hasNext()) {
        console.log(l_iter.next());
    }
    // > 7
    // > 16
    // > 24
    // > 5

##### Снова вызов на месте

<!-- TODO -->

##### Прототип

Не могу не вставить пару слов о прототипах, иначе нельзя будет совсем уже нельзя продолжать дальше.

Если есть функция-конструктор (или функция — "фабрика клонов")...

    // сейчас она ничем не отличается от обычной функции, 
    // вы просто решили, что быть ей в этой жизни конструктором
    function Clone() { ... }

...то она может хранить в себе "прототип": поименованную таблицу (хэш) свойств и функций, ссылки на которые будут храниться в каждом новом экземляре, созданном в этой фабрике. Именно _ссылки_ — то есть если изменить/подменить эти свойства или функции в прототипе, то они изменятся у всех созданных экземпляров. Всё же, что присваивается `this` в конструкторе, индивидуально создаётся для каждого нового экземпляра:

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

##### Duck typing

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

Смотрите, насколько изящнее это же делается в JavaScript, всего лишь одна функция:

    // принимает массив из абсолютно любых объектов
    // и накапливает тех, у кого есть хвост и они
    // могут издавать звуки
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

    // Используем:
    // эти конструкторы — только для демонстрации,
    // они вовсе необязательны
    function WithTailAndMayScream() {
        this.tail = true; this.scream = function() {};
    }
    function SilentButHasTail() {
        this.tail = true; this.scream = null;
    }
    var Cat = WithTailAndMayScream,
        Elephant = WithTailAndMayScream,
        TinyBird = WithTailAndMayScream,
        Lion = WithTailAndMayScream,
        Bear = WithTailAndMayScream; // Всегда будьте осторожны с запятыми,
                                 // одна точка с запятой в неверном месте
                                 // и глобальный scope загажен. Но JSHint
                                 // вам поможет. Просто будьте ответственны.
    var Tortoise = SilentButHasTail;
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

Теперь вы понимаете как сработал трюк с `Array.prototype.push.call` — встроенный метод массива `push` выглядит, скорее всего, как-то так:

    Array.prototype.push = function(what) {
        this[this.length++] = what;
    }

Никто не проверяет, является ли `this` массивом. Мы взяли, да подставили вместо `this` объект с подставным свойством `length` — и вуаля! На самом деле через эту подлость раскрывается очень серъёзный момент, _дзен JS_: 

> Если вы пишете на JS — делайте так же, как и сам язык ведёт себя с вами — _доверяйте тому, кто будет ваш код использовать_. Харе! Хотя, это доверие можно перефразировать по-другому: "Если пользователь подсунул вам фигню, значит он сам этого хотел". И если пользователь не дал вам того, что вы хотели — вместо того, просить пытаться обезопасить его, словно близкий родственник, обходя все возможные ситуации, лучше честно выкиньте ему какую-нибудь прямую и понятную ошибку.

Что было бы, если бы просто вызвали `animal.scream()` в какой-нибудь функции...

    function scream_with(animal) { animal.scream(); }

А пользователь бы дал ей что-то совсем не то?

    scream_with(15);
    // TypeError: Object 15 has no method 'scream'

Прекрасно, сам язык проверил за вас всё что нужно и дал пользователю прямой и чёткий совет.Вспомните, мы же сами любим именно такую заботу. Поэтому:

> _Не преумножайте сущности сверх необходимого_. Дружите с утками.

##### Снова arguments

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


##### Функциональщина наступает

<!-- TODO --> (Каррирование?)

##### Чистые функции

<!-- TODO -->

##### Монада state

<!-- TODO -->

##### deferred a.k.a. bind

<!-- TODO -->

##### Полноценные очереди

<!-- TODO -->

##### Генераторы

<!-- TODO -->

##### Хождения по древу

<!-- TODO -->

##### Именованные аргументы

<!-- TODO -->

### Модули

#### Области видимости

<!-- TODO -->

### Объекты

#### Клонирование и Прототипы

Заметили ли вы разделе "`this`" из главы о функциях, что мы применяли два способа определения методов:

    function Mom(name) {
        this.name = name;
    }
    Mom.prototype.cook = function() {
        ... // вкусно!
    }

    function Dad(name) {
        this.name = name;
    } 
    Dad.prototype.punish = function(son, way) {
        ... // даже не пытайтесь представить
    }

    var my_mom = new Mom('Violetta');
    // замените на dontWorryIamPregnant, если вы девушка
    my_mom.dontWorryMyGirlIsPregnant = function(baby_name) {
        ... // ей можно рассказать!
    }
    var my_dad = new Dad('Judith'); // ну, бывают такие имена
    my_dad.giveMeSomeMoney = function(howMuch) {
        return howMuch / 2000;
    }

В чём отличие между методом `cook` и методом `dontWorryMyGirlIsPregnant`? Готовить умеют все мамы (ну, почти), а вот спокойно отреагировать на раннюю беременность может не каждая — возможно, только ваша. Дать хоть сколько-нибудь денег, если хорошо попросить, тоже может отнюдь не каждый папа. В этом основное различие "прототипа" — шаблона среднестатистической мамы и конкретного экземпляров: спокойной мамы Виолетты.

В этом причина классовой ненависти в JavaScript. Ваш объект (экземпляр) вовсе не обязан иметь шаблон, хотя и может. Если вам нужно работать только с одним индивидуальным объектом, Виолеттой, то зачем вам описывать каких-то призрачных среднестатистических мам?

    // правильный путь
    var my_mom = {};
    my_mom.cook = function() { ... }
    my_mom.dontWorryMyGirlIsPregnant = function() { ... }

И только если вам вдруг понадобилось несколько мам, вы можете создать шаблон и наштамповать их столько, сколько вы хотите.

#### Duck Typing vs. instanceof

<!-- TODO -->

#### Прототипы

<!-- TODO -->

#### Миксины

<!-- TODO -->

    var c = b().circle([0, 0], 20);
    for (var i = 0; i < 30; i++) {
        c.add(b(c).move([10, 10])); // will add 30x30 children to tree 
    } // this will end up with hanging player
    
    // safe way with nesting:
    var c = b().circle([0, 0], 20);
    for (var i = 0; i < 30; i++) {
        c.add(c = b(c).move([10, 10])); // will nest every new child a level below
    }
    
    // safe way with 30 children:
    var c = b().circle([0, 0], 20);
    var clone = b(c);
    for (var i = 0; i < 30; i++) {
        c.add(b(clone).move([i*10, i*10])); // add new clone 
    }

### Литература

* [Доклад «Правильный JavaScript»][2] ([слайды][5], [видео][6], [литература][7])
* [«JavaScript Гарден»][js-garden]
* [«Путь асинхронного самурая»][1]
* [«Оператор запятая»][4]

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

[email]: mailto://shaman.sir@gmail.com
[js-garden]: http://bonsaiden.github.com/JavaScript-Garden/ru/
[js-garden-args]: http://bonsaiden.github.com/JavaScript-Garden/ru/#function.arguments
[js-garden-types]: http://bonsaiden.github.com/JavaScript-Garden/ru/#types.equality
[js-garden-this]: http://bonsaiden.github.com/JavaScript-Garden/ru/#function.this
[nek]: https://github.com/Nek