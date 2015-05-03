$(document).ready(function() {
  // use chosen jquery plugin
  $('.tag-select').chosen(
    {
      placeholder_text_multiple: 'Filter by tags'
    });

  $('.tag-edit').chosen(
    {
      placeholder_text_multiple: 'Click to select tags to add'
    });

  $('.provider-select').chosen(
    {
      placeholder_text_multiple: 'Filter by provider name'
    });
});
