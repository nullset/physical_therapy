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
  
  
  
  // Physician rotator
  var doctor_excerpts = $('#doctor_excerpt li');
  doctor_excerpts.css('display', 'none');
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
      // var num = Math.floor(Math.random() * doctor_excerpts.length);
      var num = smart_randomizer(null, doctor_excerpts.length);
      var random_doctor = $('#doctor_excerpt li:eq('+ num +')');
      current_doctor.fadeOut('slow');
      // random_doctor.css('display', 'block');
      random_doctor.fadeIn('slow');
      // setTimeout('doctor_rotator', 1000);
    }
  }
  
  function smart_randomizer(current_number, max_number) {
    current_number = typeof(current_number) != 'undefined' ? current_number : Math.floor(Math.random() * max_number);
    var new_number = Math.floor(Math.random() * max_number);
    if (new_number == current_number) {
      smart_randomizer(current_number, max_number);
    } else {
      return new_number;
    }
  }
  
  doctor_rotator();
  setInterval(function() {
      doctor_rotator();
  }, 5000);
});
