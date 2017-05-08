---
layout: post.html
title: OOP &amp; JavaScript
datetime: 19 Aug 2007 02:29
tags: [ javascript ]
---

In [previous article](../16-useful-solutions-for-javascript) I have presented you a small example of code, which allows you to use the three pillars of OOP theory in JavaScript. The way it is accomplished is a little tricky, but I have afforded mysefl to modify `extend` function a bit, to give a possibility of having a static constants for classes (in fact, the constants in result are just conventional, of course). Here I will provide a special example for it.

So, the basic functions (I'll say it again, I have taken them from [AJAXPath](http://www.ajaxpath.com/javascript-inheritance) and [AJAXPatterns](http://ajaxpatterns.org/Javascript_Inheritance) sources):

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

Through the usage of these three functions, you have a possibility to build a relatively serious and deep-constructed frameworks, not loosing the code readability and a way to find a needed place to change fast. Plus OOP possibilities, of course

These three functions were used as a foundation of OOP-Drag'n'Drop framework for a major project in Java+Wicket. I will provide later this code itself, if it will be possible and allowed by a company.

Let's return to business. For a code like this you need an example. I have build a little script that emulates a Windows OS, I hope it will match your needs:

``` javascript

/* some helping functions */

function getInstanceOf(className) {
    // creates an object using the class name
    return eval('new ' + className + '()');
}

function pause(millis) // pauses the execution of script
    // for a specified number of milliseconds
{
    var time = new Date();
    var curTime = null;
    do { curTime = new Date(); }
        while( curTime - time < millis);
}

/* === Abstract Operating System === */

var AbstractOS = Class.extend({

    construct: // constructor, parameter is a computer type
        function(computerClassName) {
            // coumputer that runs OS
            this._computer = getInstanceOf(computerClassName);
        },

    getComputer: function() { return this._computer; },

    reboot: // OS reboot
        function() {
            return this.getComputer().shutDown() &&
                   this.getComputer().startUp();
        },

    shutDown: // OS shuts down
        function() { return this.getComputer().shutDown(); },

    startUp: // OS starts
        function() { return this.getComputer().startUp(); },

    exec: // an abstract (conventionally) method to execute commands
        function(commandStr) { return false; },

    cycle: // starting OS, executing command, shutting OS down
        function(cmdStr) {
            return this.startUp() && this.exec(cmdStr) &&
                                     this.shutDown();
        }

});

/* === Blue Screen of Death === */

var BSOD = Class.extend({

    launch: // launch
        function() {
            alert('You see the BSOD');
            return true;
        }

});

/* === MS Windows Operating System === */

var MSWindows = AbstractOS.extend({
    // inherits abstract OS

    // messages are static constants (conventional)
    STARTUP_MSG: 'Windows Starting',
    EXEC_MSG: 'This program has performed an illegal operation',
    REBOOT_MSG: 'Do you really want to reboot your computer?',

    construct: // constructor, parameter is a type of computer
        function(computerClassName) {
            // calling parent constructor
            arguments.callee.$.construct.call(this, computerClassName);
            // a cached instance of death screen (it will be the only one)
            this._bsod = new BSOD();
        },

    getBSOD: function() { return this._bsod; },

    reboot: // reboot is overriden
        function() {
            // displaying message
            alert(MSWindows.REBOOT_MSG);
            // calling parent method
            return arguments.callee.$.reboot.call(this);
        },

    shutDown: // shutting off is overriden
        function() {
            // calling BSOD and if it was successfull,
            // call a parent method, boolean result is returned
            return (this.getBSOD().launch() &&
                    arguments.callee.$.shutDown.call(this));
        },

    startUp: // booting is overriden
        function() {
            // if parent method was succesfully executed
            if (arguments.callee.$.startUp.call(this)) {
                // do some required operations
                pause(400);
                //setTimeout("alert('Windows Starting')", 400);
                // say we succesfully started
                alert(MSWindows.STARTUP_MSG);
                return true;
            } else return false; // no is no
        },

    exec: // command execution is overriden
        function(commandStr) {
            // if command is valid - say a result
            // else just shut down
            return commandStr
                ? alert(MSWindows.EXEC_MSG)
                : this.shutDown();
        }

});

/* === Usual Computer === */

var SimpleComputer = Class.extend({

    startUp: // alert when starts
        function() { alert('Starting Up'); return true; },

    shutDown: // alerts when shutting down
        function() { alert('Shutting Down'); return true; }

});

/* test function */

function perform() {
    // OS is initialized on computer (installation)
    var testOs = new MSWindows('SimpleComputer');
    // starting OS
    testOs.startUp();
    // executing a trivial command
    testOs.exec('ls -laF');
    // shutting OS off
    testOs.shutDown();
}

```

**NB!** (pay attention not to put a comma after the last method definition in class, or IE will fail)

If you have disliked the previous example -- I can offer you a useful class, that really helps if the idea of DOM element intersects with the manipulated object idea inside your project:

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

You can comfortly extend this class with other classes expanding the DOM elements functionality. Also, you can use a code like this:

``` javascript

var someElement = new ElementWrapper('someElmId');

```

…and `someElement` object will be linked to element (wrapping an element) with `id` _‘`SomeElmId`’_. To access it -- as a DOM element -- you can ask `someElement.element` property.

The following class inherits `ElementWrapper` and allows to work with element as a fully-functional graphic object (using some functions from [previous article](../16-useful-solutions-for-javascript): `getElmAttr`, `setElmAttr`, `findOffsetHeight`, `getPosition`, `getAlignedPosition`)

> As it is for some functions from [previous article](../16-useful-solutions-for-javascript), the code is changed through times -- in this case it was parallelly simplified and growed in functionality:

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
			// do not assign events listeners if they are not required
		},

    // ========[ functions to work with required attributes ]==========

    /* localLeft, localTop -- coordinates of the lop left element corner,
                              taking the [scrolling] offset into account;
       localWidth, localHeight -- the real height and width of element
       baseLeft, baseTop -- coorfinates of top left element corner
                            without the [scrolling] offset */

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

    // =======[ / function to set required attributes ]=========

	show: // show element
		function() {
			this.element.style.display    = '';
			this.element.style.visibility = 'visible';
		},

	hide: // hide element
		function() {
			if (this.element.style.display != 'none') {
				this.element.style.display  = 'none';
			}
		},

	blank: // make element "blank"
		function() {
			if (this.element.style.display != '') {
				this.element.style.display    = '';
				this.element.style.visibility = 'hidden';
			}
		},

	makeBlock: // return the element from blank or hidden state
		function() {
			if (this.element.style.display != 'block') {
				this.element.style.display  = 'block';
			}
		},

	isPointInside: // is point inside the element, point in {x, y} format
		function(curPoint) {
			var localRight  = parseInt(this.getLocalLeft()) + parseInt(this.getLocalWidth())
                                       + this.element.scrollLeft;
    		var localBottom = parseInt(this.getLocalTop())  + parseInt(this.getLocalHeight())
                                       + this.element.scrollTop;
    		return (parseInt(this.getLocalLeft()) < curPoint.x) &&
    			   (parseInt(this.getLocalTop())  < curPoint.y) &&
    			   (localRight > curPoint.x) && (localBottom > curPoint.y);
    	},

	isElementNear: /* is element is positioned near the passed element
            (overlaps the region of this element with more than a half of the current element region) */
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

	isElementInside: // is passed element is inside current element
		function(graphicalElement) {
			if (graphicalElement) {
				var elmCurPos = findPos(graphicalElement.element);
				var elmHalfHeight = parseInt(graphicalElement.getOffsetHeight())/2;
				var elmHalfWidth = parseInt(graphicalElement.getOffsetWidth())/2;
				return this.isPointInside({x:(elmCurPos.x + elmHalfWidth),
									   y:(elmCurPos.y + elmHalfHeight)})
			} else return false;
		},

	isLeftSide: // is the point ({x, y}) on the left side of elements region
		function(curPoint) {
			var elmHalfWidth = parseInt(this.getLocalWidth())/2;
			var localLeft = (parseInt(this.getLocalLeft()) > 0 ? parseInt(this.getLocalLeft()) : 0);
			return (curPoint.x >= localLeft) && (curPoint.x < (localLeft + elmHalfWidth));
		},

	isRightSide: // is the point ({x, y}) on the right side of elements region
		function(curPoint) {
			var elmHalfWidth = parseInt(this.getLocalWidth())/2;
			var localRight = ((parseInt(this.getLocalLeft()) > 0
                    ? parseInt(this.getLocalLeft())
                    : 0)) + parseInt(this.getLocalWidth());
    		return (curPoint.x <= localRight) && (curPoint.x > (localRight - elmHalfWidth));
    	},

	inTopOf: // is the point ({x, y}) on the top side of elements region
		function(curPoint) {
			var localTop 	= (parseInt(this.getLocalTop()) > 0 ? parseInt(this.getLocalTop()) : 0);
			var localHeight = (parseInt(this.getLocalHeight()) > 0 ? parseInt(this.getLocalHeight()) : 0);
			if (this.element.clientHeight && (this.element.clientHeight < localHeight))
                localHeight = this.element.clientHeight;
    		return ((curPoint.y > localTop) && (curPoint.y <= (localTop + (localHeight / 10))));
    	},

	inBottomOf: // is the point ({x, y}) on the bottom side of elements region
		function(curPoint) {
			var localTop 	= (parseInt(this.getLocalTop()) > 0 ? parseInt(this.getLocalTop()) : 0);
			var localHeight = (parseInt(this.getLocalHeight()) > 0 ? parseInt(this.getLocalHeight()) : 0);
			if (this.element.clientHeight && (this.element.clientHeight < localHeight))
                localHeight = this.element.clientHeight;
    		return ((curPoint.y >= (localTop + localHeight - (localHeight / 10))) &&
                    (curPoint.y < (localTop + localHeight)));
	    },

	recalc: // recalculates the element's coordinates
	       /* baseOffset in the very most cases is
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

	addOffset: // adds the offset to element, offset is in {x, y} format
		function(offsetXY) {
			this.setLocalLeft(parseInt(this.getBaseLeft()) - offsetXY.x);
			this.setLocalTop(parseInt(this.getBaseTop()) - offsetXY.y);
		},

    copyElmRectParameters: // copy attributes of this element to another
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

Both of these classes, I hope, will help you with making DOM elements more graphical-base (for example, for Drag'n'Drop (here I've extended the dragging nodes classes, regions classes, receiving regions classes and drag helper -- from `GraphicElementWrapper`, and the main container -- from `ElementWrapper`) or, for example, for the web-application which emulates the windows-based application (here I have extended the draggable elements from `GraphicElementWrapper`, but menu, status bar and the worktable -- from `ElementWrapper`).

Seems that's all for now. Good luck in JS-contruction-deeds :).

### Links

about this…

* … - [in russian, from Dmitry Koteroff](http://dklab.ru/chicken/nablas/40.html)
* … - [later their impressions - in russian, from Dmitry Koteroff and his companions](http://forum.dklab.ru/comments/nablas/40InheritanceInJavascript.html?start=80&sid=fac82f100376bdaceb0f5024b136fb0c)
* …[at AjaxPatterns](http://ajaxpatterns.org/Javascript_Inheritance)
* …[at AJAXPath](http://www.ajaxpath.com/javascript-inheritance/)
* …[at XML.com](http://www.xml.com/pub/a/2006/06/07/object-oriented-javascript.html)
* …[at WebReference.com](http://www.webreference.com/js/column79/ )
* …[at The Code Project](http://www.codeproject.com/aspnet/JsOOP1.asp)
* …[at JavaScript Kit](http://www.javascriptkit.com/javatutors/oopjs.shtml)
* …[at DevArticles](http://www.devarticles.com/c/a/JavaScript/ObjectOriented-JavaScript-An-Introduction-to-Core-Concepts/)
* … - [about making gallery based on this](http://chunkysoup.net/advanced/oojavascript1/)
* …[shortly, from Kevin Lindsey](http://www.kevlindev.com/tutorials/javascript/inheritance/index.htm)
* …[shortly, from Dave Johnson](http://blogs.nitobi.com/dave/?p=166)
* … - [links from Zeroglif (rus)](http://forum.vingrad.ru/index.php?showtopic=120066&view=findpost&p=1215304)
