/* 2017-3-29 http://stackoverflow.com/questions/35203019/how-can-i-send-an-ajax-request-on-button-click-from-a-form-with-2-buttons */
$(document).ready(function(){
    console.log("Document READY");
  $('button').click(function(e) {
    console.log("HERE I AM");
    e.preventDefault();
//    console.log("WICKED " + $(this).attr('name'));
//    $.ajax({
//      type: 'POST',
//      url: '/post/yes',// + $(this).attr('name'),
//      data: { 
//        id: $(this).val(),
//        access_token: $("#access_token").val() 
//      },
//      success: function(result) {
//        console.log('Okay ' + result);
//      },
//      error: function(result) {
//        console.log('ERROR ' + result);
//      }
//    });
  });
});
