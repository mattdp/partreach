$(document).ready(function() {
  $('#feedback-modal-submit').on('click', function(e,content) {
    $.ajax({
      url : "/provider/submit_feedback",
      type: "POST",
      data: {
        'organization_id': $("input#hidden-organization_id")[0].value,
        'user_id': $("input#hidden-user_id")[0].value,
        'tag_id': $("input#hidden-tag_id")[0].value,
        'feedback_content': $("textarea#feedback_content")[0].value,
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