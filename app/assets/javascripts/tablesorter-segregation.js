$(document).ready(function() {
  var $table = $('table'),
      process = false;

  $('.process').click(function(){
    process = !process;
    $.tablesorter.isProcessing( $table, process );
  });

  $('.sortable').click(function(){
    $table
      .find('.tablesorter-header:last').toggleClass('sorter-false')
      .trigger('update');
  });

  $table.tablesorter({
    theme: 'bootstrap',
    headerTemplate: '{content} {icon}',
    sortList: [ [2,1], [0,0] ],
    widgets : ['columns', 'uitheme', 'filter'] // add 'filter' to get the search row back
  });
});