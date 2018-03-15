/**
 * Authors Dr David R. Damerell (david.damerell@sgc.ox.ac.uk) (University of Oxford)
 *         Paul Barrett (paul.barrett@sgc.ox.ac.uk) (University of Oxford)
 *         Xi Ting (Seacy) Zhen (University of Toronto) (original PHP version)
 *         
 * Group Leaders: 
 *         Dr Brian Marsden (brian.marsden@sgc.ox.ac.uk) (University of Oxford)
 *         Dr Matthieu Schapira (matthieu.schapira@utoronto.ca) (University of Toronto)
 *         
 */

function /*class*/ Phylo5SVGRenderer(width, height, parentElement){
   
   this.phylopaper = Raphael(parentElement.id, 900, 900);
      
   //other setup options
   //add drag/zoom support
   var zpd = new RaphaelZPD(this.phylopaper, { zoom: true, pan: true, drag: false });
   
   $('#zoom-controls').prependTo('#' + parentElement.id);
   //var evt = document.createEvent("DOMMouseScroll");
   
		$('#zoomin').click(function(evt) {

			var yevt = document.createEvent("MouseEvents");
			var mouseEventString = "DOMMouseScroll"

			if (navigator.userAgent.toLowerCase().indexOf('webkit') >= 0 || navigator.userAgent.toLowerCase().indexOf('msie') >= 0) {
				mouseEventString = "mousewheel";
			}
			else if (navigator.userAgent.toLowerCase().indexOf('opera') >= 0) {
				mouseEventString = "onmousewheel";
			}
			yevt.initMouseEvent(
			   mouseEventString, // in DOMString typeArg,
			   true,  // in boolean canBubbleArg,
			   true,  // in boolean cancelableArg,
			   window,// in views::AbstractView viewArg,
			   -3,   // in long detailArg - THIS DETERMINES UP
			   0,     // in long screenXArg,
			   0,     // in long screenYArg,
			   0,     // in long clientXArg,
			   0,     // in long clientYArg,
			   0,     // in boolean ctrlKeyArg,
			   0,     // in boolean altKeyArg,
			   0,     // in boolean shiftKeyArg,
			   0,     // in boolean metaKeyArg,
			   0,     // in unsigned short buttonArg,
			   null   // in EventTarget relatedTargetArg
			);
			zpd.root.dispatchEvent(yevt);
		});
		
		$('#zoomout').click(function(evt) {
		
			var yevt = document.createEvent("MouseEvents");
			var mouseEventString = "DOMMouseScroll"

			if (navigator.userAgent.toLowerCase().indexOf('webkit') >= 0 || navigator.userAgent.toLowerCase().indexOf('msie') >= 0) {
				mouseEventString = "mousewheel";
			}
			else if (navigator.userAgent.toLowerCase().indexOf('opera') >= 0) {
				mouseEventString = "onmousewheel";
			}
			yevt.initMouseEvent(
			   mouseEventString, // in DOMString typeArg,
			   true,  // in boolean canBubbleArg,
			   true,  // in boolean cancelableArg,
			   window,// in views::AbstractView viewArg,
			   3,   // in long detailArg - THIS DETERMINES UP
			   0,     // in long screenXArg,
			   0,     // in long screenYArg,
			   0,     // in long clientXArg,
			   0,     // in long clientYArg,
			   0,     // in boolean ctrlKeyArg,
			   0,     // in boolean altKeyArg,
			   0,     // in boolean shiftKeyArg,
			   0,     // in boolean metaKeyArg,
			   0,     // in unsigned short buttonArg,
			   null   // in EventTarget relatedTargetArg
			);
			zpd.root.dispatchEvent(yevt);
		});
   
}

Phylo5SVGRenderer.prototype.drawLine=function(path,strokeStyle){
    
	var pathstring = "M" + Math.round(path[0][0]) + " " + Math.round(path[0][1]);
	
	for(var i=1;i<path.length;i++){
	  pathstring = pathstring + "L" + Math.round(path[i][0]) + " " + Math.round(path[i][1]);
	}
	
	var c = this.phylopaper.path(pathstring)
	                       .attr({"stroke-width": 3, stroke: "#7e96c5", "stroke-linejoin": "round"});
						   //.node.setAttribute("data-stroke", strokeStyle);
	
						   
	

};

Phylo5SVGRenderer.prototype.drawText=function(text, tx, ty, x, y, rotation, textAlign){
    
	var txt = this.phylopaper.text(tx,ty,text);
	var angle=Phylo5Math.radiansToDegrees(rotation);
	txt.transform("r" + angle + "t" + x)
	   .attr({'text-anchor': textAlign})
	   .node.setAttribute("id", text);
	txt.node.setAttribute("data-target-name", text);
	txt.node.setAttribute("class", "familyHere");
	var tbx = txt.getBBox();
	var textbox = this.phylopaper.rect(tbx.x, tbx.y, tbx.width, tbx.height, 5).hide();
	//attach mouse events to animate and show icm controls
	txt.mouseover(function() {
	  txt.animate({ fill:'#f93' },100);
	}).mouseout(function() {
	  txt.animate({ fill:'#000' },200);
	}).click(function(evt){
	  toggleIcmBox(text, evt.pageX, evt.pageY);
	});
	
	
};

function toggleIcmBox(targetName, xcoord, ycoord) {
  //alert("I'm listening");
  var targetId = targetName + '_menu';
  if ($("#" + targetId).is(":visible")) {
    $('#' + targetId).hide('fast');  
  }
  else {
    $('#' + targetId).css("position","absolute").css("top",ycoord).css("left",xcoord);
    $('#' + targetId).show('fast');
  }
  
}