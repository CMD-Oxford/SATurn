$(function () {
	var iv = new iview('iview');
	var code = location.search.substr(1);
	if (!code.length) code = '3KFN';
	var loadPDB = function (code) {
		$.get('http://www.pdb.org/pdb/files/' + code + '.pdb', function (src) {
			iv.loadPDB(src);
		});
	};
	loadPDB(code);
	$('#loadPDB').change(function () {
		loadPDB($(this).val());
	});
	$('#OK').click(function () {
		loadPDB($('#loadPDB').val());
	});
	$('input[type="file"]').change(function() {
		var file = this.files[0];
		if (file === undefined) return;
		var reader = new FileReader();
		reader.onload = function () {
			iv.loadPDB(reader.result);
		};
		reader.readAsText(file);
	});

	['camera', 'background', 'colorBy', 'primaryStructure', 'secondaryStructure', 'surface', 'opacity', 'wireframe', 'ligands', 'waters', 'ions', 'labels', 'effect'].forEach(function (opt) {
		$('#' + opt).click(function (e) {
			var options = {};
			options[opt] = $(e.target).text().trim();
			iv.rebuildScene(options);
			iv.render();
		})
	});

	$('#exportCanvas').click(function (e) {
		e.preventDefault();
		iv.exportCanvas();
	});
});
