$(document).ready(function() {
  $('.sign_in_toggle').click(function(){
    provide_info_div = $('.order_provide_info')
    sign_in_div = $('.order_sign_in')
    if (provide_info_div.is(":visible")){
      provide_info_div.addClass('hidden')
      sign_in_div.removeClass('hidden')
    }else{
      provide_info_div.removeClass('hidden')
      sign_in_div.addClass('hidden')
    }
  })

  $('.generate-email-button').click(function(event) {
    event.preventDefault();
    var html = $(this).attr('data-html');
    $(this).closest('div').children('textarea').val(html);
  });

  $('.all-generate-email-button').click(function () {
    $('.generate-email-button').trigger('click');
  });

  $(".s3-uploader").S3Uploader();

  $('.s3-uploader').bind('s3_upload_complete', function(e, content) {
        if ( $('.uploaded-file-placeholder').length ) {
          $('.uploaded-file-placeholder').remove();
        }
        $('#uploads').append(
          '<input type="hidden" name="uploads[][url]" value="' + content.url + '"> \
           <input type="hidden" name="uploads[][original_filename]" value="' + content.filename + '">');
        $('#files_uploaded').val("true")
        $('#uploaded_file_list').append('<li>' + content.filename + '</li>');
  });

  $('.s3-uploader-page-refresh').bind('s3_uploads_complete', function(e, content) {
    alert("All Uploads completed")
    window.location.reload(true);
  });

  $('#parts_list_checkbox').click(function () {
    if ($(this).is(':checked')) {
      $('#parts_list_uploaded')[0].value = true;
      $('#parts-input').hide();
    } else {
      $('#parts_list_uploaded')[0].value = false;
      $('#parts-input').show();
    }
  });

  // run client-side validations (using jquery.validate)
  $("#new-order").validate({
    ignore: [],
    rules: {
      files_uploaded: "required",
      "order[units]": "required",
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
      "order[units]": "Please enter units (mm., in., etc.)",
      "user_email": "Please enter email and password",
      "user_password": "Please enter email and password",
      "signin_email": "Please enter email and password",
      "signin_password": "Please enter email and password",
    },
    errorClass: "signup_signin_errors"
  });

  $('.questions__columns input').change(function() {
    $(this).parents('td').find('label').removeClass('checked');
    $(this).closest('label').toggleClass('checked', $(this).is(':checked'));
  });

  $('#questions_experience_experienced').click(function () {
    if ($(this).is(':checked')) {
      $('#order_stated_experience')[0].value = $('#questions_experience_experienced')[0].value;
    }
  });

  $('#questions_experience_rookie').click(function () {
    if ($(this).is(':checked')) {
      $('#order_stated_experience')[0].value = $('#questions_experience_rookie')[0].value;
    }
  });

  $('#questions_priority_speed').click(function () {
    if ($(this).is(':checked')) {
      $('#order_stated_priority')[0].value = $('#questions_priority_speed')[0].value;
    }
  });


  $('#questions_priority_quality').click(function () {
    if ($(this).is(':checked')) {
      $('#order_stated_priority')[0].value = $('#questions_priority_quality')[0].value;
    }
  });


  $('#questions_priority_cost').click(function () {
    if ($(this).is(':checked')) {
      $('#order_stated_priority')[0].value = $('#questions_priority_cost')[0].value;
    }
  });

  $('#questions_manufacturing_printing').click(function () {
    if ($(this).is(':checked')) {
      $('#order_stated_manufacturing')[0].value = $('#questions_manufacturing_printing')[0].value;
    }
  });

  $('#questions_manufacturing_other').click(function () {
    if ($(this).is(':checked')) {
      $('#order_stated_manufacturing')[0].value = $('#questions_manufacturing_other')[0].value;
    }
  });

  $('#questions_manufacturing_unknown').click(function () {
    if ($(this).is(':checked')) {
      $('#order_stated_manufacturing')[0].value = $('#questions_manufacturing_unknown')[0].value;
    }
  });

});
