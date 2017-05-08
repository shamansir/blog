---
layout: post.html
title: ООП и JavaScript
datetime: 19 Aug 2007 02:29
tags: [ javascript ]
---

В [предыдущей статье](../16-useful-solutions-for-javascript) я представил на ваше рассмотрение небольшой кусок кода, который позволяет использовать три столпа ООП в JavaScript. Все это достигается несколько хитро, тем не менее я позволил себе чуточку изменить функцию `extend`, дабы классы имели понятие о том, что такое статические константы (на самом деле константы конечно получились условные, но это, думаю, можно оправдать условностью их в самом JavaScript). Здесь я рассмотрю этот вопрос поподробнее и, видимо, буду расширять статью по мере его более глубокого понимания.

Итак, исходные данные (повторюсь, заимствованы из источников на [AJAXPath](http://www.ajaxpath.com/javascript-inheritance) и на [AJAXPatterns](http://ajaxpatterns.org/Javascript_Inheritance)):

``` javascript

function Class() { };

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
        if (item instanceof Function) item.$ = superClass;
                else classDef[n] = item;
        proto[n] = item;
    }

    classDef.prototype = proto;
    classDef.extend = this.extend;

    return classDef;
};

```

Благодаря использованию трех этих функций, у вас появляется замечательная возможность строить довольно серьезные и обширные по конструкции фреймворки, не теряя при этом читабельности кода и возможности быстро найти нужное место дабы его изменить. Ну и плюс, конечно, практически все преимущества ООП.

Эти три функции использовались как фундамент ООП-Drag’n'Drop фреймворка для крупного проекта на Java+Wicket. Я бы с удовольствием безвозмездно поделился бы его кодом, но по контракту этот код - собственность компании, а компания не хочет его рассекречивать. По этой причине я могу лишь дать, если нужно, наводящие мысли, наводящие на конкретные мысли :).

Впрочем, ближе к делу. Для такого кода требуется пример. Я наваял тут небольшой скрипт, эмулирующий операционную систему Windows, надеюсь он подойдет:

``` javascript

/* пара вспомогательных функций */

function getInstanceOf(className) {
    // возвращает объект класса по имени класса
    return eval('new ' + className + '()');
}

function pause(millis) // останавливает выполнение
    // скрипта на указанное количество миллисекунд
{
    var time = new Date();
    var curTime = null;
    do { curTime = new Date(); }
        while( curTime - time < millis);
}

/* === Абстрактная Операционная Система === */

var AbstractOS = Class.extend({

    construct: // конструктор, параметр - тип компьютера
        function(computerClassName) {
            // компьютер, на котором запускается ОС
            this._computer = getInstanceOf(computerClassName);
        },

    getComputer: function() { return this._computer; },

    reboot: // перезагрузка ОС
        function() {
            return this.getComputer().shutDown() &&
                   this.getComputer().startUp();
        },

    shutDown: // выключение ОС
        function() { return this.getComputer().shutDown(); },

    startUp: // запуск ОС
        function() { return this.getComputer().startUp(); },

    exec: // абстрактный (условно) метод запуска команды
        function(commandStr) { return false; },

    cycle: // запуск ОС, выполнение команды, отключение ОС
        function(cmdStr) {
            return this.startUp() && this.exec(cmdStr) &&
                                     this.shutDown();
        }

});

/* === Синий Экран Смерти === */

var BSOD = Class.extend({

    launch: // запуск
        function() {
            alert('You see the BSOD');
            return true;
        }

});

/* === Операционная Система MS Windows === */

var MSWindows = AbstractOS.extend({
    // наследуется от абстрактной ОС

    // сообщения - статические константы (условно)
    STARTUP_MSG: 'Windows Starting',
    EXEC_MSG: 'This program has performed an illegal operation',
    REBOOT_MSG: 'Do you really want to reboot your computer?',

    construct: // конструктор, параметр - тип компьютера
        function(computerClassName) {
            // вызов родительского конструктора
            arguments.callee.$.construct.call(this, computerClassName);
            // кэш-е синего экрана смерти (ибо он будет один)
            this._bsod = new BSOD();
        },

    getBSOD: function() { return this._bsod; },

    reboot: // перегруженная перезагрузка
        function() {
            // вывод сообщения
            alert(MSWindows.REBOOT_MSG);
            // вызов родительского метода
            return arguments.callee.$.reboot.call(this);
        },

    shutDown: // перегруженное выключение
        function() {
            // запуск СЭС и, если он удачен - вызов
            // родительского метода. возвращается результат
            // удачности
            return (this.getBSOD().launch() &&
                    arguments.callee.$.shutDown.call(this));
        },

    startUp: //  перегруженная загрузка
        function() {
            // если удачно выполнился родительский метод
            if (arguments.callee.$.startUp.call(this)) {
                // выполнить необходимые операции
                pause(400);
                //setTimeout("alert('Windows Starting')", 400);
                // сообщить об удачной загрузке
                alert(MSWindows.STARTUP_MSG);
                return true;
            } else return false; // нет - так нет
        },

    exec: // перегруженное выполнение команды
        function(commandStr) {
            // если команда валидна - выдать результат
            // исполнения, иначе - выключиться
            return commandStr
                ? alert(MSWindows.EXEC_MSG)
                : this.shutDown();
        }

});

/* === Обычный Компьтер === */

var SimpleComputer = Class.extend({

    startUp: // при запуске выводит сообщение
        function() { alert('Starting Up'); return true; },

    shutDown: // при выключении выводит сообщение
        function() { alert('Shutting Down'); return true; }

});

/* проверочная функция */

function perform() {
    // инициируем ОС на обычном компьютере (инсталляция)
    var testOs = new MSWindows('SimpleComputer');
    // запускаем ОС
    testOs.startUp();
    // выполняем банальную команду
    testOs.exec('ls -laF');
    // выключаем ОС
    testOs.shutDown();
}

```

**NB!** (не забывайте - после последнего объявления метода в классе запятой ставить не нужно, иначе Ослик (IE) обидится)

Если предыдущий пример вам не понравился -- я могу предложить вам довольно полезный класс, который сильно помогает, если в вашем проекте понятие элемента DOM пересекается с понятием объекта, над которым производятся манипуляции:

``` javascript

var ElementWrapper = Class.extend({

    construct:
        function(elementId) {
            this.elementId = elementId;
            this.element = null;
            this._initializeElement();
        },

    _initializeElement:
        function() {
            var docElm = document.getElementById(this.elementId);
            if (!docElm) {
                this.element = document.createElement('div');
                this.element.id = this.elementId;
            } else {
                this.element = docElm;
            }
            this._assignListeners();
        },

    _assignListeners:
        function() {
            . . .
        },

    . . .

    reassignTo:
        function(elementId) {
            this.elementId = elementId;
            this.element = null;
            this._initializeElement();
        }

});

```

От этого класса очень удобно наследовать классы, расширяющие функциональность элементов DOM. Также, теперь вы можете использовать код типа этого:

``` javascript
var someElement = new ElementWrapper('someElmId');
```

…и объект `someElement` будет связан с элементом (оборачивать элемент) с `id` _‘`SomeElmId`’_. Доступ к нему -- как к элементу DOM -- можно будет получить через свойство `someElement.element`.

Приведенный ниже класс наследуется от `ElementWrapper` и позволяет обращаться с обернутым элементом как с практически полноценным (неполноценным? :) ) графическим объектом (используются некоторые функции из [предыдущей статьи](../16-useful-solutions-for-javascript): `getElmAttr`, `setElmAttr`, `findOffsetHeight`, `getPosition`, `getAlignedPosition`)

> Как и у некоторых функций из [предыдущей статьи](../16-useful-solutions-for-javascript), со временем код изменился -- в данном случае он оброс функциональностью и одновременно несколько упростился:

``` javascript

var DND_NS 				= 'dnd'; // to use in getAttributeNS and setAttributeNS

var DND_LWIDTH_ATTR 	= 'localWidth';
var DND_LHEIGHT_ATTR 	= 'localHeight';
var DND_LTOP_ATTR 		= 'localTop';
var DND_LLEFT_ATTR 		= 'localLeft';
var DND_BTOP_ATTR 		= 'baseTop';
var DND_BLEFT_ATTR 		= 'baseLeft';

var GraphicalElementWrapper = ExpandedElementWrapper.extend({

	_assignListeners:
		function() {
			// не назначать слушателей событий, если не необходимо
		},

    // ========[ функции установки необходимых для работы аттрибутов ]==========

    /* localLeft, localTop -- атрибуты, содержащие координату верхнего левого угла элемента
                              с учётом смещения [скроллинга];
       localWidth, localHeight -- атрибуты, содержащие реальную высоту и ширину элемента;
       baseLeft, baseTop -- атрибуты, содержащие координату верхнего левого угла элемента
                            без учёта смещения [скроллинга] */

	setLocalWidth:
		function(localWidth) {
			setElmAttr(this.element, DND_LWIDTH_ATTR, localWidth + 'px', DND_NS);
		},

	setLocalHeight:
		function(localHeight) {
			setElmAttr(this.element, DND_LHEIGHT_ATTR, localHeight + 'px', DND_NS);
		},

	setLocalLeft:
		function(localLeft) {
			setElmAttr(this.element, DND_LLEFT_ATTR, localLeft + 'px', DND_NS);
		},

	setLocalTop:
		function(localTop) {
			setElmAttr(this.element, DND_LTOP_ATTR, localTop + 'px', DND_NS);
		},

	setBaseLeft:
		function(baseLeft) {
			setElmAttr(this.element, DND_BLEFT_ATTR, baseLeft + 'px', DND_NS);
		},

	setBaseTop:
		function(baseTop) {
			setElmAttr(this.element, DND_BTOP_ATTR, baseTop + 'px', DND_NS);
		},

	getLocalWidth:
		function() {
			return getElmAttr(this.element, DND_LWIDTH_ATTR, DND_NS);
		},

	getLocalHeight:
		function() {
			return getElmAttr(this.element, DND_LHEIGHT_ATTR, DND_NS);
		},

	getLocalLeft:
		function() {
			return getElmAttr(this.element, DND_LLEFT_ATTR, DND_NS);
		},

	getLocalTop:
		function() {
			return getElmAttr(this.element, DND_LTOP_ATTR, DND_NS);
		},

	getBaseLeft:
		function() {
			return getElmAttr(this.element, DND_BLEFT_ATTR, DND_NS);
		},

	getBaseTop:
		function() {
			return getElmAttr(this.element, DND_BTOP_ATTR, DND_NS);
		},

	getOffsetWidth:
		function() {
			return this.element.offsetWidth;
		},

	getOffsetHeight:
		function() {
			return this.element.offsetHeight || this.element.style.pixelHeight || findOffsetHeight(this.element);
		},

    // =======[ / функции установки необходимых для работы аттрибутов ]=========

	show: // показать элемент
		function() {
			this.element.style.display    = '';
			this.element.style.visibility = 'visible';
		},

	hide: // спрятать элемент
		function() {
			if (this.element.style.display != 'none') {
				this.element.style.display  = 'none';
			}
		},

	blank: // "забелить" эелемент
		function() {
			if (this.element.style.display != '') {
				this.element.style.display    = '';
				this.element.style.visibility = 'hidden';
			}
		},

	makeBlock: // сделать элемент блоком (иногда необходимо)
		function() {
			if (this.element.style.display != 'block') {
				this.element.style.display  = 'block';
			}
		},

	isPointInside: // находится ли точка внутри элемента, точка в формате {x, y}
		function(curPoint) {
			var localRight  = parseInt(this.getLocalLeft()) + parseInt(this.getLocalWidth())
                                       + this.element.scrollLeft;
    		var localBottom = parseInt(this.getLocalTop())  + parseInt(this.getLocalHeight())
                                       + this.element.scrollTop;
    		return (parseInt(this.getLocalLeft()) < curPoint.x) &&
    			   (parseInt(this.getLocalTop())  < curPoint.y) &&
    			   (localRight > curPoint.x) && (localBottom > curPoint.y);
    	},

	isElementNear: /* находится ли переданный элемент рядом с этим элементом
            (перекрывает область этого элемента больше чем половиной своей) */
    	function(graphicalElement) {
    		if (graphicalElement) {
				var elmCurPos = findPos(graphicalElement.element);
				var elmHalfHeight = parseInt(graphicalElement.getLocalHeight())/2;
				var elmHalfWidth = parseInt(graphicalElement.getLocalWidth())/2;
				var localLeft = (parseInt(this.getLocalLeft()) > 0 ? parseInt(this.getLocalLeft()) : 0);
				var localTop = (parseInt(this.getLocalTop()) > 0 ? parseInt(this.getLocalTop()) : 0);
				var leftCorrect = (elmCurPos.x > (localLeft - elmHalfWidth)) &&
								  (elmCurPos.x < (localLeft + parseInt(this.getLocalWidth()) - elmHalfWidth));
				var topCorrect = (elmCurPos.y > (localTop - elmHalfHeight)) &&
							     (elmCurPos.y < (localTop + parseInt(this.getLocalHeight()) - elmHalfHeight));
				return leftCorrect && topCorrect;
			} else return false;
		},

	isElementInside: // находится ли переданный элемент внутри этого элемента
		function(graphicalElement) {
			if (graphicalElement) {
				var elmCurPos = findPos(graphicalElement.element);
				var elmHalfHeight = parseInt(graphicalElement.getOffsetHeight())/2;
				var elmHalfWidth = parseInt(graphicalElement.getOffsetWidth())/2;
				return this.isPointInside({x:(elmCurPos.x + elmHalfWidth),
									   y:(elmCurPos.y + elmHalfHeight)})
			} else return false;
		},

	isLeftSide: // находится ли точка({x, y}) на левой стороне области элемента
		function(curPoint) {
			var elmHalfWidth = parseInt(this.getLocalWidth())/2;
			var localLeft = (parseInt(this.getLocalLeft()) > 0 ? parseInt(this.getLocalLeft()) : 0);
			return (curPoint.x >= localLeft) && (curPoint.x < (localLeft + elmHalfWidth));
		},

	isRightSide: // находится ли точка({x, y}) на правой стороне элемента
		function(curPoint) {
			var elmHalfWidth = parseInt(this.getLocalWidth())/2;
			var localRight = ((parseInt(this.getLocalLeft()) > 0
                    ? parseInt(this.getLocalLeft())
                    : 0)) + parseInt(this.getLocalWidth());
    		return (curPoint.x <= localRight) && (curPoint.x > (localRight - elmHalfWidth));
    	},

	inTopOf: // находится ли точка({x, y}) на верхней стороне области элемента
		function(curPoint) {
			var localTop 	= (parseInt(this.getLocalTop()) > 0 ? parseInt(this.getLocalTop()) : 0);
			var localHeight = (parseInt(this.getLocalHeight()) > 0 ? parseInt(this.getLocalHeight()) : 0);
			if (this.element.clientHeight && (this.element.clientHeight < localHeight))
                localHeight = this.element.clientHeight;
    		return ((curPoint.y > localTop) && (curPoint.y <= (localTop + (localHeight / 10))));
    	},

	inBottomOf: // находится ли точка({x, y}) на нижней стороне области элемента
		function(curPoint) {
			var localTop 	= (parseInt(this.getLocalTop()) > 0 ? parseInt(this.getLocalTop()) : 0);
			var localHeight = (parseInt(this.getLocalHeight()) > 0 ? parseInt(this.getLocalHeight()) : 0);
			if (this.element.clientHeight && (this.element.clientHeight < localHeight))
                localHeight = this.element.clientHeight;
    		return ((curPoint.y >= (localTop + localHeight - (localHeight / 10))) &&
                    (curPoint.y < (localTop + localHeight)));
	    },

	recalc: // пересчитывает координаты элемента
	       /* baseOffset в подавляющем большинстве случаев -- это
           { x: this.element.scrollLeft, y: this.element.scrollTop } */
    	function(baseOffset) {

    		var pos = findPos(this.element);

    		this.setBaseLeft(pos.x);
    		this.setBaseTop(pos.y);
    		this.setLocalLeft(pos.x - (baseOffset ? baseOffset.x : 0));
    		this.setLocalTop(pos.y - (baseOffset ? baseOffset.y : 0));
    		this.setLocalWidth(parseInt(this.getOffsetWidth()));
    		this.setLocalHeight(parseInt(this.getOffsetHeight()));
    	},

	addOffset: // добавляет смещение к элементу, смещение в формате {x, y}
		function(offsetXY) {
			this.setLocalLeft(parseInt(this.getBaseLeft()) - offsetXY.x);
			this.setLocalTop(parseInt(this.getBaseTop()) - offsetXY.y);
		},

    copyElmRectParameters: // скопировать атрибуты с этого элемента на другой
    	function(fromElm, toElm) {
    		toElm = toElm || this.element;
	    	setElmAttr(toElm, DND_BTOP_ATTR, getElmAttr(fromElm, DND_BTOP_ATTR, DND_NS), DND_NS);
	    	setElmAttr(toElm, DND_BLEFT_ATTR, getElmAttr(fromElm, DND_BLEFT_ATTR, DND_NS), DND_NS);
	    	setElmAttr(toElm, DND_LTOP_ATTR, getElmAttr(fromElm, DND_LTOP_ATTR, DND_NS), DND_NS);
	    	setElmAttr(toElm, DND_LLEFT_ATTR, getElmAttr(fromElm, DND_LLEFT_ATTR, DND_NS), DND_NS);
	    	setElmAttr(toElm, DND_LWIDTH_ATTR, getElmAttr(fromElm, DND_LWIDTH_ATTR, DND_NS), DND_NS);
	    	setElmAttr(toElm, DND_LHEIGHT_ATTR, getElmAttr(fromElm, DND_LHEIGHT_ATTR, DND_NS), DND_NS);
	    }

});

```

Оба этих класса, надеюсь, помогут вам при решении задач, связанных с опознаванием элементов DOM как графических объектов (например, Drag’n'Drop (здесь я наследовал класс перетаскиваемыx нод, классы областей, их содержащих (несколько с разными свойствами, отнаследованных друг от друга) и помощник для перетаскивания -- от `GraphicElementWrapper`, а главный контейнер -- от `ElementWrapper`) или, например, веб-приложение, эмулирующее работу оконного (здесь, когда я этим занимался, я наследовал перетаскиваемые элементы от `GraphicElementWrapper`, а меню, статусбар, рабочую область -- от `ElementWrapper`).

Как всё это работает -- довольно-таки непростой вопрос, но я постараюсь через некоторое время уделить внимание и ему, возможно в этой же статье… А пока -- кажется всё. Удач в JS-конструировании :).

### Ссылки

про это…

* … - [по-русски, от Дмитрия Котерова](http://dklab.ru/chicken/nablas/40.html)
* … - [более поздние впечатления - по-русски, от Дмитрия Котерова и его соратников](http://forum.dklab.ru/comments/nablas/40InheritanceInJavascript.html?start=80&sid=fac82f100376bdaceb0f5024b136fb0c)
* …[на AjaxPatterns](http://ajaxpatterns.org/Javascript_Inheritance)
* …[на AJAXPath](http://www.ajaxpath.com/javascript-inheritance/)
* …[на XML.com](http://www.xml.com/pub/a/2006/06/07/object-oriented-javascript.html)
* …[на WebReference.com](http://www.webreference.com/js/column79/ )
* …[на The Code Project](http://www.codeproject.com/aspnet/JsOOP1.asp)
* …[на JavaScript Kit](http://www.javascriptkit.com/javatutors/oopjs.shtml)
* …[на DevArticles](http://www.devarticles.com/c/a/JavaScript/ObjectOriented-JavaScript-An-Introduction-to-Core-Concepts/)
* … - [как на этом делать галерею](http://chunkysoup.net/advanced/oojavascript1/)
* …[кратко, от Kevin Lindsey](http://www.kevlindev.com/tutorials/javascript/inheritance/index.htm)
* …[кратко, от Dave Johnson](http://blogs.nitobi.com/dave/?p=166)
* … - [ссылки от Zeroglif](http://forum.vingrad.ru/index.php?showtopic=120066&view=findpost&p=1215304)
