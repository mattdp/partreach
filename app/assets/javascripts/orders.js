$(document).ready(function() {
  $('.generate-email-button').click(function(event) {
    event.preventDefault();
    var html = $(this).attr('data-html');
    $(this).closest('div').children('textarea').val(html);
  });

  $('.all-generate-email-button').click(function () {
    $('.generate-email-button').trigger('click');
  });


  $("#s3-uploader").S3Uploader();

  $('#s3-uploader').bind('s3_upload_complete', function(e, content) {
    var orderGroupId = $('#order_group_id')[0].value;
    $.ajax({
      url : "/parts/create_with_external",
      type: "POST",
      data: { 'order_group_id': orderGroupId, 'filename': content.filename, 'url': content.url },
      success: function(data, textStatus, jqXHR)
      {
        $('#uploaded_file_list').append( "<li>" + content.filename + "</li>" );
        $('#files_uploaded').val("true")
      },
      error: function (jqXHR, textStatus, errorThrown)
      {
        alert("An error occurred during upload (" + jqXHR.status + ")")
      }
    });
  });


  // run client-side validations (using jquery.validate)
  $("#new-order").validate({
    ignore: [],
    rules: {
      files_uploaded: {
        required: true
      },
      stated_quantity: {
        required: true
      },
      units: {
        required: true
      },
      material_message: {
        required: true
      },
      user_email: {
        require_from_group: [2, ".signup-signin-group"]
      },
      user_password: {
        require_from_group: [2, ".signup-signin-group"]
      },
      signin_email: {
        require_from_group: [2, ".signup-signin-group"]
      },
      signin_password: {
        require_from_group: [2, ".signup-signin-group"]
      }
    },
    groups: {
      signup_signin: "user_email user_password signin_email signin_password"
    },
    messages: {
      "files_uploaded": "Please upload at least one file",
      "user_email": "Please enter email and password",
      "user_password": "Please enter email and password",
      "signin_email": "Please enter email and password",
      "signin_password": "Please enter email and password",
    },
    errorClass: "signup_signin_errors"
  });

});
