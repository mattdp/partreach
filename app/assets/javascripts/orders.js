

$(document).ready(function() {
  $('.generate-email-button').click(function() {
    event.preventDefault();
    var html = $(this).attr('data-html');
    $(this).closest('div').children('textarea').val(html);
  });

  $('.all-generate-email-button').click(function () {
    $('.generate-email-button').trigger('click');
  });
});

// $(function() {
//   var $directUpload = $('#direct-upload');
//   $directUpload.fileupload({
//     url: $directUpload.attr('action'),
//     type: 'POST',
//     autoUpload: true,
//     dataType: 'xml', // This is really important as s3 gives us back the url of the file in a XML document
//     add: function (event, data) {
//       $.ajax({
//         url: "/signed_urls",
//         type: 'GET',
//         dataType: 'json',
//         data: {doc: {title: data.files[0].name}}, // send the file name to the server so it can generate the key param
//         async: false,
//         success: function(data) {
//           // Now that we have our data, we update the form so it contains all
//           // the needed data to sign the request
//           $directUpload.find('input[name=key]').val(data.key)
//           $directUpload.find('input[name=policy]').val(data.policy)
//           $directUpload.find('input[name=signature]').val(data.signature)
//         }
//       });
//       data.submit();
//     },
//     send: function(e, data) {
//       $('.progress').fadeIn();
//     },
//     progress: function(e, data){
//       // This is what makes everything really cool, thanks to that callback
//       // you can now update the progress bar based on the upload progress
//       var percent = Math.round((e.loaded / e.total) * 100);
//       $('.bar').css('width', percent + '%');
//     },
//     fail: function(e, data) {
//       $('#direct-upload-failure').show();
//       $('#direct-upload-success').hide();
//     },
//     success: function(data) {
//       $('#direct-upload-failure').hide();
//       $('#direct-upload-success').show();
//       // Here we get the file url on s3 in an xml doc
//       var url = $(data).find('Location').text();
//       $('#direct-upload-file').val(url); // Update the real input in the other form
//     },
//     done: function (event, data) {
//       $('.progress').fadeOut(300, function() {
//         $('.bar').css('width', 0);
//       });
//     },
//   });
  
//   $('#new-order').on('ajax:before', function() {
//     // direct-upload-file
//     if ($('#direct-upload-file').val().length === 0) {
//       $('#new-order-errors').show()
//                             .find('i').text(1).end()
//                             .find('ul').html('<li>Please upload a file</li>');
//       $('body').scrollTop(0);
//       console.log('file not uploaded');
//       return false;
//     }

//   });
//   $('#new-order').on('ajax:success', function(event, xhr, status) {
//     window.location = '/orders';
//     console.log('success', xhr.responseText, status);
//   });
//   $('#new-order').on('ajax:error', function(event, xhr, status) {
//     var errors = $.parseJSON(xhr.responseText);
//     $('#new-order-errors').show()
//                           .find('i').text(errors.length).end()
//                           .find('ul').html('<li>' + errors.join('</li><li>') + '</li>');
//     $('body').scrollTop(0);
//     console.log('error', xhr.responseText, status);
//   });
// });
