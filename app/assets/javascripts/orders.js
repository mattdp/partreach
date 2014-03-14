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
  	alert(orderGroupId);
		$.ajax({
	    url : "/parts/create_with_external",
	    type: "POST",
			data: { 'order_group_id': orderGroupId, 'url': content.url, 'filename': content.filename },
	    success: function(data, textStatus, jqXHR)
	    {
	      // alert( "returned from /parts/create_with_external " );
	    },
	    error: function (jqXHR, textStatus, errorThrown)
	    {
	 			//"s3_upload_complete says: so sad..."
	    }
		});
  });

});
