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
	while(parentElement.firstChild){
		parentElement.removeChild(parentElement.firstChild);
	}
	
   this.phylopaper = Raphael(parentElement.id, width, height);
      
   this.zpd = new RaphaelZPD(this.phylopaper, { zoom: true, pan: true, drag: false });
   
   var self = this;
   
   parentElement.onmousedown=function(e) {
		clearTimeout(this.downTimer);
		this.zoomProcess = setInterval(
			function() {
				//Ext.suspendLayouts();
				if(e.shiftKey){
					self.zoomOut();
				}else if(e.ctrlKey){
					self.zoomIn();
				}
				
			}, 20);
	};
	
	parentElement.onmouseup=function(e) {
		clearInterval(this.zoomProcess);
		//Ext.resumeLayouts(true);
	};
}

Phylo5SVGRenderer.prototype.zoomOut = function(){
	var yevt = document.createEvent("MouseEvents");
	var mouseEventString = "DOMMouseScroll"

	if (navigator.userAgent.toLowerCase().indexOf('webkit') >= 0 || navigator.userAgent.toLowerCase().indexOf('msie') >= 0) {
		mouseEventString = "mousewheel";
	}else if (navigator.userAgent.toLowerCase().indexOf('opera') >= 0) {
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
	this.zpd.root.dispatchEvent(yevt);
};

Phylo5SVGRenderer.prototype.zoomIn = function(){
	var yevt = document.createEvent("MouseEvents");
	var mouseEventString = "DOMMouseScroll"

	if (navigator.userAgent.toLowerCase().indexOf('webkit') >= 0 || navigator.userAgent.toLowerCase().indexOf('msie') >= 0) {
		mouseEventString = "mousewheel";
	}else if (navigator.userAgent.toLowerCase().indexOf('opera') >= 0) {
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
	this.zpd.root.dispatchEvent(yevt);
};

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
	
	angle = Math.round(angle);
	
	x = Math.round(x);
	
	txt.transform("r" + angle + "t" + x)
	   .attr({'text-anchor': textAlign})
	   .node.setAttribute("id", text);
	txt.node.setAttribute("data-target-name", text);
	txt.node.setAttribute("class", "phylo5-tree");
	
	
	
	var tbx = txt.getBBox();
	var textbox = this.phylopaper.rect(tbx.x, tbx.y, tbx.width, tbx.height, 5).hide();
};

Phylo5SVGRenderer.prototype.startGroup=function(groupName){
    this.phylopaper.startGroup(groupName);
};

Phylo5SVGRenderer.prototype.endGroup=function(){
    this.phylopaper.endGroup();
};
