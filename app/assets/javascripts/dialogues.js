$(document).ready(function() {
  $('#email_type').change(function() {
    id = $('#id').val();
    email_type = $('#email_type option:selected').val();
    if (email_type != "select") {
      $.ajax({
        url : "/dialogues/generate_rfq_close_email",
        type: "GET",
        data: { 'id': id, 'email_type': email_type },
        success: function(response, textStatus, jqXHR)
        {
          $("#email_body").val(response);
        },
        error: function (jqXHR, textStatus, errorThrown)
        {
          alert("An error occurred: " + jqXHR.status + " (" + errorThrown + ")");
        }
      });
    }
  });
});


