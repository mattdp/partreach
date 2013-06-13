$(document).ready(function() {

	$('#all-suppliers').click(function() {
		$('.supplier-checkbox').attr("checked","true")
	});
	
	$('#tag_matrix').find('input').change(function() {
		var tag_name = $(this).attr('id');
		if($('#add-dialogues-radio').is(':checked')) {
			$('#supplier_matrix').find('input').not('.'+tag_name).closest('td').toggleClass('hidden');
		}
	});

});