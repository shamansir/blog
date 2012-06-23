// http://jsfiddle.net/shaman_sir/SFHuV/7/

function offset(elm) {
    var curleft = 0, 
        curtop = 0;
    do {
        curleft += elm.offsetLeft;
        curtop += elm.offsetTop;
    } while (elm && (elm = elm.offsetParent));
    return [ curleft, curtop ];    
}

function box(elm) {
    return [ elm.offsetWidth, elm.offsetHeight ];
}

function scrollEffect(f_type, e_anchor, f_appeared, f_visible, f_lost) {
    var appeared = false,
        f_check = f_type(e_anchor);
    window.addEventListener('scroll', function() {
        var pos; 
        if ((pos = f_check()) !== false) {
            if (!appeared) {
                appeared = true;
                if (f_appeared) f_appeared(e_anchor);
            }
            if (f_visible) f_visible(pos, e_anchor);
        } else if (appeared) {
            appeared = false;
            if (f_lost) f_lost(e_anchor); 
        }                               
    });
}
scrollEffect.VERT = function(e_anchor) {
    var win = window,
        anchorTop = offset(e_anchor)[1],
        anchorHeight = box(e_anchor)[1],
        winHeight = win.innerHeight, scrY;
    return function() {
        scrY = win.scrollY;
        return ((scrY + winHeight) > anchorTop) &&
               (scrY < (anchorTop + anchorHeight)) 
            ? (anchorTop - scrY) : false;
    }
}
scrollEffect.HORZ = function(e_anchor) {
    var win = window,
        anchorLeft = offset(e_anchor)[0],
        anchorWidth = box(e_anchor)[0],
        winWidth = win.innerWidth, scrX;
    return function() {
        scrX = win.scrollX;
        return ((scrX + winWidth) > anchorLeft) &&
               (scrX < (anchorLeft + anchorWidth))
            ? (anchorLeft - scrX) : false;
    }
}