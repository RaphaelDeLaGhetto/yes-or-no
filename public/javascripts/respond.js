/* 2017-3-29 http://stackoverflow.com/questions/35203019/how-can-i-send-an-ajax-request-on-button-click-from-a-form-with-2-buttons */
$(document).ready(function(){
    console.log("Document READY");
  $('button').click(function(e) {
    e.preventDefault();
    console.log("WICKED " + $(this).attr('name'));
    $.ajax({
      type: 'POST',
      url: '/post/' + $(this).attr('name'),
      data: { 
        id: $(this).val(),
        authenticity_token: $('meta[name="csrf-token"]').attr('content') 
      },
      success: function(result) {
        console.log('Okay ');
        console.log(JSON.stringify(result));
      },
      error: function(result) {
        console.log('ERROR ');
        console.log(JSON.stringify(result));
      }
    });
  });
});
