$(document).ready(function() {
  $placeholderForMainSearch = '';
  $select = $('.selectize');

  if ($select.is(".homepage-search")) {
    $placeholderForMainSearch = 'Search for Keywords and Suppliers';
  }
  
  $('.selectize').selectize({
    sortField: 'text',
    placeholder: $placeholderForMainSearch
  });
});
