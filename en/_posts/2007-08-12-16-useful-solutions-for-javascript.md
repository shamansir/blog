---
layout: post.html
title: 16 Practical Solutions for Javascript
datetime: 12 Aug 2007 17:55
tags: [ javascript ]
---

Let me present you a set of functions that I keep in separate `utils.js` file - they are the most frequent functions I used. They do trying very hard to be compliant with the modern browsers and they are tested in IE6/7, FF2 and Safari 2 and also in a hard complicated web-system. And they are supposed to work in other, not very old, browsers - I've used browser detection only for exceptional cases. Some of them, surely, are just mixes of something found in the open web (I am pointing to the source everywhere I remember it) and the bigger part is constructed on the base of my own ideas (and colleagues advices) intended to work properly - just because in that variety of scripts the subtleties (which become generics with closer examination :) ) are not taken into account, and to remain legible.

Functions are grouped in sections, by themes:

* **[OOP](#oop)** -- _giving a possibility to use (or just emulating) the principles of OOP in JavaScript_
* **[JS Object model](#js-object-model)** -- _usage of and extending native JavaScript objects_
* **[Browser detection](#browser-detection)** -- _to use in those exceptional cases when it is really-hopeless-required :)_
* **[Coordinates / Positioning](#coordinates-positioning)** -- _calculation of coordinates and positioning elements - it is a really tricky thing, incidentally_
* **[DOM](#dom)** -- _working with Document Object Model_
* **[AJAX](#ajax)** -- _helper functions for AJAX -- this detergent used frequently in modern times :)_
* **[Logging](#logging)** -- _it is really required sometimes :)_

**NB!** (optimising and fixing proposals are welcome)

**NB!** (all the examples are taken from the working code, but in several places function names and some small functionality is changed offhand. also, the line-wrapping was applied to the code - currently, without checking the resulting code to work. so just when it will be completely checked for its correct work, after these changes, this comment will be removed)

### OOP

<a name="sol-1"></a> _1._ First block -- is a set of three functions (two of them are empty ones :) ), providing a possibility to use (emulate?) all of three **OOP** principles in **JavaScript**. I've chosen this variant from some of proposed at [AJAXPath](http://www.ajaxpath.com/javascript-inheritance) and [AJAXPatterns](http://ajaxpatterns.org/Javascript_Inheritance) because of its both lucidity and quick execution time and I've changed it a bit, to allow the separate properties (key-values that are not defined in class methods but as class object properties) to act as a static constants.

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

The complete examples of usage are too huge for this article, so I'll pass them to [the next article](../javascript-oop), and now we'll proceed further. You may notice two simple examples in the points _[2](#sol-2)_, _[5](#sol-5)_ and _[15](#sol-15)_.

<a name="sol-2"></a> _2._ Next function -- a simple but elegant one -- is useful in combination with previous set -- it **creates a function reference for the method**:

``` javascript

function createMethodReference(object, methodName) {
    return function () {
        return object[methodName].apply(object, arguments);
    };
}

```

Now you can write something like that:

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

You can associate the instances of this class with the element-having-the-specified-ID scrolling event and to perform something in this case.

### JS Object Model

<a name="sol-3"></a> _3._ The following function **clones** any **object** including all of its properties:

``` javascript

function cloneObj(objToClone) {
    var clone = [];
    for (i in objToClone) {
        clone[i] = objToClone[i];
    }
    return clone;
}

```

The usage is enormously simple:

``` javascript

var clonedObj = cloneObj(objToClone);

```

<a name="sol-4"></a> _4._ **Objects converter**. Next function provides an elegant way to make a conditional constructs like  `if (tablet.toLowerCase() in oc(['cialis','mevacor','zocor'])) { alert('I will not!') };` work. The code is borrowed from [here]http://snook.ca/archives/javascript/testing_for_a_v/).

``` javascript

function oc(a) {
    var o = {};
    for(var i=0;i<a.length;i++) {
        o[a[i]]='';
    }
    return o;
}

```

An example is the situation when you first need to test is object exist in some set of single objects, and then, is it exist in pair with another object in another set of object pairs. Let's imagine that we've organized a party for the people with concrete allowed names, if they are single, and with concrete allowed name pairs, if they are in pair:

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

<a name="sol-5"></a> _5._ A function that allows to create **hash** seems to be a little bit overhead at first sight: JavaScript objects act almost like hashes, but sometimes you find yourself in need to use some existing variable value as a key -- and here comes the `Hash` function (yes, you can also make this function it in your favourite look-how-I-hacked-up-this-feee-js style, but I think my method is a little bit more polite to JS :) -- you can exclude this function from the 'useful' list if you want :) )

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

To access the elements, just use `items` property (may be I need to make `keys` property in new version by the way? :) ):

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

<a name="sol-6"></a> _6._ Three other functions just make some operations easier/lighter: `getTime` shortens the access to **current time** in 11 symbols, `getTimeDelta` lets you to find the **time difference in milliseconds** between the moments of time (or the one passed moment and the current time in the single-parameter-mode), and the last function just extends the **methods of `Number`** object **to get 0 when it's `NaN`** a little bit easier.

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

### Browser detection

<a name="sol-7"></a> _7._ A small object, the named properties of it -- are conditions. This is how the readability of **most types of browsers detection** is achieved here. This object was borrowed by me from the project I've participated in -- and I found myself that use it frequently, but I think the real authors are somewhere in the web, and the code is not so complicated to pretend on something... If you don't like the way it works or it not works for your browser, you may use an alternative [from HowToCreate](http://www.howtocreate.co.uk/jslibs/htmlhigh/sniffer.html). And I'll repeat: this way of detection I use "_only in the case if concrete bug in concrete browser is known and I need to avoid it". Also, you can use this object as a long line of code to make it work faster (how -- look [here](http://www.howtocreate.co.uk/jslibs/htmlhigh/sniffer.html) again)

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

### Coordinates / Positioning

<a name="sol-8"></a> _8._ The set of functions that allow to get **element coordinates** on the user screen.

If your document is static relatively to the window, and there are no scrollbars -- you better use `getPosition` function -- this will work faster. If this statement is false for you, use `getAlignedPosition` -- it checks the scrollbars positions. Just pay attention: `top` or `left` attribute of element can be negative, if it is placed outside the window -- to be synchronized with mouse pointer you'll possibly need to reset the height of element to 0. The basic script is take from [one blog](http://blog.firetree.net/2005/07/04/javascript-find-position/), Aligned-version -- is a result of much searches mixed with the information from [two](http://xhtml.ru/2007/03/10/advanced-thumbnail-creator/) [articles](http://www.habrahabr.ru/blog/webdev/13897.html) (when IE sees `DOCTYPE` it goes in its own, a little bit unpredictable, mode). Also this method is combined with getting positions from [sources](http://www.webreference.com/programming/javascript/mk/column2/Dragging%20and%20Dropping%20in%20JavaScript_files/drag_drop.js) [of Drag’n'Drop tutorial](http://www.webreference.com/programming/javascript/mk/column2/). Pay attention: the function `NaN0` from point _[6](#sol-6)_ is used here, you'll need to add it to the script to make it work correctly :) (thanks, [Homer](http://invisibleman.ru/)).

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

> The times passed, and this two function has merged into one, a little bit simpler one, universal one and correct herewith (but if you getting position of the element that is held inside another scrollable element -- do not forget to add `scrollTop` or `scrollLeft` coordinated of the last one to the first one: your code will look nicer and more logical if you will use it in concrete place, unlike with aligned-version:

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

<a name="sol-9"></a> _9._ Getting current **mouse pointer coordinates** is relatively easy, if you use the according function (constructed on the base [of](http://xhtml.ru/2007/03/10/advanced-thumbnail-creator/) [three](http://www.habrahabr.ru/blog/webdev/13897.html) [sources](http://quirksmode.org/js/events_properties.html)):

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

> The updated version of `getMouseOffset` for the variant with single position detection function:
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

The last function can also be used in two modes, using the `aligned` parameter and intended for easy usage in events handlers, for example:

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

**NB!** (if this functions (_suddenly_ :) ) will not work in some case -- please report -- I want to achieve the maximum of portability)

<a name="sol-10"></a> _10._ Evaluating **the height of element** is a hard task in several cases, harder then getting its other parameters, but this two functions will help:

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

<a name="sol-11"></a> _11._ Sometimes you need **to walk the DOM tree recursively**, starting from some element and performing some function with each child, getting to the deepest deeps. There is `TreeWalker` object in DOM, but it fails to work in IE and it is not always easy/simple in use. `walkTree` function allows to perform some another function with each of child elements and also to pass some data package. `searchTree` function differs in that it stops the walk after the first successful result and returns the result to the call point:

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

The functions `setElmAttr` and `getElmAttr`, are used in example, I'll present them in _[13](#sol-13)_ point. By fact, they do the same as `getAttribute` and `setAttribute` do. The used `oc` function description is in _[4](#sol-4)_ point. In the first part of example the root element's "`nodeType`" attribute is set to "`root`", and for all of its children - to "`child`". In the second part the data package passing is demonstrated -- when we find the first element having the "`class`" attribute equal to one of the names in the package, its "`isTarget`" attribute is set to "`true`".

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

**NB!** (be careful with these functions and try to avoid the frequent calls of them (more than one time in a second) even on the easy tree - they can eat a lot of resources. Or at least call them in background using `setTimeout`)

<a name="sol-12"></a> _12._ **Removing nodes** is sometimes the task you need to do. In one cases you need to remove the single node, in other -- only its children.  `removeChildrenRecursively` function remove all the children of the specified node excluding itself. `removeElementById` removes element by its `id` - the task is simple but the way is tricky:

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

<a name="sol-13"></a> _13._ Seems the elementary task -- working with attributes of the element -- but sometimes you meet the absolutely occasional problems: IE, for example, throws an exception when trying to access `table` element width/height attributes, and Safari differs in access to attributes with namespaces. The following function are avoiding all the problems I've met, without severe damage for the execution speed (for sure, it is better to use the native functions in standard cases):

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

### AJAX

<a name="sol-14"></a> _14._ If you need nothing more but just **execute asynchronous call** and do something and on the basis of data obtained -- this function is for you. The way of getting `XMLHttpRequest` object can be replaced, of course. Comments are intentionally left to show the ideas on extending the function:

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

The example of usage -- is from one of my working test task, that searched over the music and/or music database using the string entered in the element with "`searchStr`" `id`, using `LIKE` in `SQL`:

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

### Logging

<a name="sol-15"></a> _15._ The function presented below is very simple and intended to help in **logging**. Just add somewhere in the document the `<div id="LOG_DIV"></div>` element, set the required height for it, and you'll get an information redirected in it, even with scrolling:

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

<a name="sol-16"></a> _16._ In the very cool [Firebug](http://www.getfirebug.com/) plugin for Firefox there is the very cool **console**, where you can [place your logs](http://www.getfirebug.com/console.html) with much of features. However, if you are debugging the code in other browsers -- calling it will cause errors and even crashes. Not to clear your `console.log` calls every time, you can use this stub instead:

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

Combining the previous point with CSS can inspire you to write your own console but for another browsers ;). If you'll make it - please share with me :).

### Bonus

As a bonus (not to mess with number in the title, pleasantly smelling with binariness :) ) I will tell you about **double click** problem -- not me who fought with this bug, but my colleagues, the problem is -- when registering `ondblclick` event, the `onclick` event is called anyway. So, if you really need to handle this (not so obvious for web user, I need to mention) event - you need to have something like this code in the scripts (with the milliseconds count you need and saving an element that was clicked, if required):

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

Its usage causes severe conditions. Now in `ondblclick` handler you need to call first function at the start and -- when you've done handling -- the second in the end, and in the `onclick` handler you need to ensure that double click was _not_ performed:

``` html

<div id="someId" onclick="if (!dblClicked) alert('click');"
ondblick="dblClick(this); alert('dblclick'); releaseDblClick();";></div>

```

Also, for the point  _[1](#sol-1)_ we can add a small function of **getting an instance** (you can change it to pass arguments in constructor if you wish):

``` javascript

function getInstanceOf(className) {
    return eval('new ' + className + '()');
}

```

The **pause** function will fit the point _[6](#sol-6)_ (the real pause, not what the `setTimeout` does):

``` javascript

function pause(millis)
{
    var time = new Date();
    var curTime = null;
    do { curTime = new Date(); }
        while (curTime - time < millis);
}

```

**Upd.** Some more functions for the point _[6](#sol-6)_:

Determining of **number occurrence in the range**, limited by the `start` number inclusively and `stop` number exclusively:

``` javascript

Number.prototype.inBounds=function(start,stop){return ((this>=start)&&(this<stop))?true:false;};

```

**Trimming** starting and ending **whitespace symbols** from the line:

``` javascript

String.prototype.trim=function(){var temp = this.replace( /^\s+/g, "" );return temp.replace( /\s+$/g, "" );}

```

**Converting** the object or the string **to `boolean` type**. It can be declared also for a `Boolean`-object, just because you may not know the type of passed object:

``` javascript

function boolFromObj(obj){return(((obj=="true")||(obj == true))?true:false);}

String.prototype.asBoolVal=function(){return ((this=="true")?true:false);}

Boolean.prototype.asBoolVal=function(){return ((this==true)?true:false);}

```

**Padding with zeroes** the number until its digits-length with not fit the specified one:

``` javascript

Number.prototype.getFStr=function(fillNum){var fillNum=fillNum?fillNum:2;var
temp=""+this;while(temp.length<fillNum)temp="0"+temp;return temp;}

```

Along with that, we can add the **sorting** functions to the [second part](#js-obj-model),...

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

...where the `getObjSortedProps` function allows to get the array of sorted (with `sortFunc` comparator) names of passed object properties, and `intComparator` function can be passed to the arrays `sort` function or the very same `getObjSortedProps` function, if the required array or object properties names are consist of numeric values...

...and two function to **ease the work with arrays**:

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

`indexOf` return the index of the specified element in array, and `removeFromArray` removes the specified element from array.

### Epilogue

That's all, seems, for now. The article is ready for corrections (if they will appear :) ), I can pass to the next ones :). In the [next-article](./javascript-oop) I want to tell about OOP in JavaScript and make a few simple but useful examples of classes. I hope this article saved some of your man-hours that you may potentially had spent in the fighting with variable browsers quirks.
