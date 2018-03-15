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

function /*class*/ Phylo5CanvasRenderer(width, height, parentElement){
   this.canvas=document.createElement("canvas");
   parentElement.appendChild(this.canvas);

   this.canvas.width=width;
   this.canvas.height=height;
   this.ctx=this.canvas.getContext('2d');
   this.ctx.translate(0.5,0.5); //offset to get sharp lines.
}

Phylo5CanvasRenderer.prototype.drawLine=function(path,strokeStyle){
    this.ctx.strokeStyle=strokeStyle;
    this.ctx.beginPath();
    this.ctx.moveTo(Math.round(path[0][0]), path[0][1]);
    
    for(var i=1;i<path.length;i++){
        this.ctx.lineTo(Math.round(path[i][0]),Math.round(path[i][1]));
    }
    
    this.ctx.stroke();
};

Phylo5CanvasRenderer.prototype.drawText=function(text, tx, ty, x, y, rotation, textAlign){
    this.ctx.save();
    this.ctx.translate(tx,ty);
    
    this.ctx.rotate(rotation);
    this.ctx.textAlign=textAlign;
    this.ctx.fillText(text, x,y);
    
    this.ctx.restore();
};

Phylo5CanvasRenderer.prototype.startGroup=function(groupName){
    
};

Phylo5CanvasRenderer.prototype.endGroup=function(){
    
};