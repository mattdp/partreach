$(document).ready(function() {
  $('.generate-email-button').click(function() {
    event.preventDefault();
    var html = $(this).attr('data-html');
    $(this).closest('div').children('textarea').val(html);
  });

  $('.all-generate-email-button').click(function () {
    $('.generate-email-button').trigger('click');
  });

  $("#s3-uploader").S3Uploader();

  var orderGroupId;

  $('#s3-uploader').bind('s3_uploads_start', function() {
		$.ajax({
	    url : "/order_groups/create_default",
	    type: "POST",
	    success: function(data, textStatus, jqXHR)
	    {
	    	orderGroupId = data;
	    	$('#order_group_id').val(orderGroupId)
	    },
	    error: function (jqXHR, textStatus, errorThrown)
	    {
	 			// "s3_uploads_start says: so sad..."
	    }
		});
  });

  $('#s3-uploader').bind('s3_upload_complete', function(e, content) {
		$.ajax({
	    url : "/parts/create_with_external",
	    type: "POST",
			data: { 'order_group_id': orderGroupId, 'url': content.url, 'filename': content.filename },
	    success: function(data, textStatus, jqXHR)
	    {
	    	//
	    },
	    error: function (jqXHR, textStatus, errorThrown)
	    {
	 			//"s3_upload_complete says: so sad..."
	    }
		});
  });

  //all uploads, not just one. I keep missing the 's' without this comment
  $('#s3-uploader').bind('s3_uploads_complete', function(e, content) {
  	alert( "Uploading complete. Feel free to choose more files if necessary." );
  });

  // run client-side validations (using jquery.validate)
  $("#new-order").validate({
        rules: {
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
            "user_email": "Please enter email and password",
            "user_password": "Please enter email and password",
            "signin_email": "Please enter email and password",
            "signin_password": "Please enter email and password",
        },        
        errorClass: "signup_signin_errors"
    });

});
