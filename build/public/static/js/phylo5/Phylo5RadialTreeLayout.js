/**
 * Phylo5RadialTreeLayout
 * 
 * Authors Dr David R. Damerell (david.damerell@sgc.ox.ac.uk) (University of Oxford)
 *         Paul Barrett (paul.barrett@sgc.ox.ac.uk) (University of Oxford)
 *         Xi Ting (Seacy) Zhen (University of Toronto) (original PHP version)
 *         
 * Group Leaders: 
 *         Dr Brian Marsden (brian.marsden@sgc.ox.ac.uk) (University of Oxford)
 *         Dr Matthieu Schapira (matthieu.schapira@utoronto.ca) (University of Toronto)
 * 
 * Phylo5RadialTreeLayout is able to layout a phylogenetic tree in radial format.
 * 
 * var radialEngine=new Phylo5RadialTreeLayout(400,400);
 * var canvas5Renderer=new Phylo5CanvasRenderer(400, 400, document.body);
 * 
 * radialEngine.render(rootNode, [], canvas5Renderer);
 */

function /*class*/ Phylo5RadialTreeLayout(width, height){
    this.cx=width/2;
    this.cy=height/2;
};

Phylo5RadialTreeLayout.prototype.render=function(treeNode, treeNodeToPosition, renderer){
    for(var i=0;i<treeNode.children.length;i++){
        var childNode=treeNode.children[i];
        
        var x1=this.cx+treeNode.x;
        var y1=this.cy+treeNode.y;
        
        var x2=this.cx+childNode.x;
        var y2=this.cy+childNode.y;
        
        var xDiff=x2-x1;
        var yDiff=y2-y1;
       
        renderer.drawLine([[x1,y1],[x2,y2]], "rgb(0,0,255)");
        
        var angle=Phylo5Math.radiansToDegrees(childNode.angle+childNode.wedge/2) * -1;
        
        if(childNode.isLeaf()===true){            
            var va=angle;
            
            if(treeNode.parent!==null){
                va=Phylo5Math.radiansToDegrees(treeNode.angle+treeNode.wedge/2)*-1;
            }
            
            if(va<-90 && va > -270){                
                renderer.drawText(childNode.name, x2, y2, -2, 3, Phylo5Math.degreesToRadians(Phylo5Math.radiansToDegrees(Math.atan2(yDiff, xDiff))+180), "end");
            }else{
                renderer.drawText(childNode.name, x2, y2, 2, 3, Math.atan2(yDiff, xDiff), "start");
            }
			//this.renderIcmBox(childNode.name);
        }else{
            //renderer.startGroup('GROUP_');
            this.render(childNode, treeNodeToPosition, renderer);
            //renderer.endGroup();
        }
    }
};

Phylo5RadialTreeLayout.prototype.renderIcmBox=function(targetName) {
  //do stuff here
  $('#drawhere').append('<div id="' + targetName + '_menu" class="details" style="display:none;"><div><p class="title">' + targetName + '</p><p class="close" id="' + targetName + '_close">x</p></div></div>');
  $("#"+targetName+"_close").click(function() {
		$("#"+targetName+"_menu").hide('fast');
	});
}