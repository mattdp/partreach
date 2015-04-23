$(document).ready(function() {
  // use chosen jquery plugin
  $('.tag-select').chosen(
    {
      placeholder_text_multiple: 'Filter by tags'
    });

  $('.provider-select').chosen(
    {
      placeholder_text_multiple: 'Filter by provider name'
    });
});
