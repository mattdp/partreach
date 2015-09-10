$(document).ready(function() {
  // use chosen jquery plugin
  $('.provider-search-terms-select').chosen(
    {
      placeholder_text_multiple: 'Search for Keywords and Suppliers'
    });
  $('.tag-edit').chosen(
    {
      placeholder_text_multiple: 'Click to select tags to add'
    });
});
