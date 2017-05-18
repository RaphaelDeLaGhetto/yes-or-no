/**
 * Deapprove image that no longer exists or attached to mangled URL
 * This is called on the `onError` event on `img` tags. The jQuery
 * `error` event only seems to get called once
 */
var deapprove = function(el) {
  var parent = el;
  var parentId = $(el).parent().parent().parent().attr('id');
  $.ajax({
    type: 'POST',
    url: '/post/deapprove',
    data: { 
      id: parentId.replace('post-', ''),
      authenticity_token: $('meta[name="csrf-token"]').attr('content') 
    },
    success: function(result) {
      if(result.isOwner) {
        var $warningBox = $('<div>', { 'class': 'alert alert-warning' });
        var $topLine = $('<div></div>', { text: 'This URL does not point to an image that can be loaded:' });
        var $brokenUrl = $('<a>', { 'class': 'broken', href: result.url, text: result.url });
        var $bottomLine = $('<div>', { text: 'Image files typically end with ' }).
                          append('<em>.jpg</em>, <em>.gif</em>, or <em>.png</em>. ').
                          append('In most browsers you can <em>right-click</em>').
                          append(' on an image and select <em>\'Copy image address\'</em>. ').
                          append('Use this <em>URL</em> to post a new image.');
        $warningBox.append($topLine).append($brokenUrl).append($bottomLine);
        $('#' + parentId + ' .image a').html($warningBox);
      } else {
        $('#' + parentId).hide();
      }
    },
    error: function(jqXHR, textStatus, errorThrown) {
      console.log(JSON.stringify(jqXHR));
      console.log(JSON.stringify(textStatus));
      console.log(JSON.stringify(errorThrown));
    }
  });
};

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
        result = JSON.parse(result);
        $('#post-' + id + ' .star-ratings-top').width(result.rating + '%');
        $('#post-' + id + ' .nos').text(result.nos);
        $('#post-' + id + ' .yeses').text(result.yeses);
        $('#post-' + id + ' .total-votes').text(result.yeses + result.nos);
        $('#post-' + id + ' .percent-rating').text(result.rating + '%');
        $('#post-' + id + ' button').prop('disabled', true);
        $('#post-' + id + ' button').hide();
        $('#post-' + id + ' .results').show();
        $('#post-' + id + ' .details').show();
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

  /**
   * Collapse on scroll
   */
  $(window).scroll(function() {
    if ($('#question').offset().top > 25) {
      $('#question').addClass('top-collapse');
      $('#points').addClass('top-collapse');
    } else {
      $('#question').removeClass('top-collapse');
      $('#points').removeClass('top-collapse');
    }
  });
});
