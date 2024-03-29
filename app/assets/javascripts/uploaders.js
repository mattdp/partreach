$(document).ready(function() {

  $(".s3-uploader").S3Uploader();
  $('.s3-uploader').bind('s3_upload_complete', function(e, content) {
        if ( $('#uploaded-file-placeholder').length ) {
          $('#uploaded-file-placeholder').remove();
        }
        $('#order_uploads').append(
          '<input type="hidden" name="order_uploads[][url]" value="' + content.url + '"> \
           <input type="hidden" name="order_uploads[][original_filename]" value="' + content.filename + '">');
        $('#files_uploaded').val("true")
        $('#uploaded_file_list').append('<li><a href="' + content.url + '" target="_blank">' + content.filename + '</a></li>');
  });


  $('.s3-provider-photo-upload').S3Uploader();
  $('.s3-provider-photo-upload').bind('s3_upload_complete', function(e, content) {
    $.ajax({
      url : "/provider/upload_photo",
      type: "POST",
      data: {
        'provider_id': $('#id_for_upload')[0].value,
        'filepath': content.filepath,
        'filename': content.filename
      },
      success: function(response, textStatus, jqXHR)
      {
        if ( $('#profile_photo_gallery').length) {
          if ($('#profile_photo_gallery')[0].childElementCount == 0) {
            li = '<li>'
          } else {
            li = '<li class="col-lg-3 col-md-4 col-sm-3 col-xs-4">'
          }
          $('#profile_photo_gallery').append(li + '<img src="' + response + '"</li>');
        }
      },
      error: function (jqXHR, textStatus, errorThrown)
      {
        alert("An error occurred during upload (" + jqXHR.status + ")")
      }
    });
  });


  $('.s3-comment-photo-upload').S3Uploader();
  $('.s3-comment-photo-upload').bind('s3_upload_complete', function(e, content) {
    $.ajax({
      url : "/comment/upload_photo",
      type: "POST",
      data: {
        'filepath': content.filepath,
        'filename': content.filename
      },
      dataType: 'json',
      success: function(response, textStatus, jqXHR)
      {
        $('#comment_uploads').append(
          '<input type="hidden" name="comment_uploads[][filepath]" value="' + content.filepath + '"> \
           <input type="hidden" name="comment_uploads[][filename]" value="' + content.filename + '">');

        if ( $('#comment_photo_gallery').length) {
          if ($('#comment_photo_gallery')[0].childElementCount == 0) {
            li = '<li>'
          } else {
            li = '<li class="col-lg-3 col-md-4 col-sm-3 col-xs-4">'
          }
          $('#comment_photo_gallery').append(li + '<img src="' + response.expiring_image_url + '"</li>');
        }
      },
      error: function (jqXHR, textStatus, errorThrown)
      {
        alert("An error occurred during upload (" + jqXHR.status + ")")
      }
    });
  });

});
