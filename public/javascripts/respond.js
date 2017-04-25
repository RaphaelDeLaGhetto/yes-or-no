/* 2017-3-29 http://stackoverflow.com/questions/35203019/how-can-i-send-an-ajax-request-on-button-click-from-a-form-with-2-buttons */
$(document).ready(function(){
  $('button').click(function(e) {
    e.preventDefault();
    var id = $(this).val();
    $.ajax({
      type: 'POST',
      url: '/post/' + $(this).attr('name'),
      data: { 
        id: id,
        authenticity_token: $('meta[name="csrf-token"]').attr('content') 
      },
      success: function(result) {
        $('#post-' + id + ' .star-ratings-top').width(JSON.parse(result).rating + '%');
        $('#post-' + id + ' button').prop('disabled', true);
        $('#post-' + id + ' button').hide();
        $('#post-' + id + ' .star-ratings').show();
      },
      error: function(jqXHR, textStatus, errorThrown) {
        if(jqXHR.status === 403) {
          $( location ).attr("href", '/login');
        } else {
          console.log(JSON.stringify(jqXHR));
          console.log(JSON.stringify(textStatus));
          console.log(JSON.stringify(errorThrown));
        }
      }
    });
  });

  $('.question-image').on('error', function(instance) {
    var parent = this;
    var parentId = $(this).parent().parent().parent().attr('id');
    $.ajax({
      type: 'POST',
      url: '/post/deapprove',
      data: { 
        id: parentId.replace('post-', ''),
        authenticity_token: $('meta[name="csrf-token"]').attr('content') 
      },
      success: function(result) {
        if(result.isOwner) {
          $('#'+parentId).
            html('<div class="alert alert-warning">The image at ' + result.url + ' could not be loaded</div>');
        } else {
          $('#'+parentId).hide();
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.log(JSON.stringify(jqXHR));
        console.log(JSON.stringify(textStatus));
        console.log(JSON.stringify(errorThrown));
      }
    });
  });
});
