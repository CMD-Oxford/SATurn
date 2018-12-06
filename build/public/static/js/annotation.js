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


$("#essentiality_crispr_cancer_score, #essentiality_crispr_cancer_types").click(function(e) {		
		if ($(this).closest(".x-field").siblings('#essentiality_crispr').hasClass('x-form-cb-checked')) {
		}
		else {
				$(this).closest(".x-field").siblings('#essentiality_crispr').find('input').click();
		}
})

$("#essentiality_rnai_cancer_score, #essentiality_rnai_cancer_types").click(function(e) {		
		if ($(this).closest(".x-field").siblings('#essentiality_rnai').hasClass('x-form-cb-checked')) {
		}
		else {
				$(this).closest(".x-field").siblings('#essentiality_rnai').find('input').click();
		}
})