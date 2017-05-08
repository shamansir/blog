---
layout: post.html
title: 16 полезных решений для Javascript
datetime: 12 Aug 2007 17:55
tags: [ javascript ]
---

Представляю вам набор функций, которые у меня лежат в отдельном файле `utils.js` - это функции, которые я использую чаще всего. Они стараются быть кроссбраузерными и проверены на IE6/7, FF2 и Safari 2 и на боевой, сложной системе, в XHTML документах. Должны, по идее, работать, и на других, но не очень старых версиях браузеров - проверку браузера я использовал только в исключительных случаях. Некоторая часть из них, конечно же, просто нарыта на просторах интернета (где - обычно указано) и заимствована ввиду открытости, а большая часть - сконструирована из многих ресурсов и своих идей (и советов коллег), дабы работать на ура - поскольку часто в разных скриптах не учитываются разные тонкости, которые, тем не менее - при ближайшем рассмотрении - оказываются общностями :), ну и быть довольно читабельными.

Фукнции разделены тематически:

* **[ООП](#ооп)** -- _обеспечение (или, вернее сказать - эмуляция) возможности использовать принципы ООП в JavaScript_
* **[Объектная модель JS](#объектная-модель-js)** -- _использование и расширение встроенных объектов JS_
* **[Определение браузера](#определение-браузера)** -- _чтобы использовать в тех редких случаях, когда это все-таки неизбежно необходимо :)_
* **[Координаты / Позиционирование](#координаты-позиционирование)** -- _вычисление координат и позиционирование объектов - ввиду того, что это часто довольно хитрая штука_
* **[DOM](#dom)** -- _работа с объектной моделью документа_
* **[AJAX](#ajax)** -- _вспомогательные функции для AJAX -- так как это средство часто применимо :)_
* **[Логгинг](#логгинг)** -- _иногда он нужен чтобы везде :)_

**NB!** (советы по оптимизации и исправлениям приветствуются)

**NB!** (при написании статьи примеры были взяты из рабочего кода, но в некоторых навскидку изменены названия функций и даже некоторая функциональность. также к коду функций было применено такое форматирование как переносы строк - на данный момент - без проверки последующей работоспособности. как только код будет полностью проверен на работоспособность - этот комментарий будет отсюда удален)

### ООП

<a name="sol-1"></a> _1._ Первый блок -- набор из трех функций (две из которых пустые :) ), позволяющих применять (эмулировать?) все три принципа **ООП** в **JavaScript**. Из нескольких предложенных на [AJAXPath](http://www.ajaxpath.com/javascript-inheritance) и на [AJAXPatterns](http://ajaxpatterns.org/Javascript_Inheritance) вариантов я выбрал именно этот ввиду его одновременной понятности и быстрой скорости выполнения и немного его видоизменил так? чтобы отдельно объявленные свойства воспринимались как статические константы.

``` javascript

function Class() { }

Class.prototype.construct = function() { };

Class.extend = function(def) {
    var classDef = function() {
        if (arguments[0] !== Class) {
            this.construct.apply(this, arguments);
        }
    };

    var proto = new this(Class);
    var superClass = this.prototype;

    for (var n in def) {
        var item = def[n];
        if (item instanceof Function) item.$ = superClass; else classDef[n] = item;
        proto[n] = item;
    }

    classDef.prototype = proto;

    classDef.extend = this.extend;
    return classDef;
};

```

Полные примеры использования относительно велики, поэтому я их вынесу в [следующую статью](../javascript-oop) и проследую далее. Пару простых примеров вы можете наблюдать в пунктах _[2](#sol-2)_, _[5](#sol-5)_ и _[15](#sol-15)_.

<a name="sol-2"></a> _2._ Следующая функция -- простая, но изящная -- полезна в сочетании с предыдущим набором -- она **создает функцию-ссылку на метод**:

``` javascript

function createMethodReference(object, methodName) {
    return function () {
        return object[methodName].apply(object, arguments);
    };
}

```

Теперь можно, например, сделать так:

``` javascript

var ScrollingHandler = Class.extend({

    construct:
        function(elementId) {
            this._elementId = elementId;
            this.assignListener();
        },

    assignListener:
        function() {
            var scrollControlElem = document.getElementById(this._elementId);
            if (scrollControlElem) {
                scrollControlElem.onscroll = createMethodReference(this, "_onElementScroll");
            }
        },

    _onElementScroll:
        function(ev) {
            ev = ev || window.event;
            alert("please stop scrolling, I've already got an event: " + ev);
        }
});

var elmScrollHandler = new ScrollHandler('SomeElmId');

```

Объект этого класса можно будет ассоциировать с событием скроллинга элемента с указанным ID и совершать что-либо по этому случаю.

### Объектная модель JS

<a name="sol-3"></a> _3._ Нижеприведенная функция **клонирует** любой **объект** вместе со всеми его свойствами:

``` javascript

function cloneObj(objToClone) {
    var clone = [];
    for (i in objToClone) {
        clone[i] = objToClone[i];
    }
    return clone;
}

```

Использование -- простейшее до невозможности:

``` javascript

var clonedObj = cloneObj(objToClone);

```

<a name="sol-4"></a> _4._ **Конвертер объектов**, следующая функция, позволяет удобно использовать всяческие условные (и претендующие ими быть :) ) конструкции вида `if (tablet.toLowerCase() in oc(['cialis','mevacor','zocor'])) { alert(’I will not!’) };`. Код заимствован [отсюда](http://snook.ca/archives/javascript/testing_for_a_v/).

``` javascript

function oc(a) {
    var o = {};
    for(var i=0;i<a.length;i++) {
        o[a[i]]='';
    }
    return o;
}

```

Для примера возьмем ситуацию, когда сначала требуется определить, входит ли объект в какое-либо множество одиночных объектов, а затем - не входит ли он в сочетании с другим объектом в другое множество пар объектов. Допустим, на вечеринку пускают одиночек только с определенными именами, либо пары из списка с позволенными сочетаниями имен:

``` javascript

function isPersonAllowed(maleName, femaleName) {
    var pairsAllowed = new Array([ "John", "Yoko" ],
            [ "Bill",  "Monica" ], [ "Phil",  "Sue" ],
            [ "Jason",  "Harrison" ], [ "Adam",  "Eve" ]);
    var singlesAllowed = new Array("Michael", "Pete", "John",
            "Dave", "Matthew");
    return (femaleName
            ? ([maleName, femaleName] in oc(pairsAllowed))
            : (maleName in oc(singlesAllowed)));
}

alert(isPersonAllowed("Jack")); // false
alert(isPersonAllowed("Adam")); // false
alert(isPersonAllowed("John")); // true
alert(isPersonAllowed("Phil","Marlo")); // false
alert(isPersonAllowed("Jason","Harrison")); // true
alert(isPersonAllowed("Martin","Luther")); // false

```

<a name="sol-5"></a> _5._ Функция, позволяющая создавать **хэш** сначала кажется немного излишней: объекты в JavaScript -- те же хеши, но вот иногда в качестве имени проперти/ключа требуется задать значение переменной и тогда приходит на помощь функия `Hash`. (да-да, конечно же есть встроенные возможности, но так возможно просто немного очевиднее :) -- можете исключить эту функцию из полезных, если хотите :) )

``` javascript

function Hash()
{
    this.length = 0;
    this.items = new Array();
    for (var i = 0; i < arguments.length; i++) {
        this.items[arguments[i][0]] = arguments[i][1];
    }
}

```

Доступ к элементам производится засчет свойства `items` (кстати, следует, может, в более тяжелой версии добавить `keys` :) ?):

``` javascript

var Game = Class.extend({

    STG_STOP: 0,
    STG_START: 1,
    STG_LOADING: 2,
    STG_MENU: 3,
    STG_PROCESS: 4,

    construct:
        function() { this._stage = Game.STG_LOADING; },

    getStage:
        function() { return this._stage; }

});

var stateMap = new Hash(
            [ Game.STG_START,   "start"    ],
            [ Game.STG_LOADING, "loading"  ],
            [ Game.STG_MENU,    "menu"     ],
            [ Game.STG_PROCESS, "process"  ],
            [ Game.STG_STOP,    "stopping" ]);

var someGame = new Game();
alert("You are in "+stateMap.items[someGame.getStage()]+" stage!");

```

<a name="sol-6"></a> _6._ Три других функции просто упрощают и/или делают очевиднее некоторые операции: `getTime` на 11 символов сокращает доступ к получению **текущего времени**, `getTimeDelta` позволяет найти **промежуток в милисекундах** между отрезками времени (или указанным моментом и текущим временем, в формате с одним параметром), а последняя функция расширяет **свойства** объекта **`Number`** для того чтобы **при** его **значении `NaN`** можно было чуть быстрее **получить 0**.

``` javascript

function getTime() {
    return new Date().getTime();
}

function getTimeDelta(timeBegin, timeEnd) {
    timeEnd = timeEnd || getTime();
    return timeEnd - timeBegin;
}

Number.prototype.NaN0=function() { return isNaN(this) ? 0 : this; }

```

### Определение браузера

<a name="sol-7"></a> _7._ Небольшой объект, поименованные по названиям браузеров свойства которого -- суть условия. Этим достигается более читабельное (но не настолько скурпулезное насколько могло бы быть) **определение большинства типов браузеров**. Этот объект был заимствован мной из проекта, в котором я учавствовал -- и как-то прижился, но, думаю, истинные авторы всё-таки где-то в сети, да и код не так уж сложен и громоздок чтобы на него сильно претендовать :). Кроме того, он конечно не идеально надежен (а некоторые говорят что не надежен вообще), но пока на перечисленных браузерах он меня не подвел ни разу :). Если вас не устраивает такое положение дел - вы можете использовать нечто похожее [с HowToCreate](http://www.howtocreate.co.uk/jslibs/htmlhigh/sniffer.html). И повторюсь: данное определение я стараюсь использовать (как и сказано, например, по ссылке) "_только в случае если известен конкретный баг в конкретном браузере и его нужно обойти_". Также -- несложно пересобрать этот объект в одно длинное условие, для меньшей скорости исполнения (см., опять же, [ссылку](http://www.howtocreate.co.uk/jslibs/htmlhigh/sniffer.html))

``` javascript

var USER_DATA = {

    Browser: {
        KHTML: /Konqueror|KHTML/.test(navigator.userAgent) &&
                !/Apple/.test(navigator.userAgent),
        Safari: /KHTML/.test(navigator.userAgent) &&
                /Apple/.test(navigator.userAgent),
        Opera: !!window.opera,
        MSIE: !!(window.attachEvent && !window.opera),
        Gecko: /Gecko/.test(navigator.userAgent) &&
                !/Konqueror|KHTML/.test(navigator.userAgent)
    },

    OS: {
        Windows: navigator.platform.indexOf("Win") > -1,
        Mac: navigator.platform.indexOf("Mac") > -1,
        Linux: navigator.platform.indexOf("Linux") > -1
    }
}

```

### Координаты / Позиционирование

<a name="sol-8"></a> _8._ Набор функций, позволяющих получить **координаты элемента** на экране пользователя.

Если ваш документ статичен относительно окна и не имеет скроллбаров -- лучше использовать функцию `getPosition` -- так будет быстрее. В обратном случае используйте `getAlignedPosition` -- она учитывает положения скроллбаров. Только обратите внимание: значение `top` или `left` у элемента может быть орицательным, если элемент частично расположен за пределами окна -- для синхронизации с курсором мыши иногда нужно обнулить в этом случае высоту. Основной скрипт позаимствован из [одного блога](http://blog.firetree.net/2005/07/04/javascript-find-position/), Aligned-версия -- результат поисков по сусекам и совмещения с информацией из [двух](http://xhtml.ru/2007/03/10/advanced-thumbnail-creator/) [статей](http://www.habrahabr.ru/blog/webdev/13897.html) (при обнаружении `DOCTYPE` IE входит в свой собственный, несколько непредсказуемый, режим). Также этот метод скомбинирован с получением позиций из [исходников](http://www.webreference.com/programming/javascript/mk/column2/Dragging%20and%20Dropping%20in%20JavaScript_files/drag_drop.js) [руководства по Drag’n'Drop](http://www.webreference.com/programming/javascript/mk/column2/). Обратите внимание: здесь используется функция `NaN0` из пункта _[6](#sol-6)_, вам нужно будет добавить ее в скрипт чтобы все работало как надо :) (спасибо, [Homer](http://invisibleman.ru/)).

``` javascript

function getPosition(e) {
    var left = 0;
    var top  = 0;

    while (e.offsetParent) {
        left += e.offsetLeft + (e.currentStyle ? (parseInt(e.currentStyle.borderLeftWidth)).NaN0() : 0);
        top  += e.offsetTop  + (e.currentStyle ? (parseInt(e.currentStyle.borderTopWidth)).NaN0() : 0);
        e = e.offsetParent;
    }

    left += e.offsetLeft + (e.currentStyle ? (parseInt(e.currentStyle.borderLeftWidth)).NaN0() : 0);
    top  += e.offsetTop  + (e.currentStyle ? (parseInt(e.currentStyle.borderTopWidth)).NaN0(): 0);

    return {x:left, y:top};
}

var IS_IE = USER_DATA['Browser'].MSIE;

function getAlignedPosition(e) {
    var left = 0;
    var top  = 0;

    while (e.offsetParent) {
        left += e.offsetLeft + (e.currentStyle ? (parseInt(e.currentStyle.borderLeftWidth)).NaN0() : 0);
        top  += e.offsetTop  + (e.currentStyle ? (parseInt(e.currentStyle.borderTopWidth)).NaN0() : 0);
        e  = e.offsetParent;
        if (e.scrollLeft) {left -= e.scrollLeft; }
        if (e.scrollTop)  {top  -= e.scrollTop; }
    }

    var docBody = document.documentElement ? document.documentElement : document.body;

    left += e.offsetLeft + (e.currentStyle ?
                (parseInt(e.currentStyle.borderLeftWidth)).NaN0()
                : 0) +
        (IS_IE ? (parseInt(docBody.scrollLeft)).NaN0() : 0) -
        (parseInt(docBody.clientLeft)).NaN0();
    top  += e.offsetTop  + (e.currentStyle ?
                (parseInt(e.currentStyle.borderTopWidth)).NaN0()
                :  0) +
        (IS_IE ? (parseInt(docBody.scrollTop)).NaN0() : 0) -
        (parseInt(docBody.clientTop)).NaN0();

    return {x:left, y:top};
}

```

> Со временем две приведённые функции слились в одну, несколько более упрощённую, универсальную и при этом корректную (однако, если вы определяете позицию элемента внутри другого элемента, имеющего скроллинг -- не забудьте к координатам первого прибавить значение `scrollTop` или, соответсвенно, `scrollLeft` последнего: если вы сделаете это в отдельном месте -- ваш код будет работать быстрее и выглядеть логичнее, чем если бы вы использовали Aligned-версию):

``` javascript

function findPos(e) {
	var baseEl = e;
	var curleft = curtop = 0;
	if (e.offsetParent) {
		do {
			curleft += e.offsetLeft;
			curtop += e.offsetTop;
		} while (e = e.offsetParent);
	}
	var docBody = document.documentElement ? document.documentElement : document.body;
	if (docBody) {
		curleft += (baseEl.currentStyle?(parseInt(baseEl.currentStyle.borderLeftWidth)).NaN0():0) +
				   (IS_IE ? (parseInt(docBody.scrollLeft)).NaN0() : 0) - (parseInt(docBody.clientLeft)).NaN0();
		curtop  += (baseEl.currentStyle?(parseInt(baseEl.currentStyle.borderTopWidth)).NaN0():0) +
				   (IS_IE ? (parseInt(docBody.scrollTop)).NaN0() : 0) - (parseInt(docBody.clientTop)).NaN0();
	}
	return {x: curleft, y:curtop};
}

```

<a name="sol-9"></a> _9._ Определить текущие **координаты курсора** мыши и **смещение элемента относительно курсора** легко, если использовать соответствующие функции (собранные на [основе](http://xhtml.ru/2007/03/10/advanced-thumbnail-creator/) [трёх](http://www.habrahabr.ru/blog/webdev/13897.html) [источников](http://quirksmode.org/js/events_properties.html)):

``` javascript

function mouseCoords(ev){
	if (ev.pageX || ev.pageY) {
		return {x:ev.pageX, y:ev.pageY};
	}
	var docBody = document.documentElement ? document.documentElement : document.body;

	return {
		x: ev.clientX + docBody.scrollLeft - docBody.clientLeft,
		y: ev.clientY + docBody.scrollTop  - docBody.clientTop
	};
}

function getMouseOffset(target, ev, aligned) {
    ev = ev || window.event;
    if (aligned == null) aligned = false;

    var docPos    = aligned
        ? getAlignedPosition(target)
        : getPosition(target);
    var mousePos  = mouseCoords(ev);

    return {
        x: mousePos.x - docPos.x,
        y: mousePos.y - docPos.y
    };
}

```

> Обновлённая версия функии `getMouseOffset` для варианта с одной функцией нахождения позиции:
>
> ``` javascript
>
> function getMouseOffset(target, ev) {
>     ev = ev || window.event;
>
>     var docPos = findPos(target);
>     var mousePos = mouseCoords(ev);
>
>     return {
>         x: mousePos.x - docPos.x,
>         y: mousePos.y - docPos.y
>     };
> }
>
> ```

Последняя функция также может использоваться в двух режимах засчет атрибута `aligned` и предназначена для удобного использования в обработчиках событий, например:

``` javascript

function onMouseMove(elm, ev) {
    var mouseOffset = getMouseOffset(elm, ev);
    console.log("x: %d; y: %d", mouseOffset.x, mouseOffset.y);
}

```

``` html

<div id="someId" onmousemove="onMouseMove(this, event);
    return false;"></div>

```

**NB!** (если данные функции (_вдруг_ :) ) не заработают в каком-либо определенном случае -- прошу сообщать -- хочется добиться максимальной их переносимости)

<a name="sol-10"></a> _10._ Определение **высоты элемента** иногда более нелегкая задача чем определение других его параметров, но эти две функции придут на помощь:

``` javascript

function findOffsetHeight(e) {
    var res = 0;
    while ((res == 0) && e.parentNode) {
        e = e.parentNode;
        res = e.offsetHeight;
    }
    return res;
}

function getOffsetHeight(e) {
    return this.element.offsetHeight ||
           this.element.style.pixelHeight ||
           findOffsetHeight(e);
}

```

### DOM

<a name="sol-11"></a> _11._ Иногда нужно **пройти рекурсивно по дереву DOM**, начиная с некоторого элемента и выполняя некоторую функцию над каждым из потомков, забираясь в самую глубь. В DOM есть объект `TreeWalker`, но он не работает в IE и не всегда удобен/прост в использовании. Функция `walkTree` позволяет выполнить некоторую другую функцию над каждым из элементов и позволяет также передать в нее некоторый пакет данных. Функция `searchTree` отличается от нее тем, что останавливает проход по дереву при первом удачном результате и возвращает результат в точку вызова:

``` javascript

function walkTree(node, mapFunction, dataPackage) {
	if (node == null) return;
	mapFunction(node, dataPackage);
	for (var i = 0; i < node.childNodes.length; i++) {
		walkTree(node.childNodes[i], mapFunction, dataPackage);
	}
}

function searchTree(node, searchFunction, dataPackage) {
	if (node == null) return;
	var funcResult = searchFunction(node, dataPackage);
	if (funcResult) return funcResult;
	for (var i = 0; i < node.childNodes.length; i++) {
		var searchResult = searchTree(node.childNodes[i], searchFunction, dataPackage);
		if (searchResult) return searchResult;
	}
}

```

В примере используются функции `setElmAttr` и `getElmAttr`, которые будут рассмотрены позже - в пункте _[13](#sol-13)_. По сути они делают то же что и `getAttribute` и `setAttribute`. Пояснения к используемой функции `oc` вы можете посмотреть в пукте _[4](#sol-4)_. В первой части примера корневому элементу атрибут "`nodeType`" устанавливается в "`root`", а всем его потомкам - в "`child`". Во второй части демонстрируется также передача пакета данных -- при нахождении первого элемента с атрибутом "`class`", равным одному из перечисленных в пакете имен, атрибут "`isTarget`" ему устанавливается в "`true`".

``` javascript

var rootElement = document.getElementById('rootElm');

setElmAttr(rootElement, "nodeType", "root");
var childNodeFunc = function(node) {
    if (node.nodeName && (node.nodeName !== '#text')
                      && (node.nodeName !== '#comment')) {
        setElmAttr(node, "nodeType", "child");
    }
}
walkTree(rootElement, childNodeFunc);

var findTargetNode = function(node, classList) {
    if ((node.nodeName && (node.nodeName !== '#text')
                       && (node.nodeName !== '#comment')) &&
                       (getElmAttr(node, "class") in oc(classList))) {
        return node;
    }
}
var targetNode = searchTree(rootElement, findTargetNode,
                    ['headingClass', 'footerClass', 'tableClass']);
setElmAttr(targetNode, "isTarget", true);

```

**NB!** (будьте осторожны с использованием этих функций и постарайтесь избежать их чересчур частого вызова (более раза в секунду) даже на средней ветвистости дереве - они могут пожрать немало ресурсов. или, по крайней мере, вызывайте их в фоне через `setTimeout`)

<a name="sol-12"></a> _12._ **Удаление узлов** - иногда необходимая задача. Иногда нужно удалить сам узел, а иногда -- только его потомков. Функция `removeChildrenRecursively` рекурсивно удаляет всех потомков указанного узла, не затрагивая, конечно, его самого. Функция `removeElementById`, как и сказано в названии, удалает узел по его `id` - при всей простоте задачи способ относительно хитрый:

``` javascript

function removeChildrenRecursively(node)
{
    if (!node) return;
    while (node.hasChildNodes()) {
        removeChildrenRecursively(node.firstChild);
        node.removeChild(node.firstChild);
    }
}

function removeElementById(nodeId) {
    document.getElementById(nodeId).parentNode.removeChild(
                            document.getElementById(nodeId));
}

```

<a name="sol-13"></a> _13._ Казалось бы -- элементарная задача работы с атрибутами элемента -- иногда наталкивает на абсолютно неожиданные проблемы: например, IE бросает исключение при попытке доступа к атрибутам высоты/ширины элемента `table`, а у Safari отличается способ доступа к атрибутам с пространствами имен. Приведенные ниже функции обходят все встреченные мной проблемы без сильного ущерба к скорости выполнения (конечно же, в стандартных случаях лучше использовать встроенные функции):

``` javascript

var IS_SAFARI = USER_DATA['Browser'].Safari;

function getElmAttr(elm, attrName, ns) {
    // IE6 fails getAttribute when used on table element
    var elmValue = null;
    try {
        elmValue = (elm.getAttribute
                    ? elm.getAttribute((ns ? (ns + NS_SYMB) : '')
                    + attrName) : null);
    } catch (e) { return null; }
    if (!elmValue && IS_SAFARI) {
        elmValue = (elm.getAttributeNS
                    ? elm.getAttributeNS(ns, attrName)
                    : null);
    }
    return elmValue;
}

function setElmAttr(elm, attrName, value, ns) {
    if (!IS_SAFARI || !ns) {
        return (elm.setAttribute
                    ? elm.setAttribute((ns ? (ns + NS_SYMB) : '')
                    + attrName, value) : null);
    } else {
        return (elm.setAttributeNS
                    ? elm.setAttributeNS(ns, attrName, value)
                    : null);
    }
}

function remElmAttr(elm, attrName, ns) {
    if (!IS_SAFARI || !ns) {
        return (elm.removeAttribute
                    ? elm.removeAttribute((ns ? (ns + NS_SYMB) : '')
                    + attrName) : null);
    } else {
        return (elm.removeAttributeNS
                    ? elm.removeAttributeNS(ns, attrName)
                    : null);
    }
}

```

Засчет универсальности появляется некоторая неудобочитаемость ввиду того, что необязательный атрибут пространства имен -- последний. Решения приветствуются.

### AJAX

<a name="sol-14"></a> _14._ Если вам не нужно ничего большего, чем просто **выполнить асинхронный запрос** и на основе полученных данных сделать нечто -- для вас эта функция. Способ получения объекта `XMLHttpRequest` безусловно может быть заменен. Комментарии намеренно оставлены, дабы показать некоторые идеи по расширению:

``` javascript

/* AJAX call */

/* locationURL - URL to use */
/* parameters - url parameters, null if not required (format: "parameter1=value1&parameter2=value2[...]") */
/* onComplete - listener: function (http_request) or (http_request, package) */
/* doPost - (optional) specifies if POST (true) or GET (false/null) request required
/* package - (optional) some variable or array to tranfer to complete listener, may be not specified */

function makeRequest(locationURL, parameters, onComplete, doPost, dataPackage) {

    var http_request = false;
    try {
        http_request = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (e1) {
        try {
            http_request= new ActiveXObject("Microsoft.XMLHTTP");
        } catch (e2) {
            http_request = new XMLHttpRequest();
        }
    }

    //if (http_request.overrideMimeType) { // optional
    //  http_request.overrideMimeType('text/xml');
    //}

    if (!http_request) {
      throw new Error('Cannot create XMLHTTP instance');
      return false;
    }

    var completeListener = function() {
        if (http_request.readyState == 4) {
            if (http_request.status == 200) {
                onComplete(http_request, dataPackage)
            }
        }
    };

    //var salt = hex_md5(new Date().toString());
    http_request.onreadystatechange = completeListener;
    if (doPost) {
		http_request.open('POST', locationURL, true);
		http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
		http_request.setRequestHeader("Content-length", parameters.length);
		http_request.setRequestHeader("Connection", "close");
		http_request.send(parameters);
    } else {
    	http_request.open('GET', locationURL + (parameters ? ("?" + parameters) : ""), true);
    	//http_request.open('GET', './proxy.php?' + parameters +
                    // "&salt=" + salt, true);
    	http_request.send(null);
    }

}

```

Пример использования -- из одного моего рабочего тестового задания, которое занималось поиском в базе музыки и/или фильмов по введенной в элемент (с `id` "`searchStr`") строке, используя SQL’ный `LIKE`:

``` javascript

function gotSearchResults(http_request, dataPackage) {
    request_result = http_request.responseText;
    var divElement = document.getElementById(dataPackage["divId"]);
    divElement.innerHTML = request_result;
}

function insertMusicSearchResults(divId) {
    var searchStrElement = document.getElementById("searchStr");
    var dataPackage = new Array();
    dataPackage["divId"] = divId;
    makeRequest("getAlbums.php", "searchStr="
            + searchStrElement.value, gotSearchResults, false,
            dataPackage);
}

function insertVideoSearchResults(divId) {
    var searchStrElement = document.getElementById("searchStr");
    var dataPackage = new Array();
    dataPackage["divId"] = divId;
    makeRequest("getMovies.php", "searchStr="
            + searchStrElement.value, gotSearchResults, false,
            dataPackage);
}

```

### Логгинг

<a name="sol-15"></a> _15._ Представленная ниже функция для помощи в **ведении логов** очень проста, добавьте в нужное место в документе элемент `<div id="LOG_DIV"></div>`, задайте ему необходимую высоту, и в него будет сбрасываться информация + обеспечиваться ее скроллинг:

``` javascript

function LOG(informerName, text) {
    var logElement = document.getElementById('LOG_DIV');
    if (logElement) {
        logElement.appendChild(document.createTextNode(
                        informerName + ': ' + text));
        logElement.appendChild(document.createElement('br'));
        logElement.scrollTop += 50;
    }
}

```

<a name="sol-16"></a> _16._ В замечательном плагине [Firebug](http://www.getfirebug.com/) для браузера Firefox есть замечательная **консоль**, в которую с широкими возможностями можно [производить логгинг](http://www.getfirebug.com/console.html). Однако, если вы отлаживаете параллельно код в других браузерах -- обращения к ней могут вызывать ошибки и даже крэши. Для того чтобы не очищать каждый раз код от логов, можно использовать такую заглушку:

``` javascript

var Console = Class.extend({
    // the stub class to allow using console when browser have it,
    // if not - just pass all calls
    construct: function() {},
    log: function() { },
    info: function() { },
    warn: function() { },
    error: function() { }
});

if (!window.console) {
    console = new Console();
}

```

Сочетание этого и предыдущего пункта + CSS может вдохновить вас на написание собственной консоли с функциональностью консоли Firebug, но для других браузеров ;). Если вы ее напишете - поделитесь, пожалуйста, со мной :).

### Бонус

В качестве бонуса (чтобы не портить приятно отдающее двоичностью число в заголовке :) ) рассажу о проблеме **двойного клика** -- бился над ней не я, а мои коллеги, решение также сетевое -- но в некоторой обработке. Проблема состоит в том, что при регистрации события `ondblclick` все равно вызывается событие `onclick`. Поэтому, если уж очень это событие (неочевидное, стоит заметить, для пользователя сети) необходимо - лучше всего иметь в скриптах что-то вроде такого кода (с необходимым вам количеством миллисекунд и сохраняя, если необходимо, элемент, на котором был совершен клик):

``` javascript

var dblClicked = false;
var dblClickedNode = null;

var DBL_CLICK_MAXTIME = 300;

function dblClick(clickedNode) {
    dblClicked = true;
    dblClickedNode = clickedNode || dblClickedNode;
}

function releaseDblClick() {
    setTimeout('dblClicked=false;', DBL_CLICK_MAXTIME);
}

```

Его использование накладывает относительно сложные условия. Теперь в обработчике `ondblclick` нужно вызывать сначала первую функцию, затем - закончив собственно обработку - вторую, а в обработчике `onclick` проверять, не совершен ли двойной клик:

``` html

<div id="someId" onclick="if (!dblClicked) alert('click');"
     ondblick="dblClick(this); alert('dblclick'); releaseDblClick();";></div>

```

Также, к пункту _[1](#sol-1)_ можно добавить небольшую функцию **получения инстанса** (на ваше усмотрение вы можете изменить ее так, чтобы она предавала аргументы в конструктор):

``` javascript

function getInstanceOf(className) {
    return eval('new ' + className + '()');
}

```

К пункту _[6](#sol-6)_ подойдет функция **паузы** (именно паузы, а не выполнения в отдельном поптоке, как делает setTimeout):

``` javascript

function pause(millis)
{
    var time = new Date();
    var curTime = null;
    do { curTime = new Date(); }
        while (curTime - time < millis);
}

```

**Upd.** Ещё пара функций, относящихся к пункту  _[6](#sol-6)_:

Определение **Вхождения числа в область** чисел, ограниченную числом `start` спереди включительно и числом `stop` в конце исключительно:

``` javascript
Number.prototype.inBounds=function(start,stop){return ((this>=start)&&(this<stop))?true:false;};
```

**Срезание** начальных и конечных **пробельных символов строки**:

``` javascript
String.prototype.trim=function(){var temp = this.replace( /^\s+/g, "" );return temp.replace( /\s+$/g, "" );}
```

**Преобразование** объекта и строки **в тип `boolean`**. Для `boolean`-объектов метод также описан, ввиду того, что данные о типе переданного объекта (строка или `boolean`) могут быть неизвестны:

``` javascript
function boolFromObj(obj){return(((obj=="true")||(obj == true))?true:false);}

String.prototype.asBoolVal=function(){return ((this=="true")?true:false);}

Boolean.prototype.asBoolVal=function(){return ((this==true)?true:false);}
```

**Дополнение нулями** числа до тех пор, пока количество цифр в нём не достигнет указанного:

``` javascript
Number.prototype.getFStr=function(fillNum){var fillNum=fillNum?fillNum:2;var
temp=""+this;while(temp.length<fillNum)temp="0"+temp;return temp;}
```

Кроме этого, ко [второй части](#объектная-модель-js) можно отнести функции, связанные с **сортировкой**,...

``` javascript

function intComparator(a, b) {
	return a - b;
}

function getObjSortedProps(obj, sortFunc) {
	var propsArr = [];
	for (propName in obj) {
		propsArr.push(propName);
	}
	return propsArr.sort(sortFunc);
}

```

...где функция `getObjSortedProps` позволяет получить массив из отсортированных (с применением указанного компаратора `sortFunc`) имён свойств переданного объекта, а функция `intComparator` может быть передана функции массивов `sort` или той же самой `getObjSortedProps`, если нужный массив или имена свойств объекта содержит/содержат числовые значения...

...и две функции для **работы с массивами**:

``` javascript

function indexOf(arr, elem) {
	for (itemIdx in arr) {
		if (arr[itemIdx] == elem) return itemIdx;
	}
	return null;
}

function removeFromArray(arr, element) { // removes only one item!
	for (itemIndex in arr) {
		if (arr[itemIndex] == element) {
			arr.splice(itemIndex, 1);
			return arr;
		}
	}
	return null;
}

```

`indexOf` возвращает индекс указанного элемента в переданном массиве, а функция `removeFromArray` удаляет из указанного массива переданный элемент.

### Заключение

Ну вот -- кажется, пока всё. Статья -- в состоянии готовности к исправлениям (если понадобятся :) ), можно переходить к следующим :). В [следующей статье](#javascript-oop) я намереваюсь рассказать поподробнее про ООП в JavaScript и привести в пример пару простых, но полезных классов. Надеюсь, эта статья вам помогла и хоть немного сократила имеющие потенциальную возможность быть потраченными на решение всяких причуд браузеров рабочие человекочасы.
