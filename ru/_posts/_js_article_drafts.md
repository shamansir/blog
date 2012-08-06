function Y(f) {
    return (
        (function (x) {
            return f(function (v) { return x(x)(v); }); })
        (function (x) {
            return f(function (v) { return x(x)(v); }); })
    );
}



// Factorial function using the Y combinator
var factorial = Y(function (fac) {
    return function (n) {
        if (n == 0) { return 1; }
        else { return n * fac(n - 1); }
    };
});

factorial(5);

Number.prototype.to = function(to) {
    for (var i = this; i <= to; ++i) {
        yield(i);
    }
}

immutable lists and functions rule
                         ( thrill.filter(s => s.length == 4)
                           thrill.foreach(s => print(s))
                           thrill.foreach(print)
                           thrill.map(s => s + "y")
                           thrill.sort((s, t) => s.charAt(0).toLower <
                                                 t.charAt(0).toLower) )

yield

for_in

0.to(1)

.apply
.update

cons / car / cdr

monads

http://net.tutsplus.com/tutorials/javascript-ajax/digging-into-design-patterns-in-javascript/

--------------------------------

val filename =
    if (!args.isEmpty) args(0)
    else "default.txt"

 for (
          file <- filesHere
          if file.isFile
          if file.getName.endsWith(".scala")
) println(file)

val filesHere = (new java.io.File(".")).listFiles
    for (file <- filesHere if file.getName.endsWith(".scala"))
        println(file)

def grep(pattern: String) =
          for (
            file <- filesHere
            if file.getName.endsWith(".scala");
            line <- fileLines(file)
            if line.trim.matches(pattern)
          ) println(file +": "+ line.trim)
        grep(".*gcd.*")

def scalaFiles =
    for {
      file <- filesHere
      if file.getName.endsWith(".scala")
    } yield file

try {
    val f = new FileReader("input.txt")
    // Use and close file
  } catch {
    case ex: FileNotFoundException => // Handle missing file
    case ex: IOException => // Handle other I/O error
}

def urlFor(path: String) =
          try {
            new URL(path)
          } catch {
            case e: MalformedURLException =>
              new URL("http://www.scala-lang.org")
}

def f(): Int = try { return 1 } finally { return 2 } // equal to
def g(): Int = try { 1 } finally { 2 }

 val firstArg = if (!args.isEmpty) args(0) else ""
        val friend =
          firstArg match {
            case "salt" => "pepper"
            case "chips" => "salsa"
            case "eggs" => "bacon"
            case _ => "huh?"
          }
        println(friend)

someNumbers.filter(_ > 0)
someNumbers.filter(x => x > 0)

someNumbers.foreach(println _)
someNumbers.foreach(x => println(x))
someNumbers.foreach(println) // if arg of foreach is func

def sum(a: Int, b: Int, c: Int) = a + b + c
val b = sum(1, _: Int, 3)
b(2) == 6
b(5) == 9

class Frog extends Animal with Philosophical with HasLegs {
          override def toString = "green"
}

object FileMatcher {
    private def filesHere = (new java.io.File(".")).listFiles
    private def filesMatching(matcher: String => Boolean) =
      for (file <- filesHere; if matcher(file.getName))
        yield file
    def filesEnding(query: String) =
      filesMatching(_.endsWith(query))
    def filesContaining(query: String) =
      filesMatching(_.contains(query))
    def filesRegex(query: String) =
      filesMatching(_.matches(query))
}

scala> def curriedSum(x: Int)(y: Int) = x + y
curriedSum: (x: Int)(y: Int)Int
scala> curriedSum(1)(2)
res5: Int = 3
scala> val twoPlus = curriedSum(2)_
twoPlus: (Int) => Int = <function1>
scala> twoPlus(2)
res8: Int = 4

scala> def twice(op: Double => Double, x: Double) = op(op(x))
twice: (op: (Double) => Double,x: Double)Double
scala> twice(_ + 1, 5)res9: Double = 7.0

def withPrintWriter(file: File, op: PrintWriter => Unit) {
    val writer = new PrintWriter(file)
    try {
      op(writer)
    } finally {
      writer.close()
    }
}
withPrintWriter(
    new File("date.txt"),
    writer => writer.println(new java.util.Date)
)

def withPrintWriter(file: File)(op: PrintWriter => Unit) {
    val writer = new PrintWriter(file)
    try {
      op(writer)
    } finally {
      writer.close()
    }
}
val file = new File("date.txt")
  withPrintWriter(file) {
    writer => writer.println(new java.util.Date)
}

Listing 7.1 · Scala’s idiom for conditional initialization.

