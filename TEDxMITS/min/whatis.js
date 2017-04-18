//$(document).ready(function(){
//    var state = 1;
//    document.getElementById('whatis-ted').style.display = 'inline';
//    document.getElementById('whatis-tedx').style.display = 'none';
//    document.getElementById('whatis-faq').style.display = 'none';
//    $("#slide_btn").click(function(){
//        if(state === 1){
//            document.getElementById('whatis-ted').style.display = 'none';
//            document.getElementById('whatis-tedx').style.display = 'inline';
//            state = state + 1;
//        }else if(state === 2){
//            document.getElementById('whatis-faq').style.display = 'inline';
//            document.getElementById('whatis-tedx').style.display = 'none';
//        }
//    });
//});
var storedcontent = {};
var state = 0;
$(document).ready(function() {
  var ripple_wrap = $('.ripple-wrap'),
      rippler = $('.ripple'),
      finish = false,
      monitor = function(el) {
        var computed = window.getComputedStyle(el, null),
            borderwidth = parseFloat(computed.getPropertyValue('border-left-width'));
        if (!finish && borderwidth >= 1500) {
          el.style.WebkitAnimationPlayState = "paused";
          el.style.animationPlayState = "paused";
          swapContent();
        }
        if (finish) {
          el.style.WebkitAnimationPlayState = "running";
          el.style.animationPlayState = "running";
          return;
        } else {
          window.requestAnimationFrame(function() {monitor(el)});
        }
      };

  storedcontent[0] = $('#whatis-tedx').html();
  $('#whatis-tedx').remove();
  storedcontent[1] = $('#whatis-faq').html();
  $('#whatis-faq').remove();

  rippler.bind("webkitAnimationEnd oAnimationEnd msAnimationEnd mozAnimationEnd animationend", function(e){
    ripple_wrap.removeClass('goripple');
  });

  $('#slide_btn').on('click', function(e) {
    rippler.css('left', e.clientX + 'px');
    rippler.css('top', e.clientY + 'px');
    e.preventDefault();
    finish = false;
    ripple_wrap.addClass('goripple');
    window.requestAnimationFrame(function() {monitor(rippler[0])});
  });



  function swapContent() {
      var newcontent = $('#whatis').html();
      $('#whatis').html(storedcontent[state]);
      storedcontent[state] = newcontent;
      // do some Ajax, put it in the DOM and then set this to true
      setTimeout(function() {
        finish = true;
      },10);
      state = state + 1;
      $('.collapsible').collapsible();
      if(state === 2){
        $('#slide_btn').hide();   
      }
  }

});

