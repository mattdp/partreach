//this is currentlyfor tags-table

//need for all instances providers table 
//      sortList: [ [3,1], [2,1], [0,0] ],
//need for providers table without include_tag_column
//
//      sortList: [ [3,1], [2,1], [0,0] ],
//     widgets : ['columns', 'uitheme']

$(document).ready(function() {
  var $table = $('.tablesorter-active'),
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

  var sortList = [], 
      widgets = ['columns', 'uitheme', 'filter'];
  if ($table.is(".tags-list-table")) {
    sortList = [ [2,1], [0,0] ];
  }
  else if ($table.is(".providers-list-table")) {
    sortList = [ [3,1], [2,1], [0,0] ];
  }

  $table.tablesorter({
    theme: 'bootstrap',
    headerTemplate: '{content} {icon}',
    sortList: sortList,
    widgets : ['columns', 'uitheme', 'filter'] 
  });

});