This time, the if has two branches. If args is not empty, the initial element, args(0), is chosen. Else, the default value is chosen. The if ex- pression results in the chosen value, and the filename variable is initialized with that value. This code is slightly shorter, but its real advantage is that it uses a val instead of a var. Using a val is the functional style, and it helps you in much the same way as a final variable in Java. It tells readers of the
code that the variable will never change, saving them from scanning all code in the variable’s scope to see if it ever changes.

A second advantage to using a val instead of a var is that it better sup- ports equational reasoning. The introduced variable is equal to the expres- sion that computes it, assuming that expression has no side effects. Thus, any time you are about to write the variable name, you could instead write the expression. Instead of println(filename), for example, you could just as well write this:

println(if (!args.isEmpty) args(0) else "default.txt")

The choice is yours. You can write it either way. Using vals helps you safely
make this kind of refactoring as your code evolves over time.

Look for opportunities to use vals. They can make your code both easier to read and easier to refactor.

 If a function isn’t returning any interesting value, which is what a result type of Unit means, the only way that function can make a difference in the world is through some kind of side effect. A more functional approach would be to define a method that formats the passed args for printing, but just returns the formatted string, as shown in Listing 3.9:

--------------------------------

Mastering True JavaScript

// Intro (this article continues previous articles)
// Why JS? (about libraries, current version, client side, dynamic typing flexibility; no overloading / custom operators, types vs. classes)
// Why Functional? (all these articles are about the fact classes are not required, uniform access (field or method is no difference), no side effects, pure functions, immutable objects)
// Why Not Functional? (vars and vals, other stuff, memory for immutable objects, readability, API is not affected sometimes, no overloading)
// Objects
// Lists
// Functions
//   Structure
//   Function is a Block (Brick)
//   Anonymous calls
//   In-place calls
//   Anonymous In-place calls
//   this Keyword, Methods vs. Functions + Local Functions
//   Mastering Arguments
//   Cheating with `this` (call & apply)
//   [Flexibility]
//   Closures (unbound vars, open / closed term, p.198)
// Prototyping
//   Approach (Not classes: clone / extend, not inherit, prototyping is for Types)
//   Dynamic Types: pros & cons (no overloading, less strict)
//   Fields / Properties
//   Prototype
//   The Holy New
//   Methods
//   Static Methods
//   this Keyword
// Why Not a Library? (variable names allowed to be unicode chars, but not recommended)
// Не преумножать сущности
// Extending Types: Evil or Not
// Mastering Functions
//   Pure Functions (side-effects, avoid multiple returns)
//   Lambdas (simplify to have a var like _ in Scala, comparison to other languages)
//   Modules
//   Recursing (Tail Recursing, p.202)
//   Magic Comma
//   Advanced Looping (incl. each and while (i--))
//   Iterators / Collections
//   Generators / Yielding / Ranges
//   Walking / Travelling through Trees
//   Graphs
//   Map / Reduce
//   Chaining
//   Logical Chaining ( ||, && ... )
//   Currying (+ car / cdr...)
//   Deferring
//   Chains of Deferred Functions (Queues)
//   Decorating
//   Y-Combinator
//   Monads
//   Named & Default Params
//   Event Bus
//   Loops return value, not only conditions?
//   Mighty Match instead of Switch
//   Partially Defined Functions (some arguments are predefined before calling)
//   Factories, Observers and other Patterns
//   [Loops w/ no break / continue]
// Mastering Clones
//   Immutability
//   Cloning
//   Duck Typing
//   Interfaces
//   Mixing In, Traits (same-named methods?)
//   Overriding
//   Validation in Conctructors
//   Validation of Values in Methods (like require() in scala)
//   Multiple Constructors
//   [Combinators]
//   [Abstract Methods]
// Literature (Scala helped)


------------

function _YieldValue(val) {
   this.val = val;
}
function yield(what) {
   throw new _YieldValue(what);
}
function _(gen) {
  var l = [];
  try { gen(); } catch(y) { l.push(y); }
  return l;
}
_(function() { yield(2); yield(3); });





var vals;

function _(f) {
  vals = [];
  var finished;
  setTimeout(function() {
    f(); // <- deferred call
    finished = 1;
  }, 1);
  while (!finished); // <- keeps executing
  console.log(vals);
  return vals;
}

function yield(val) {
  vals.push(val);
}
function range(st, f) {
  return function() { for (var i = st; i <= f; i++) yield(i); }
}
_(range(1, 5));



// Generator demo for JavaScript
// http://nixtu.blogspot.it/2012/03/implementing-generators-in-javascript.html

