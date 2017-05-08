---
layout: post.html
title: 3 Маленьких JS-Сниппета
datetime: 03 Feb 2011 11:55
tags: [ javascript ]
---

В данный момент я делаю разные вещи на JavaScript и мне нужно, чтобы код с которым я работаю, был насколько возможно лёгок и прост. Лёгок и прост так же, как и эта статья. Но есть вещи, которые для комфортного программирования мне обязательны. Поэтому и от них тоже я требую лёгкости и простоты.

### Сниппет первый. Двустрочный each (одна функция)

Работает с массивами и объектами. В случае объектов в колбэк передаются ключ и значение. В случае массивов - элемент.

``` javascript

/**
 * Нано-each
 * @param {Array, Object} iterable сущность, по которой производится итерирование
 * @param {Function} func вызвается на каждой итерации, в режиме массива принимает элемент (func(elem)),
                                                        в режиме объекта принимает ключ и значение (func(v, k))
 */
function each(iterable, func) {
    if (iterable instanceof Array) for (var i = 0; i < iterable.length; i++) func.call(iterable, iterable[i]);
    else if (iterable instanceof Object) for (field in iterable) func.call(iterable, iterable[field], field);
}

```

### Сниппет второй. Быстрое создание объекта (Одиночное наследование, одна функция)

Это совсем чуть-чуть изменённая версия [из этой прелестной статьи](http://www.willmcgugan.com/blog/tech/2009/12/5/javascript-snippets/). Кстати, функция `bind` полезна для случаев типа такого: `var catMeow = bind(cat, Cat.meow);`.

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

#### Использование

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

### Сниппет третий. Легкий механизм тестирования (одна или две функции)

Для быстрого TDD, если вам оно нравится. Если вам нужно просто проверять ассерты, а не запускать большие сложные тесты, берите только `AssertException` и функцию `assert` - это всё что вам нужно. Если нет, `runTests` позволяет вам запускать `JUnit`-подобные коллекции текстов, даже с использованием  `setUp` и `tearDown`. (Использует консоль для вывода результатов тестов, так что в этом варианте может работать только в Firefox и WebKit)

``` javascript

function AssertException(result, expectation) { this.result = result;
                                                this.expectation = expectation; }
AssertException.prototype.toString = function () {
    if (this.expectation) return ('AssertException: Expected: ' + this.expectation + ' Got: ' + this.result);
    else return ('AssertException: Got: ' + this.result);
}

/**
 * Нано-ассерт
 * @param {Boolean} test тестируемое выражение
 * @param {String} [_expectation] что ожидалось
 * @throws {AssertException} если ассерт не прошёл
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
 * Гонщик тестов
 * @param {Object, Function} suite для параметров типа функция,
                                       вызывает эту функцию и пишет в консоль Firebug если какой-либо ассерт не прошёл
                                   для параметров типа объект,
                                       работает как JUnit, вызывает каждый метод с именем начинающимся с 'test...',
                                       также в нужные моменты вызывает 'setUp' и 'tearDown'
                                       сообщает в консоль Firebug о пройденных/упавших тестах вместе с именем метода
 * @param {String} [_name] имя теста или коллекции тестов (используется только для того, чтобы помочь вам определить в логах что именно упало)
 * @param {String} [_stopWhenFailed] для режима объекта, прекращает выполнение тестов при первом упавшем ассерте
 * @returns {AssertException} в режиме функции - первый упавший ассерт, в режиме объектов - ничего не возвращается
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

#### Примеры

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

### Тесты для сниппетов

С использованием TDD-сниппета я написал общий Test Suite для всех трёх сниппетов, чтобы продемонстрировать их во взаимодействии:

[Test Suite](http://paste.pocoo.org/show/344963/) | [Все сниппеты](http://paste.pocoo.org/show/344962/)

**P.S.** См. тж. [atom.js](https://github.com/theshock/nanojs) ([статья](http://habrahabr.ru/blogs/javascript/109762/))
