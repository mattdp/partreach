$(document).ready(function() {

	var classList = 0;
	var summary = "";

	$('.question_radio_button').on('click', function(event) {
		summary = $(this).data("summary");
		classList = this.className.split(/\s+/);
		$.each(classList, function(index, item){
			if (item === 'experience') {
				$('.summary_experience').text(summary);
			}
			else if (item === 'priority') {
				$('.summary_priority').text(summary);
			}
			else if (item === 'manufacturing') {
				$('.summary_manufacturing').text(summary);
			}
		});
	});

	$('.chosen-select').chosen(
		{
			disable_search_threshold: 20
		});
});
