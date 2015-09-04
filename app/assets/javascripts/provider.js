$(document).ready(function() {
  // use chosen jquery plugin
  $('.provider-search-terms-select').chosen();
  $('.tag-edit').chosen(
    {
      placeholder_text_multiple: 'Click to select tags to add'
    });
});