function generator(valueCb) {
  return function() {
    var i = 0;

    return {
      next: function() {
        var ret = valueCb(i);
        i++;

        return ret;
      }
    };
  }();
}

function cycle() {
  var items = arguments;

  return generator(function(i) {
    return items[i % items.length];
  });
}

function pows(n) {
  return generator(function(i) {
    return Math.pow(i, n);
  });
}

function range(a, b) {
  if(!b) { // TODO: check against undefined
    b = a;
    a = 0;
  }

  return generator(function(i) {
    return a + i < b? a + i: null;
  });
}

var nums = pows(1);
var squares = pows(2);
var cubes = pows(3);
var choices = cycle('red', 'green', 'blue');

var r = range(1, 5);

console.log('Running generators');
while(r.next()) {
  console.log(choices.next());
}






var state = 0;

function watcher() {
    if (state == -1) { console.log('finished'); }
    else setTimeout(watcher, 1);
}
setTimeout(watcher, 1);


setTimeout(function() { state = -1 }, 5000);


http://ejohn.org/blog/how-javascript-timers-work/
http://bjouhier.wordpress.com/2011/05/24/yield-resume-vs-asynchronous-callbacks/
http://answers.oreilly.com/topic/1506-yielding-with-javascript-timers/
http://stackoverflow.com/questions/7029776/strange-yield-syntax-in-javascript
https://github.com/mozilla/task.js
http://ejohn.org/blog/javascript-18-progress/
http://balpha.de/2011/06/introducing-lyfe-yield-in-javascript/


------


https://bitbucket.org/balpha/lyfe

