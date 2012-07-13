var socialElm = document.getElementById('nwao-social');
var toTopElm = document.getElementById('nwao-jump-to-top');
var titleElm = document.getElementById('nwao-title');
var topTargElm = document.getElementById('top');
var navElm = document.getElementById('nwao-nav');

var prevTop = navElm.style.top;
var prevPos = navElm.style.position;
var titleHeight = titleElm.offsetHeight;
var titleTop = titleElm.offsetTop;
var navHeight = navElm.offsetHeight;

if (false) {

scrollEffect(scrollEffect.VERT, titleElm,
                /* appeared */ null,
                /* visible */ function(pos) {
                    console.log(pos, (titleHeight + pos) - navHeight - titleTop); 
                    navElm.style.position = 'fixed'; navElm.style.top = Math.min(0, (titleHeight + pos) - navHeight - titleTop) + 'px'; },
                /* lost */ function() { navElm.style.position = prevPos; navElm.style.top = prevTop; });

} // if (false)

if (false) {

scrollEffect(scrollEffect.VERT, socialElm,
                /* appeared */ null,
                /* visible */ function(pos) {
                                 
                              },
                /* lost */ null);

}