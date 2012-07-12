var __s = Array.prototype.slice; 
function deferrable_as(ctx, f) {
  return function() {
    return (function(args) {
      return function(result, next) { return f.apply(ctx, args.concat([result, next])); };
    })(__s.call(arguments));
  }
}
function queue(/*f...*/) {
    var as = __s.call(arguments);
    console.log(as);
    if(!(as.slice(-1)[0] instanceof Function)){
        var prev_res = as.slice(-1)[0];
    }
    if(as.slice(1).length){
        var callback = function(res) {
            as.push(res);
            queue.apply(null, as.slice(1));
        }
    }
    as[0](prev_res, callback);
}

function _read_file(name, prev_readed, next){
    //console.log(arguments);
    setTimeout(function() {
        alert('readed '+name);
        if(prev_readed){
            name = prev_readed+'_'+name;
        }
        next(name);
    }, 1000);
}

function _notify_success(name, next){
    alert(name + ' was read');
    next('next_file');
}

var read_file = deferrable_as(null, _read_file);
var notify_success = deferrable_as(null, _notify_success);

queue(read_file('book_name_1'), read_file('book_name_2'), read_file('book_name_3'), notify_success());​








var __s = Array.prototype.slice; 
function deferrable_as(ctx, f) {
  return function() {
    return (function(args) {
      return function(result, next) { return f.apply(ctx, args.concat([next, result])); };
    })(__s.call(arguments));
  }
}
function queue(/*f...*/) {
    var as = __s.call(arguments),
        prev_res = as.slice(-1)[0];
    as[0](prev_res, function(res) {
        as.push(res);
        queue.apply(null, as.slice(1));
    });
}

function _read_file(name, next){
    setTimeout(function() {
      alert('reading '+name);
      next(name);
    }, 2000);
}

function _notify_success(name, next){
    alert(name + ' was read');
    next('next_file');
}

var read_file = deferrable_as(null, _read_file);
var notify_success = deferrable_as(null, _notify_success);

queue(read_file('book_name_1'), read_file('book_name_2'), read_file('book_name_3'), notify_success()); ​




// author is frvade

var __s = Array.prototype.slice; 
function deferrable_as(ctx, f) {
  return function() {
    return (function(args) {
      return function(result, next) { return f.apply(ctx, args.concat([next, result])); };
    })(__s.call(arguments));
  }
}
function queue(/*f...*/) {
    var as = __s.call(arguments),
        prev_res = as.slice(-1)[0];
    as[0](prev_res, function(res) {
        as.push(res);
        queue.apply(null, as.slice(1));
    });
}

function _read_file(name, next){
    setTimeout(function() {
      alert('reading '+name);
      next(name);
    }, 2000);
}

function _notify_success(name, next){
    alert(name + ' was read');
    next('next_file');
}

var read_file = deferrable_as(null, _read_file);
var notify_success = deferrable_as(null, _notify_success);

queue(read_file('book_name_1'), read_file('book_name_2'), read_file('book_name_3'), notify_success()); ​