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


  var myFavoriteVariable;

  $('#s3-uploader').bind('s3_uploads_start', function() {
		$.ajax({
		    url : "/order_groups/create_default",
		    type: "POST",
		    success: function(data, textStatus, jqXHR)
		    {
		    	myFavoriteVariable = data;
		      // alert( "order_group id returned: " + data );
		    },
		    error: function (jqXHR, textStatus, errorThrown)
		    {
		 			alert( "s3_uploads_start says: so sad..." );
		    }
		});
  });

  $('#s3-uploader').bind('s3_upload_complete', function(e, content) {
  	alert(myFavoriteVariable);
		$.ajax({
		    url : "/parts/create_with_external",
		    type: "POST",
				data: { 'order_group_id': myFavoriteVariable, 'url': content.url, 'filename': content.filename },
		    success: function(data, textStatus, jqXHR)
		    {
		      // alert( "returned from /parts/create_with_external " );
		    },
		    error: function (jqXHR, textStatus, errorThrown)
		    {
		 			alert( "s3_upload_complete says: so sad..." );
		    }
		});
  });

});
