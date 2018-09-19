package saturn.client.programs.chromohub;


/**
 * Authors Dr David R. Damerell (david.damerell@sgc.ox.ac.uk) (University of Oxford)
 *         Sefa Garsot (sefa.garsot@sgc.ox.ac.uk) (University of Oxford)
 *         Paul Barrett (paul.barrett@sgc.ox.ac.uk) (University of Oxford)
 *         Xi Ting (Seacy) Zhen (University of Toronto) (original PHP version)
 *         
 * Group Leaders: 
 *         Dr Brian Marsden (brian.marsden@sgc.ox.ac.uk) (University of Oxford)
 *         Dr Matthieu Schapira (matthieu.schapira@utoronto.ca) (University of Toronto)
 *         
 */

class ChromoHubCanvasRenderer implements ChromoHubRendererI {

    var canvas : Dynamic;
    public var ctx : Dynamic;
    public var scale:Float=1.0;
    var parent: Dynamic;
    var rootNode:Dynamic;
    public var cx: Dynamic;
    public var cy: Dynamic;
    public var prog : ChromoHubViewer;


    public function new (program : ChromoHubViewer,width:Int, height:Int, parentElement:Dynamic,rootNode:Dynamic){
        this.prog = program;

       var doc:Dynamic;

       this.canvas=js.Browser.document.createElement("canvas");
       this.parent=parentElement;
       parentElement.appendChild(this.canvas);

       this.canvas.width=width;
       this.canvas.height=height;

       this.rootNode=rootNode;


       this.ctx=this.canvas.getContext('2d');
       cx=Math.round(width/2);
       cy=Math.round(height/2);
       this.ctx.translate(cx,cy); //offset to get sharp lines.


    }

    public function drawLine (x0:Float,y0:Float, x1:Float, y1:Float,strokeStyle:Dynamic, lineWidth : Float){

       // this.ctx.scale(this.scale,this.scale);
        this.ctx.strokeStyle=strokeStyle;
        this.ctx.beginPath();
        this.ctx.moveTo(Math.round(x0), Math.round(y0));

        this.ctx.lineTo(Math.round(x1),Math.round(y1));

        this.ctx.lineWidth = lineWidth;

        this.ctx.stroke();

    }

    public function drawArc (x : Float, y : Float, radius : Float, sAngle, eAngle, strokeStyle : String, lineWidth : Float){

        // this.ctx.scale(this.scale,this.scale);
        this.ctx.strokeStyle=strokeStyle;
        this.ctx.beginPath();
        this.ctx.arc(x,y,Math.abs(radius),sAngle,eAngle);

        this.ctx.lineWidth = lineWidth;

        this.ctx.stroke();

    }

