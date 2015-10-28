$(document).ready(function() {
  $('#feedback-modalsubmit').on('click', function(e,content) {
    $.ajax({
      url : "/provider/submit_feedback",
      type: "POST",
      data: {
        'organization_id': "test text submission",
        'user_id': 1234567,
        'feedback_content': content.feedback_content,
      },
      success: function(response, textStatus, jqXHR)
      {
        alert("Success placeholder!")
      },
      error: function (jqXHR, textStatus, errorThrown)
      {
        alert("An error occurred during saving (" + jqXHR.status + ")")
      }
    });
  });
});