package saturn.client.programs.phylo;


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

class PhyloCanvasRenderer implements PhyloRendererI {
    var canvas : Dynamic;
    public var ctx : Dynamic;
    public var scale:Float=1.0;
    var parent: Dynamic;
    var rootNode:Dynamic;
    public var cx: Dynamic;
    public var cy: Dynamic;
    var config : PhyloCanvasConfiguration;
    var width : Int;
    var height : Int;

    var translateX : Float = 0.;
    var translateY : Float = 0.;
    var selectedNode : PhyloTreeNode;
    var contextDiv = null;

    var nodeClickListeners : Array<PhyloTreeNode->PhyloScreenData->Dynamic->Void> = new Array<PhyloTreeNode->PhyloScreenData->Dynamic->Void>();

    public function new (width:Int, height:Int, parentElement:Dynamic,rootNode:Dynamic, config = null){
        this.parent = parentElement;
        this.width = width;
        this.height = height;

        this.rootNode=rootNode;

       var doc:Dynamic;

       if(config == null){
           config = new PhyloCanvasConfiguration();
       }

        this.config = config;

        if(config.enableTools){
            addNodeClickListener(defaultNodeClickListener);
        }

        createCanvas();
    }

    public function notifyNodeClickListeners(node : PhyloTreeNode, data : PhyloScreenData, e :Dynamic){
        for(listener in nodeClickListeners){
            listener(node, data, e);
        }
    }

    public function defaultNodeClickListener(node : PhyloTreeNode, data : PhyloScreenData, e : Dynamic){
        contextDiv = js.Browser.document.createElement('div');
        contextDiv.style.position = 'absolute';
        contextDiv.style.left = e.clientX;
        contextDiv.style.top = e.clientY;

        contextDiv.innerText = 'Options';

        var wedgeInputColour :Dynamic = js.Browser.document.createElement('input');
        wedgeInputColour.setAttribute('type', 'color');
        wedgeInputColour.addEventListener('change', function(){
            node.wedgeColour = wedgeInputColour.value;

            redraw();
        });

        contextDiv.appendChild(wedgeInputColour);

        parent.appendChild(contextDiv);
    }

    public function addNodeClickListener(listener : PhyloTreeNode->PhyloScreenData->Dynamic->Void){
        nodeClickListeners.push(listener);
    }

    public function createCanvas(){
        if(this.canvas != null){
            ctx.save();

            ctx.setTransform(1, 0, 0, 1, 0, 0);

            ctx.clearRect(0, 0, canvas.width, canvas.height);

            ctx.restore();

            translateY = 0;
            translateX = 0;
        }else{
            this.canvas=js.Browser.document.createElement("canvas");
            parent.appendChild(this.canvas);

            this.canvas.width=width;
            this.canvas.height=height;

            this.ctx=this.canvas.getContext('2d');
            cx=Math.round(width/2);
            cy=Math.round(height/2);
            this.ctx.translate(cx,cy); //offset to get sharp lines.

            if(config.enableZoom){
                canvas.addEventListener('mousewheel', function(e : Dynamic) {
                    //parent.removeChild(canvas);

                    createCanvas();

                    if(e.wheelDelta<0){
                        if(config.scale<=4.0){
                            config.scale = config.scale+0.2;
                        }

                        zoomIn([],[], config.scale);
                    }else{
                        config.scale = config.scale-0.2;

                        zoomOut([],[],config.scale);
                    }
                });

                var mouseDownX = 0.;
                var mouseDownY = 0.;
                var mouseDown = false;

                canvas.addEventListener('mousedown', function(e : Dynamic) {
                    mouseDownX=e.pageX - translateX;
                    mouseDownY=e.pageY - translateY;

                    mouseDown = true;

                    if(contextDiv != null){
                        parent.removeChild(contextDiv);

                        contextDiv = null;
                    }
                });

                canvas.addEventListener('mousemove', function(e : Dynamic) {
                    if(mouseDown && mouseDownX != 0 && mouseDownY != 0){
                        //parent.removeChild(canvas);

                        createCanvas();

                        translateX = e.pageX - mouseDownX;
                        translateY = e.pageY - mouseDownY;

                        js.Browser.console.log(translateX);

                        redraw();
                    }
                });

                canvas.addEventListener('mouseup', function(e : Dynamic) {
                    mouseDown = false;
                    mouseDownX = 0;
                    mouseDownY = 0;

                    var d = checkPosition(e);
                    if (d!=null) {
                        selectedNode = rootNode.nodeIdToNode.get(d.nodeId);

                        notifyNodeClickListeners(selectedNode, d, e);
                    }
                });
            }
        }
    }

