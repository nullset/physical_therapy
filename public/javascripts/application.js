$(document).ready(function() {
  $('#content .content_text .box_container .box:even').css('padding-left', '1px');
  
  var physician_box = $('#content .content_text .box:first');
  var next_box = $('#content .content_text .box:eq(1)');
  if (next_box.height() > physician_box.height()) {
    physician_box.height(next_box.height());
  }
  
  $('#content .content_text .box_container').append('<div class="line"></div>');
  $('#content .content_text .box_container div.line').each(function() {
    var parent_height = $(this).parent().height();
    $(this).height(parent_height);
  });
  
  
  
  // doctor excerpt rotator
  var doctor_excerpts = $('#doctor_excerpt li'); // .sort(function() {return 0.5 - Math.random()});
  doctor_excerpts.css('display', 'none');
  doctor_excerpts.eq(Math.floor(Math.random() * doctor_excerpts.length)).show();
  
  doctor_excerpts_max_height = 0;
  doctor_excerpts.each(function(i) {
    $(this).css('left', '0');
    if ($(this).height() > doctor_excerpts_max_height) {
      doctor_excerpts_max_height = $(this).height();
    }
  });
  doctor_excerpts.parent().height(doctor_excerpts_max_height);
  rotate_doctors = true;
  doctor_excerpts.parent().bind("mouseenter", function(e) {
    rotate_doctors = false;
  });
  doctor_excerpts.parent().parent().parent().bind("mouseleave", function(e) {
    rotate_doctors = true;
  });

  function doctor_rotator() {
    if (rotate_doctors != false) {
      var current_doctor = $('#doctor_excerpt li:visible');
      current_doctor.fadeOut('slow');
      if (current_doctor.nextAll().length != 0) {
        next_doctor = current_doctor.next();
      } else {
        next_doctor = current_doctor.parent().children(":first");
      }
      next_doctor.fadeIn('slow');
      return false;
    }
  }
  
  setInterval(function() {
      doctor_rotator();
  }, 5000);
  
  
  $('.print').click(function() {
    window.print();
  });
});
