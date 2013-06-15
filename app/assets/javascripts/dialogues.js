$(document).ready(function() {

	//select all suppliers
	$('#all-suppliers').click(function() {
		$('.supplier-checkbox').attr("checked","true")
	});

	//allow multitag searching
	$('#tag_matrix').find('input').change(function() {
		if($('#add-dialogues-radio').is(':checked')) {
			$('#supplier_matrix').find('td').addClass('hidden');

			//get a list of all checked boxes
			var checkedBoxes = [];
			$('#tag_matrix').find('input').each (function () {
				if($(this).is(':checked')) {
					checkedBoxes.push($(this).closest('td').find('p').text());
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

});