    public function drawLine (x0:Float,y0:Float, x1:Float, y1:Float,strokeStyle:Dynamic, lineWidth : Float){

        this.ctx.save();

        applyDefaultConfiguration();

       // this.ctx.scale(this.scale,this.scale);
        this.ctx.strokeStyle=strokeStyle;
        this.ctx.beginPath();
        this.ctx.moveTo(Math.round(x0), Math.round(y0));

        this.ctx.lineTo(Math.round(x1),Math.round(y1));

        this.ctx.lineWidth = lineWidth;

        this.ctx.stroke();

        this.ctx.restore();

    }

    public function drawArc (x : Float, y : Float, radius : Float, sAngle, eAngle, strokeStyle : String, lineWidth : Float){

        // this.ctx.scale(this.scale,this.scale);

        this.ctx.save();

        applyDefaultConfiguration();

        this.ctx.strokeStyle=strokeStyle;

        this.ctx.beginPath();
        this.ctx.arc(x,y,Math.abs(radius),sAngle,eAngle);

        this.ctx.lineWidth = lineWidth;

        this.ctx.stroke();
        this.ctx.closePath();

        this.ctx.restore();
    }

    public function drawWedge(x : Float, y : Float, radius : Float, sAngle, eAngle, strokeStyle : String, lineWidth : Float){
        ctx.save();

        ctx.fillStyle = strokeStyle;

        ctx.globalAlpha = 0.5;

        this.ctx.strokeStyle=strokeStyle;

        this.ctx.beginPath();

        ctx.moveTo(0,0);
        this.ctx.arc(x,y,Math.abs(radius),sAngle,eAngle);

        this.ctx.lineWidth = lineWidth;

        this.ctx.stroke();
        this.ctx.closePath();
        this.ctx.fill();

        this.ctx.restore();
    }

    public function bezierCurve (x0:Float,y0:Float, x1:Float, y1:Float, firstX : Float, firstY : Float, secondX : Float, secondY : Float, strokeStyle:Dynamic, lineWidth: Float){

        this.ctx.save();

        applyDefaultConfiguration();

        this.ctx.strokeStyle=strokeStyle;
        this.ctx.beginPath();
        this.ctx.moveTo(Math.round(x0), Math.round(y0));

        this.ctx.bezierCurveTo(Math.round(firstX),Math.round(firstY),Math.round(secondX),Math.round(secondY), Math.round(x1), Math.round(y1));
        this.ctx.lineWidth = lineWidth;
        this.ctx.stroke();

        this.ctx.restore();

    }

    public function drawText (text:String , tx:Float, ty:Float, x:Float, y:Float, rotation: Float, textAlign:String, color: String):Void{

        this.ctx.save();

        applyDefaultConfiguration();

        this.ctx.translate(tx,ty);

        this.ctx.rotate(rotation);
        this.ctx.textAlign=textAlign;
        this.ctx.fillStyle = color;
        this.ctx.fillText(text, x,y);


        this.ctx.restore();

    }

    public function drawTextNoTranslate (text:String , tx:Float, ty:Float, x:Float, y:Float, rotation: Float, textAlign:String, color: String):Void{

        this.ctx.save();

        applyDefaultConfiguration();

        this.ctx.translate(tx,ty);
        this.ctx.rotate(rotation);
        this.ctx.textAlign=textAlign;
        this.ctx.fillStyle = color;
        this.ctx.fillText(text, x,y);


        this.ctx.restore();

    }

