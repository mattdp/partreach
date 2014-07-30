$(document).ready(function() {

  //select all visible suppliers
  $('#all-suppliers').click(function() {
    $("td:not(.hidden)").find(".supplier-checkbox").attr("checked","true")
  });

  //allow multitag searching
  $(document).find('.tag_matrix').find('input').change(function() {
    if($('#add-dialogues-radio').is(':checked')) {
      $('#supplier_matrix').find('td').addClass('hidden');

      //get a list of all checked boxes
      var checkedBoxes = [];
      $('.tag_matrix').find('input').each (function () {
        if($(this).is(':checked')) {
          checkedBoxes.push($(this).attr('id'));
        }
      });

      var activeCheckbox = true;
      var unhide = true;
      var i = 0;

      //reveal all that have each criterion
      $('#supplier_matrix').find('input').each (function () {
        activeCheckbox = $(this);
        unhide = true;
        for (i = 0; i < checkedBoxes.length; i = i + 1) {
          if (!activeCheckbox.hasClass(checkedBoxes[i])) {
            unhide = false;
          }
        }
        if (unhide) {
          activeCheckbox.closest('td').removeClass('hidden');
        }
      });
    }
  });

  // get rfq close email template
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