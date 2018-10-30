$("input[componentid^='protein_level'], .protein-cancer-type").click(function(e) {		
		if ($(this).closest(".x-field").siblings('#protein_option').hasClass('x-form-cb-checked')) {
		}
		else {
				$(this).closest(".x-field").siblings('#protein_option').find('input').click();
		}
})


$("input[componentid*='perc_protein_level'], .perc-protein-in-percentage, input[componentid*='perc_protein_reliability']").click(function(e) {		
		if ($(this).closest(".x-field").siblings('#perc_protein_option').hasClass('x-form-cb-checked')) {
		}
		else {
				$(this).closest(".x-field").siblings('#perc_protein_option').find('input').click();
		}
})