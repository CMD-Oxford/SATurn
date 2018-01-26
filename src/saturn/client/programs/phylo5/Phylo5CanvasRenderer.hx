/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.phylo5;

class Phylo5CanvasRenderer implements Phylo5RendererI {

    var canvas : Dynamic;
    public var ctx : Dynamic;
    public var scale:Float=1.0;
    var parent: Dynamic;
    var rootNode:Dynamic;
    public var cx: Dynamic;
    public var cy: Dynamic;

    public function new (width:Int, height:Int, parentElement:Dynamic,rootNode:Dynamic){
       var doc:Dynamic;

       this.canvas=js.Browser.document.createElement("canvas");
       this.parent=parentElement;
       parentElement.appendChild(this.canvas);

       this.canvas.width=width;
       this.canvas.height=height;

       this.rootNode=rootNode;


       this.ctx=this.canvas.getContext('2d');
       this.ctx.translate(0.5,0.5); //offset to get sharp lines.


    }

    public function drawLine (x0:Float,y0:Float, x1:Float, y1:Float,strokeStyle:Dynamic){

       // this.ctx.scale(this.scale,this.scale);
        this.ctx.strokeStyle=strokeStyle;
        this.ctx.beginPath();
        this.ctx.moveTo(Math.round(x0), Math.round(y0));

        this.ctx.lineTo(Math.round(x1),Math.round(y1));

        this.ctx.stroke();

    }

    public function drawText (text:String , tx:Float, ty:Float, x:Float, y:Float, rotation: Float, textAlign:String, color: String):Void{

        this.ctx.save();
        this.ctx.translate(tx,ty);

        this.ctx.rotate(rotation);
        this.ctx.textAlign=textAlign;
        this.ctx.fillStyle = color;
        this.ctx.fillText(text, x,y);


        this.ctx.restore();

    }

    // drawShape will draw the shape indicated by sha.
    // sha = 1 square
    // sha = 2 circle
    // sha = ...
    // we can add the shapes we want, just by adding its function call
  /*  public function drawShape (sha:Int , tx:Float, ty:Float, rotation: Float):Void{

        //this.ctx.rotate(rotation);

        switch sha{
            case 1 : drawCircle(tx,ty);// break;
           // case 2 : drawSquare(path);
        }

    }*/
    public function drawSquare (tx:Float, ty:Float, color:String):Void{
        this.ctx.save();
        this.ctx.beginPath();
        this.ctx.rect(tx, ty, 10, 10);
        this.ctx.fillStyle = color;
        this.ctx.fill();
        this.ctx.restore();
    }
    public function drawCircle (tx:Float, ty:Float, color:String):Void{
        var radius = 5;
        this.ctx.save();
        this.ctx.beginPath();
        this.ctx.strokeStyle=color;
        this.ctx.arc(tx,ty,radius,0,2*Math.PI);

        this.ctx.fillStyle=color;
        this.ctx.fill();
        this.ctx.restore();

    }

    public function drawImg (tx:Float, ty:Float,img:String):Void{


        this.ctx.drawImage(img, tx, ty);

    }


    public function mesureText(text : String):Int{
         return this.ctx.measureText(text).width;
    }

    public function startGroup (groupName: String){

    }

    public function endGroup (){

    }


    public function zoomIn(annotations:Dynamic){
        //WorkspaceApplication.getApplication().debug("hello");

        this.scale=this.scale+0.2;

        var newWidth = this.canvas.width * this.scale;
        var newHeight = this.canvas.height * this.scale;

        this.ctx.save();
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        this.ctx.translate(this.cx,this.cy);
        this.ctx.scale(this.scale, this.scale);
        var radialRendererObj  : Dynamic = new Phylo5RadialTreeLayout(this.canvas.width, this.canvas.height);

        radialRendererObj.render(this.rootNode, this,annotations);

        this.ctx.restore();
    }

    public function zoomOut(annotations:Dynamic){

        if (this.scale>0.4){ // do we need a minimum scale?

            this.scale=this.scale-0.2;

            var newWidth = this.canvas.width * this.scale;
            var newHeight = this.canvas.height * this.scale;

            this.ctx.save();
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
            this.ctx.translate(this.cx,this.cy);
            this.ctx.scale(this.scale, this.scale);
            var radialRendererObj  : Dynamic = new Phylo5RadialTreeLayout(this.canvas.width, this.canvas.height);

            radialRendererObj.render(this.rootNode,this, annotations);

            this.ctx.restore();
        }
    }
}
