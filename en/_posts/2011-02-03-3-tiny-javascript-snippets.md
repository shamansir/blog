---
layout: post.html
title: 3 Tiny JavaScript Snippets
datetime: 03 Feb 2011 11:55
tags: [ javascript ]
---

Currently I am doing some stuff in JavaScript and I need to have just a tiny amounts of code to work with. As tiny as this article. But there are some things I really need to make the development comfortable for myself. So I require them to be tiny too.

### Two-Liner Each (one function)

Works just with objects and arrays. For objects, callback takes key and value. For arrays, callback takes element.

``` javascript

/**
 * Tiny each
 * @param {Array, Object} iterable the iterable to iterate through
 * @param {Function} func to call on each iteration, in array-mode gets an element (func(elem)),
                                                     in object-mode gets a key and value (func(v, k))
 */
function each(iterable, func) {
    if (iterable instanceof Array) for (var i = 0; i < iterable.length; i++) func.call(iterable, iterable[i]);
    else if (iterable instanceof Object) for (field in iterable) func.call(iterable, iterable[field], field);
}

```

### Quick Class Construction (Single Inheritance, one function)

This is just a slightly modified version from [this nice article](http://www.willmcgugan.com/blog/tech/2009/12/5/javascript-snippets/). Also, `bind` function is useful to make stuff like this: `var catMeow = bind(cat, Cat.meow);`.

``` javascript

function class_(def) {
    var _proto = def;
    if (def['_extends'] !== undefined) {
        var _ex = def['_extends'];
        if (typeof _ex === 'function') {
            each(_ex.prototype, function(v, k){
                if (_proto[k] === undefined) {
                    _proto[k] = v;
                } else {
                    _proto['_s_'+k] = v;
                }
            });
        } else throw new Error('Wrong _extends field');
    }

    var _init = def['_init'];
    if (_init === undefined) {
        _init = function() {
            if (this.prototype['_s__init']) this._init_super();
        }
    }
    _init.prototype = _proto;

    def['hasOwnProperty'] = function(k) {
        return (k !== 'hasOwnProperty')
               && (Object.prototype.hasOwnProperty.call(this, k)
                  || Object.prototype.hasOwnProperty.call(_proto, k));
    }

    return _init;
}

function bind(obj, method) {
    return function() { return method.apply(obj, arguments); }
}

```

#### Usage

``` javascript

var Base = class_({

    _init: function(a, b) {
        this.a = a;
        this.b = b;
    }

    someMethod: function() {
        console.log('parent');
    }

});

var Child = class_({

    _extends: Base,

    _init: function(c) {
        this._s__init(5, 6);
        this.c = 7;
        console.log(this.a);
        console.log(this.b);
        console.log(this.c);
    },

    someMethod: function() {
        this._s_someMethod();
        console.log('child');
    }

});

var b = new Base();
var c = new Child();

b.someMethod();
c.someMethod();

console.log(b instanceof Base);
console.log(b instanceof Child);
console.log(c instanceof Base);
console.log(c instanceof Child);

```

### Easy assertions mechanism (one or two functions)

Just for quick TDD, if you like it. If you need only assertions, not a tests suites, take just `AssertException` and `assert` function - they are everything you need. Else, `runTests` allows you to run `JUnit`-like tests suites, even with proper `setUp` and `tearDown`. (Uses console to inform about tests results so in the presented form it may work only in Firefox / WebKit browsers)

``` javascript

function AssertException(result, expectation) { this.result = result;
                                                this.expectation = expectation; }
AssertException.prototype.toString = function () {
    if (this.expectation) return ('AssertException: Expected: ' + this.expectation + ' Got: ' + this.result);
    else return ('AssertException: Got: ' + this.result);
}

/**
 * Tiny assert
 * @param {Boolean} test the expression to test
 * @param {String} [_expectation] what was expected
 * @throws {AssertException} if assertion was failed
 */
function assert(test, _expectation) {
    if (!test) throw new AssertException(test, _expectation);
}

function _assert(test, val, expectation) {
    if (!test) throw new AssertException(val, expectation);
}

function assertNotNull(test) { _assert(test !== null, test + ' == null', 'not null'); }
function assertDefined(test) { _assert(test !== undefined, test + ' !== undefined', 'defined'); }
function assertTrue(test) { _assert(test, test + ' != true', 'true'); }
function assertFalse(test) { _assert(!test, test + ' != false', 'false'); }
function assertEquals(first, second) { _assert(first === second, first + ' != ' + second, second + ' == ' + second); }
function assertInstance(test, cls) { _assert(test instanceof cls, test + ' not instance of ' + cls, test + ' instance of ' + cls); }
function assertType(test, typename) { _assert(typeof test == typename, test + ' is not of type ' + typename, test + ' has type ' + typename); }

/**
 * Tests runner
 * @param {Object, Function} suite for function-typed parameter,
                                       calls a function and informs through Firebug console about assertions
                                   for object-typed parameter,
                                       works like JUnit, calls every method which name starts with 'test...'
                                       also calls 'setUp' and 'tearDown' in the proper moments
                                       informs through Firebug console about assertions and passed/failed methods
 * @param {String} [_name] some name for test case or test suite (used only in logs to help you determine what failed)
 * @param {String} [_stopWhenFailed] for object-mode, stops testing when first assertion is failed in some method
 * @returns {AssertException} first failed exception for function-mode, nothing for object-mode
 *
 * runTests(new SomeClass());
 * runTests(someFunc(), 'someFunc');
 */
var __tCount = 0,
    __fCount = 0;
function runTests(suite, _name, _stopWhenFailed) {
    if (typeof suite === 'function') { __fCount++;
        var field = (_name ? _name : ('Function ' + __fCount));
        try { suite();
              console.info('%s: %s', field, 'OK');
        } catch (ex) {
            if (ex instanceof AssertException) {
                var info_ = '(' + field;
                if (ex.lineNumber) info_ += ':' + ex.lineNumber;
                if (ex.expectation)  console.error('Assertion failed. Expected:', ex.expectation,
                                                    '. Got:', ex.result, info_ + ')');
                else console.error('Assertion failed. Got:', ex.result, info_ + ')');
                console.error(ex);
                console.warn('%s: %s', field, 'FAILED');
                return ex;
            } else {
                throw new Error(ex.toString());
            }
        }
    } else if (typeof suite === 'object') { __tCount++;
        var title = _name || ("Suite " + __tCount);
        console.group(title);
        for (var field in suite) {
            if ((typeof suite[field] === 'function') &&
                (field.indexOf('test') === 0) && suite.hasOwnProperty(field)) {
                console.log('Running', title + ' / ' + field);
                if (suite.setUp) suite.setUp();
                var result = runTests(bind(suite, suite[field]), field);
                var passed = (result === null);
                if (_stopWhenFailed && (result !== null)) return result;
                if (suite.tearDown) suite.tearDown();
            }
        }
        console.groupEnd();
    } else {
        throw new Exception('Passed var has invalid type');
    }
    return null;
}

```

#### Examples

``` javascript

var T1 = class_({

   _init: function() {  },

   setUp: function() { },

   test1: function() {
       assert(null == null);
       assert(12 == null, '12 == null');
       assert('a' == null);
       assertTrue(true);
       assertFalse(false);
       assertTrue(false);
       assertFalse(true);
       assertEquals(5, 5.1);
       assertEquals(5, 5);
       assertEquals('a', 'ab');
       assertEquals('a', 'a');
       assertType(12, 'integer');
       assertType(12, 'string');
       assertType('12', 'string');
       assertInstance(this, T1);
       assertInstance(this, Object);
       assertInstance(null, Object);
       assertNotNull(this);
       assertNotNull(null);
   },

   test2: function() {
       //throw new Error('Alala');
       assertEquals(6, 7.2);
   },

   tearDown: function() { }

});

var _f = function() {
    assertTrue(true);
    assertEquals('12', true);
}

runTests(new T1());
runTests(_f, '_f');

new T1().test1();

_f();

```

### Snippets tests

Using TDD-snippet, I wrote a general Test Suite for all of three snippets to demonstrate their interaction.

[Test Suite](http://paste.pocoo.org/show/344963/) | [All snippets](http://pastie.org/pastes/1585157)