    public function bezierCurve (x0:Float,y0:Float, x1:Float, y1:Float, firstX : Float, firstY : Float, secondX : Float, secondY : Float, strokeStyle:Dynamic, lineWidth: Float){


        //var grd = this.ctx.createLinearGradient(0,0,0,150);
        // light blue
        //grd.addColorStop(0, 'white');
        // dark blue
        //grd.addColorStop(1, strokeStyle);


        // this.ctx.scale(this.scale,this.scale);
        this.ctx.strokeStyle=strokeStyle;
        this.ctx.beginPath();
        this.ctx.moveTo(Math.round(x0), Math.round(y0));

        this.ctx.bezierCurveTo(Math.round(firstX),Math.round(firstY),Math.round(secondX),Math.round(secondY), Math.round(x1), Math.round(y1));
        this.ctx.lineWidth = lineWidth;
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

    public function drawTextNoTranslate (text:String , tx:Float, ty:Float, x:Float, y:Float, rotation: Float, textAlign:String, color: String):Void{

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

    public function drawGraphic (tx:Float, ty:Float, columns:Array<Int>):Void{
        this.ctx.save();
        this.ctx.beginPath();
        this.ctx.moveTo(Math.round(tx), Math.round(ty-10));
       // this.ctx.lineTo(Math.round(tx),Math.round(ty+6));//eix y
        this.ctx.moveTo(Math.round(tx), Math.round(ty+6));
        this.ctx.lineTo(Math.round(tx+14),Math.round(ty+6));//eix x
        this.ctx.strokeStyle="rgb(6,6,6)";
        this.ctx.stroke();
        //this.ctx.fill();
        var len=columns[1];
        var pos=ty+6-columns[1];
        this.ctx.fillStyle="rgb(41,128,214)";
        this.ctx.rect(tx+1, pos, 2, len);//inflamation
        var len2=columns[2];
        var pos2=ty+6-columns[2];
        this.ctx.fillStyle="rgb(191,0,0)";
        this.ctx.fillRect(tx+3, pos2, 2, len2);//cancer
        var len3=columns[3];
        var pos3=ty+6-columns[3];
        this.ctx.fillStyle="rgb(99,207,27)";
        this.ctx.fillRect(tx+5, pos3, 2, len3);//viral infecctions
        var len4=columns[4];
        var pos4=ty+6-columns[4];
        this.ctx.fillStyle="rgb(255,128,0)";
        this.ctx.fillRect(tx+7, pos4, 2, len4);//Neurological diseases
        var len5=columns[5];
        var pos5=ty+6-columns[5];
        this.ctx.fillStyle="rgb(192,86,145)";
        this.ctx.fillRect(tx+9, pos5, 2, len5);//Metabolic disoreder
        var len6=columns[6];
        var pos6=ty+6-columns[6];
        this.ctx.fillStyle="rgb(255,204,0)";
        this.ctx.fillRect(tx+11, pos6, 2, len6);//immune
        var len7=columns[7];
        var pos7=ty+6-columns[7];
        this.ctx.fillStyle="rgb(121,63,243)";
        this.ctx.fillRect(tx+13, pos7, 2, len7);//Neurological diseases

        this.ctx.restore();

    }

    public function drawImg (tx:Float, ty:Float,img:String, mode:Int):Void{

        if (mode==0) this.ctx.drawImage(img, tx, ty);
        else this.ctx.drawImage(img,28, 0, 125, 125, tx, ty, 20,20);
        // destX, destY, destWidth, destHeight);

    }


    public function mesureText(text : String):Int{
         return this.ctx.measureText(text).width;
    }

    public function startGroup (groupName: String){

    }

    public function endGroup (){

    }


    public function zoomIn(annotations:Dynamic, annotList:Array<ChromoHubAnnotation>, scale:Float){
        //WorkspaceApplication.getApplication().debug("hello");

        this.scale=scale;

        var newWidth = this.canvas.width * this.scale;
        var newHeight = this.canvas.height * this.scale;

        this.ctx.save();
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        this.ctx.translate(this.cx,this.cy);
        this.ctx.scale(this.scale, this.scale);
        var radialRendererObj  : Dynamic = new ChromoHubRadialTreeLayout(prog,this.canvas.width, this.canvas.height);

        radialRendererObj.render(this.rootNode, this,annotations, annotList);

        this.ctx.restore();
    }

    public function zoomOut(annotations:Dynamic, annotList:Array<ChromoHubAnnotation>, scale:Float){

        //if (scale>0.4){ // do we need a minimum scale?

            this.scale=scale;

            var newWidth = this.canvas.width * this.scale;
            var newHeight = this.canvas.height * this.scale;

            this.ctx.save();
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
            this.ctx.translate(this.cx,this.cy);
            this.ctx.scale(this.scale, this.scale);
            var radialRendererObj  : Dynamic = new ChromoHubRadialTreeLayout(prog, this.canvas.width, this.canvas.height);

            radialRendererObj.render(this.rootNode,this, annotations, annotList);

            this.ctx.restore();
        //}
    }
}