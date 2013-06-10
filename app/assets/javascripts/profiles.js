$(document).ready(function() {
	$('.description-toggle').on('click', function() {
		$('.supplier-variable-content').children().addClass('hidden');
		$('.description-content').removeClass('hidden');
		$('.options-menu').find('li').removeClass('active')
		$('.description-toggle').closest('li').addClass('active');
	});
	$('.machines-toggle').on('click', function() {
		$('.supplier-variable-content').children().addClass('hidden');
		$('.machines-content').removeClass('hidden');
		$('.options-menu').find('li').removeClass('active')
		$('.machines-toggle').closest('li').addClass('active');
	});
	$('.reviews-toggle').on('click', function() {
		$('.supplier-variable-content').children().addClass('hidden');
		$('.reviews-content').removeClass('hidden');
		$('.options-menu').find('li').removeClass('active')
		$('.reviews-toggle').closest('li').addClass('active');
	});
	$('.photos-toggle').on('click', function() {
		$('.supplier-variable-content').children().addClass('hidden');
		$('.photos-content').removeClass('hidden');
		$('.options-menu').find('li').removeClass('active')
		$('.photos-toggle').closest('li').addClass('active');
	});
});
