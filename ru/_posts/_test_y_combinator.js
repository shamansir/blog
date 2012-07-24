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