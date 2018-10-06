$("input[componentid*='perc_protein_level'], .perc-protein-in-percentage").click(function(e) {		
		if ($(this).closest(".x-field").siblings('#perc_protein_option').hasClass('x-form-cb-checked')) {
		}
		else {
				$(this).closest(".x-field").siblings('#perc_protein_option').find('input').click();
		}
})