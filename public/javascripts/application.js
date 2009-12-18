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
});