    public function drawSquare (tx:Float, ty:Float, color:String):Void{
        this.ctx.save();

        applyDefaultConfiguration();

        this.ctx.beginPath();
        this.ctx.rect(tx, ty, 10, 10);
        this.ctx.fillStyle = color;
        this.ctx.fill();
        this.ctx.restore();
    }
    public function drawCircle (tx:Float, ty:Float, color:String):Void{
        var radius = 5;
        this.ctx.save();

        applyDefaultConfiguration();

        this.ctx.beginPath();
        this.ctx.strokeStyle=color;
        this.ctx.arc(tx,ty,radius,0,2*Math.PI);

        this.ctx.fillStyle=color;
        this.ctx.fill();
        this.ctx.restore();

    }

    public function drawGraphic (tx:Float, ty:Float, columns:Array<Int>):Void{
        this.ctx.save();

        applyDefaultConfiguration();

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

        applyDefaultConfiguration();

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


    public function zoomIn(annotations:Dynamic, annotList:Array<PhyloAnnotation>, scale:Float){
        //WorkspaceApplication.getApplication().debug("hello");

        this.scale=scale;

        this.redraw(annotations, annotList);
    }

    public function zoomOut(annotations:Dynamic, annotList:Array<PhyloAnnotation>, scale:Float){

        //if (scale>0.4){ // do we need a minimum scale?

            this.scale=scale;

        this.redraw(annotations, annotList);
        //}
    }

    public function redraw(annotations:Dynamic = null, annotList:Array<PhyloAnnotation> = null){
        if(annotations == null ){
            annotations = [];
        }

        if(annotList == null){
            annotList = [];
        }

        var newWidth = this.canvas.width * this.scale;
        var newHeight = this.canvas.height * this.scale;

        this.ctx.save();
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        this.ctx.translate(translateX,translateY);
        this.ctx.scale(this.scale, this.scale);
        var radialRendererObj  : Dynamic = new PhyloRadialTreeLayout(this.canvas.width, this.canvas.height);

        radialRendererObj.renderCircle(this.rootNode,this, annotations, annotList);

        this.ctx.restore();
    }

    public function setConfig(config : PhyloCanvasConfiguration){
        this.config = config;
    }

    public function getConfig() : PhyloCanvasConfiguration{
        return this.config;
    }

    public function applyDefaultConfiguration(){
        if(this.config.enableShadow){
            this.ctx.shadowOffsetX = 4;
            this.ctx.shadowOffsetY = 4;
            this.ctx.shadowBlur    = 7;
            this.ctx.shadowColor   = this.config.shadowColour;
        }
    }

    public function checkPosition(e:Dynamic):PhyloScreenData{
        var i,j:Int;
        var sx, sy :Int;
        var res:Bool;
        res=false;

        var auxx, auxy:Int;

        auxx=Math.round(e.offsetX);
        auxy=Math.round(e.offsetY);

        var x,y:Dynamic;
        x=auxx-Math.round(cx);
        y=auxy-Math.round(cy);

        var active:Bool;
        active=false;
        //if there is a annotation active and at least one of the leaves has an annotation to be shown, the rootNode.screen array won't be empty
        // we need to go throw all of the array in order to check if the mouse hovers one of them
        i=0;
        while((i<this.rootNode.screen.length)&&(res==false)){ //I must be sure the annotation in Screen array are only the ones of Active Annotations. So, that means when an annotation gets inactive, I must remove them from Screen array.!!!!!!!!!!
            if(this.rootNode.screen[i].checkMouse(x,y)==true) {
                res=true;

                this.rootNode.screen[i].root=this.rootNode;
                this.rootNode.divactive=i;
            }
            else this.rootNode.screen[i].created=false; //make sure it's false
            i=i+1;
        }
        if(res==true){
            return this.rootNode.screen[i-1];
        }
        else return null;
    }

    public static function main(){

    }
}

class PhyloCanvasConfiguration{
    public var enableShadow : Bool  = false;
    public var shadowColour : String = 'gray';
    public var bezierLines : Bool = false;
    public var drawingMode  = ChromoHubDrawingMode.CIRCULAR;
    public var editmode : Bool = false;
    public var highlightedGenes :Map<String, Bool> = new Map<String, Bool>();
    public var enableZoom : Bool = false;
    public var scale : Float = 1;
    public var enableTools : Bool = false;

    public function new(){

    }
}

enum ChromoHubDrawingMode{
    STRAIGHT;
    CIRCULAR;
}