/*!
 * Copyright (c) 2011, 2012 Benjamin Dumke-von der Ehe
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished
 * to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

(function () {

    var arrIndexOf;
    if (Array.prototype.indexOf) {
        arrIndexOf = function (arr, val) { return arr.indexOf(val); };
    } else {
        arrIndexOf = function (arr, val) {
            var len = arr.length;
            for (var i = 0; i < len; i++)
                if (i in arr && arr[i] === val)
                    return i;
            return -1;
        };
    }

    var BreakIteration = {};

    var Generator = function (source) {
        if (!(this instanceof Generator))
            return new Generator(source);

        if (typeof source === "function")
            this.forEach = makeForEach_fromFunction(source);
        else if (source.constructor === Array)
            this.forEach = makeForEach_fromArray(source);
        else
            this.forEach = makeForEach_fromObject(source);
    };

    var asGenerator = function (source) {
        if (source instanceof Generator)
            return source;

        return new Generator(source);
    };

    var stopIteration = function () {
        throw BreakIteration;
    };

    var IterationError = function (message) {
        this.message = message;
        this.name = "IterationError";
    };
    IterationError.prototype = Error.prototype;

    var makeForEach_fromFunction = function (f) {
        return function (g, thisObj) {
            var stopped = false,
                index = 0,
                Yield = function (val) {
                    if (stopped)
                        throw new IterationError("yield after end of iteration");
                    var send = g.call(thisObj, val, index, stopIteration);
                    index++;
                    return send;
                },
                yieldMany = function (source) {
                    asGenerator(source).forEach(function (val) { Yield(val); })
                };
            try {
                f(Yield, yieldMany, stopIteration);
            } catch (ex) {
                if (ex !== BreakIteration)
                    throw ex;
            } finally {
                stopped = true;
            }
        };
    };

    var makeForEach_fromArray = function (arr) {
        return makeForEach_fromFunction(function (Yield) {
            var len = arr.length;
            for (var i = 0; i < len; i++)
                if (i in arr)
                    Yield(arr[i]);
        });
    };

    var makeForEach_fromObject = function (obj) {
        return makeForEach_fromFunction(function (Yield) {
            for (var key in obj)
                if (obj.hasOwnProperty(key))
                    Yield([key, obj[key]]);
        });
    };

    var selector = function (f) {
        if (typeof f === "string")
            return function (o) { return o[f]; }
        return f;
    }

    Generator.prototype = {
        toArray: function () {
            var result = [];
            this.forEach(function (val) { result.push(val); });
            return result;
        },
        filter: function (pred, thisObj) {
            var source = this;
            pred = selector(pred);
            return new Generator(function (Yield) {
                source.forEach(function (val) {
                    if (pred.call(thisObj, val))
                        Yield(val);
                });
            });
        },
        take: function (n) {
            var source = this;
            return new Generator(function (Yield) {
                source.forEach(function (val, index, stop) {
                    if (index >= n)
                        stop();
                    Yield(val);
                });
            });
        },
        skip: function (n) {
            var source = this;
            return new Generator(function (Yield) {
                source.forEach(function(val, index) {
                    if (index >= n)
                        Yield(val);
                });
            });
        },
        map: function (f, thisObj) {
            var source = this;
            f = selector(f);
            return new Generator(function (Yield) {
                source.forEach(function (val) {
                    Yield(f.call(thisObj, val));
                });
            });
        },
        zipWithArray: function (arr, zipper) {
            if (typeof zipper === "undefined")
                zipper = function (a, b) { return [a, b]; };

            var source = this;

            return new Generator(function (Yield) {
                var len = arr.length;

                source.forEach(function (val, index, stop) {
                    if (index >= len)
                        stop();
                    Yield(zipper(val, arr[index]));
                });
            });
        },
        reduce: function (f, firstValue) {
            var first,
                current;

            if (arguments.length < 2) {
                first = true;
            } else {
                first = false;
                current = firstValue;
            }

            this.forEach(function (val) {
                if (first) {
                    current = val;
                    first = false;
                } else {
                    current = f(current, val);
                }
            });
            return current;
        },
        and: function (other) {
            var source = this;
            return new Generator(function (Yield, yieldMany) {
                yieldMany(source);
                yieldMany(other);
            });
        },
        takeWhile: function (pred) {
            var source = this;
            pred = selector(pred);
            return new Generator(function (Yield) {
                source.forEach(function (val, index, stop) {
                    if (pred(val))
                        Yield(val);
                    else
                        stop();
                });
            });
        },
        skipWhile: function (pred) {
            var source = this;
            pred = selector(pred);
            return new Generator(function (Yield) {
                var skipping = true;

                source.forEach(function (val) {
                    skipping = skipping && pred(val);
                    if (!skipping)
                        Yield(val);
                });
            });
        },
        all: function (pred) {
            var result = true;
            pred = selector(pred);
            this.forEach(function (val, index, stop) {
                if (!(pred ? pred(val) : val)) {
                    result = false;
                    stop();
                }
            });
            return result;
        },
        any: function (pred) {
            var result = false;
            pred = selector(pred);
            this.forEach(function (val, index, stop) {
                if (pred ? pred(val) : val) {
                    result = true;
                    stop();
                }
            });
            return result;
        },
        first: function () {
            var result;
            this.forEach(function (val, index, stop) {
                result = val;
                stop();
            });
            return result;
        },
        groupBy: function (grouper) {
            var source = this;
            grouper = selector(grouper);
            return new Generator(function (Yield, yieldMany) {
                var groups = [],
                    group_contents = [];

                source.forEach(function (val) {
                    var group = grouper(val);
                    var i = arrIndexOf(groups, group);
                    if (i === -1) {
                        groups.push(group);
                        group_contents.push([val]);
                    } else {
                        group_contents[i].push(val);
                    }
                });

                yieldMany(new Generator(groups).zipWithArray(group_contents, function (group, contents) {
                    var result = new Generator(contents);
                    result.key = group;
                    return result;
                }));
            });
        },
        evaluated: function () {
            return new Generator(this.toArray());
        },
        except: function (what) {
            return this.filter(function (x) { return x !== what; });
        },
        sortBy: function (keyFunc) {
            var source = this;
            keyFunc = selector(keyFunc);
            return new Generator(function (Yield) {
                var arr = source.toArray(),
                    indexes = Range(0, arr.length).toArray();

                indexes.sort(function (a, b) {
                    var ka = keyFunc(arr[a]),
                        kb = keyFunc(arr[b]);
                    if (typeof ka === typeof kb) {
                        if (ka === kb)
                            return a < b ? -1 : 1;
                        if (ka < kb)
                            return -1;
                        if (ka > kb)
                            return 1;
                    }
                    throw new TypeError("cannot compare " + ka + " and " + kb);
                });
                new Generator(indexes).forEach(function (index) {
                    Yield(arr[index]);
                });
            });
        },
        count: function () {
            var result = 0;
            this.forEach(function () { result++; });
            return result;
        }
    }

    var Count = function (start, step) {
        var i = start;
        if (typeof step === "undefined")
            step = 1;
        return new Generator(function (Yield) {
            while (true) {
                Yield(i);
                i += step;
            }
        });
    }

    var Range = function (start, len) {
        return Count(start, 1).take(len);
    }

    window.Generator = Generator;
    Generator.BreakIteration = BreakIteration;
    Generator.Count = Count;
    Generator.Range = Range;
    Generator.IterationError = IterationError;

})();

