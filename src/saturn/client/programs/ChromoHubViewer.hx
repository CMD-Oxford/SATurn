/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Copyright (C) 2015  Structural Genomics Consortium
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package saturn.client.programs;

import saturn.core.Table;
import saturn.core.domain.Alignment;
import js.html.Event;
import saturn.core.Util;

import saturn.client.programs.blocks.BaseTable;
import js.html.Uint8ClampedArray;
import saturn.client.programs.chromohub.ChromoHubScreenData;
import saturn.client.programs.SimpleExtJSProgram;
import saturn.util.StringUtils;
import js.html.CanvasElement;

import bindings.Ext;

import saturn.client.workspace.Workspace;
import saturn.client.workspace.Workspace.WorkspaceListener;

import saturn.client.workspace.ChromoHubWorkspaceObject;
import saturn.client.workspace.DNAWorkspaceObject;
import saturn.client.workspace.ProteinWorkspaceObject;

import saturn.client.programs.chromohub.ChromoHubRadialTreeLayout;
import saturn.client.programs.chromohub.ChromoHubCanvasRenderer;
import saturn.client.programs.chromohub.ChromoHubMath;
//import saturn.client.programs.ChromoHub.ChromoHubSVGRenderer;
import saturn.client.programs.chromohub.ChromoHubNewickParser;
import saturn.client.programs.chromohub.ChromoHubRendererI;
import saturn.client.programs.chromohub.ChromoHubTreeNode;
import saturn.client.programs.chromohub.ChromoHubAnnotation;

import saturn.core.DNA;
import saturn.client.programs.blocks.BaseTable;

import saturn.client.core.CommonCore;
import saturn.client.programs.chromohub.ChromoHubViewerHome;

import saturn.client.WorkspaceApplication;
typedef UndoLast = {
    var data: ChromoHubScreenData;
    var angle: Float;
    var x: Dynamic;
    var y: Dynamic;
    var clock: Bool;
}

class ChromoHubViewer  extends SimpleExtJSProgram  {
	static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ ChromoHubWorkspaceObject ];

    public var rootNode : ChromoHubTreeNode;
    var theComponent : Dynamic;
    var radialR  : Dynamic;
    var internalFrameId : String;
    public var currentView: Int; // 0 = Landing page, 1 = Tree View, 2 = Annotation Table View

	var canvas : Dynamic;
    var dom : Dynamic;

    var centrex: Dynamic;
    var centrey: Dynamic;
    var zoom: Dynamic;

	public var newickStr : String = '';

    public var annotations: Array<ChromoHubAnnotation>;
    public var activeAnnotation:Array<Bool>;
    var alreadyGotAnnotation:Map<String,Bool>;
    public var highlightedGenes:Map<String,Bool>;
    public var geneMap:Map<String,ChromoHubTreeNode>;

    var viewOptionsActive : Bool;
    public var editmode : Bool;
    var controlToolsActive : Bool;
    var tableActive : Bool;
    var onSubmenu:Bool=false;

    public var jsonFile : Dynamic;
    var jsonTipsFile : Dynamic;
    var tableAnnot :Table;
    var baseTable :BaseTable;
    var numTotalAnnot: Int;
    public var tips: Array<Dynamic>;
    public var tipActive=0;
    var nameAnnot: Array<String>;
    public var treeName:String;
    var scale=1.0;
    public var userMessage=true;
    public var userDomainMessage=true;

	static var newLineReg = ~/\n/g;
    static var carLineReg = ~/\r/g;
    static var whiteSpaceReg = ~/\s/g;

    public var treeType:String; // by default. Otherwise "gene"


    /*** single app vars ***/
    public var centralTargetPanel : Dynamic;

    public var menuScroll=0;

    var undolist: Array<UndoLast>;
    var updatedlist: Array<UndoLast>;
    var recovered=false;
    var tipOfDay=true;

    var standaloneMode = false;
    var singleAppContainer : SingleAppContainer;

    var enableEditMode = true;

    var selectedAnnotationOptions = [];

    var currentAdjustmentColour = null;
    var enableColourAdjust = false;

    var subtreeName = null;

    public function new(){
        super();
    }

    override public function emptyInit() {
        super.emptyInit();


        //currentView = 1;

        //init structures
        undolist=new Array();
        updatedlist=new Array();
        searchedGenes=new Array();
        activeAnnotation=new Array();
        annotations=new Array();
        selectedAnnotationOptions = new Array();
        highlightedGenes=new Map<String, Bool>();
        alreadyGotAnnotation=new Map<String, Bool>();
        geneMap=new Map<String, ChromoHubTreeNode>();

        #if UBIHUB
        treeType='gene';
        #else
        treeType='domain';
        #end
        treeName='';
        rootNode=null;

        getJSonViewOptions(); // Get the annotations and tips of the day data from JSON files

        this.internalFrameId = 'INTERNAL_ALN_FRAME';

        var self : ChromoHubViewer  = this;

        theComponent = Ext.create('Ext.panel.Panel', {
            flex:1,
            title: 'ChromoHub Viewer',
            simpleDrag: true,
            width:'100%',
            height: '100%',
            region:'center',
            //autoScroll : true,
            layout : 'fit',
            items : [{
                        xtype : "component",
                        itemId: internalFrameId,
                        autoEl : {
                            tag : "div"
                        },
						height : '100%',
                        autoScroll : true,
						width : '100%'
			}],
            listeners : {
                'afterrender' : function() { self.initialiseDOMComponent(); },
                'render': afterRender,

                'resize': function(){ redraw(); },
                'keypress': {
                    element: 'el',
                    fn: function(){
                        js.Browser.alert('Hello');
                    }
                }
            },
            cls: 'x-tree-background'
        });

        //if(!standaloneMode){
        //    singleAppContainer = new SingleAppContainer();
        //    singleAppContainer.setProgram(this);
        //}

        registerDropFolder('Sequences', WorkspaceObject, true);
    }

    private function afterRender(panel) {

        var moving : String = 'No';
        var leaving=false;
        var current_x,current_y, current_mx, current_my, new_x,new_y, new_mx, new_my: Dynamic;

        panel.body.on('mousedown', function(e : Dynamic) {

            if(standaloneMode){
                var container = getApplication().getSingleAppContainer();
                container.hideExportSubMenu();
                container.hideHelpingDiv();

                if(getApplication().getScreenMode() != ScreenMode.DEFAULT){
                    container.hideSubMenuToolBar();
                }
            }
            //closeAnnotWindows();

            moving='yes';
            current_mx=e.pageX;
            current_my=e.pageY;

        });
        panel.body.on('mouseup', function(e : Dynamic ) {
            js.Browser.document.body.style.cursor = "auto";
            moving='no';
            new_mx=e.pageX - current_mx;
            new_my=e.pageY - current_my;
            leaving=false;
            if(currentView==1){
                save_centre(new_mx, new_my);
            }
            var d = checkPosition(e);
            if (d!=null) {
                js.Browser.document.body.style.cursor = "auto";
                if(d.isAnnot==true){
                    showScreenData(false,d,e.pageX,e.pageY);
                }else if(editmode==true){
                    var node:ChromoHubTreeNode;
                    node=this.rootNode.nodeIdToNode.get(d.nodeId);
                    var clock=true;
                    if(e.parentEvent.shiftKey==true){
                        clock=false;
                    }
                    undolist[undolist.length]={data:d,x:d.x,y:d.y,angle:node.angle, clock:clock};
                    //we need to check wheter the SHIFT key is pressed
                    //var a=js.html.event.
                    moveNode(d,false, clock);
                }else if(enableColourAdjust){
                    var node:ChromoHubTreeNode = this.rootNode.nodeIdToNode.get(d.nodeId);

                    if(d.nodeId == 0){
                        node = rootNode;
                    }


                    //undolist[undolist.length]={data:d,x:d.x,y:d.y,angle:node.angle, clock:clock};

                    colourNode(node);
                }
            }
        });

        panel.body.on('dblclick', function(e : Dynamic ) {
            if(standaloneMode){
                var container = getApplication().getSingleAppContainer();
                container.removeAnnotWindows();
            }
        });


        panel.body.on('mousewheel', function(e : Dynamic) {
            if(standaloneMode){
                var container = getApplication().getSingleAppContainer();
                container.hideExportSubMenu();
                container.hideHelpingDiv();
                container.hideSubMenuToolBar();
            }

            if(e.getWheelDelta()<0){
                zoomIn(this.activeAnnotation);
            }else{
                zoomOut(this.activeAnnotation);
            }
        });

        panel.body.on('mousemove', function(e) {
            //getApplication().getSingleAppContainer().hideExportSubMenu();
            if(this.rootNode!=null){
                if(moving=='yes'){
                    new_mx=e.pageX - current_mx;
                    new_my=e.pageY - current_my;
                    newposition(new_mx, new_my);

                    js.Browser.document.body.style.cursor = "move";
                }
            }
        });

        panel.body.on('mouseenter', function(e) {
           /* WorkspaceApplication.getApplication().debug("enter");
            if(getApplication().getSingleAppContainer().getAnnotWindow()!=null){
                getApplication().getSingleAppContainer().closeAnnotWindow();
            }
            leaving=false;*/
        });

        panel.body.on('mouseleave', function(e) {
             moving="no";
            // if (leaving==true)showScreenData(true,null,e.pageX,e.pageY);
             leaving=true;
        });
    }

    public function colourNode(node: ChromoHubTreeNode){
        node.colour = currentAdjustmentColour;

        newposition(0,0);
    }


    public function moveNode(d:ChromoHubScreenData,undo:Bool,clock:Bool){
        var node:ChromoHubTreeNode;
        var alpha:Float;
        var n:Dynamic;
        if(undo==true){
            var auxpop=undolist.pop();
            d=auxpop.data;
            node=this.rootNode.nodeIdToNode.get(d.nodeId);
            node.x=auxpop.x;
            node.y=auxpop.y;
            node.angle=auxpop.angle;
            n=node.angle;
        }
        else{
            if(clock==true)alpha=0.3;
            else alpha=-0.3;
            node=this.rootNode.nodeIdToNode.get(d.nodeId);
            node.x=((d.x-d.parentx)*Math.cos(alpha))-((d.y-d.parenty)*Math.sin(alpha))+d.parentx;
            node.y=((d.x-d.parentx)*Math.sin(alpha))+((d.y-d.parenty)*Math.cos(alpha))+d.parenty;
            node.angle=node.angle+alpha;
            n=node.angle;
        }

        var i=0;
        while(i<node.children.length){

            node.children[i].wedge=((node.children[i].l/node.children[i].root.l)*2*Math.PI)+Math.PI/20; // we scale the angles to avoid label overlapping
            node.children[i].angle=n;

            n=n+node.children[i].wedge;
            node.children[i].preOrderTraversal(0);
            i++;
        }
        newposition(0,0);
    }

    public function checkPosition(e:Dynamic):ChromoHubScreenData{
        if(this.canvas == null){
            //too early
            return null;
        }

        var i,j:Int;
        var sx, sy :Int;
        var res:Bool;
        res=false;

        var auxx, auxy:Int;

        auxx=Math.round(e.browserEvent.offsetX);
        auxy=Math.round(e.browserEvent.offsetY);

        var x,y:Dynamic;
        x=auxx-Math.round(this.centrex);
        y=auxy-Math.round(this.centrey);

        var active:Bool;
        active=false;
        //if there is a annotation active and at least one of the leaves has an annotation to be shown, the rootNode.screen array won't be empty
        // we need to go throw all of the array in order to check if the mouse hovers one of them
        i=0;
        while((i<this.rootNode.screen.length)&&(res==false)){ //I must be sure the annotation in Screen array are only the ones of Active Annotations. So, that means when an annotation gets inactive, I must remove them from Screen array.!!!!!!!!!!
            if(this.rootNode.screen[i].checkMouse(x,y)==true) {
                res=true;

                //WorkspaceApplication.getApplication().debug('target is '+this.rootNode.screen[i].target);
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

    public function showScreenData(active:Bool, data: ChromoHubScreenData, mx: Int, my:Int){
        if(this.canvas == null){
            //too early
            return;
        }

     // if(data!=null){
        if(active==false){ //the DIV must be shown
//
            var mxx:String;
            mxx=mx+'px';
            var myy:String;
            myy=my+'px';
            if(data.created==false){
                var container = getApplication().getSingleAppContainer();
                container.hideExportSubMenu();
                container.hideHelpingDiv();
                container.hideSubMenuToolBar();
                data.divAccessed=false;
                if((annotations[data.annotation.type].hasClass!=null)&&(annotations[data.annotation.type].divMethod!=null)){
                    var hook:Dynamic;
                    var clazz,method:String;

                    data.suboption=annotations[data.annotation.type].optionSelected[0];
                    data.title=annotations[data.annotation.type].label;
                    data.family = treeName;
                    clazz=annotations[data.annotation.type].hasClass;
                    method=annotations[data.annotation.type].divMethod;

                    //WorkspaceApplication.getApplication().debug(method);

                    hook = Reflect.field(Type.resolveClass(clazz), method);
                    hook(data,mxx, myy,treeType, function(div){
                        data.created=true;
                        data.div=div;
                        var nn='';
                        if(data.target!=data.targetClean){
                            if(data.target.indexOf('(')!=-1 || data.target.indexOf('-')!=-1){
                                var auxArray=data.target.split('');
                                var j:Int;
                                for(j in 0...auxArray.length){
                                    if (auxArray[j]=='(' || auxArray[j]=='-') {
                                        nn=auxArray[j+1];
                                        break;
                                    }
                                }
                            }
                        }
                        if(data.annotation.type==4){
                            if(data.annotation.text.indexOf('.')!=-1){
                                var auxArray=data.annotation.text.split('');
                                var j:Int;
                                var naux='';
                                for(j in 0...auxArray.length){
                                    if(auxArray[j]!='.') naux+=auxArray[j];
                                }
                                nn=nn+naux;
                            }else if(data.annotation.text.indexOf('/')!=-1){
                                var auxArray=data.annotation.text.split('');
                                var j:Int;
                                var naux='';
                                for(j in 0...auxArray.length){
                                    if(auxArray[j]!='/') naux+=auxArray[j];
                                }
                                nn=nn+naux;
                            }else nn=nn+data.annotation.text;
                        }

                        var nom='';
                        if(data.targetClean.indexOf('/')!=-1){
                            var auxArray=data.targetClean.split('');
                            var j:Int;
                            for(j in 0...auxArray.length){
                                if(auxArray[j]!='/') nom+=auxArray[j];
                            }
                        }else nom=data.targetClean;
                        var id=data.annotation.type+'-'+nom+nn;
                        container.showAnnotWindow(div, mx, my,data.title,id,data);
                    });
                }
            }
            else{

               //the div is already created we just need to move it
               //  js.Browser.document.getElementById('divAnnotTable').style.left = mxx;
               // js.Browser.document.getElementById('divAnnotTable').style.top = myy;

            }
        }
        else{
            //we need to remove the div
            if(this.rootNode.divactive!=99999){
                if(this.rootNode.screen[this.rootNode.divactive]!=null) this.rootNode.screen[this.rootNode.divactive].created=false;
                this.rootNode.divactive=99999;

            }
           // if(getApplication().getSingleAppContainer().getAnnotWindow()!=null){
             //   getApplication().getSingleAppContainer().closeAnnotWindow();
            //}
        }
      //}
    }

    public function save_centre(x:Dynamic, y:Dynamic){
        this.centrex=this.centrex+x;
        this.centrey=this.centrey+y;
        this.canvas.cx=this.centrex;
        this.canvas.cy=this.centrey;
    }

    public function newposition(new_x:Dynamic, new_y:Dynamic){

        if(currentView==1){
            this.dom = theComponent.down('component').getEl().dom;

            var newWidth  : Int = this.dom.clientWidth;
            var newHeight : Int = this.dom.clientHeight;


            this.canvas.canvas.width=newWidth;
            this.canvas.canvas.height=newHeight;

            var ctx=this.canvas.canvas.getContext('2d');
            ctx.save();
            ctx.clearRect(0, 0, this.canvas.canvas.width, this.canvas.canvas.height);

            ctx.translate(this.centrex+new_x,this.centrey+new_y);

            ctx.scale(this.canvas.scale, this.canvas.scale);

            this.radialR= new ChromoHubRadialTreeLayout(this, this.canvas.canvas.width, this.canvas.canvas.height);

            this.rootNode.screen=new Array();// we need to initizalize the array everytime we render the tree

            this.rootNode.rectangleLeft=Std.int(this.rootNode.children[0].x);
            this.rootNode.rectangleRight=Std.int(this.rootNode.children[0].x);
            this.rootNode.rectangleBottom=Std.int(this.rootNode.children[0].y);
            this.rootNode.rectangleTop=Std.int(this.rootNode.children[0].y);

            this.radialR.renderCircle(this.rootNode, this.canvas, this.activeAnnotation,annotations);

            this.canvas.ctx.save();
            this.canvas.ctx.beginPath();

            this.canvas.cx=this.centrex;
            this.canvas.cy=this.centrey;
            ctx.restore();
        }

    }
    function centerCanvas(){
        var left,right,top,bottom,w,h:Int;
        left=this.rootNode.rectangleLeft;
        right=this.rootNode.rectangleRight;
        top=this.rootNode.rectangleBottom;
        bottom=this.rootNode.rectangleTop;
        w=0;h=0;

        if(left<=0 && right>=0) w=Std.int(Math.abs(left)+right);
        if(left<=0 && right<=0) w=Std.int(Math.abs(left)-Math.abs(right));
        if(left>=0 && right>0) w=left-right;

        var x,y:Int;
        x=left-60;

        if(top<=0 && bottom<=0) h=Std.int(Math.abs(top)-Math.abs(bottom));
        if(bottom>=0 && top<=0) h=Std.int(Math.abs(top)+bottom);
        if(top>=0 && bottom>=0) h=bottom-top;
        if(top>=0 && bottom<=0) h=top-bottom;


        if(top>0)y=top+60;
        else y=top-60;

        w=w+120;
        h=h+200;

       /* this.canvas.ctx.rect(x, y, w, h);
        this.canvas.ctx.fillStyle = '#ff0000';
        this.canvas.ctx.fill();
        this.canvas.ctx.restore();*/

        var newWidth  : Int = this.dom.clientWidth;
        var newHeight : Int = this.dom.clientHeight;

        if(scale!=1.0){
            scale=1.0;
            this.canvas.zoomIn(activeAnnotation,annotations,scale);
        }


        if(newWidth<w || newHeight<=h){
            var fx=1.0; var fy=1.0;
            if(newWidth<w) fx=newWidth/w;
            if(newHeight<=h) fy=newHeight/h;
            var f=0.0;
            if(fx>fy)f=fy;
            else f=fx;
            if(f<0.4) f=0.4;
            if(f!=1.0){
                scale=f;
                this.canvas.zoomIn(activeAnnotation,annotations,scale);
            }
        }

        newposition(0, 0);
       // newposition(new_x, new_y);
       // WorkspaceApplication.getApplication().debug('the area should be from left-top ('+this.rootNode.rectangleLeft+','+this.rootNode.rectangleTop+') and righ-bottom ('+this.rootNode.rectangleRight+','+this.rootNode.rectangleBottom+')');

    }

    public function redraw(){
        if(this.canvas == null){
            //too early
            return;
        }

        this.dom = theComponent.down('component').getEl().dom;

        var newWidth  : Int = this.dom.clientWidth;
        var newHeight : Int = this.dom.clientHeight;

        this.canvas.canvas.width=newWidth;
        this.canvas.canvas.height=newHeight;


        var ctx=this.canvas.canvas.getContext('2d');
        newposition(0,0);

        ctx.restore();
    }

	public function setTreeFromNewickStr( myNewickStr : String ) {
        getObject().newickStr = myNewickStr;

        newickStr = myNewickStr;

        var w0 : ChromoHubWorkspaceObject = cast(super.getActiveObject(ChromoHubWorkspaceObject), ChromoHubWorkspaceObject);
        w0.newickStr = myNewickStr;

		if (newickStr == null || newickStr == '') {
            theComponent.addCls('x-tree-background');
			return ;
		}else{
            theComponent.removeCls('x-tree-background');
        }

		newickStr = whiteSpaceReg.replace(newickStr, "");
        newickStr = newLineReg.replace(newickStr,"");
        newickStr = carLineReg.replace(newickStr, "");

		var newickParser :ChromoHubNewickParser = new ChromoHubNewickParser();

        //this is the time when rootNode gets its content
        rootNode = newickParser.parse(newickStr); //rootNoder is a ChromoHubTreeNode
        rootNode.calculateScale();

        rootNode.minBranch = 0;

        rootNode.postOrderTraversal();
        if (rootNode.leaves > 150) this.rootNode.dist=60;
        rootNode.x = 0;
        rootNode.y = 0;
        rootNode.wedge = 2*Math.PI;
        rootNode.angle = 0;
        rootNode.preOrderTraversal(1);



        // in this point we have the tree with ALL details to be drawn


        this.dom = theComponent.down('component').getEl().dom;

        var parentWidth : Int = this.dom.clientWidth;
        var parentHeight : Int = this.dom.clientHeight;

        var minSize : Float = Math.min(parentWidth, parentHeight);

        if(this.canvas!=null){
            this.canvas.parent.removeChild( this.canvas.canvas);//otherwise, we'll get two trees
        }

        this.canvas = new ChromoHubCanvasRenderer(this,parentWidth, parentHeight, this.dom, this.rootNode);

        this.centrex=Math.round(parentWidth/2);
        this.centrey=Math.round(parentHeight/2);
        this.canvas.cx=this.centrex;
        this.canvas.cy=this.centrey;
        this.rootNode.screen=new Array(); // we need to initizalize the array with all information about annotations position in screen
        var radialRendererObj  : Dynamic = new ChromoHubRadialTreeLayout(this,parentWidth, parentHeight);

       // annotations= new Array();

        radialRendererObj.renderCircle(this.rootNode,this.canvas,this.activeAnnotation, annotations);




		// map one key by key code
		var map = new bindings.KeyMap(theComponent.getEl(), {
			key: '+',
			shift : true,
			fn: function() {
				zoomIn(this.activeAnnotation);
			}
		});
	}

    public function checkAnnotationJSonData():Bool{

        var a=getApplication();
        var atLeastOneBtn=false;
        var i=0;var j=0; var z=0;
        var codesUsed: Map<Int, Bool>;
        var codesUsed: Map<Int, Bool>;
        var namesUsed: Map<String, Bool>;

        var m=WorkspaceApplication.getApplication();
        codesUsed = new Map();
        namesUsed = new Map();
        if(jsonFile.btnGroup.length==0){
            a.debug('No buttons groups defined in JSON File');
            m.showMessage('Alert','Annotations JSon file is not correct.');
            return false;
        }
        while(i< jsonFile.btnGroup.length){
            j=0;
            while(j<jsonFile.btnGroup[i].buttons.length){
                atLeastOneBtn=true;
                var btn=jsonFile.btnGroup[i].buttons[j];

                if(btn.isTitle==false){
/** Annotation Code ****/
                    if(btn.annotCode==null){
                        a.debug('Annotation without Code assigned');
                        m.showMessage('Alert','Annotations JSon file is not correct.');
                        return false;
                    }
                    if (codesUsed.exists(btn.annotCode)){
                        a.debug('Annotation Code already used');
                        m.showMessage('Alert','Annotations JSon file is not correct.');
                        return false;
                    }else{
                        codesUsed.set(btn.annotCode,true);
                    }

/*** Annotation Name ***/
                    if(btn.label==null){
                        a.debug('Annotation without Name/Label');
                        m.showMessage('Alert','Annotations JSon file is not correct.');
                        return false;
                    }
                    if (namesUsed.exists(btn.label)){
                        a.debug('Annotation Name already used');
                        m.showMessage('Alert','Annotations JSon file is not correct.');
                        return false;
                    }else{
                        namesUsed.set(btn.label,true);
                    }

/*** Annotation Shape ***/
                    if(btn.shape==null){
                        a.debug('Annotation without assigned SHAPE');
                        m.showMessage('Alert','Annotations JSon file is not correct.');
                        return false;
                    }
                    if (btn.shape!='image' && btn.shape!='text' && btn.shape!='cercle' && btn.shape!='square' && btn.shape!='html'){
                        a.debug('Annotation SHAPE is not supported');
                        m.showMessage('Alert','Annotations JSon file is not correct.');
                        return false;
                    }
                    if (btn.shape=='image' && btn.annotImg==null){
                        a.debug('Annotation img path not specified');
                        m.showMessage('Alert','Annotations JSon file is not correct.');
                        return false;
                    }
                    if (btn.shape!='image' && btn.color==null){
                        a.debug('Annotation color not specified');
                        m.showMessage('Alert','Annotations JSon file is not correct.');
                        return false;
                    }

/*** Mysql Alias ***/
                    if(btn.hookName==null){
                        a.debug('Annotation mysql alias not specified');
                        m.showMessage('Alert','Annotations JSon file is not correct.');
                        return false;
                    }

/*** Methods ***/
                    if((btn.hasMethod!=null || btn.divMethod!=null || btn.familyMethod!="")&& btn.hasClass==null){
                        a.debug('Annotation hasClass needed and not specified');
                        m.showMessage('Alert','Annotations JSon file is not correct.');
                        return false;
                    }

/*** SUBMENU ***/
                    //having options.length!=0 we'll only check the suboptions
                    if(btn.options!=null && btn.options.length>0){
                        btn.submenu=true; //we want to be sure
                        var optsel=10000;
                        var z=0;
                        /*  for (z in 0 ...btn.options.length){
                                if(btn.options[z].isTitle==false && btn.options[z].isLabelTitle==false){
                                    optsel=z; //in case OptionSelected is null, we'll get the first possible option
                                }
                                if(btn.options[j].hookName==null){
                                    a.debug('Annotation suboptions without Mysql Alias');
                                    return false;
                                }
                            }
                            if (btn.optionSelected==null && optsel!=10000){
                                btn.optionSelected=new Array();
                                btn.optionSelected[0]=optsel;
                            }else if (btn.optionSelected==null && optsel==10000){
                                a.debug('Annotation suboptions without Option Selected defined');
                                return false;
                            }*/
                    }
                }
                j++;
            }
            i++;
        }
        if(atLeastOneBtn==false){
            a.debug('No buttons defined in JSON File');
            m.showMessage('Alert','Annotations JSon file is not correct.');
            return false;
        }
        else{
            return true;
        }
    }

    public function setSelectedAnnotationOptions(annotation : Int, selectedOptions : Dynamic){
        selectedAnnotationOptions[annotation] = selectedOptions;
    }

    public function getSelectedAnnotationOptions(annotation : Int) : Dynamic{
        return selectedAnnotationOptions[annotation];
    }

    public function fillAnnotationwithJSonData(){

        var i=0; var j=0; var z=0;
        nameAnnot=new Array();

        var b=0;
        while(i< jsonFile.btnGroup.length){
            j=0;
            while(j<jsonFile.btnGroup[i].buttons.length){

                //check if it's a subtitle
                if(jsonFile.btnGroup[i].buttons[j].isTitle==false){
                    var a:Int;
                    a=jsonFile.btnGroup[i].buttons[j].annotCode;
                    annotations[a]= new ChromoHubAnnotation();

                    selectedAnnotationOptions[a] = null;

                    if (jsonFile.btnGroup[i].buttons[j].shape == "image") {
                        annotations[a].uploadImg(jsonFile.btnGroup[i].buttons[j].annotImg); //summary
                    }
//this.activeAnnotation.set(jsonFile.btnGroup[i].buttons[j].annotCode]=false;
                    this.alreadyGotAnnotation[jsonFile.btnGroup[i].buttons[j].annotCode]=false;
                    annotations[a].shape=jsonFile.btnGroup[i].buttons[j].shape;
                    annotations[a].label=jsonFile.btnGroup[i].buttons[j].label;
                    annotations[a].color=jsonFile.btnGroup[i].buttons[j].color;
// annotations[a].type=jsonFile.btnGroup[i].buttons[j].annotCode;
                    annotations[a].hookName=jsonFile.btnGroup[i].buttons[j].hookName;
                    annotations[a].splitresults=jsonFile.btnGroup[i].buttons[j].splitresults;
                    annotations[a].popup=jsonFile.btnGroup[i].buttons[j].popUpWindows;

                    if(jsonFile.btnGroup[i].buttons[j].hasClass!=null) annotations[a].hasClass=jsonFile.btnGroup[i].buttons[j].hasClass;

                    if(jsonFile.btnGroup[i].buttons[j].hasMethod!=null) annotations[a].hasMethod=jsonFile.btnGroup[i].buttons[j].hasMethod;
                    if(jsonFile.btnGroup[i].buttons[j].divMethod!=null) annotations[a].divMethod=jsonFile.btnGroup[i].buttons[j].divMethod;
                    if(jsonFile.btnGroup[i].buttons[j].familyMethod!=null) annotations[a].familyMethod=jsonFile.btnGroup[i].buttons[j].familyMethod;
                    if(jsonFile.btnGroup[i].buttons[j].popUpWindows!=null && jsonFile.btnGroup[i].buttons[j].popUpWindows==true){
                        annotations[a].popMethod=jsonFile.btnGroup[i].buttons[j].windowsData[0].popMethod;
                    }

                    annotations[a].options=new Array();
                    if(jsonFile.btnGroup[i].buttons[j].legend!=null){
                        annotations[a].legend=jsonFile.btnGroup[i].buttons[j].legend.image;

                        if(jsonFile.btnGroup[i].buttons[j].legend.clazz != null) {
                            annotations[a].legendClazz = jsonFile.btnGroup[i].buttons[j].legend.clazz;
                            annotations[a].legendMethod = jsonFile.btnGroup[i].buttons[j].legend.method;
                        }
                    }

                    if(jsonFile.btnGroup[i].buttons[j].submenu==true){
                        var zz:Int;
                        for (zz in 0 ...jsonFile.btnGroup[i].buttons[j].options.length){
                            annotations[a].options[zz]=jsonFile.btnGroup[i].buttons[j].options[zz].hookName;
                            if(jsonFile.btnGroup[i].buttons[j].options[zz].defaultImg!=null)
                                annotations[a].defaultImg=jsonFile.btnGroup[i].buttons[j].options[zz].defaultImg;
                        }
                        annotations[a].optionSelected[0] = jsonFile.btnGroup[i].buttons[j].optionSelected[0];
                    }
                    nameAnnot[b]=jsonFile.btnGroup[i].buttons[j].label;
                    b++;
                }
                j++;
            }
            numTotalAnnot=numTotalAnnot+j;
            i++;
        }
    }

    public function fillTipswithJSonData(){

        var i=0; var j=0; var z=0;
        tipActive=jsonTipsFile.active;
        tips=new Array();

        var b=0;
        for(i in 0... jsonTipsFile.tips.length){
            tips.push({
                position: jsonTipsFile.tips[i].position,
                title: jsonTipsFile.tips[i].title,
                html: jsonTipsFile.tips[i].html
            });
        }
    }

    //Functions that update Legend adding or remmoving the image of the annotation
    public function updateLegend(bntJson:Dynamic, activate:Bool){
        var currentAnnot=bntJson.annotCode;
        if(annotations[currentAnnot].legend!=''){
            if(activate==false){
                //we need to show the legend of that annotation
                getApplication().getSingleAppContainer().addImageToLegend(annotations[currentAnnot].legend, currentAnnot);

            }
            else{
                // we need to remove the legend of that annotation
                getApplication().getSingleAppContainer().removeComponentFromLegend(currentAnnot);
            }
        }
    }


    //Function called when the user select any annotation to be added
    //like any of the checks in the current chromohub
    //depending on if it's already checked or not , active will be true or false
    public function showAnnotation(annotCode:Dynamic, active:Bool){
        //here we should check the scroll position for annotations menu

        var currentAnnot=annotCode;

        //update activeAnnotation array
        activeAnnotation[currentAnnot]=active;

        var container = getApplication().getSingleAppContainer();

        if(active==true){
            var i:Int;
            var needToExpandLegend=false;

            for (i in 0...activeAnnotation.length){
                if (activeAnnotation[i]==true){
                   if(annotations[i].legend!='' && annotations[i].legendClazz == '') {
                       needToExpandLegend=true;
                       container.addImageToLegend(annotations[i].legend, i);
                   } else if(annotations[i].legendClazz != '' && annotations[i].legendMethod != ''){
                       var clazz = Type.resolveClass(annotations[i].legendClazz);
                       var method = Reflect.field(clazz, annotations[i].legendMethod);
                       var legend = method(treeName);

                       container.addImageToLegend(legend, i);
                   }
                }
            }
            if( needToExpandLegend==true){
                container.legendPanel.expand();
            }
            var annot=annotations[currentAnnot];
            if(annot.familyMethod==""){
                var myGeneList: Array<String>;
                myGeneList=this.rootNode.targets;

                var currentOption=100;
                var alias:Dynamic;
                var dbAccessed=false;
                var u:Int;
                if(annot.options.length==0){ //there aren't options
                    alias= annot.hookName;
                    annot.defaultImg=0;
                    if(this.alreadyGotAnnotation.exists(alias)==false){ //it's the first time we access the db
                        this.alreadyGotAnnotation.set(alias,true);//we need to add it
                        dbAccessed=false;
                    }
                    else {dbAccessed=true;}
                }else{
                    if(annot.optionSelected.length==1){
                        currentOption =annot.optionSelected[0];
                        alias= annot.options[currentOption];
                        if(annot.defaultImg==null) annot.defaultImg=0;
                        else annot.defaultImg=currentOption;
                        dbAccessed=false;
                    }
                    else{
                        dbAccessed=false;
                        alias='';
                    }
                }

                var error:Dynamic;
                dbAccessed=false;
                if(dbAccessed==false){
                    var parameter:Dynamic;
                    //before calling the mysql select, we need to check the tree type (domain or gene)
                    if(treeName!=''){
                        if(this.treeName.indexOf('/')!=-1){
                            var aux=this.treeName.split('/');
                            parameter=aux[1];
                        }
                        else{
                            parameter=this.treeName;
                        }
                        if(this.treeType=='gene'){
                            alias='gene_'+alias;
                        }
                    }else{ //own genes option
                        parameter=this.rootNode.targets;
                    }

                    WorkspaceApplication.getApplication().getProvider().getByNamedQuery(alias,{param : parameter}, null, true, function(db_results, error){
                        if(error == null) {
                            addAnnotData(db_results,currentAnnot,currentOption, function(){
                                newposition(0,0);
                            });
                        }
                        else {
                            WorkspaceApplication.getApplication().debug(error);
                        }
                    });
                } else{
                    newposition(0,0);
                }
            }
            else{

                if(annot.familyMethod!=""){
                    var hook:Dynamic;
                    var clazz,method:String;
                    activeAnnotation[currentAnnot]=false;
                    clazz=annotations[currentAnnot].hasClass;
                    method=annotations[currentAnnot].familyMethod+'table';

                    var data=new ChromoHubScreenData();

                    data.renderer=this.radialR;
                    data.target='';
                    data.targetClean='';
                    data.annot=currentAnnot;
                    data.divAccessed=false;
                    data.root=this.rootNode;
                    data.title= annotations[currentAnnot].label;

                    hook = Reflect.field(Type.resolveClass(clazz), method);

                    this.dom = theComponent.down('component').getEl().dom;

                    var posXDiv  = (this.dom.clientWidth/2)-100;
                    var posYDiv = this.dom.clientHeight/5;
                    closeDivInTable();

                    hook(data,Math.round(posXDiv), Math.round(posYDiv),treeName, treeType, function(div){
                        data.created=true;
                        data.div=div;

                        var nn='';
                        if(data.target!=data.targetClean){
                            if(data.target.indexOf('(')!=-1 || data.target.indexOf('-')!=-1){
                                var auxArray=data.target.split('');
                                var j:Int;
                                for(j in 0...auxArray.length){
                                    if (auxArray[j]=='(' || auxArray[j]=='-') {
                                        nn=auxArray[j+1];
                                        break;
                                    }
                                }
                            }
                        }
                        if(currentAnnot==4){
                            if(data.annotation.text.indexOf('.')!=-1){
                                var auxArray=data.annotation.text.split('');
                                var j:Int;
                                var naux='';
                                for(j in 0...auxArray.length){
                                    if(auxArray[j]!='.') naux+=auxArray[j];
                                }
                                nn=nn+naux;
                            }else if(data.annotation.text.indexOf('/')!=-1){
                                var auxArray=data.annotation.text.split('');
                                var j:Int;
                                var naux='';
                                for(j in 0...auxArray.length){
                                    if(auxArray[j]!='/') naux+=auxArray[j];
                                }
                                nn=nn+naux;
                            }else nn=nn+data.annotation.text;
                        }

                        var nom='';
                        if(data.targetClean.indexOf('/')!=-1){
                            var auxArray=data.targetClean.split('');
                            var j:Int;
                            for(j in 0...auxArray.length){
                                if(auxArray[j]!='/') nom+=auxArray[j];
                            }
                        }else nom=data.targetClean;
                        var id=currentAnnot+'-'+nom+nn;
                        getApplication().getSingleAppContainer().showAnnotWindow(div, Math.round(posXDiv), Math.round(posYDiv), data.title,id,data);

                    });
                }
            }
        }
        else{
            newposition(0,0);
            container.emptyLegend();
            var i:Int;
            var needToExpandLegend=false;

            for (i in 0...activeAnnotation.length){
                if (activeAnnotation[i]==true){
                    if(annotations[i].legend!=''){
                        needToExpandLegend=true;
                        container.addImageToLegend(annotations[i].legend, i);
                    }
                }
            }
            if( needToExpandLegend==false){
                container.legendPanel.collapse();
            }

        }
    }

    public function addAnnotDataGenes (annotData  : Array<Dynamic>, annotation: Int, callback:Void->Void ){
        var i:Int;

        var mapResults: Map<String, Dynamic>;
        mapResults=new Map();

        var target:String;
        var j=0;

        for(i in 0 ... annotData.length){
            if(annotation==1){
                var aux=annotData[i].pmid_list;
                var aux2=aux.split(';');
                var max = aux2.length;

                var v = this.annotations[1].fromresults[1];

                if(max>v || this.annotations[1].fromresults[1]==null){
                    this.annotations[1].fromresults[1]=max;
                }
            }
            target=annotData[i].target_id+'_'+j;
            while (mapResults.exists(target)){
                j++;
                target=annotData[i].target_id+'_'+j;
            }
            j=0;
            mapResults.set(target, annotData[i]);
        }

        var items=new Array();
        var i=0;
        for (i in 0...searchedGenes.length){
            items[i]=searchedGenes[i];
        }

        processGeneAnnotations(items, mapResults, annotation, callback);
    }

    /**
    * processGeneAnnotations
    **/
    public function processGeneAnnotations(items:Array<String>, mapResults: Map<String, Dynamic>, annotation: Int, cb:Void->Void){
        var toComplete = items.length;

        var onDone = function(){
            if(toComplete == 0){
                cb();
            }
        }

        if(toComplete == 0){
            cb(); return;
        }

        for(name in items){
            var target = name + '_0';

            if (mapResults.exists(target)){
                var res = mapResults.get(target);

                var leafaux: ChromoHubTreeNode = geneMap.get(name);

                var index = null;
                var variant = '1';

                // TODO: What is the purpose of this block?
                #if PHYLO5

                #else
                if(annotation == 13 && Reflect.hasField(res, 'family_id')) {
                    leafaux.targetFamily = mapResults.get(target).family_id;
                }
                #end

                if((annotations[annotation].hasClass != null) && (annotations[annotation].hasMethod != null)){
                    var clazz = annotations[annotation].hasClass;
                    var method = annotations[annotation].hasMethod;

                    var hook : Dynamic = Reflect.field(Type.resolveClass(clazz), method);

                    hook(name, res, 0, annotations, name, function(r : HasAnnotationType){
                        if(r.hasAnnot){
                            leafaux.activeAnnotation[annotation] = true;

                            if(leafaux.annotations[annotation] == null){
                                leafaux.annotations[annotation] = new ChromoHubAnnotation();
                                leafaux.annotations[annotation].myleaf = leafaux;
                                leafaux.annotations[annotation].text = r.text;
                                leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                                leafaux.annotations[annotation].saveAnnotationData(annotation,mapResults.get(target),100,r);
                            }else{
                                if(leafaux.annotations[annotation].splitresults == true){
                                    var z = 0;

                                    while(leafaux.annotations[annotation].alfaAnnot[z] != null){
                                        z++;
                                    }

                                    leafaux.annotations[annotation].alfaAnnot[z] = new ChromoHubAnnotation();
                                    leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
                                    leafaux.annotations[annotation].alfaAnnot[z].text = '';
                                    leafaux.annotations[annotation].alfaAnnot[z].defaultImg = annotations[annotation].defaultImg;
                                    leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,mapResults.get(target),100,r);
                                }
                            }
                        }

                        toComplete--;
                        onDone();
                    });
                }else{
                    var col = '';

                    if(annotations[annotation].color[0] != null){
                        col = annotations[annotation].color[0].color;
                    }

                    var r : HasAnnotationType = {hasAnnot : true, text : '', color : {color : col, used : true}, defImage : annotations[annotation].defaultImg};

                    var leafaux: ChromoHubTreeNode = geneMap.get(name);
                    leafaux.activeAnnotation[annotation] = true;

                    if(leafaux.annotations[annotation] == null){
                        leafaux.annotations[annotation] = new ChromoHubAnnotation();
                        leafaux.annotations[annotation].myleaf = leafaux;
                        leafaux.annotations[annotation].text = '';
                        leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                        leafaux.annotations[annotation].saveAnnotationData(annotation,mapResults.get(target),100,r);
                    }else{
                        if(leafaux.annotations[annotation].splitresults == true){
                            var z = 0;

                            while(leafaux.annotations[annotation].alfaAnnot[z]!=null){
                                z++;
                            }

                            leafaux.annotations[annotation].alfaAnnot[z] = new ChromoHubAnnotation();
                            leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
                            leafaux.annotations[annotation].alfaAnnot[z].text = '';
                            leafaux.annotations[annotation].alfaAnnot[z].defaultImg = annotations[annotation].defaultImg;
                            leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,mapResults.get(target),100,r);
                        }
                    }

                    toComplete--;
                    onDone();
                }
            }else{
                //in case of suboptions we have to be sure we remove the previous ones
                var leafaux: ChromoHubTreeNode = geneMap.get(name);
                leafaux.activeAnnotation[annotation] = false;
                leafaux.annotations[annotation] = null;

                toComplete--;
                onDone();
            }
        }
    }

    public function addAnnotData(annotData  : Array<Dynamic>, annotation: Int, option:Int, callback:Void->Void ){
        var i:Int;
        var mapResults: Map<String, Dynamic>;
        mapResults=new Map();
        var j=0;
        var target:String;
        for(i in 0 ... annotData.length){
            #if PHYLO5

            #else
            if(annotation==1){
                var aux=annotData[i].pmid_list;
                var aux2=aux.split(';');
                var max = aux2.length;

                var v = this.annotations[1].fromresults[1];

                if(max>v || this.annotations[1].fromresults[1]==null) this.annotations[1].fromresults[1]=max;
            }
            #end
            target=annotData[i].target_id+'_'+j;
            while (mapResults.exists(target)){
                j++;
                target=annotData[i].target_id+'_'+j;
            }
            j=0;
            mapResults.set(target, annotData[i]);
        }

        //creating target list to be processed
        var items=new Array();
        for(i in 0 ... this.rootNode.targets.length){
            items[i]=this.rootNode.targets[i];
        }
        processFamilyAnnotations(items, mapResults, annotation, option, callback);
    }


    /**
    * processFamilyAnnotations
    *
    * TODO: Fully document this function especially around Sefa's code to handle variants and indexes as I don't understand this
    **/
    public function processFamilyAnnotations(items:Array<String>,mapResults: Map<String, Dynamic>,annotation: Int, option:Int, cb:Void->Void){
        var toComplete = 0;

        // First we work out how many annotations we need to process
        // We do this so that it's easy for our onDone function to work out when all async callbacks have finished
        // We used to use a timer to wait for all the callbacks to finish but that's not necessary
        for(item in items){
            var name  = '';
            var hookCount = 0;

            var index = null;
            var variant = '1';
            var hasName = false;

            if(item.indexOf('(') != -1 || item.indexOf('-') != -1){
                hasName = true;

                var auxArray = item.split('');

                for(j in 0...auxArray.length){
                    if(auxArray[j] == '(' || auxArray[j] == '-'){
                        if(auxArray[j] == '(') {
                            index  = auxArray[j+1];
                            variant = '1';
                        }else if(auxArray[j] == '-') {
                            index = null;
                            variant = auxArray[j+1];
                        }

                        break;
                    }

                    name += auxArray[j];
                }
            }else{
                name = item;
            }

            var j = 0;
            var finished = false;
            var showAsSgc = false;

            while((mapResults.exists(name+'_'+j)==true)&&(finished==false)){
                var keepgoing=true;
                var res=mapResults.get(name+'_'+j);

                if (mapResults.get(name+'_'+ j).sgc == 1 || showAsSgc == true) {
                    res.sgc = 1;
                    showAsSgc = true;
                }

                if(hasName==true){
                    if(res.target_name_index!=index || res.variant_index!=variant){
                        keepgoing=false;
                    }
                }
                if(keepgoing==false){
                    j++;
                }else{
                    toComplete += 1;
                    if((annotations[annotation].hasClass!=null)&&(annotations[annotation].hasMethod!=null)){
                        j++;
                    }else{
                        finished=true;
                    }
                }
            }
        }


        var onDone = function(){
            if(toComplete  == 0){
                cb();
            }
        };

        if(toComplete == 0){
            cb();return;
        }

        for(item in items){
            var hookCount = 0;

            var index = null;
            var variant = '1';
            var hasName = false;
            var name = '';

            if(item.indexOf('(') != -1 || item.indexOf('-') != -1){
                hasName = true;

                var auxArray = item.split('');

                for(j in 0...auxArray.length){
                    if(auxArray[j] == '(' || auxArray[j] == '-'){
                        if(auxArray[j] == '(') {
                            index  = auxArray[j+1];
                            variant = '1';
                        }else if(auxArray[j] == '-') {
                            index = null;
                            variant = auxArray[j+1];
                        }

                        break;
                    }

                    name += auxArray[j];
                }
            }else{
                name = item;
            }

            var j = 0;
            var finished = false;
            var showAsSgc = false;

            while((mapResults.exists(name+'_'+j) == true) && (finished == false)){
                var keepGoing = true;
                var res = mapResults.get(name+'_'+j);

                if(mapResults.get(name+'_'+ j).sgc == 1 || showAsSgc == true) {
                    res.sgc = 1;
                    showAsSgc = true;
                }

                if(hasName==true){
                    if(res.target_name_index != index || res.variant_index != variant){
                        keepGoing=false;
                    }
                }

                if(keepGoing==false){
                    j++;
                }else{
                    if((annotations[annotation].hasClass != null)&&(annotations[annotation].hasMethod != null)){
                        var clazz = annotations[annotation].hasClass;
                        var method :Dynamic = annotations[annotation].hasMethod;

                        var _processAnnotation = function(r:HasAnnotationType){
                            if(r.hasAnnot){
                                var leafaux: ChromoHubTreeNode;
                                leafaux = this.rootNode.leafNameToNode.get(item);

                                leafaux.activeAnnotation[annotation] = true;
                                if(leafaux.annotations[annotation] == null){
                                    leafaux.annotations[annotation] = new ChromoHubAnnotation();
                                    leafaux.annotations[annotation].myleaf = leafaux;
                                    leafaux.annotations[annotation].text = r.text;
                                    leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                                    leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                                }else{
                                    if(annotations[annotation].splitresults == true){
                                        leafaux.annotations[annotation].splitresults = true;

                                        var z=0;

                                        while(leafaux.annotations[annotation].alfaAnnot[z] != null){
                                            z++;
                                        }

                                        leafaux.annotations[annotation].alfaAnnot[z] = new ChromoHubAnnotation();
                                        leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
                                        leafaux.annotations[annotation].alfaAnnot[z].text = '';
                                        leafaux.annotations[annotation].alfaAnnot[z].defaultImg = annotations[annotation].defaultImg;
                                        leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,res,option,r);
                                        if(leafaux.annotations[annotation].alfaAnnot[z].text == leafaux.annotations[annotation].text){
                                            leafaux.annotations[annotation].alfaAnnot[z] = null;
                                        }
                                    }else{
                                        if(leafaux.annotations[annotation].option != annotations[annotation].optionSelected[0]){
                                            leafaux.annotations[annotation] = new ChromoHubAnnotation();
                                            leafaux.annotations[annotation].myleaf = leafaux;
                                            leafaux.annotations[annotation].text = '';
                                            leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                                            leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                                        }
                                    }
                                }
                            }

                            toComplete--;
                            onDone();
                        };

                        if(Reflect.isFunction(method)){
                            method(name,res,option, annotations, item, _processAnnotation);
                        }else{
                            var hook : Dynamic = Reflect.field(Type.resolveClass(clazz), method);

                            hook(name,res,option, annotations, item, _processAnnotation);
                        }

                        j++;
                    }else {
                        finished=true;

                        var col = '';
                        if(annotations[annotation].color[0] != null){
                            col=annotations[annotation].color[0].color;
                        }

                        var r : HasAnnotationType = {hasAnnot : true, text : '',color : {color : col, used : true},defImage : annotations[annotation].defaultImg};

                        var leafaux: ChromoHubTreeNode = this.rootNode.leafNameToNode.get(item);
                        leafaux.activeAnnotation[annotation]=true;

                        if(leafaux.annotations[annotation] == null){
                            leafaux.annotations[annotation] = new ChromoHubAnnotation();
                            leafaux.annotations[annotation].myleaf = leafaux;
                            leafaux.annotations[annotation].text = '';
                            leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                            leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                        }else{
                            if(leafaux.annotations[annotation].splitresults == true){
                                var z=0;

                                while(leafaux.annotations[annotation].alfaAnnot[z]!=null){
                                    z++;
                                }

                                leafaux.annotations[annotation].alfaAnnot[z] = new ChromoHubAnnotation();
                                leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
                                leafaux.annotations[annotation].alfaAnnot[z].text = '';
                                leafaux.annotations[annotation].alfaAnnot[z].defaultImg = annotations[annotation].defaultImg;
                                leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,res,option,r);

                            }else{
                                if(leafaux.annotations[annotation].option != annotations[annotation].optionSelected[0]){
                                    leafaux.annotations[annotation] = new ChromoHubAnnotation();
                                    leafaux.annotations[annotation].myleaf = leafaux;
                                    leafaux.annotations[annotation].text = '';
                                    leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                                    leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                                }
                            }
                        }

                        toComplete--;
                        onDone();
                    }
                }
            }
        }
    }



    public function zoomIn(activeAnnotation:Dynamic){
        if(standaloneMode){
            var container = getApplication().getSingleAppContainer();
            closeAnnotWindows();
            container.hideHelpingDiv();
        }

        if(this.canvas!=null){
            this.canvas.parent.removeChild( this.canvas.canvas);//otherwise, we'll get two trees
        }

        this.dom = theComponent.down('component').getEl().dom;

        var parentWidth : Int = this.dom.clientWidth;
        var parentHeight : Int = this.dom.clientHeight;
        this.canvas = new ChromoHubCanvasRenderer(this,parentWidth, parentHeight, this.dom, this.rootNode);

        this.canvas.cx=Math.round(parentWidth/2);
        this.canvas.cy=Math.round(parentHeight/2);
        if(this.scale<=2.0)this.scale=this.scale+0.2;
        this.canvas.zoomIn(activeAnnotation,annotations,scale);
        newposition(0,0);
    }

    public function adviseUser(b:Bool){
        userMessage=b;
    }
    public function adviseDomainUser(b:Bool){
        userDomainMessage=b;
    }

    public function zoomOut(activeAnnotation:Dynamic){
        if(standaloneMode){
            var container = getApplication().getSingleAppContainer();
            container.hideHelpingDiv();
            closeAnnotWindows();
        }

        if(this.canvas!=null){
            this.canvas.parent.removeChild( this.canvas.canvas);//otherwise, we'll get two trees
        }
        this.dom = theComponent.down('component').getEl().dom;

        var parentWidth : Int = this.dom.clientWidth;
        var parentHeight : Int = this.dom.clientHeight;
        this.canvas = new ChromoHubCanvasRenderer(this,parentWidth, parentHeight, this.dom, this.rootNode);

        this.canvas.cx=Math.round(parentWidth/2);
        this.canvas.cy=Math.round(parentHeight/2);
        if(this.scale>=0.6)this.scale=this.scale-0.2;
        this.canvas.zoomOut(activeAnnotation, annotations,this.scale);
        newposition(0,0);
    }

    override public function setTitle(title : String){
        theComponent.setTitle(title);
    }

    override public function getComponent() : Dynamic {
        return theComponent;
    }

    override public function getRawComponent() : Dynamic {
        return theComponent;
    }

    override public function onFocus(){
        super.onFocus();

        if(standaloneMode){
            chromohubOnFocus();
        }else{
            treeViewInterface();
        }
    }

    public function addCanvasButton(button : Dynamic){
        if(standaloneMode){
            getApplication().getSingleAppContainer().addComponentToCentralPanel(button);
        }else{
            getApplication().getToolBar().add(button);
        }
    }

    public function chromohubOnFocus(){
        //the jsonFile hasn't been downloaded = abort
        if(jsonFile != null){
            var res=checkAnnotationJSonData();
            if (res==false){
                WorkspaceApplication.getApplication().showMessage('Alert','Annotations JSon file is not correct.');
                return;
            }else {
                fillAnnotationwithJSonData();
            }

            fillTipswithJSonData();
        }


        var obj : ChromoHubWorkspaceObject = getActiveObject(ChromoHubWorkspaceObject);
        var container = getApplication().getSingleAppContainer();

        if(container == null){
            // too early
            return;
        }

        getApplication().hideMiddleSouthPanel();

        if(standaloneMode){
            currentView=0;//landing page
        }else{
            currentView=1;
        }

        //we create all panel/toolbar that we'll need and hide them
        container.createControlToolBar();
        container.addElemToControlToolBar({
            iconCls :'x-btn-export-single',
            handler : function(){
               // exportXls();
            },
            tooltip : {dismissDelay: 10000, text: 'Export table as xls'}
        });
        //container.createMessageWindow(this);
        container.createMessageDomainWindow(this);
        container.hideControlToolBar();
        container.createEditToolBar();
        container.addElemToEditToolBar({
            iconCls :'x-btn-undo-single',
            handler : function(){
                if(undolist.length>0) moveNode(undolist[undolist.length-1].data,true, true);
            },
            tooltip : {dismissDelay: 10000, text: 'Undo last action'}
        });

        #if !UBIHUB
        container.addElemToEditToolBar({
            iconCls :'x-btn-save-single',
            handler : function(){

                if(recovered==true){
                    WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookDelTree',[{'domain':this.subtreeName,'family':this.treeName}], null, false,function(db_results, error){
                        if(error == null) {
                            if(undolist.length>0){
                                var blocks = [];
                                var nodelist:Map<Int,Bool>;
                                nodelist=new Map();
                                var k=0;
                                while(undolist.length>0){
                                    k=undolist.length-1;
                                    var auxpop=undolist.pop();
                                    updatedlist[k]=auxpop;
                                    k++;
                                    var d=auxpop.data;
                                    if(nodelist.exists(d.nodeId)==false){
                                        //nodeId, familyName, domainbase, nodeX, nodeY, angle
                                        var s={'nodeId':d.nodeId,'family':this.subtreeName,'domain':this.treeType,'nodeX':auxpop.x, 'nodeY':auxpop.y, 'angle':auxpop.angle, 'clock':auxpop.clock};
                                        blocks.push(s);
                                        nodelist.set(d.nodeId,true);
                                    }
                                }

                                updatedlist=new Array();
                                WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookUpTree',blocks, null, false,function(db_results, error){
                                    if(error == null) {
                                        //undolist=new Array();//once you have saved the tree the undo arrya gets empty

                                        getApplication().showMessage('Message','Your changes have been saved.');
                                        undolist=new Array();
                                        updatedlist=new Array();
                                        recovered=false;
                                        editmode=false;
                                        container.removeComponentFromEditToolBar('recover');
                                        container.hideEditToolBar();
                                        undolist=new Array();

                                        if(viewOptionsActive==false){
                                            viewOptionsActive=true;

                                            container.showOptionsToolBar();
                                        }
                                        else{

                                            viewOptionsActive=false;
                                            container.hideOptionsToolBar();
                                            container.hideSubMenuToolBar();
                                            if (controlToolsActive == true) container.showControlToolBar();
                                        }
                                        newposition(0,0);
                                    }
                                    else {
                                        WorkspaceApplication.getApplication().debug(error);
                                    }
                                });
                            }
                            else{
                                getApplication().showMessage('Message','Your changes have been saved.');
                                undolist=new Array();
                                recovered=false;
                                editmode=false;
                                container.removeComponentFromEditToolBar('recover');
                                container.hideEditToolBar();
                                undolist=new Array();

                                updatedlist=new Array();
                                if(viewOptionsActive==false){
                                    viewOptionsActive=true;

                                    container.showOptionsToolBar();
                                }
                                else{

                                    viewOptionsActive=false;
                                    container.hideOptionsToolBar();
                                    container.hideSubMenuToolBar();
                                    if (controlToolsActive == true) container.showControlToolBar();
                                }
                                newposition(0,0);
                            }
                        }
                        else {
                            WorkspaceApplication.getApplication().debug(error);
                        }
                    });
                }
                else{
                    if(undolist.length>0){
                        var blocks = [];
                        var nodelist:Map<Int,Bool>;
                        nodelist=new Map();
                        var k=0;
                        while(undolist.length>0){
                            k=undolist.length-1;
                            var auxpop=undolist.pop();
                            updatedlist[k]=auxpop;
                            k++;
                            var d=auxpop.data;
                            if(nodelist.exists(d.nodeId)==false){
                                //nodeId, familyName, domainbase, nodeX, nodeY, angle
                                var s={'nodeId':d.nodeId,'family':this.treeName,'domain':this.treeType,'nodeX':auxpop.x, 'nodeY':auxpop.y, 'angle':auxpop.angle, 'clock':auxpop.clock};
                                blocks.push(s);
                                nodelist.set(d.nodeId,true);
                            }
                        }

                        WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookUpTree',blocks, null, false,function(db_results, error){
                            if(error == null) {
                                //undolist=new Array();//once you have saved the tree the undo arrya gets empty

                                getApplication().showMessage('Message','Your changes have been saved.');
                                undolist=new Array();
                                recovered=false;
                                editmode=false;
                                container.hideEditToolBar();
                                undolist=new Array();


                                if(viewOptionsActive==false){
                                    viewOptionsActive=true;

                                    container.showOptionsToolBar();
                                }
                                else{

                                    viewOptionsActive=false;
                                    container.hideOptionsToolBar();
                                    container.hideSubMenuToolBar();
                                    container.hideExportSubMenu();
                                    container.hideHelpingDiv();
                                    if (controlToolsActive == true) container.showControlToolBar();
                                }
                                newposition(0,0);
                            }
                            else {
                                WorkspaceApplication.getApplication().debug(error);
                            }
                        });
                    }
                }
            },
            tooltip : {dismissDelay: 10000, text: 'Save Tree'}
        });
        #end

        editmode=false;
        container.hideEditToolBar();
        undolist=new Array();

        container.createOptionsToolBar();
        container.hideOptionsToolBar();
        container.createSubMenuToolBar();
        container.createHelpingDiv();
        container.createExportSubMenu(this);
        container.hideSubMenuToolBar();
        container.hideExportSubMenu();
        container.hideHelpingDiv();
        container.createPopUpWindow();
        container.hidePopUpWindow();

        // we create the Target Class Selection Panel
        var mapFam=new Map();

        createBtnsForLandingPage(true,mapFam);
        createTargetCentralPanel(); //create centralTargetPanel with ALL buttons

        container.addComponentToCentralPanel(centralTargetPanel);

        //we get the main tool bar (already created in Saturn) and add the buttons we need
        var modeToolBar = container.getModeToolBar();
        addBtnsToMainToolBar(false);

        //add this with cookies
        var cookies = untyped __js__('Cookies');
        var cookie = cookies.getJSON('tipday');

        #if !UBIHUB
        if(cookie == null) showTipOfTheDay();
        #end
    }

    private function refreshOptionsToolBar(active:Bool)  {
        var container=getApplication().getSingleAppContainer();
        container.updateOptionsToolBar(active);
    }

    public function setAdjustmentColour(colour :String){
        this.currentAdjustmentColour = colour;
    }

    public function enableColourAdjustment(enable : Bool){
        enableColourAdjust = enable;
    }

    public function setLineWidth(width : Float){
        _setLineWidth(rootNode,width);

        newposition(0,0);
    }

    public function _setLineWidth(node : ChromoHubTreeNode, width : Float){
        node.lineWidth = width;

        for(i in 0...node.children.length){
            _setLineWidth(node.children[i], width);
        }
    }

    public function setStraightLines(){
        setLineType(LineMode.STRAIGHT);
    }

    public function setBezierLines(){
        setLineType(LineMode.BEZIER);
    }

    public function setLineType(lineMode: LineMode){
        _setLineType(rootNode,lineMode);

        newposition(0,0);

    }

    public function _setLineType(node : ChromoHubTreeNode,lineMode: LineMode){
        node.lineMode = lineMode;

        for(i in 0...node.children.length){
            _setLineType(node.children[i], lineMode);
        }
    }

    private function addControlBtnsToCentralPanel(){
        if(standaloneMode){
            var text:String;
            if(this.treeType=='domain'){
                text=' tree based on alignment of the '+this.treeName+' domain';
            }else{
                text=' tree based on alignment of full-length proteins';
            }
            if(this.treeName!=null ) text=this.treeName+text;

            var container=getApplication().getSingleAppContainer();
            container.addComponentToCentralPanel( {
                xtype: 'label',
                text: text ,
                cls:'targetclass-treetitle',
                top:33,
                left:10
            });

            container.addComponentToCentralPanel({
                cls :'x-btn-close-options',
                xtype: 'button',
                itemId: 'closeAnnotmenu',
                handler: function(){
                    var elem=js.Browser.document.getElementById('optionToolBarId');
                    menuScroll=elem.scrollTop;
                    if(viewOptionsActive==false){
                        viewOptionsActive=true;
                        container.showOptionsToolBar();
                    }
                    else{
                        viewOptionsActive=false;
                        container.hideOptionsToolBar();
                        container.hideSubMenuToolBar();
                        if (controlToolsActive == true) container.showControlToolBar();
                    }
                    refreshOptionsToolBar(viewOptionsActive);
                    newposition(0,0);
                    var elem=js.Browser.document.getElementById('optionToolBarId');
                    elem.scrollTop=menuScroll;
                },
                listeners:{
                    mouseover:
                    function(e){
                        container.hideExportSubMenu();
                        container.hideHelpingDiv();
                    }
                },
                //tooltip: {dismissDelay: 10000, text: 'Close Options Tab'}
            });

            addCanvasButton({
                cls :'x-btn-export-single',
                xtype: 'button',
                top:40,
                listeners:{
                    mouseover:
                    function(e){

                        var ev : Dynamic;
                        var d : Dynamic = js.Browser.window;
                        ev = d.event;
                        var xposition: Dynamic = ev.pageX;

                        getApplication().getSingleAppContainer().showExportSubMenu(xposition);
                    }
                }
            });


            var items :Array<Dynamic> = [];

            items.push({
                text:'Edit Mode',
                hidden : false,
                handler: function(){
                    if(editmode){
                        editmode = false;
                        getApplication().getSingleAppContainer().hideEditToolBar();
                    }else{
                        editmode = true;

                        getApplication().getSingleAppContainer().showEditToolBar();
                    }

                }
            });

            items.push({
                text:'Straight Lines',
                hidden : false,
                handler: function(){
                    setStraightLines();
                }
            });

            items.push({
                text:'Bezier Lines',
                hidden : false,
                handler: function(){
                    setBezierLines();
                }
            });

            var colourPickerItems : Array<Dynamic> = [];
            colourPickerItems.push( {
                xtype:'component',
                autoEl:{
                    tag:'label',
                    html:'Choose Colour',
                    'for':'colour_picker'
                }
            });

            colourPickerItems.push({
                xtype:'component',
                autoEl: {
                    html: '<input name="colour_picker" id="colour_picker" type="color"/>'
                },
                listeners:{
                    el:{
                        delegate: 'input',
                        change:function(){
                            var colourField : Dynamic = js.Browser.document.getElementById('colour_picker');

                            setAdjustmentColour(colourField.value);
                        }
                    }
                }
            });

            items.push({
                text:'Adjust Colours',
                hidden : false,
                handler: function(){
                    var window = Ext.create('Ext.window.Window', {
                        listeners: {
                            afterrender: function(){

                            }
                        },
                        items:colourPickerItems
                    });

                    window.show();
                },
                listeners:{
                    click:function(){
                        enableColourAdjustment(true);
                    }
                }
            });

            items.push({
                text:'Set line width',
                hidden : false,
                handler: function(){
                    Ext.Msg.prompt('Enter line width', 'Enter line width', function(btn, text){
                        if(btn == 'ok'){
                            setLineWidth(Std.parseFloat(text));
                        }
                    });
                },
                listeners:{
                    click:function(){
                        enableColourAdjustment(true);
                    }
                }
            });

            addCanvasButton({
                cls :'x-btn-export-single-fake',
                xtype: 'button',
                top:40,
                menu: Ext.create('Ext.menu.Menu',{
                    items: items
                }),
            });

            addCanvasButton({
                cls :'x-btn-magplus-single',
                xtype: 'button',
                top:40,
                handler: function(){
                    zoomIn(this.activeAnnotation);
                },
                listeners:{
                    mouseover:
                    function(e){
                        getApplication().getSingleAppContainer().hideExportSubMenu();
                        getApplication().getSingleAppContainer().hideHelpingDiv();
                    }
                },
                tooltip: {dismissDelay: 10000, text: 'Zoom in on tree'}
            });

            addCanvasButton({
                cls : 'x-btn-magminus-single' ,
                xtype: 'button',
                top:40,
                handler: function(){
                    zoomOut(this.activeAnnotation);
                },
                listeners:{
                    mouseover:
                    function(e){
                        getApplication().getSingleAppContainer().hideExportSubMenu();
                        getApplication().getSingleAppContainer().hideHelpingDiv();
                    }
                },
                tooltip: {dismissDelay: 10000, text: 'Zoom out of tree'}
            });
        }else{
            addCanvasButton({
                iconCls :'x-btn-export',
                text: 'Export SVG',
                handler: function(){
                    exportSVG();
                },
                tooltip: {dismissDelay: 10000, text: 'Export tree as SVG (open in Illustrator or Inkscape)'}
            });

            addCanvasButton({
                iconCls :'x-btn-export',
                text: 'Export PNG',
                handler: function(){
                    exportPNG();
                },
                tooltip: {dismissDelay: 10000, text: 'Export tree as PNG'}
            });


            addCanvasButton({
                iconCls :'x-btn-copy',
                text: 'Update',
                handler: function(){
                    updateAlignment();
                },
                tooltip: {dismissDelay: 10000, text: 'Update tree with current sequences'}
            });

            addCanvasButton({
                iconCls :'x-btn-copy',
                text: 'Import Protein',
                handler: function(){
                    addAllProteinSequencesFromWorkspace();
                },
                tooltip: {dismissDelay: 10000, text: 'Import all protein sequences from the workspace (click update to update tree)'}
            });

            addCanvasButton({
                iconCls :'x-btn-copy',
                text: 'Import DNA',
                handler: function(){
                    addAllDNASequencesFromWorkspace();
                },
                tooltip: {dismissDelay: 10000, text: 'Import all DNA sequences from the workspace (click update to update tree)'}
            });

            addCanvasButton({
                cls:'x-btn-magplus',
                xtype: 'button',
                handler: function(){
                    zoomIn(this.activeAnnotation);
                },
                tooltip: {dismissDelay: 10000, text: 'Zoom in on tree'}
            });

            addCanvasButton({
                cls:'x-btn-magminus',
                xtype: 'button',
                handler: function(){
                    zoomOut(this.activeAnnotation);
                },
                tooltip: {dismissDelay: 10000, text: 'Zoom out of tree'}
            });
        }

        if(standaloneMode){
            var container=getApplication().getSingleAppContainer();

            container.addComponentToCentralPanel({
                cls : 'x-btn-center-single' ,
                xtype: 'button',
                top:40,
                handler: function(){
                    var parentWidth : Int = this.dom.clientWidth;
                    var parentHeight : Int = this.dom.clientHeight;
                    this.centrex=Math.round(parentWidth/2);
                    this.centrey=Math.round(parentHeight/2);
                    centerCanvas();
                    //newposition(0,0);
                },
                listeners:{
                    mouseover:
                    function(e){
                        getApplication().getSingleAppContainer().hideExportSubMenu();
                        getApplication().getSingleAppContainer().hideHelpingDiv();
                    }
                },
                tooltip: {dismissDelay: 10000, text: 'Centre Tree'}
            });

            container.addComponentToCentralPanel({
                cls : 'x-btn-highlight-single' ,
                xtype: 'button',
                top:40,
                handler: function(){

                        var container=getApplication().getSingleAppContainer();

                        closeAnnotWindows();
    //garsot
                    if(this.rootNode.targets.length!=0){
                        var div :Array<Dynamic>;
                        div=new Array();
                        var i=0;
                        var title=this.rootNode.targets.length;
                        for(i in 0 ... this.rootNode.targets.length){
                            div[i]={
                                xtype: "checkboxfield",
                                boxLabel: this.rootNode.targets[i],
                                labelSeparator : "",
                                name: "gene",
                                cls: "highlightgene-checkbox",
                                inputValue: this.rootNode.targets[i],
                                id:  "hight-"+i
                            };
                        }
                        var container=getApplication().getSingleAppContainer();
                        var mydom=js.Browser.document.getElementById('id-centralPanel');
                        var parentWidth : Int = mydom.clientWidth;
                        var parentHeight : Int = mydom.clientHeight;
                        var cx=Math.round(parentWidth/2)-350;
                        var cy=Math.round(parentHeight/5);

                        container.showHighlightWindow(div,cx,cy,title,this);

                    }
                },
                tooltip: {dismissDelay: 10000, text: 'Highlight gene in tree'}
            });
        }
    }


    public function updateAlignment(){
        var self : ChromoHubViewer = this;

        var objectIds = getState().getReferences('Sequences');

        var strBuf : StringBuf = new StringBuf();

        for (objectId in objectIds) {
            var w0 : WorkspaceObject<Dynamic> = getWorkspace().getObject(objectId);

            if ( Std.is(w0, DNAWorkspaceObject) ) {
                var object : DNAWorkspaceObject<DNA> = getWorkspace().getObjectSafely(objectId, DNAWorkspaceObject);
                strBuf.add('>'+w0.getName()+'\n'+object.getObject().getSequence()+'\n');
            }else if ( Std.is(w0, ProteinWorkspaceObject) ) {
                var object : ProteinWorkspaceObject = cast(w0, ProteinWorkspaceObject);
                strBuf.add('>'+w0.getName()+'\n'+object.getObject().getSequence()+'\n');
            }else{
                var d: Dynamic = w0;
                strBuf.add('>'+d.getName()+'\n'+d.getSequence()+'\n');
            }
        }

        BioinformaticsServicesClient.getClient().sendPhyloReportRequest(strBuf.toString(), function(response, error){
            if(error == null){
                var phyloReport = response.json.phyloReport;

                var location : js.html.Location = js.Browser.window.location;

                var dstURL = location.protocol+'//'+location.hostname+':'+location.port+'/'+phyloReport;

                Ext.Ajax.request({
                    url: dstURL,
                    success: function(response, opts) {
                        var obj = response.responseText;

                        self.setTreeFromNewickStr(obj);
                    },
                    failure: function(response, opts) {
                        //response.status
                    }
                });
            }else{
                getApplication().showMessage('Tree generation error', error);
            }
        });
    }

    public function addAllDNASequencesFromWorkspace() {
        registerAllFromWorkspace(DNAWorkspaceObject, 'Sequences');
    }

    public function addAllProteinSequencesFromWorkspace() {
        registerAllFromWorkspace(ProteinWorkspaceObject, 'Sequences');
    }

    private function treeViewInterface():Bool{
        var container=getApplication().getSingleAppContainer();
        if(!standaloneMode || currentView!=1){
            if(standaloneMode && treeName=='' && newickStr==''){
                if(currentView==0){//landing page
                    //if it's the first time and no family tree has been selected yet
                    // or the user has been working just with genes
                    getApplication().showMessage('Alert','Please select a family domain');
                }
                else if(currentView==2){ //annotations table
                    // The user has listed her own genes, and want to generate the tree
                    WorkspaceApplication.getApplication().showMessage('Alert','This functionality is not available. Please select a family domain from Home page.');
                }
                return false;
            }else{
                //the user wants to go back to the tree view he was seeing before
                //or see the one for the family tree selected
                currentView=1;

                if(standaloneMode){

                    //clear Central Panel

                    if(this.canvas!=null){
                        this.canvas.parent.removeChild( this.canvas.canvas);//otherwise, we'll get two trees
                        this.canvas=null;
                    }
                    container.setCentralComponent(theComponent);
                    theComponent.doLayout();

                    if(container.getControlToolBar!=null){
                        container.hideControlToolBar();
                    }
                    viewOptionsActive=true;
                    var modeToolBar = container.getModeToolBar();
                    container.clearModeToolBar();
                    addBtnsToMainToolBar(false);

                    if(container.getOptionsToolBar!=null){
                        //container.createOptionsToolBar();
                        //this.activeAnnotation=new Array();//improve it

                        createViewOptions();
                        container.clearOptionsToolBar();
                        container.addElemToOptionsToolBar(viewOptions);
                        container.optionsToolBar.doLayout();
                        container.showOptionsToolBar();
                    }
                    container.legendPanel=null;
                    container.createLegendPanel();
                    var i:Int;
                    var needToExpandLegend=false;
                    for (i in 0...activeAnnotation.length){
                        if (activeAnnotation[i]==true){
                            needToExpandLegend=true;
                            container.addImageToLegend(annotations[i].legend, i);
                        }
                    }
                    if( needToExpandLegend==true){
                        container.legendPanel.expand();
                    }
                }

                addControlBtnsToCentralPanel();

                if(standaloneMode){


                    this.theComponent.doLayout();
                }

                return true;
            }
        }
        else if(editmode==true) return true;
        else return false;
    }

    public function renderTable(){
        if(!standaloneMode){
            return;
        }

        var container=getApplication().getSingleAppContainer();
        while(undolist.length>0){
            moveNode(null,true, true);//if we are undoing actions, the undolist is doing pop so increasing its length
        }
        editmode=false;
        //container.viewClose(true);
        container.hideEditToolBar();
        undolist=new Array();
        currentView=2;

        if(this.canvas!=null){
            this.canvas.parent.removeChild( this.canvas.canvas);//otherwise, we'll get two trees
            this.canvas=null;
        }
        container.setCentralComponent(theComponent);
        theComponent.doLayout();

        container.hideSubMenuToolBar();
        container.hideOptionsToolBar();

        var modeToolBar = container.getModeToolBar();
        container.clearModeToolBar();
        addBtnsToMainToolBar(true);

        //THe export button doesn't work, so we don't need to show that  toolbar yet
        //container.showControlToolBar();

        generateAnnotTable();
    }

    private function tableViewFunction(){

        var container = getApplication().getSingleAppContainer();
        container.hideExportSubMenu();
        container.hideHelpingDiv();

        closeAnnotWindows();

        if(currentView!=2){

            if( this.annotations[1]!=null && this.annotations[1].fromresults!=null) this.annotations[1].fromresults[1]=0;
            if(treeName==''){
                if(searchedGenes.length==0) WorkspaceApplication.getApplication().showMessage('Alert','Use the search box on your righ to add genes.');
                else{
                    renderTable();
                }
            }
            else{
                var keepgoing=false;
                if(editmode==true){
                    if(undolist.length>0){
                        WorkspaceApplication.getApplication().userPrompt('Question', 'You are going to lose your changes. Do you want to continue?', renderTable);
                    }
                    else {
                        keepgoing=true;
                    }
                } else {
                    keepgoing=true;
                }

                if(keepgoing==true){
                   // WorkspaceApplication.getApplication().showMessage('Alert','This process might take some time. Please wait.');
                    container.showProgressBar();
                    renderTable();
                    //container.hideProgressBar();
                }
            }
        }else{

            generateAnnotTable();
        }
    }

    public function generateAnnotTable(){
        if(!standaloneMode){
            return;
        }

        currentView=2;
        var type='';
        if(treeName=='' || newickStr==''){
            //only genes
            //the user has a list of searched genes
            type='genes';
        }else{
            //the user has selected a family tree
           //only familytree
            type='family';
        }
        var d : Array<Dynamic>;
        d=new Array();
        var ti=0;
        fillInDataInAnnotTable(type,function(d, error){
            if(error != null){
                Util.debug('An error has occurred');
            }

            if(d!=null){
                tableAnnot = new Table();

                tableAnnot.setFixedRowHeight(120);
                tableAnnot.setData(d);
                var title="Annotation Table";
                if(treeName!=''){
                    title=title+" for "+treeName;
                }
                tableAnnot.setTitle(title);

                tableAnnot.name = 'Annotations Table';
                baseTable = new BaseTable(null, null, 'Annotations Table',null, false, false);
                baseTable.reconfigure(tableAnnot.tableDefinition);
                baseTable.addListener(function(event : Dynamic){
                    closeAnnotWindows();
                });

                var tt=baseTable.getComponent();
                tt.addCls('x-tableAnnot');

                var container=getApplication().getSingleAppContainer();

                container.setCentralComponent(theComponent);
                container.addComponentToCentralPanel(tt);
                this.theComponent.doLayout();
                container.hideProgressBar();
            }
        });

    }

    private function rebuildBtns(results:Dynamic){
        var container = getApplication().getSingleAppContainer();
        container.setCentralComponent(theComponent);
        theComponent.doLayout();

        var mapFam:Map<String,Bool>;
        mapFam=new Map();
        var i:Int;
        for(i in 0...results.length){
            if (mapFam.exists(results[i].family)==false){
                mapFam.set(results[i].family, true);
            }
        }
        createBtnsForLandingPage(false,mapFam);
        createTargetCentralPanel();

        container.addComponentToCentralPanel(centralTargetPanel);
        var centralPanel=container.getCentralPanel();
        centralPanel.doLayout();

    }

    private function renderHome(){
        if(!standaloneMode){
            return;
        }

        var container=getApplication().getSingleAppContainer();
        container.clearCentralPanel();
        container.hideHelpingDiv();

        var centralPanel=container.getCentralPanel();
        centralPanel.doLayout();

        while(undolist.length>0){
            moveNode(null,true, true);//if we are undoing actions, the undolist is doing pop so increasing its length
        }

        editmode=false;
        container.hideEditToolBar();
        undolist=new Array();

        currentView=0;

        var mapFam:Map<String,Bool>;
        mapFam=new Map();
        createBtnsForLandingPage(false,mapFam);


        var itemslist = centralTargetPanel.items;
        itemslist.each(function(item,index,length){
            centralTargetPanel.remove(item, false);
        });
        centralTargetPanel.doLayout();
        treeTypeSelection.doLayout();
        createTargetCentralPanel();
        centralPanel.doLayout();

        if(this.canvas!=null){
            this.canvas.parent.removeChild( this.canvas.canvas);//otherwise, we'll get two trees
            this.canvas=null;
        }
        container.setCentralComponent(theComponent);
        theComponent.doLayout();

        //create centralTargetPanel with ALL buttons
        //we need to remove all existing bars

        container.hideExportSubMenu();
        if(container.getOptionsToolBar!=null){
            container.hideOptionsToolBar();
        }
        /*if(container.getLegendPanel!=null){
            container.hideLegendPanel();
        }*/
        if(container.getSubMenuToolBar!=null){
            container.hideSubMenuToolBar();
        }
        if(container.getControlToolBar!=null){
            container.hideControlToolBar();
        }

        var modeToolBar = container.getModeToolBar();
        container.clearModeToolBar();
        addBtnsToMainToolBar(false);

        container.addComponentToCentralPanel(centralTargetPanel);

        centralPanel.doLayout();
       /* if(tipOfDay==true){
            showTipOfTheDay();
        }*/
    }

    private function showTipOfTheDay(){
        if(tips == null || tips.length ==0){
            return;
        }

        var container=getApplication().getSingleAppContainer();

        var mydom :Dynamic;
        mydom=js.Browser.document.childNodes[0];
        var top, left, width, height:Int;
        var w=mydom.clientWidth;
        width=Std.int(w*0.6);
        left=Std.int(w*0.2);
        var h= mydom.clientHeight;
        height=Std.int(h*0.9);
        top=Std.int(h*0.15);
        if(container.getTipWindow()==null){
            var title =tips[tipActive].title;
            var html =tips[tipActive].html;
            var text="<h2>"+title+"</h2>"+html;
            container.createTipWindow(this, top, left, width, height, text);
        }else{
            container.showTipWindow();
        }


    }

    private function addBtnsToMainToolBar(searchField:Bool){
        if(!standaloneMode){
            return;
        }

        var container=getApplication().getSingleAppContainer();

        container.addElemToModeToolBar({
            cls     :   if(currentView==0)'btn-selected' else '',
            xtype   :   'button',
            text    :   'Home',
            handler :   function(){
                if(currentView!=0){
                    var container = getApplication().getSingleAppContainer();
                    container.hideExportSubMenu();
                    container.hideHelpingDiv();

                    closeAnnotWindows();
                    if(annotations[1]!=null && annotations[1].fromresults!=null) annotations[1].fromresults[1]=0;
                    var keepgoing=false;
                    if(editmode==true){
                        if(undolist.length>0){
                            WorkspaceApplication.getApplication().userPrompt('Question', 'You are going to lose your changes. Do you want to continue?', renderHome);
                        }else{
                            keepgoing=true;
                        }
                    }else{
                        keepgoing=true;
                    }

                    if(keepgoing==true){
                        renderHome();
                    }

                }
            },
            tooltip: {dismissDelay: 10000, text: 'Protein Family Selection'}
        });

        container.addElemToModeToolBar({
            cls     :   if(currentView==1)'btn-selected' else '',
            xtype   :   'button',
            text    :   'Tree View',
            handler :   function(){
                if(treeName==''){
                    if(currentView==0){//landing page
                        //if it's the first time and no family tree has been selected yet
                        // or the user has been working just with genes
                        getApplication().showMessage('Alert','Please select a family domain');
                    }
                    else if(currentView==2){ //annotations table
                        // The user has listed her own genes, and want to generate the tree
                        WorkspaceApplication.getApplication().showMessage('Alert','This functionality is not available. Please select a family domain from Home page.');
                    }
                }else{
                    menuScroll=0;
                    if( this.annotations[1]!=null && this.annotations[1].fromresults!=null) this.annotations[1].fromresults[1]=0;
                    showTree(newickStr);
                    var parentWidth : Int = this.dom.clientWidth;
                    var parentHeight : Int = this.dom.clientHeight;
                    this.centrex=Math.round(parentWidth/2);
                    this.centrey=Math.round(parentHeight/2);
                    centerCanvas();
                    var elem=js.Browser.document.getElementById('optionToolBarId');
                    elem.scrollTop=menuScroll;
                }
            },
            tooltip :   {dismissDelay: 10000, text: 'Phylogenetic Viewer'}
        });

        #if !UBIHUB
        container.addElemToModeToolBar({
            cls     :   if(currentView==2)'btn-selected' else '',
            xtype   :   'button',
            text    :   'Annotation Table',
            handler :   tableViewFunction,
            tooltip :   {dismissDelay: 10000, text: 'Annotation List'}
        });
        #end

        if((searchField==true)&&(treeName=='')){
            container.addElemToModeToolBar({
                xtype   :   'label',
                text    :   'Add Genes',
                cls     :   'addGene-menu-title',
                handler :   function(){

                },
                tooltip: {text:'',dismissDelay:0},
                iconCls:''
            });

            var searchFieldObj=getApplication().getGlobalSearchFieldObj();
            searchFieldObj.setValue('');
            container.addElemToModeToolBar(searchFieldObj);
        }

        container.addElemToModeToolBar({
        cls     :   if(currentView==3)'btn-selected' else '',
        xtype   :   'button',
        text    :   'Help',
        handler :   function(){
            var keepgoing=false;
            var container = getApplication().getSingleAppContainer();
            container.hideHelpingDiv();
            if(editmode==true){
                if(undolist.length>0){
                    WorkspaceApplication.getApplication().userPrompt('Question', 'You are going to lose your changes. Do you want to continue?', function(){
                        keepgoing=false;
                        while(undolist.length>0){
                            moveNode(null,true, true);//if we are undoing actions, the undolist is doing pop so increasing its length
                        }
                        editmode=false;
                        container.viewClose(true);
                        container.hideEditToolBar();
                        undolist=new Array();

                        if(viewOptionsActive==false){
                            viewOptionsActive=true;

                            container.showOptionsToolBar();
                        }

                        newposition(0,0);
                    });
                }else keepgoing=true;
            }else keepgoing=true;

            if(keepgoing==true){

                while(undolist.length>0){
                    moveNode(null,true, true);//if we are undoing actions, the undolist is doing pop so increasing its length
                }
                editmode=false;
                //container.viewClose(true);
                container.hideEditToolBar();
                undolist=new Array();

                if(viewOptionsActive==false){
                    viewOptionsActive=true;

                    container.showOptionsToolBar();
                }
                //newposition(0,0);
                showTipOfTheDay();
            }
        },
        tooltip: {dismissDelay: 10000, text: 'Help'}
        });
    }

    public function redrawTable(){
        var type='';
        if(treeName=='' || newickStr==''){
            //only genes
            //the user has a list of searched genes
            type='genes';
        }else{
            //the user has selected a family tree
            //only familytree
            type='family';
        }

        var leaves;

        if(type=='family'){
            leaves= rootNode.targets;
        }else{
            leaves=this.searchedGenes;
        }

        var d=dataforTable(annotations, leaves);

        tableAnnot = new Table();

        tableAnnot.setFixedRowHeight(120);
        tableAnnot.setData(d);
        var title="Annotation Table";
        if(treeName!=''){
            title=title+" for "+treeName;
        }
        tableAnnot.setTitle(title);

        tableAnnot.name = 'Annotations Table';
        baseTable = new BaseTable(null, null, 'Annotations Table',null, false, false);
        baseTable.reconfigure(tableAnnot.tableDefinition);
        baseTable.addListener(function(event : Dynamic){
            closeAnnotWindows();
        });

        var tt=baseTable.getComponent();
        tt.addCls('x-tableAnnot');

        var container=getApplication().getSingleAppContainer();

        container.setCentralComponent(theComponent);
        container.addComponentToCentralPanel(tt);
        this.theComponent.doLayout();
        container.hideProgressBar();
    }

    private function  fillInDataInAnnotTable(type:String,callback : Dynamic->String->Void){
        var annotlist : Array<Dynamic> = this.annotations;

        var leaves : Array<Dynamic> ;
        var myGeneList: Array<String>;

        if(type=='family'){
            myGeneList=this.rootNode.targets;
            leaves= rootNode.targets;
        }else{
            myGeneList=this.searchedGenes;
            leaves=this.searchedGenes;
        }

        var total=numTotalAnnot;

        var completedAnnotations = 0;

        var onDone = function(error, annotation){
            if(completedAnnotations == total){
                Util.debug('All results fetch');

                var d=dataforTable(annotlist, leaves);//only when it's the last one
                callback(d,null);

                return;
            }
        }

        // total+1 as min...max excludes max - i.e. min to max-1
        for(currentAnnot in 1...total+1){
            // What is annotation 11?
            if(currentAnnot==11){
                completedAnnotations += 1;
                onDone(null, currentAnnot);
                continue;
            }

            var alias = annotlist[currentAnnot].hookName;
            if(alias==''){
                completedAnnotations += 1;
                onDone(null, currentAnnot);
                continue;
            }

            var parameter:Dynamic;

            //before calling the mysql select, we need to check the tree type (domain or gene)
            if(treeName != ''){
                if(treeType=='gene'){
                    alias='gene_'+alias;
                }

                parameter=this.treeName;

                if(annotlist[currentAnnot].popup==false){
                    var u =annotlist[currentAnnot].optionSelected[0];

                    WorkspaceApplication.getApplication().getProvider().getByNamedQuery(alias,{param : parameter}, null, true, function(db_results, error){

                        if(error == null) {
                            addAnnotData(db_results,currentAnnot,u,function(){
                                completedAnnotations += 1;
                                onDone(null,currentAnnot);
                            });
                        }else {
                            Util.debug(error);

                            completedAnnotations += 1;
                            onDone(error,currentAnnot);
                        }
                    });
                }else{
                    var l=currentAnnot;
                    var popMethod=annotlist[currentAnnot].popMethod;
                    var hasClass=annotlist[currentAnnot].hasClass;
                    var hook = Reflect.field(Type.resolveClass(hasClass), popMethod);

                    hook(currentAnnot,null,this.treeType,treeName,null,this, function(results, error){
                        completedAnnotations += 1;

                        //TODO: Why doesn't this method do anything!!!!!!!

                        if(error == null){
                            onDone(null, currentAnnot);
                        }else{
                            Util.debug(error);

                            onDone(error, currentAnnot);
                        }
                    });
                }
            }else{
                if(annotlist[currentAnnot].popup==false){
                    alias='list_'+alias;
                    var parameter=this.searchedGenes;

                    if(this.treeType=='gene'){
                        alias='gene_'+alias;
                    }

                    WorkspaceApplication.getApplication().getProvider().getByNamedQuery(alias,{param : parameter}, null, true, function(db_results, error){
                        if(error == null) {
                            addAnnotDataGenes(db_results,currentAnnot,function(){
                                completedAnnotations += 1;

                                onDone(null, currentAnnot);
                            });
                        }else {
                            getApplication().showMessage('Unknown',error);
                            completedAnnotations += 1;
                            onDone(error, currentAnnot);
                        }
                    });
                }else{
                    var l=currentAnnot;
                    var popMethod=annotlist[currentAnnot].popMethod;
                    var hasClass=annotlist[currentAnnot].hasClass;
                    var hook = Reflect.field(Type.resolveClass(hasClass), popMethod);

                    hook(currentAnnot,null,this.treeType,treeName,this.searchedGenes,this, function(results, error){
                        completedAnnotations += 1;
                        onDone(null,currentAnnot);
                    });
                }
            }
        }
    }

    function dataforTable(annotlist:Array<Dynamic>, leaves:Array<Dynamic>):Array<Dynamic>{
        var d=new Array();
        var total=numTotalAnnot;
        if(treeName!=''){

            var results=new Array();
            for (i in 0 ... leaves.length){

                if(rootNode.leafNameToNode.exists(leaves[i])){
                    var leaf=rootNode.leafNameToNode.get(leaves[i]);

                    var j:Int;

                    for(j in 1...total+1){
                        if(annotlist[j]!=null && annotlist[j].familyMethod!=''){
                            results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showFamilyMethodDivInTable('+j+',\''+annotlist[j].familyMethod+'\')";return false;"><span style="text-align:center;color:">Visualize</span></a> ';
                            Util.debug('Here!');
                        }else{
                            Util.debug('Here2!');
                            if(leaf.annotations[j]!=null){
                                if(leaf.annotations[j]!=null){
                                    if(leaf.annotations[j].hasAnnot==true){
                                        if (leaf.annotations[j].alfaAnnot.length==0){

                                            switch (annotations[j].shape){
                                                case "cercle": results[j]= '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">O</span></a> ';
                                                case "html": results[j]= generateIcon(j, leaf.annotations[j].myleaf.name, leaf.results);
                                                case "square": results[j]= '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><div id="rectangle" style="text-align:center;width:10px; height:10px; background-color:'+leaf.annotations[j].color[0].color+'"/> </div></a> ';
                                                case "text": results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">'+leaf.annotations[j].text+'</span></a> ';
                                                case "image":
                                                    var t=leaf.annotations[j].defaultImg;
                                                    if(t==null) t=0;
                                                    if((annotations[j].annotImg[t]!=null)&&(annotations[j].annotImg[t].currentSrc!=null)){
                                                        if (t!=100){
                                                            if(j==1) results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'" width="20px"/><a> ';
                                                            else results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'"/><a> ';
                                                        }
                                                        else results[j]='';
                                                    }
                                            }
                                        }else{
// var g:Int;
                                            results[j]='';
                                            if(leaf.annotations[j].hasAnnot==true){
                                                switch (annotations[j].shape){
                                                    case "cercle": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">O</span></a> ';
                                                    case "square": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><div id="rectangle" style="text-align:center;width:10px; height:10px; background-color:'+leaf.annotations[j].color[0].color+'"/> </div></a> ';
                                                    case "html": results[j]=results[j]+generateIcon(j, leaf.annotations[j].myleaf.name, leaf.results);
                                                    case "text": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\',\''+leaf.annotations[j].text+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">'+leaf.annotations[j].text+'</span></a> ';
                                                    case "image":
                                                        var t=leaf.annotations[j].defaultImg;
                                                        if(t==null) t=0;
                                                        if((annotations[j].annotImg[t]!=null)&&(annotations[j].annotImg[t].currentSrc!=null)){
                                                            if (t!=100) results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'"/><a> ';

                                                        }
                                                }
                                            }
                                            var b:Int;
                                            for(b in 0...leaf.annotations[j].alfaAnnot.length){
                                                if(leaf.annotations[j].alfaAnnot[b]!=null){

                                                    switch (annotations[j].shape){
                                                        case "cercle": results[j]=results[j]+ '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].alfaAnnot[b].color[0].color+'">O</span></a> ';
                                                        case "square": results[j]=results[j]+ '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><div id="rectangle" style="text-align:center;width:10px; height:10px; background-color:'+leaf.annotations[j].alfaAnnot[b].color[0].color+'"/> </div></a> ';
                                                        case "html": results[j]=results[j]+generateIcon(j, leaf.annotations[j].myleaf.name, leaf.results);
                                                        case "text": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\',\''+leaf.annotations[j].alfaAnnot[b].text+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].alfaAnnot[b].color[0].color+'">'+leaf.annotations[j].alfaAnnot[b].text+'</span></a> ';
                                                        case "image":
                                                            var t=leaf.annotations[j].alfaAnnot[b].defaultImg;
                                                            if(t==null) t=0;
                                                            if((annotations[j].annotImg[t]!=null)&&(annotations[j].annotImg[t].currentSrc!=null)){
                                                                if (t!=100) results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'"/><a> ';
                                                            }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        results[j]='';
                                    }
                                }
                                else{
                                    results[j]='';
                                }
                            }
                            else{
                                results[j]='';
                            }
                        }
                    }

                    d[i] = {};

                    var a=0;
                    Reflect.setField(d[i], 'Target', leaf.name);
                    for(a in 0 ... annotations.length){
                        if(a==12){
                            var iwanttostop=true;
                        }
                        if(results[a+1]!=null){
                            //annotcode=11 doesnt exist
                            if(a!=10)  Reflect.setField(d[i], annotations[a+1].label, results[a+1]);
                            //if(a!=10)  Reflect.setField(d[i], "<a href='www.google.com'>"+annotations[a+1].label+"</a>", results[a+1]);
                        }
                    }
                }
            }
            //d=results;
        }
        else{
            var results=new Array();
            var leaf:ChromoHubTreeNode;
            for (i in 0 ... searchedGenes.length){
                    leaf=geneMap.get(searchedGenes[i]);

                    var j:Int;
                    for(j in 1...total+1){
                        if(annotlist[j]!=null && annotlist[j].familyMethod!=''){
                                //results[j]='n/a';
                            if(leaf.targetFamilyGene!=null && leaf.targetFamilyGene.length!=0){
                                var ii=0;
                                var r='';
                                for(ii in 0...leaf.targetFamilyGene.length){
                                    r=r+leaf.targetFamilyGene[ii]+' ';
                                }
                                results[j]=r;
                            }
                            else results[j]='';
                        }
                        else{
                            if(leaf.annotations[j]!=null){
                                if(leaf.annotations[j].hasAnnot==true){
                                        if (leaf.annotations[j].alfaAnnot.length==0){
                                            switch (annotations[j].shape){
                                                case "cercle": results[j]= '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">O</span></a> ';
                                                case "square": results[j]= '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><div id="rectangle" style="text-align:center;width:10px; height:10px; background-color:'+leaf.annotations[j].color[0].color+'"/> </div></a> ';
                                                case "html": results[j]= generateIcon(j, leaf.annotations[j].myleaf.name, leaf.results);
                                                case "text": results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">'+leaf.annotations[j].text+'</span></a> ';
                                                case "image":
                                                    var t=leaf.annotations[j].defaultImg;
                                                    if(t==null) t=0;
                                                    if((annotations[j].annotImg[t]!=null)&&(annotations[j].annotImg[t].currentSrc!=null)){
                                                        if (t!=100) {
                                                            if(j==1) results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'" width="20px"/><a> ';
                                                            else results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'"/><a> ';
                                                        }
                                                        else results[j]='';
                                                    }
                                            }
                                        }else{
// var g:Int;
                                            results[j]='';
                                            if(leaf.annotations[j].hasAnnot==true){
                                                switch (annotations[j].shape){
                                                    case "cercle": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">O</span></a> ';
                                                    case "square": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><div id="rectangle" style="text-align:center;width:10px; height:10px; background-color:'+leaf.annotations[j].color[0].color+'"/> </div></a> ';
                                                    case "html": results[j]=results[j]+generateIcon(j, leaf.annotations[j].myleaf.name, leaf.results);
                                                    case "text": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\',\''+leaf.annotations[j].text+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">'+leaf.annotations[j].text+'</span></a> ';
                                                    case "image":
                                                        var t=leaf.annotations[j].defaultImg;
                                                        if(t==null) t=0;
                                                        if((annotations[j].annotImg[t]!=null)&&(annotations[j].annotImg[t].currentSrc!=null)){
                                                            if (t!=100) {
                                                                if(j==1) results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'" width="20px"/><a> ';
                                                                else results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'"/><a> ';
                                                            }
                                                        }
                                                }
                                            }
                                            var b:Int;
                                            for(b in 0...leaf.annotations[j].alfaAnnot.length){
                                                if(leaf.annotations[j].alfaAnnot[b]!=null){

                                                    switch (annotations[j].shape){
                                                        case "cercle": results[j]=results[j]+ '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].alfaAnnot[b].color[0].color+'">O</span></a> ';
                                                        case "square": results[j]=results[j]+ '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><div id="rectangle" style="text-align:center;width:10px; height:10px; background-color:'+leaf.annotations[j].alfaAnnot[b].color[0].color+'"/> </div></a> ';
                                                        case "html": results[j]=results[j]+ '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><div id="rectangle" style="text-align:center;width:10px; height:10px; background-color:'+leaf.annotations[j].alfaAnnot[b].color[0].color+'"/> </div></a> ';
                                                        case "text": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\',\''+leaf.annotations[j].alfaAnnot[b].text+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].alfaAnnot[b].color[0].color+'">'+leaf.annotations[j].alfaAnnot[b].text+'</span></a> ';
                                                        case "image":
                                                            var t=leaf.annotations[j].alfaAnnot[b].defaultImg;
                                                            if(t==null) t=0;
                                                            if((annotations[j].annotImg[t]!=null)&&(annotations[j].annotImg[t].currentSrc!=null)){
                                                                if (t!=100){
                                                                    if(j==1) results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'" width="20px"/><a> ';
                                                                    else  results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'"/><a> ';
                                                                }
                                                            }
                                                    }
                                                }
                                            }
                                        }
                                }
                                else{
                                    results[j]='';
                                }
                            }
                            else{
                                results[j]='';
                            }
                        }
                    }

                    d[i] = {};

                    var a=0;
                    Reflect.setField(d[i], 'Target', leaf.name);
                    var tt='';
                    for(a in 0 ... annotations.length){
                        if(results[a+1]!=null){

                            //annotcode=11 doesnt exist
                            if(a!=10){
                                if(a+1==5) Reflect.setField(d[i], 'Family Domains', results[a+1]);
                                else Reflect.setField(d[i], annotations[a+1].label, results[a+1]);
                            }
                        }
                    }
                    //we need to add into the second column, the list of family domains where the target belongs
                  /*  WorkspaceApplication.getApplication().getProvider().getByNamedQuery("getFamilies",{gene: leaf.name}, null, true, function(db_results, error){

                        if(error == null) {
                            tt=generateFamilyDomainList(db_results);
                            Reflect.setField(d[i], 'Family Domains', tt);


                            return d;
                        }
                        else {
                            WorkspaceApplication.getApplication().debug(error);
                            return null;
                        }

                    });*/
            }
        }

        return d;
    }

    function generateIcon(j:Int, tarname:String,results:Array<Int>):String{
        var name=tarname;
        if(name.indexOf('(')!=-1 || name.indexOf('/')!=-1){
            var auxArray=name.split('');
            var j:Int;
            var nn='';
            for(j in 0...auxArray.length){
                if (auxArray[j]!='(' && auxArray[j]!=')' && auxArray[j]!='/') {
                  nn=nn+auxArray[j];
                }
            }
            name=nn;
        }
        var r1=23-results[1];
        var r2=23-results[2];
        var r3=23-results[3];
        var r4=23-results[4];
        var r5=23-results[5];
        var r6=23-results[6];
        var r7=23-results[7];
        return "<script type=\"text/javascript\">
        $('.horizontal .progress-fill span').each(function(){
  var percent = $(this).html();
  $(this).parent().css('width', percent);
});


$('.vertical .progress-fill span').each(function(){
  var percent = $(this).html();
  var pTop = 100 - ( percent.slice(0, percent.length - 1) ) + \"%\";
  $(this).parent().css({
    'height' : percent,
    'top' : pTop
  });
});
                </script>"+'
                <style type="text/css" media="all">
                *, *:before, *:after {
  -moz-box-sizing: border-box; -webkit-box-sizing: border-box; box-sizing: border-box;
 }
.container {
  width: 23px;
  height: 23px;
  background: #fff;
  overflow: hidden;
  border-bottom:1px solid #000;
}

.vertical .progress-bar {
  float: left;
  height: 100%;
  width: 3px;
}

.vertical .progress-track {
  position: relative;
  width: 3px;
  height: 100%;
  background: #ffffff;
}

.vertical .progress-track-1 {
   position: relative;
   width: 3px;
   height: 100%;
   background: #2980d6;
}
.vertical .progress-fill-1'+name+' {
  position: relative;
  height: '+r1+'px;
  width: 3px;
  background-color:#ffffff;
}

.vertical .progress-track-2 {
   position: relative;
   width: 3px;
   height: 100%;
   background: #bf0000;
}
.vertical .progress-fill-2'+name+' {
  position: relative;
  height: '+r2+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-track-3 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #63cf1b;
}
.vertical .progress-fill-3'+name+' {
  position: relative;
  height: '+r3+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-track-4 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #ff8000;
}
.vertical .progress-fill-4'+name+' {
  position: relative;
  height: '+r4+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-track-5 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #c05691;
}
.vertical .progress-fill-5'+name+' {
  position: relative;
  height: '+r5+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-fill-6'+name+' {
  position: relative;
  height: '+r6+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-track-6 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #ffcc00;
}
.vertical .progress-track-7 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #793ff3;
}
.vertical .progress-fill-7'+name+' {
  position: relative;
  height: '+r7+';
  width: 3px;
  background-color:#ffffff;
}
                </style>
                '+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showDivInTable('+j+',\''+tarname+'\')";return false;">
                <div class="container vertical flat">
                          <div class="progress-bar">
                            <div class="progress-track-1">
                              <div class="progress-fill-1'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-2">
                              <div class="progress-fill-2'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-3">
                              <div class="progress-fill-3'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-4">
                              <div class="progress-fill-4'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-5">
                              <div class="progress-fill-5'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-6">
                              <div class="progress-fill-6'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-7">
                              <div class="progress-fill-7'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>
                        </div></a>';
    }
    public function showFamilyMethodDivInTable(annotation:Int){
        if((annotations[annotation].hasClass!=null)&&(annotations[annotation].familyMethod!=null)){
            var hook:Dynamic;
            var clazz,method:String;

            clazz=annotations[annotation].hasClass;
            method=annotations[annotation].familyMethod+'table';

            var data=new ChromoHubScreenData();

            data.renderer=this.radialR;
            data.target='';
            data.targetClean='';
            data.annot=annotation;
            data.divAccessed=false;
            data.root=this.rootNode;
            data.title=annotations[annotation].label;

            hook = Reflect.field(Type.resolveClass(clazz), method);

            this.dom = theComponent.down('component').getEl().dom;

            var posXDiv  = (this.dom.clientWidth/2)-100;
            var posYDiv = this.dom.clientHeight/5;


            hook(data,Math.round(posXDiv), Math.round(posYDiv),treeName, treeType, function(div){
                data.created=true;
                data.div=div;
                var nn='';
                if(data.target!=data.targetClean){
                    if(data.target.indexOf('(')!=-1 || data.target.indexOf('-')!=-1){
                        var auxArray=data.target.split('');
                        var j:Int;
                        for(j in 0...auxArray.length){
                            if (auxArray[j]=='(' || auxArray[j]=='-') {
                                nn=auxArray[j+1];
                                break;
                            }
                        }
                    }
                }
                var nom='';
                if(data.targetClean.indexOf('/')!=-1){
                    var auxArray=data.targetClean.split('');
                    var j:Int;
                    for(j in 0...auxArray.length){
                        if(auxArray[j]!='/') nom+=auxArray[j];
                    }
                }else nom=data.targetClean;
                var id=annotation+'-'+nom+nn;

                getApplication().getSingleAppContainer().showAnnotWindow(div, Math.round(posXDiv), Math.round(posYDiv), data.title,id,data);

            });
        }
    }

    public function showDivInTable(annotation:Int,target:String, ?text:String){
        var leaf:Dynamic;
        if(treeName=='') leaf=geneMap.get(target);
        else leaf=rootNode.leafNameToNode.get(target);

        if((annotations[annotation].hasClass!=null)&&(annotations[annotation].divMethod!=null)){
            var hook:Dynamic;
            var clazz,method:String;

            clazz=annotations[annotation].hasClass;
            method=annotations[annotation].divMethod;

            var data=new ChromoHubScreenData();

            data.renderer=this.radialR;
            data.target=target;
            data.annot=annotation;
            if(text!=null){
                data.annotation.text=text;
            }
            else data.annotation.text=leaf.annotations[annotation].text;
            var name='';
            if(target.indexOf('(')!=-1 || target.indexOf('-')!=-1){
                var auxArray=target.split('');
                var j:Int;
                for(j in 0...auxArray.length){
                    if (auxArray[j]=='(' || auxArray[j]=='-') {

                       // if(auxArray[j]=='(') {index=auxArray[j+1]; variant='1';}
                       // if(auxArray[j]=='-') {index=null; variant=auxArray[j+1];}
                        break;
                    }
                    name+=auxArray[j];
                }
                data.targetClean=name;
            }
            else{
                data.targetClean=target;
            }
            data.annot=annotation;
            data.divAccessed=false;
            data.root=this.rootNode;
            data.title=annotations[annotation].label;

            hook = Reflect.field(Type.resolveClass(clazz), method);

            this.dom = theComponent.down('component').getEl().dom;

            var posXDiv  = (this.dom.clientWidth/2)-100;
            var posYDiv = this.dom.clientHeight/5;
           // closeDivInTable();

            hook(data,Math.round(posXDiv), Math.round(posYDiv),treeType, function(div){
                data.created=true;
                data.div=div;

                var nn='';
                if(data.target!=data.targetClean){
                    if(data.target.indexOf('(')!=-1 || data.target.indexOf('-')!=-1){
                        var auxArray=data.target.split('');
                        var j:Int;
                        for(j in 0...auxArray.length){
                            if (auxArray[j]=='(' || auxArray[j]=='-') {
                                nn=auxArray[j+1];
                                break;
                            }
                        }
                    }
                }
                if(annotation==4){
                    if(data.annotation.text.indexOf('.')!=-1){
                        var auxArray=data.annotation.text.split('');
                        var j:Int;
                        var naux='';
                        for(j in 0...auxArray.length){
                            if(auxArray[j]!='.') naux+=auxArray[j];
                        }
                        nn=nn+naux;
                    }else if(data.annotation.text.indexOf('/')!=-1){
                        var auxArray=data.annotation.text.split('');
                        var j:Int;
                        var naux='';
                        for(j in 0...auxArray.length){
                            if(auxArray[j]!='/') naux+=auxArray[j];
                        }
                        nn=nn+naux;
                    }else nn=nn+data.annotation.text;
                }

                var nom='';
                if(data.targetClean.indexOf('/')!=-1){
                    var auxArray=data.targetClean.split('');
                    var j:Int;
                    for(j in 0...auxArray.length){
                        if(auxArray[j]!='/') nom+=auxArray[j];
                    }
                }else nom=data.targetClean;

                var id=annotation+'-'+nom+nn;

                getApplication().getSingleAppContainer().showAnnotWindow(div, Math.round(posXDiv), Math.round(posYDiv), data.title,id,data);

            });
        }
    }

    public function closeDivInTable(){
        var container = getApplication().getSingleAppContainer();
       // closeAnnotWindows();
    }

    public function generateFamilyDomainList(families:Array<Dynamic>):String{

        var i:Int;
        var tt:String;
        tt='';
        for(i in 0 ... families.length){
            tt+='<a id="myLink" title="Click to visualize family domain tree"  href="#" onclick="app.getActiveProgram().changeToFamilyDomain(\''+families[i].family+'\')";return false;">'+families[i].family+'</a> ';
        }
        return tt;
    }

    public function changeToFamilyDomain(treeName:String){
        WorkspaceApplication.getApplication().userPrompt('Question', 'You are going to lose your gene list. Do you want to continue?', function(){

            this.treeName=treeName;
            this.searchedGenes=new Array();
            geneMap=new Map<String, ChromoHubTreeNode>();
            generateTree(treeName,treeType);
        });
    }


    public function myDoLayout(el: Dynamic){
        el.doLayout();
    }



    public function createTargetCentralPanel(){
        centralTargetPanel = Ext.create('Ext.panel.Panel', {

            region:'center',
            cls:'x-page-targetclass',
            autoScroll: true,
            listeners: {
                resize: {
                    fn: function(el) {
                        myDoLayout(el);
                    }
                },
                render: {
                    fn: function(el) {
                        myDoLayout(el);
                    }
                }
            }
        });

        #if PHYLO5
            var home = new ChromoHubViewerHome(this);
            home.addUploadForm();
        #else
        centralTargetPanel.add({
            xtype: 'label',
            text: 'Search/Add Genes',
            cls:'searchgene-title',
            handler: function(){

            },
            tooltip: {text:'',dismissDelay:0},
            iconCls:''
        });

        var sobj=getApplication().getGlobalSearchFieldObj();
        centralTargetPanel.add(sobj);

        #if !UBIHUB
        centralTargetPanel.add(treeTypeSelection);

        centralTargetPanel.add({
            xtype: 'label',
            text: 'Chemical Modification of Proteins',
            cls:'targetclass-title'
        });
        centralTargetPanel.add(
            Ext.create('Ext.panel.Panel', {
                width: '100%',
                layout: 'hbox',
                bodyPadding: '10px 0px',
                cls: 'x-table-targeticons',

                defaults: {
                    frame: true,
                    bodyPadding: 10
                },

                items: [
                    {
                        title: 'Writers',
                        flex: 3,
                        xtype : 'panel',
                        items: chmodproWriters
                    },
                    {
                        title: 'Readers',
                        flex: 6,
                        xtype : 'panel',
                        items: chmodproReaders
                    },
                    {

                        title: 'Erasers',
                        flex: 3,
                        xtype : 'panel',
                        items: chmodproErasers
                    }
                ]
            })
        );
        centralTargetPanel.doLayout();

        //Second set of target classes
        centralTargetPanel.add(
            Ext.create('Ext.panel.Panel', {
                layout:'hbox',
                cls: 'x-table-targetgroup',

                defaults: {
                    frame: false,
                    bodyPadding: 0
                },

                items: [
                    {
                        title: 'Chemical Modifications of DNA',
                        flex: 4,
                        margin: '0 10 0 0',
                        xtype : 'panel',
                        layout:'column',
                        cls: 'chmodDRnagroup',

                        items: chmodDna
                    },
                    {

                        title: 'Chemical Modifications of RNA',
                        flex: 4,
                        margin: '0 10 0 0',
                        xtype : 'panel',
                        layout:'column',
                        cls: 'chmodDRnagroup',

                        items: chmodRna
                    }
                ]
            })
        );

        centralTargetPanel.doLayout();

        var items :Array<Dynamic> = [
            {
                title: 'Chromation Remodelling',
                flex: 2,
                margin: '0 10 0 0',
                xtype : 'panel',

                items: chromatin
            },
            {
                title: 'Histones',
                flex: 1,
                margin: '0 10 0 0',
                xtype : 'panel',

                items: histones
            },
            {

                title: 'WDR',
                flex: 1,
                margin: '0 10 0 0',
                xtype : 'panel',

                items: wdr
            },
            {

                title: 'NUDIX',
                flex: 3,
                margin: '0 10 0 0',
                xtype : 'panel',
                items: nudix
            },
            {

                title: ' ',
                flex: 1,
                margin: '0 10 0 0',
                xtype : 'panel',
                cls:'x-target-addmore',
                items: addicon
            }
        ];

        centralTargetPanel.add(
            Ext.create('Ext.panel.Panel', {
                layout:'hbox',
                bodyPadding: 10,
                cls: 'x-table-targetlasticons',

                defaults: {
                    frame: false,
                    bodyPadding: '10 10 10 0'
                },

                items: items
            })
        );

        centralTargetPanel.doLayout();
        centralTargetPanel.add({
            xtype: 'panel',
            html: 'If you find this resource helpful in your research, thank you for citing the following article:<br>
                   Liu L, Zhen XT, Denton E, Marsden BD, Schapira M., Bioinformatics (2012): <b>ChromoHub: a data hub for navigators of chromatin-mediated signalling</b> <a href="http://www.ncbi.nlm.nih.gov/pubmed/22718786" target="_blank">[pubmed]</a>',
            cls:'targetclass-citation'
        });
        #else

        centralTargetPanel.add({
            xtype: 'label',
            text: 'Ubiquitin Biology',
            cls:'targetclass-title'
        });

        centralTargetPanel.add(
            Ext.create('Ext.panel.Panel', {
                width: '100%',
                layout: 'hbox',
                bodyPadding: '10px 0px',
                cls: 'x-table-targeticons',
                defaults: {
                    frame: true,
                    bodyPadding: 10
                },
                items: ubiButtons
            })
        );

        centralTargetPanel.doLayout();
        #end
        #end

    }

    public function setAlignmentURL(alignmentURL : String){
        var frame : Dynamic = theComponent.getComponent(internalFrameId).getEl().dom;
        frame.src = alignmentURL;

        this.getActiveAlignmentObject().setAlignmentURL(alignmentURL);
    }

    public function getActiveAlignmentObject() : Alignment {
        var activeObject : WorkspaceObject<Dynamic> = super.getActiveObject(ChromoHubWorkspaceObject);

        if(activeObject != null){
            var w0 : ChromoHubWorkspaceObject = cast(activeObject, ChromoHubWorkspaceObject);

            return w0.getObject();
        }else{
            return null;
        }
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);


        this.standaloneMode = getObject().standloneMode;

        if(!standaloneMode){
            setTreeFromNewickStr(getObject().newickStr);
        }
    }

    public function exportPNG(){
        if(standaloneMode){
            var container = getApplication().getSingleAppContainer();
            container.hideExportSubMenu();
            container.hideHelpingDiv();

            closeAnnotWindows();
        }

        var newWidth  : Int = 1200;
        var newHeight : Int = 900;

        var ctx=this.canvas.canvas.getContext('2d');
        ctx.save();
        this.canvas.canvas.width=newWidth;
        this.canvas.canvas.height=newHeight;
        ctx.clearRect(0, 0, this.canvas.canvas.width, this.canvas.canvas.height);
        ctx.translate(newWidth/2,newHeight/2);
        ctx.scale(1,1);

        this.radialR= new ChromoHubRadialTreeLayout(this,this.canvas.canvas.width, this.canvas.canvas.height);

        this.radialR.renderCircle(this.rootNode, this.canvas, this.activeAnnotation,annotations);

        this.canvas.cx=this.centrex;
        this.canvas.cy=this.centrey;
        ctx.restore();

        var blob=this.canvas.canvas.msToBlob();
        WorkspaceApplication.getApplication().saveFile(blob, this.treeName+'_'+this.treeType+'_tree.png');

        newposition(0,0);
    }

    public function exportSVG(){
        if(standaloneMode){
            var container = getApplication().getSingleAppContainer();
            container.hideExportSubMenu();
            container.hideHelpingDiv();

            closeAnnotWindows();
        }


        this.canvas.canvas.width=1200;
        this.canvas.canvas.height=900;

        var width = this.canvas.canvas.width;
        var height = this.canvas.canvas.height;
        var svgGraphCanvas = untyped __js__('new C2S(width,height)');

        var originalCanvas = this.canvas.ctx;

        this.canvas.ctx = svgGraphCanvas;
        this.canvas.ctx.save();

        this.canvas.ctx.translate(width/2,height/2);
        this.canvas.ctx.scale(1, 1);

        this.radialR= new ChromoHubRadialTreeLayout(this, width, height);

        this.radialR.renderCircle(this.rootNode, this.canvas, this.activeAnnotation,annotations);


        this.canvas.ctx = originalCanvas;
        newposition(0,0);

        var d : Dynamic = cast svgGraphCanvas;

        WorkspaceApplication.getApplication().saveTextFile(d.getSerializedSvg(true), this.treeName+'_'+this.treeType+'_tree.svg');

    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-tree',
                html:'Phylogenetic<br/>ViewerA',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new ChromoHubWorkspaceObject(new Alignment(), "Tree"), true);
                },
                tooltip: {dismissDelay: 10000, text: 'Generate a phylogenetic tree from DNA or Protein sequences'}
            }
        ];
    }

    override public function getCentralPanelLayout(){
        return 'hbox';
    }

    function showTree(myNewickStr:String){
        var container = null;

        if(standaloneMode){
            container = getApplication().getSingleAppContainer();

            container.hideHelpingDiv();
            if(container.getExportSubMenu()!=null){
                container.hideExportSubMenu();
            }

            closeAnnotWindows();
        }

        var keepgoing=false;
        if(recovered==true){
            keepgoing=true;
        }else if(editmode==true){
            if(undolist.length>0){
                WorkspaceApplication.getApplication().userPrompt('Question', 'You are going to lose your changes. Do you want to continue?', function(){
                    keepgoing=false;
                    while(undolist.length>0){
                        moveNode(null,true, true);//if we are undoing actions, the undolist is doing pop so increasing its length
                    }
                    editmode=false;
                    if(standaloneMode){
                        container.viewClose(true);
                        container.hideEditToolBar();
                    }

                    undolist=new Array();

                    if(viewOptionsActive==false){
                        viewOptionsActive=true;
                        if(standaloneMode){
                            container.showOptionsToolBar();
                        }

                    }
                    this.activeAnnotation=new Array();
                    var go=treeViewInterface(); //return true if we can show the tree
                    if(go==true){
                        var a=annotations;
                        setTreeFromNewickStr(myNewickStr);
                        this.rootNode.targetFamily=this.treeName;
                    }
                    newposition(0,0);

                    var elem=js.Browser.document.getElementById('optionToolBarId');
                    elem.scrollTop=menuScroll;
                });
            }else keepgoing=true;
        }else keepgoing=true;

        if(keepgoing==true){

            if(recovered==false){
                while(undolist.length>0){
                    moveNode(null,true, true);//if we are undoing actions, the undolist is doing pop so increasing its length
                }
                undolist=new Array();
                if(viewOptionsActive==false){
                    viewOptionsActive=true;
                    if(standaloneMode){
                        container.showOptionsToolBar();
                    }

                    var elem=js.Browser.document.getElementById('optionToolBarId');
                    elem.scrollTop=menuScroll;
                }
            }

           this.activeAnnotation=new Array();
            var go=treeViewInterface(); //return true if we can show the tree
            if(recovered==false){
                editmode=false;

                if(standaloneMode){
                    container.hideEditToolBar();
                }
            }

            if(go==true){
                var a=annotations;
                setTreeFromNewickStr(myNewickStr);
                if(standaloneMode){
                    container.viewClose(true);
                }

                this.rootNode.targetFamily=this.treeName;
            }

            newposition(0,0);
            var nav=js.Browser.navigator.appName;

            if(standaloneMode){
                var elem=js.Browser.document.getElementById('optionToolBarId');

                elem.scrollTop=menuScroll;
            }
        }
    }

    public function closeAnnotWindows(){
        var container = getApplication().getSingleAppContainer();
        var annotWindow=container.annotWindow;
        var key:Int;
        var numWindows=0;
        for(key in annotWindow.keys()){
            numWindows++;
        }
        if(numWindows>1){
            WorkspaceApplication.getApplication().userPrompt('Question', 'You have popup windows opened. Do you want to close them?', function(){
                container.removeAnnotWindows();
            });
        }else{
            if(numWindows==1){
                container.removeAnnotWindows();
            }

        }
    }

    public function showSearchedGenes(targetId :String){
        if(currentView==0){
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery("getFamilies",{gene: targetId}, null, true, function(db_results, error){

                if(error == null) {
                    rebuildBtns(db_results);
                }
                else {
                    WorkspaceApplication.getApplication().debug(error);
                }

            });
        }
    }

    public function showAddedGenes(targetId :String){
        this.treeName='';
        this.treeType='gene';
        this.newickStr='';

        if(geneMap.exists(targetId)==true){
            WorkspaceApplication.getApplication().showMessage('Alert','This gene already exists in the gene list.');
        }else{
            searchedGenes[searchedGenes.length]=targetId;

//we need to create a TreeNode and add it into our geneMap structure
            var geneNode=new ChromoHubTreeNode(null, targetId, true, 0);

            geneNode.l =1;
            geneNode.annotations= new Array();
            geneNode.activeAnnotation= new Array();

            geneMap.set(targetId,geneNode);

            if(currentView==0){
                treeName='';
                tableViewFunction();
            }
            else if(currentView==2){
                generateAnnotTable();
            }
        }

    }

    private function generateTree(name: String, type:String, subtreeName : String = null){
        WorkspaceApplication.getApplication().debug(name);
        this.searchedGenes=new Array();
        this.highlightedGenes=new Map<String, Bool>();
        this.geneMap=new Map<String, ChromoHubTreeNode>();

        if(((name=='KAT')||(name=='E1')||(name=='E2')||(name=='NON_USP')||(name=='USP')||(name=='Histone')||(name=='MACRO')||(name=='WDR')||(name=='NUDIX'))&&(type=='domain')){
           // WorkspaceApplication.getApplication().showMessage('Alert','There is no domain-based alignment for this family. This phylogenetic tree is based on full-length alignment.');

            if(userDomainMessage==true){
                #if !UBIHUB
                var container=getApplication().getSingleAppContainer();
                container.showMessageDomainWindow();
                #end
            }
            this.treeType='gene';
            type=this.treeType;
        }

        if(subtreeName == null){
            subtreeName = name;
        }

        WorkspaceApplication.getApplication().getProvider().getByNamedQuery("getNewickStr",{family : subtreeName, type: type}, null, true, function(db_results, error){
            if(error == null) {
                if(this.treeName.indexOf('/')!=-1){
                    var aux=this.treeName.split('/');
                    this.treeName=aux[1];
                }
                setNewickStr(db_results[0].newickstr);
            }
            else {
                WorkspaceApplication.getApplication().debug(error);
            }

        });

    }

    public function setNewickStr(newickStr:String){
        var myNewickStr = newickStr;

        if (myNewickStr==''){
            WorkspaceApplication.getApplication().debug("newickstr is empty");
        }else {
            showTree(myNewickStr);
            //we need to check if there are updates in db for this tree
            if(recovered==false && treeName != null ){
                WorkspaceApplication.getApplication().getProvider().getByNamedQuery('getTreeUpdates',{family :this.subtreeName ,domain:this.treeType}, null, false, function(results: Dynamic, error){
                    if((error == null) &&(results.length!=0)){
                        var i=0;
                        var auxlist:Dynamic;
                        auxlist=new Array();
                        updatedlist=new Array();
                        for(i in 0...results.length){
                            updatedlist.push(results[i]);
                            auxlist.push(results[i]);
                        }
                        var j=0;
                        while(auxlist.length>0){
                            var node:ChromoHubTreeNode;
                            var alpha:Float;
                            var n:Dynamic;
                            var auxpop=auxlist.pop();
                            var z=0;
                            var d:ChromoHubScreenData;
                            d=null;
                            for(z in 0...rootNode.screen.length){
                                if(rootNode.screen[z].nodeId==auxpop.nodeId) d=rootNode.screen[z];
                            }
                            node=this.rootNode.nodeIdToNode.get(auxpop.nodeId);
                            node.x=auxpop.nodeX;
                            node.y=auxpop.nodeY;
                            node.angle=auxpop.angle;

                            if(auxpop.clock==true){
                                alpha=0.3;
                            }
                            else{
                                alpha=-0.3;
                            }

                            node.x=((node.x-d.parentx)*Math.cos(alpha))-((node.y-d.parenty)*Math.sin(alpha))+d.parentx;
                            node.y=((node.x-d.parentx)*Math.sin(alpha))+((node.y-d.parenty)*Math.cos(alpha))+d.parenty;
                            node.angle=node.angle+alpha;

                            n=node.angle;

                            var i=0;
                            while(i<node.children.length){

                                node.children[i].wedge=((node.children[i].l/node.children[i].root.l)*2*Math.PI)+Math.PI/20; // we scale the angles to avoid label overlapping
                                node.children[i].angle=n;

                                n=n+node.children[i].wedge;
                                node.children[i].preOrderTraversal(0);
                                i++;
                            }
                            newposition(0,0);
                        }
                    }else{
                        if(error!=null){
                            WorkspaceApplication.getApplication().debug("Error getting the tree updates from the db: "+error);
                        }
                        else{
                            WorkspaceApplication.getApplication().debug("No tree updates from the db");
                        }
                    }
                });
            }

            var parentWidth : Int = this.dom.clientWidth;
            var parentHeight : Int = this.dom.clientHeight;
            this.centrex=Math.round(parentWidth/2);
            this.centrey=Math.round(parentHeight/2);
            centerCanvas();
        }
    }

    /***************************
     We create here the arrays of all target buttons
    ************************************/

    public var searchedGenes :Array<String>;

    var treeTypeSelection : Dynamic;

    var chmodproWriters : Array <Dynamic>;
    var chmodproReaders : Array <Dynamic>;
    var chmodproErasers : Array <Dynamic>;

    var chmodDnaWriters : Array <Dynamic>;
    var chmodDnaReaders : Array <Dynamic>;
    var chmodDnaErasers : Array <Dynamic>;

    var chmodRnaWriters : Array <Dynamic>;
    var chmodRnaReaders : Array <Dynamic>;
    var chmodRnaErasers : Array <Dynamic>;
    var nudix : Array <Dynamic>;

    var chromatin : Array <Dynamic>;
    var histones : Array <Dynamic>;
    var wdr : Array <Dynamic>;
    var addicon : Array<Dynamic>;

    var chmodDna : Array <Dynamic>;
    var chmodRna : Array <Dynamic>;

    var ubiButtons : Array<Dynamic>;

/***** View Options Array****/
   public var viewOptions : Array <Dynamic>;

   private function createBtnsForLandingPage(first:Bool,?mapFam:Map<String,Bool>){
       var ge=false;
       var dom=true;

       if(treeType!='domain'){
           ge=true;
           dom=false;
       }

       if(first==true){
           treeTypeSelection=null;
           treeTypeSelection=Ext.create('Ext.form.Panel', {
               bodyPadding: 10,
               id:'treeTypeCmp',
               width: 300,
               items: [
                   {
                       xtype      : 'radiogroup',
                       fieldLabel : 'View trees based on alignment of',
                       // defaultType: 'radiofield',
                       cls: 'x-treetype-select',
                       defaults: {
                           flex: 1
                       },
                       id:'treeType',
                       layout: 'hbox',
                       items: [
                           {
                               boxLabel  : 'the specified domain',
                               name      : 'type',
                               inputValue: 'domain',
                               id        : 'domain-radio',
                               checked   :dom,
                               handler: function(e) {
                                   if(e.getValue()){
                                       treeType='domain';
                                   }
                               }
                           },
                           {
                               boxLabel  : 'full-length proteins',
                               name      : 'type',
                               inputValue: 'gene',
                               checked   : ge,
                               id        : 'gene-radio',
                               handler: function(e) {
                                   if(e.getValue()) {
                                       treeType='gene';
                                   }
                               }
                           }
                       ],
                       listeners: {
                           change: function (field, newValue, oldValue) {
                               treeType=newValue.type;
                               renderHome();
                           }
                       }
                   }
               ]
           });
       }else{
           treeTypeSelection.items.items[0].items.items[0].setValue(dom);
           treeTypeSelection.items.items[0].items.items[1].setValue(ge);
       }


       #if PHYLO5

       #elseif UBIHUB
        var level1Items :Array<Dynamic> = [
            {
                xtype:'label',
                text:'E1 & E2',
                style:{
                    color: '#4d749f'
                }
            },
            {
                xtype:'panel',
                layout:'hbox',
                items:[
                    {
                        margin: '0 10 5 0',
                        xtype : 'button',
                        cls : if (mapFam.exists('E1') == true && treeType == 'domain')'x-btn-target-found x-btn-target-e1' else if (mapFam.exists('E1') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-e1-gene' else if (mapFam.exists('E1') == false && treeType == 'domain') 'x-btn-target-e1' else 'x-btn-target-e1-gene',
                        handler: function() {
                            treeName = 'E1';

                            subtreeName = treeName;

                            generateTree(treeName, treeType);
                        },
                        tooltip: {dismissDelay: 10000, text: if (treeType == 'gene') 'E1' else 'There is no domain-based alignment for this family. Select "full length proteins" above to see access this tree.'}
                    },
                    {
                        margin: '0 10 5 0',
                        xtype : 'button',
                        cls : if (mapFam.exists('E2') == true && treeType == 'domain')'x-btn-target-found x-btn-target-e2' else if (mapFam.exists('E2') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-e2-gene' else if (mapFam.exists('E2') == false && treeType == 'domain') 'x-btn-target-e2' else 'x-btn-target-e2-gene',
                        handler: function() {
                            treeName = 'E2';

                            subtreeName = treeName;

                            generateTree(treeName, treeType);
                        },
                        tooltip: {dismissDelay: 10000, text: if (treeType == 'gene') 'E2' else 'There is no domain-based alignment for this family. Select "full length proteins" above to see access this tree.'}
                    }
                ]
            }
        ];

        var level2Items :Array<Dynamic> = [
            {
                xtype:'label',
                text:'E3',
                style:{
                    color: '#4d749f'
                }
            },
            {
                xtype:'panel',
                layout:'hbox',
                items:[
                   {
                    xtype: 'component',
                    html:'
                        <form>
                            <fieldset>
                            <legend>
                            Involved in UPS confidence
                            </legend>
                            <div style="max-width:400px">
                            Indicates the confidence level that a protein is involved in the ubiquitin proteasome system.
            "degrad" found in Uniprot function: 1 point.
            "degrad" found in Reactome pathway(s): 1 point.
            "degrad" found in Reactome pathway enriched among biogrid interactors [pathway must be found in at least 3 interactors and enriched at least 3 fold compared with proteome]: 1 point
                            </div>
                            <div>
                                <input type="radio" name="usp_confidence" value="Cluster" checked/>
                                <label>Any</label>
                                <input type="radio" name="usp_confidence" value="1" />
                                <label>confidence >= 1</label>
                                <input type="radio" name="usp_confidence" value="2"  />
                                <label>confidence >= 2</label>
                                <input type="radio" name="usp_confidence" value="3"  />
                                <label>confidence >= 3</label>
                            </div>
                            </fieldset>
                        </form>
                   '
                   }
                ]
            }
        ];

        var level3Items :Array<Dynamic> = [
            {
                margin: '0 10 5 0',
                xtype : 'button',
                cls : if (mapFam.exists('E2') == true && treeType == 'domain')'x-btn-target-found x-btn-target-e2' else if (mapFam.exists('E2') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-e2-gene' else if (mapFam.exists('E2') == false && treeType == 'domain') 'x-btn-target-e2' else 'x-btn-target-e2-gene',
                handler: function() {
                    treeName = 'E3_Complex';

                    var d : Dynamic = js.Browser.document.querySelector('input[name="usp_confidence"]:checked');

                    subtreeName = treeName + '_' + d.value;

                    generateTree(treeName, treeType,subtreeName);
                },
                tooltip: {dismissDelay: 10000, text: if (treeType == 'gene') 'Multi-subunit E3 ligases' else 'There is no domain-based alignment for this family. Select "full length proteins" above to see access this tree.'}
            },
            {
                margin: '0 10 5 0',
                xtype : 'button',
                cls : if (mapFam.exists('E2') == true && treeType == 'domain')'x-btn-target-found x-btn-target-e2' else if (mapFam.exists('E2') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-e2-gene' else if (mapFam.exists('Simple E3 ligases') == false && treeType == 'domain') 'x-btn-target-e2' else 'x-btn-target-e2-gene',
                handler: function() {
                    treeName = 'E3_Ligase';

                    var d : Dynamic = js.Browser.document.querySelector('input[name="usp_confidence"]:checked');

                    subtreeName = treeName + '_' + d.value;

                    generateTree(treeName, treeType,subtreeName);
                },
                tooltip: {dismissDelay: 10000, text: if (treeType == 'gene') 'Simple E3 ligases' else 'There is no domain-based alignment for this family. Select "full length proteins" above to see access this tree.'}
            }
        ];

        var level4Items :Array<Dynamic> =[
            {
                xtype:'label',
                text:'DUPs',
                style:{
                    color: '#4d749f'
                }
            },
            {
                xtype:'panel',
                layout:'hbox',
                items:[
                    {
                        margin: '0 10 5 0',
                        xtype : 'button',
                        cls : if (mapFam.exists('NON-USP') == true && treeType == 'domain')'x-btn-target-found x-btn-target-non-usp' else if (mapFam.exists('NON-USP') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-non-usp-gene' else if (mapFam.exists('NON-USP') == false && treeType == 'domain') 'x-btn-target-non-usp' else 'x-btn-target-non-usp-gene',
                        handler: function() {
                            treeName = 'NON_USP';

                            subtreeName = treeName;

                            generateTree(treeName, treeType);
                        },
                        tooltip: {dismissDelay: 10000, text: if (treeType == 'gene') 'NON-USP' else 'There is no domain-based alignment for this family. Select "full length proteins" above to see access this tree.'}
                    },
                    {
                        margin: '0 10 5 0',
                        xtype : 'button',
                        cls : if (mapFam.exists('USP') == true && treeType == 'domain')'x-btn-target-found x-btn-target-usp' else if (mapFam.exists('USP') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-usp-gene' else if (mapFam.exists('USP') == false && treeType == 'domain') 'x-btn-target-usp' else 'x-btn-target-usp-gene',
                        handler: function() {
                            treeName = 'USP';

                            subtreeName = treeName;

                            generateTree(treeName, treeType);
                        },
                        tooltip: {dismissDelay: 10000, text: if (treeType == 'gene') 'USP' else 'There is no domain-based alignment for this family. Select "full length proteins" above to see access this tree.'}
                    }
                 ]
             }
        ];

        ubiButtons = [
            {
                xtype: 'panel',
                layout: 'vbox',
                items:[
                    {
                        xtype: 'panel',
                        layout: 'vbox',
                        items: level1Items
                    },
                    {
                        xtype: 'panel',
                        layout: 'vbox',
                        items: level4Items
                    },
                    {
                        xtype: 'panel',
                        layout:'vbox',
                        items:level2Items
                    },
                    {
                        xtype: 'panel',
                        layout: 'hbox',
                        items: level3Items
                    }

                ]
            }
        ];
       #else
       chmodproWriters = new Array();
       chmodproWriters = [
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('HMT') == true && treeType == 'domain')'x-btn-target-found x-btn-target-pmt' else if (mapFam.exists('PMT') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-pmt-gene' else if (mapFam.exists('PMT') == false && treeType == 'domain') 'x-btn-target-pmt' else 'x-btn-target-pmt-gene',
               handler: function() {
                   treeName = 'PMT/HMT';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'PMT: Methylate lysines'}
           }
       ];

       if (treeType == 'domain') {
           chmodproWriters.push(
               {
                   margin: '0 10 5 0',
                   xtype : 'button',
                   cls : if (mapFam.exists('HMT') == true)'x-btn-target-found x-btn-target-pmt2' else 'x-btn-target-pmt2',
                   handler: function() {
                       treeName = 'PMT-2/HMT';

                       subtreeName = treeName;

                       generateTree(treeName, treeType);
                   },
                   tooltip: {dismissDelay: 10000, text: 'PMT: Methylate lysines'}
               }
           );
       }

       chmodproWriters.push(
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('KAT') == true && treeType == 'domain')'x-btn-target-found x-btn-target-kat' else if (mapFam.exists('KAT') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-kat-gene' else if (mapFam.exists('KAT') == false && treeType == 'domain') 'x-btn-target-kat' else 'x-btn-target-kat-gene',
               handler: function(e) {
                   treeName = 'KAT';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: if (treeType == 'gene') 'KAT: Acetylate lysines' else 'There is no domain-based alignment for this family. Select "full length proteins" above to see access this tree.'}
           });

       chmodproWriters.push(
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('PARP') == true && treeType == 'domain')'x-btn-target-found x-btn-target-parp' else if (mapFam.exists('PARP') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-parp-gene' else if (mapFam.exists('PARP') == false && treeType == 'domain') 'x-btn-target-parp' else 'x-btn-target-parp-gene',
               handler: function() {
                   treeName = 'PARP';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'PARP: ADP - ribosylate proteins'}
           });


       chmodproReaders = new Array();
       chmodproReaders = [
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('ADD') == true && treeType == 'domain')'x-btn-target-found x-btn-target-add' else if (mapFam.exists('ADD') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-add-gene' else if (mapFam.exists('ADD') == false && treeType == 'domain') 'x-btn-target-add' else 'x-btn-target-add-gene',
               handler: function() {
                   treeName = 'ADD';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'ADD'}
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('BAH') == true && treeType == 'domain')'x-btn-target-found x-btn-target-bah' else if (mapFam.exists('BAH') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-bah-gene' else if (mapFam.exists('BAH') == false && treeType == 'domain') 'x-btn-target-bah' else 'x-btn-target-bah-gene',
               handler: function() {
                   this.treeName = 'BAH';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'BAH: Read methyl-lysines'}
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('BROMO') == true && treeType == 'domain')'x-btn-target-found x-btn-target-bromo' else if (mapFam.exists('BROMO') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-bromo-gene' else if (mapFam.exists('BROMO') == false && treeType == 'domain') 'x-btn-target-bromo' else 'x-btn-target-bromo-gene',
               handler: function() {
                   this.treeName = 'BROMO';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'BROMO: Read Acetyl-lysines'}
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('CW') == true && treeType == 'domain')'x-btn-target-found x-btn-target-cw' else if (mapFam.exists('CW') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-cw-gene' else if (mapFam.exists('CW') == false && treeType == 'domain') 'x-btn-target-cw' else 'x-btn-target-cw-gene',
               handler: function() {
                   this.treeName = 'CW';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'CW: methyl-lysine reader'}
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('CHROMO') == true && treeType == 'domain')'x-btn-target-found x-btn-target-chromo' else if (mapFam.exists('CHROMO') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-chromo-gene' else if (mapFam.exists('CHROMO') == false && treeType == 'domain') 'x-btn-target-chromo' else 'x-btn-target-chromo-gene',
               handler: function() {
                   this.treeName = 'CHROMO';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'CHROMO: Read methyl-lysines'}
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('MACRO') == true && treeType == 'domain')'x-btn-target-found x-btn-target-macro' else if (mapFam.exists('MACRO') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-macro-gene' else if (mapFam.exists('MACRO') == false && treeType == 'domain') 'x-btn-target-macro' else 'x-btn-target-macro-gene',
               handler: function() {
                   this.treeName = 'MACRO';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: if (treeType == 'gene') 'MACRO: bind ADP-ribosylated proteins' else 'There is no domain-based alignment for this family. Select "full length proteins" above to see access this tree.' }
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('MBT') == true && treeType == 'domain')'x-btn-target-found x-btn-target-mbt' else if (mapFam.exists('MBT') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-mbt-gene' else if (mapFam.exists('MBT') == false && treeType == 'domain') 'x-btn-target-mbt' else 'x-btn-target-mbt-gene',
               handler: function() {
                   this.treeName = 'MBT';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'MBT: Read methyl-lysines'}
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('PHD') == true && treeType == 'domain')'x-btn-target-found x-btn-target-phd' else if (mapFam.exists('PHD') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-phd-gene' else if (mapFam.exists('PHD') == false && treeType == 'domain') 'x-btn-target-phd' else 'x-btn-target-phd-gene',
               handler: function() {
                   this.treeName = 'PHD';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'PHD: Read methyl-lysines, acetylated lysines, methyl-arginines, unmodified lysines'}
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('PWWP') == true && treeType == 'domain')'x-btn-target-found x-btn-target-pwwp' else if (mapFam.exists('PWWP') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-pwwp-gene' else if (mapFam.exists('PWWP') == false && treeType == 'domain') 'x-btn-target-pwwp' else 'x-btn-target-pwwp-gene',
               handler: function() {
                   this.treeName = 'PWWP';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'PWWP: Read methyl-lysines, bind DNA'}
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('SPINDLIN') == true && treeType == 'domain')'x-btn-target-found x-btn-target-spindlin' else if (mapFam.exists('SPINDLIN') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-spindlin-gene' else if (mapFam.exists('SPINDLIN') == false && treeType == 'domain') 'x-btn-target-spindlin' else 'x-btn-target-spindlin-gene',
               handler: function() {
                   this.treeName = 'SPINDLIN';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'SPINDLIN: methyl-lysine/arginine reader'}
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('TUDOR') == true && treeType == 'domain')'x-btn-target-found x-btn-target-tudor' else if (mapFam.exists('TUDOR') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-tudor-gene' else if (mapFam.exists('TUDOR') == false && treeType == 'domain') 'x-btn-target-tudor' else 'x-btn-target-tudor-gene',
               handler: function() {
                   this.treeName = 'TUDOR';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'TUDOR: Read methyl-lysines, methyl-arginines'}
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('YEATS') == true && treeType == 'domain')'x-btn-target-found x-btn-target-yeats' else if (mapFam.exists('YEATS') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-yeats-gene' else if (mapFam.exists('YEATS') == false && treeType == 'domain') 'x-btn-target-yeats' else 'x-btn-target-yeats-gene',
               handler: function() {
                   this.treeName = 'YEATS';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'YEATS: read acetyl-lysines and crotonyl-lysines'}
           }
       ];

       chmodproErasers = new Array();
       chmodproErasers = [
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('HDAC') == true && treeType == 'domain')'x-btn-target-found x-btn-target-hdac' else if (mapFam.exists('HDAC') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-hdac-gene' else if (mapFam.exists('HDAC') == false && treeType == 'domain') 'x-btn-target-hdac' else 'x-btn-target-hdac-gene',
               handler: function() {
                   this.treeName = 'HDAC_SIRT';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'HDAC: Deacetylate lysines'}
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('KDM') == true && treeType == 'domain')'x-btn-target-found x-btn-target-kdm' else if (mapFam.exists('KDM') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-kdm-gene' else if (mapFam.exists('KDM') == false && treeType == 'domain') 'x-btn-target-kdm' else 'x-btn-target-kdm-gene',
               handler: function() {
                   this.treeName = 'KDM';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'KDM: De-methylate lysines'}
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('PADI') == true && treeType == 'domain')'x-btn-target-found x-btn-target-padi' else if (mapFam.exists('PADI') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-padi-gene' else if (mapFam.exists('PADI') == false && treeType == 'domain') 'x-btn-target-padi' else 'x-btn-target-padi-gene',
               handler: function() {
                   this.treeName = 'PADI';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'PADI: Deiminate arginines'}
           }
       ];

       chmodDnaWriters = new Array();
       chmodDnaWriters = [
           {
               margin: '0 10 5 0',
               bodyPadding: '0 0 0 9px',
               xtype : 'button',
               cls : if (mapFam.exists('DNMT') == true && treeType == 'domain')'x-btn-target-found x-btn-target-dnmt' else if (mapFam.exists('DNMT') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-dnmt-gene' else if (mapFam.exists('DNMT') == false && treeType == 'domain') 'x-btn-target-dnmt' else 'x-btn-target-dnmt-gene',
               handler: function() {
                   this.treeName = 'DNMT';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'DNMT: Methylate CpG dinucleotides'}
           }
       ];

       chmodDnaReaders = new Array();
       chmodDnaReaders = [
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('CXXC') == true && treeType == 'domain')'x-btn-target-found x-btn-target-cxxc' else if (mapFam.exists('CXXC') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-cxxc-gene' else if (mapFam.exists('CXXC') == false && treeType == 'domain') 'x-btn-target-cxxc' else 'x-btn-target-cxxc-gene',
               handler: function() {
                   this.treeName = 'CXXC';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'CXXC: Bind to nonmethyl-CpG dinucleotides'}
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('MBD') == true && treeType == 'domain')'x-btn-target-found x-btn-target-mbd' else if (mapFam.exists('MBD') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-mbd-gene' else if (mapFam.exists('MBD') == false && treeType == 'domain') 'x-btn-target-mbd' else 'x-btn-target-mbd-gene',
               handler: function() {
                   this.treeName = 'MBD';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'MBD: Bind to methyl-CpG dinucleotides'}
           }
       ];

       chmodDnaErasers = new Array();
       chmodDnaErasers = [
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('TET') == true && treeType == 'domain')'x-btn-target-found x-btn-target-tet' else if (mapFam.exists('TET') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-tet-gene' else if (mapFam.exists('TET') == false && treeType == 'domain') 'x-btn-target-tet' else 'x-btn-target-tet-gene',
               handler: function() {
                   this.treeName = 'TET';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'TET: DNA hydroxylases. Participate in DNA de-methylation'}
           }
       ];

       chmodRnaWriters = new Array();
       chmodRnaWriters = [
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('RNMT') == true && treeType == 'domain')'x-btn-target-found x-btn-target-rnmt' else if (mapFam.exists('RNMT') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-rnmt-gene' else if (mapFam.exists('RNMT') == false && treeType == 'domain') 'x-btn-target-rnmt' else 'x-btn-target-rnmt-gene',
               handler: function() {
                   this.treeName = 'RNMT';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'RNMT: Methylate RNA'}
           },
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('PUS') == true && treeType == 'domain')'x-btn-target-found x-btn-target-pus' else if (mapFam.exists('PUS') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-pus-gene' else if (mapFam.exists('PUS') == false && treeType == 'domain') 'x-btn-target-pus' else 'x-btn-target-pus-gene',
               handler: function() {
                   this.treeName = 'PUS';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'Pseudouridine synthases: catalyze the site-specific isomerization of uridines on RNA'}
           }
       ];

       chmodRnaReaders = new Array();
       chmodRnaReaders = [
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('YTH') == true && treeType == 'domain')'x-btn-target-found x-btn-target-yth' else if (mapFam.exists('YTH') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-yth-gene' else if (mapFam.exists('YTH') == false && treeType == 'domain') 'x-btn-target-yth' else 'x-btn-target-yth-gene',
               handler: function() {
                   this.treeName = 'YTH';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'YTH: bind to methylated RNA'}
           }
       ];

       chmodRnaErasers = new Array();
       chmodRnaErasers = [
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('RNA-DMT') == true && treeType == 'domain')'x-btn-target-found x-btn-target-rna-dmt' else if (mapFam.exists('RNA-DMT') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-rna-dmt-gene' else if (mapFam.exists('RNA-DMT') == false && treeType == 'domain') 'x-btn-target-rna-dmt' else 'x-btn-target-rna-dmt-gene',
               handler: function() {
                   this.treeName = 'RNA-DMT';

                   subtreeName = treeName;

                   generateTree(treeName, treeType);
               },
               tooltip: {dismissDelay: 10000, text: 'RNA-DMT'}
           }
       ];

        chmodDna=new Array();
        chmodDna= [
            {
                title: 'Writers',
                flex: 1,
                margin: '0 10 0 0',
                xtype : 'panel',
                cls: 'x-panel-floating',

                items: chmodDnaWriters
            },
            {
                title: 'Readers',
                flex: 2,
                margin: '0 10 0 0',
                xtype : 'panel',
                cls: 'x-panel-floating2',

                items: chmodDnaReaders
            },
            {

                title: 'Erasers',
                flex: 1,
                margin: '0 10 0 0',
                xtype : 'panel',
                cls: 'x-panel-floating',

                items: chmodDnaErasers
            }
        ];

        chmodRna=new Array();
        chmodRna= [
            {
                title: 'Writers',
                flex: 2,
                margin: '0 10 0 0',
                xtype : 'panel',
                cls: 'x-panel-floating2',

                items: chmodRnaWriters
            },
            {
                title: 'Readers',
                flex: 1,
                margin: '0 10 0 0',
                xtype : 'panel',
                cls: 'x-panel-floating',

                items: chmodRnaReaders
            },
            {

                title: 'Erasers',
                flex: 1,
                margin: '0 10 0 0',
                xtype : 'panel',
                cls: 'x-panel-floating',

                items: chmodRnaErasers
            }
        ];

//last group
        chromatin=new Array();
        chromatin= [
            {
                margin: '0 10 5 0',
                xtype : 'button',
                cls : if (mapFam.exists('DEXDc')==true && treeType=='domain')'x-btn-target-found x-btn-target-dexdc' else if(mapFam.exists('DEXDc')==true && treeType=='gene') 'x-btn-target-found x-btn-target-dexdc-gene' else if(mapFam.exists('DEXDc')==false && treeType=='domain') 'x-btn-target-dexdc' else 'x-btn-target-dexdc-gene',
                handler: function(){
                    this.treeName='DEXDc';

                    subtreeName = treeName;

                    generateTree(treeName,treeType);
                },
                tooltip: {dismissDelay: 10000, text: 'DEXDc'}
            },
            {
                margin: '0 10 5 0',
                xtype : 'button',
                cls : if (mapFam.exists('Helicases')==true && treeType=='domain')'x-btn-target-found x-btn-target-helicc' else if(mapFam.exists('Helicases')==true && treeType=='gene') 'x-btn-target-found x-btn-target-helicc-gene' else if(mapFam.exists('Helicases')==false && treeType=='domain') 'x-btn-target-helicc' else 'x-btn-target-helicc-gene',
                handler: function(){
                    this.treeName='HELICC/Helicases';

                    subtreeName = treeName;

                    generateTree(treeName,treeType);
                },
                tooltip: {dismissDelay: 10000, text: 'HELICc'}
            },
            {
                margin: '0 10 5 0',
                xtype : 'button',
                cls : if (mapFam.exists('SANT')==true && treeType=='domain')'x-btn-target-found x-btn-target-sant' else if(mapFam.exists('SANT')==true && treeType=='gene') 'x-btn-target-found x-btn-target-sant-gene' else if(mapFam.exists('SANT')==false && treeType=='domain') 'x-btn-target-sant' else 'x-btn-target-sant-gene',
                handler: function(){
                    this.treeName='SANT';

                    subtreeName = treeName;

                    generateTree(treeName,treeType);
                },
                tooltip: {dismissDelay: 10000, text: 'SANT: Involved in chromatin remodeling'}
            }
        ];
        histones=new Array();
        histones= [
            {
                margin: '0 10 5 0',
                xtype : 'button',
                cls : if (mapFam.exists('HISTONE')==true && treeType=='domain')'x-btn-target-found x-btn-target-histone' else if(mapFam.exists('HISTONE')==true && treeType=='gene') 'x-btn-target-found x-btn-target-histone-gene' else if(mapFam.exists('HISTONE')==false && treeType=='domain') 'x-btn-target-histone' else 'x-btn-target-histone-gene',
                handler: function(){
                    this.treeName='Histone';

                    subtreeName = treeName;

                    generateTree(treeName,treeType);
                },
                tooltip:  {dismissDelay: 10000, text: if(treeType=='gene') 'Histone' else 'There is no domain-based alignment for this family. Select "full length proteins" above to see access this tree.'}
            }
        ];
        wdr=new Array();
        wdr= [
            {
                margin: '0 10 5 0',
                xtype : 'button',
                cls : if (mapFam.exists('WDR')==true && treeType=='domain')'x-btn-target-found x-btn-target-wdr' else if(mapFam.exists('WDR')==true && treeType=='gene') 'x-btn-target-found x-btn-target-wdr-gene' else if(mapFam.exists('WDR')==false && treeType=='domain') 'x-btn-target-wdr' else 'x-btn-target-wdr-gene',
                handler: function(){
                    this.treeName='WDR';

                    subtreeName = treeName;

                    generateTree(treeName,treeType);
                },
                tooltip: {dismissDelay: 10000, text: if(treeType=='gene') 'WDR: Versatile binding module'  else 'There is no domain-based alignment for this family. Select "full length proteins" above to see access this tree.'}
            }
        ];


       nudix=new Array();
       nudix= [
           {
               margin: '0 10 5 0',
               xtype : 'button',
               cls : if (mapFam.exists('NUDIX')==true && treeType=='domain')'x-btn-target-found x-btn-target-nudix' else if(mapFam.exists('NUDIX')==true && treeType=='gene') 'x-btn-target-found x-btn-target-nudix-gene' else if(mapFam.exists('NUDIX')==false && treeType=='domain') 'x-btn-target-nudix' else 'x-btn-target-nudix-gene',
               handler: function(){
                   this.treeName='NUDIX';

                   subtreeName = treeName;

                   generateTree(treeName,treeType);
               },
               tooltip: {dismissDelay: 10000, text:  if(treeType=='gene') 'NUDIX: Break a phosphate bond from RNA caps and other substrates'  else 'There is no domain-based alignment for this family. Select "full length proteins" above to see access this tree.'}
           }
       ];


        addicon=new Array();
        addicon= [
            {
                margin: '0 10 5 0',
                xtype : 'button',
                cls : 'x-btn-target-ultradd',
                handler: function(){
                    showUltraDDGenes();
                },
                tooltip: {dismissDelay: 10000, text: 'Show UltraDD genes list'}
            }
        ];

       #end

    }

    function showUltraDDGenes(){
        WorkspaceApplication.getApplication().getProvider().getByNamedQuery("getUltraDDGenes",{param:''}, null, true, function(db_results:Array<Dynamic>, error){
            if(error == null) {
                if(db_results.length!=0){
                    var div :Array<Dynamic>;
                    div=new Array();
                    var i=0;
                    var title=db_results.length;
                    for(i in 0 ... db_results.length){
                        div[i]={
                            xtype: "checkboxfield",
                            boxLabel: db_results[i].target_id,
                            labelSeparator : "",
                            name: "ultradd",
                            cls: "ultradd-checkbox",
                            inputValue: db_results[i].target_id,
                            id:  "ultradd-"+i
                        };
                    }
                    var container=getApplication().getSingleAppContainer();
                    var mydom=js.Browser.document.getElementById('id-centralPanel');
                    var parentWidth : Int = mydom.clientWidth;
                    var parentHeight : Int = mydom.clientHeight;
                    var cx=Math.round(parentWidth/2)-350;
                    var cy=Math.round(parentHeight/5);

                    container.showUltraDDWindow(div,cx,cy,title,this);

                }else{
                    WorkspaceApplication.getApplication().showMessage('Alert','No UltraDD genes in the current database.');
                }
            }
        });
    }

    function prepareHelpingDiv(e: Dynamic, text:String){

        var h = e.ownerCt.y - e.ownerCt.ownerCt.el.dom.scrollTop;

        var container=getApplication().getSingleAppContainer();

       // closeAnnotWindows();

        container.hideHelp=true;
        container.clearHelpingDiv();

        container.addHtmlTextHelpingDiv(text);

        container.setTopHelpingDiv(h);

        container.showHelpingDiv();
    }

    function closeHelpingDiv(){
        var container=getApplication().getSingleAppContainer();
        var i=0;
        for(i in 0...300000000){

        }
        if(container.hideHelp==true) container.hideHelpingDiv();
    }

    /**Function used to remove the previous results of a PopUp Window Annotations. **/
    public function cleanAnnotResults(annot:Int){

        var items=new Array();
        for(i in 0 ... this.rootNode.targets.length){
            var item=this.rootNode.targets[i];

            var leafaux=this.rootNode.leafNameToNode.get(item);
            if(leafaux.annotations[annot]!=null) leafaux.annotations[annot].hasAnnot=false;
        }

    }

/************ View Options Array  from JSON file****/
    public function createViewOptions(){
        viewOptions = new Array<Dynamic>();

        if(jsonFile == null){
            return;
        }

        var i=0;var j=0;
        while(i< jsonFile.btnGroup.length){

            //we generate the annotations menu from json file
            viewOptions[j]=
            {
                text : jsonFile.btnGroup[i].title,
                margin: '0 10 5 0',
                xtype : 'label',
                cls : 'x-title-viewoptions'
            };
            var z=0;
            j++;
            while(z<jsonFile.btnGroup[i].buttons.length){
                var b=jsonFile.btnGroup[i].buttons[z];

                if(!b.enabled){
                    z++;
                    continue;
                }

                if(b.annotCode == 26 && treeName == 'E1' || b.annotCode == 26 && treeName == 'E2' || b.annotCode == 26 && treeName == 'USP'){
                    z++;
                    continue;
                }

                if(b.isTitle==true){
                    viewOptions[j]=
                    {
                        text : b.label,
                        margin: '0 0 5 0',
                        xtype : 'label',
                        cls : 'x-title-viewsuboptions'
                    };
                }else{
                    var auxtext:String;
                    if(b.submenu){
                        var k=b.optionSelected[0];
                        auxtext = b.label+' ('+b.options[k].label+')';
                    }
                    else auxtext = b.label;
                    var tit=b.label+' Options';
                    //we need to create the help button

                    var _viewOptions_Items :Array<Dynamic>= [
                        {
                            text:'',
                            margin: '0',
                            xtype : 'button',
                            cls : 'x-button-helpicon',
                            icon : '/static/js/images/helpicon.png',
                            handler: function(){},
                            listeners:{
                                mouseout:
                                function(e){
                                    closeHelpingDiv();

                                },
                                mouseover:
                                    //show a flying help div
                                function(e){
                                    prepareHelpingDiv(e,b.helpText);
                                }
                            }
                        },

                        {
                            text:'',
                            margin: '0',
                            xtype : if(this.activeAnnotation[b.annotCode]==true) 'button' else 'container',
                            width: 19,
                            cls : if(this.activeAnnotation[b.annotCode]==true) 'x-button-uncheck-icon' else 'x-button-hidden',
                            icon : '/static/js/images/checkicon.png',
                            handler: function(){

                                var elem=js.Browser.document.getElementById('optionToolBarId');
                                menuScroll=elem.scrollTop;
                                var container=getApplication().getSingleAppContainer();

                                closeAnnotWindows();

                                showAnnotation(b.annotCode,false);

                                container.clearOptionsToolBar();
                                createViewOptions();
                                container.addElemToOptionsToolBar(viewOptions);

                                var elem=js.Browser.document.getElementById('optionToolBarId');
                                elem.scrollTop=menuScroll;
                            },
                            listeners:{
                                mouseout:
                                function(e){
                                    //hide the flying help div
                                    // closeHelpingDiv();

                                },
                                mouseover:
                                    //show a flying help div
                                function(e){
                                    closeHelpingDiv();
                                }
                            }
                        },
                        {
                            text:auxtext,
                            margin: '0 10 5 0',
                            xtype : 'button',

                            cls :
                            if(b.submenu) {
                                if(this.activeAnnotation != null && this.activeAnnotation.length > 0 && this.activeAnnotation[b.annotCode]==true) 'x-btn-viewoptions-suboptions-checked';
                                else  'x-btn-viewoptions-suboptions';
                            }
                            else if(b.popUpWindows) {
                                if(this.activeAnnotation != null && this.activeAnnotation.length > 0 && this.activeAnnotation[b.annotCode]==true) 'x-btn-viewoptions-popup-checked';
                                else  'x-btn-viewoptions-popup';
                            }
                            else{
                                if(this.activeAnnotation != null && this.activeAnnotation.length > 0 && this.activeAnnotation[b.annotCode]==true) 'x-btn-viewoptions-checked';
                                else
                                    'x-btn-viewoptions';
                            },
                            icon : '',
                            handler:
                            if(b.popUpWindows==true){
                                var ia=i; var za=z;
                                function(){
                                    var elem=js.Browser.document.getElementById('optionToolBarId');
                                    menuScroll=elem.scrollTop;
                                    var container=getApplication().getSingleAppContainer();

                                    closeAnnotWindows();

                                    container.clearPopUpWindow();
                                    container.setPosPopUpWindow(300,150);
                                    container.setPopUpWindowTitle(tit);

                                    var optt=jsonFile.btnGroup[ia].buttons[za].windowsData[0];
                                    container.addFormItemToPopUpWindow(optt.form.items,b.annotCode,optt.hasClass,optt.popMethod, this.treeType, this.treeName, null, this );
                                    container.showPopUpWindow();
                                };
                            }else {
                                function(){
                                    var elem=js.Browser.document.getElementById('optionToolBarId');
                                    menuScroll=elem.scrollTop;
                                    var act=this.activeAnnotation[b.annotCode];
                                    if(this.activeAnnotation[b.annotCode]==null || this.activeAnnotation[b.annotCode]==false){
                                        var container=getApplication().getSingleAppContainer();

                                        closeAnnotWindows();

                                        container.hideSubMenuToolBar();
                                        showAnnotation(b.annotCode,true);

                                        var cert=!this.activeAnnotation[b.annotCode];
                                        // if (tableActive==false){
                                        //it's the tree
                                        updateLegend(b,cert);
                                        //}
                                        container.clearOptionsToolBar();
                                        createViewOptions();
                                        container.addElemToOptionsToolBar(viewOptions);
                                        var elem=js.Browser.document.getElementById('optionToolBarId');
                                        elem.scrollTop=menuScroll;
                                        if(tableActive==true){
                                            baseTable.reconfigure(tableAnnot.tableDefinition);
                                        }
                                        if(cert==false){
                                            container.legendPanel.expand();
                                        }
                                    }
                                    else{


                                        var elem=js.Browser.document.getElementById('optionToolBarId');
                                        menuScroll=elem.scrollTop;
                                        var container=getApplication().getSingleAppContainer();

                                        closeAnnotWindows();

                                        showAnnotation(b.annotCode,false);

                                        container.clearOptionsToolBar();
                                        createViewOptions();
                                        container.addElemToOptionsToolBar(viewOptions);

                                        var elem=js.Browser.document.getElementById('optionToolBarId');
                                        elem.scrollTop=menuScroll;
                                    }

                                    //if (controlToolsActive == true) getApplication().getSingleAppContainer().showControlToolBar();
                                }
                            },
                            listeners:{
                                mouseout:
                                function(e){
                                    var container = getApplication().getSingleAppContainer();
                                    container.hideHelpingDiv();
                                    if (onSubmenu==false){
                                        container.hideSubMenuToolBar();
                                    }

                                },
                                mouseover:
                                if(b.submenu){
                                    var a=j;
                                    var subm:Array<Dynamic>;
                                    var t=0;
                                    var t1,i1,z1:Int;
                                    subm=new Array();
                                    t1=0;
                                    var nuopt=b.options.length;
                                    while (t<b.options.length){
                                        i1=i; z1=z; t1=t;
                                        subm[t]={
                                            text:b.options[t].label,
                                            //margin: '0 10 5 0',
                                            xtype : if((b.options[t].isTitle==false)&&(b.options[t].isLabelTitle==false)) 'button';
                                            else 'label',
                                            cls :
                                            if((b.options[t].isTitle==true)||(b.options[t].isLabelTitle==true)) {
                                                if(b.options[t].isTitle==true) 'x-btn-viewoptions-title';
                                                else 'x-btn-viewoptions-label';
                                            }
                                            else{
                                                if (b.optionSelected[0]==t)'x-btn-viewoptions-default';
                                                else 'x-btn-viewoptions';
                                            },

                                            handler:
                                            if((b.options[t].isTitle==false)&&(b.options[t].isLabelTitle==false)){
                                                var t2=t;
                                                function(){

                                                    var container=getApplication().getSingleAppContainer();

                                                    closeAnnotWindows();

                                                    var check:Bool;
                                                    check=changeDefaultOption(t2,i1,z1);
                                                    showAnnotation(b.annotCode,check);
                                                    container.hideExportSubMenu();
                                                    container.hideHelpingDiv();
                                                    container.hideSubMenuToolBar();
                                                    onSubmenu=false;
                                                    container.clearOptionsToolBar();
                                                    createViewOptions();
                                                    container.addElemToOptionsToolBar(viewOptions);
                                                }
                                            }
                                            else{
                                                function(){
                                                    //
                                                }
                                            },
                                            tooltip: { text: b.options[t].helpText}
                                        };
                                        t++;
                                    }
                                    function(e){
                                        var h = e.ownerCt.y - e.ownerCt.ownerCt.el.dom.scrollTop;
                                        var n=t;
                                        var container=getApplication().getSingleAppContainer();

                                        //closeAnnotWindows();

                                        container.hideHelpingDiv();
                                        container.clearSubMenuToolBar();
                                        container.addElemToSubMenuToolBar(subm);

                                        container.setTopSubMenuToolBar(h);
                                        container.setHeightSubMenuToolBar(n*25);

                                        container.showSubMenuToolBar();
                                        onSubmenu=true;
                                    }
                                }
                                else{
                                    function(e){
                                        var container = getApplication().getSingleAppContainer();
                                        container.hideHelpingDiv;

                                        // closeAnnotWindows();

                                        container.hideSubMenuToolBar();
                                        onSubmenu=false;
                                    }
                                }

                            }
                        }
                    ];

                    var _viewOptions = {
                        xtype: "container",
                        cls: "x-group2btns",
                        layout: "hbox",
                        items: _viewOptions_Items
                    };

                    viewOptions[j]=_viewOptions;

                }
                j++;z++;
            }

            i++;
        }
        var l=this.activeAnnotation.length;
        var i=1;
        var num=0;
        var showhide=false;
        while(i < l && num<2){
            if(this.activeAnnotation[i]==true){
                num++;
            }
            i++;
        }
        if(num==2) showhide=true;
        if(showhide==true){
            viewOptions[j]={
                text:'Hide all',
                margin: '20 10 5 0',
                xtype : 'button',
                cls : 'x-btn-viewoptions x-btn-viewoptions-hide',
                handler: function(){
                    onSubmenu=false;
                    var l=this.activeAnnotation.length;
                    var i=1;
                    while(i < l){
                        this.activeAnnotation[i]=false;
                        i++;
                    }

                    var container = getApplication().getSingleAppContainer();
                    container.hideExportSubMenu();
                    container.hideHelpingDiv();

                    closeAnnotWindows();

                    container.hideSubMenuToolBar();
                    container.clearOptionsToolBar();
                    createViewOptions();
                    container.emptyLegend();
                    container.addElemToOptionsToolBar(viewOptions);
                },
                listeners:{
                    mouseover:
                    function(e){
                        onSubmenu=false;
                        var container = getApplication().getSingleAppContainer();
                        container.hideExportSubMenu();
                        container.hideHelpingDiv();

                       // closeAnnotWindows();

                        container.hideSubMenuToolBar();
                    }
                },
                tooltip: {dismissDelay: 10000, text: 'Remove all Annotations'}
            };
        }
    }
    function getJSonViewOptions(){
        #if CHROMOHUB
        standaloneMode = true;
        #end

        CommonCore.getContent(
            "/static/json/ViewOptionsBtns.json",function(content) {
                var d : Dynamic = WorkspaceApplication.getApplication().getActiveProgram();
                d.jsonFile = haxe.Json.parse(content);

                getJSonTips();

            },function(err) {
                WorkspaceApplication.getApplication().debug(err);
                getJSonTips();
            });
    }
    function getJSonTips(){
        #if CHROMOHUB
        standaloneMode = true;
        #end

        if(standaloneMode){
            CommonCore.getContent("/static/json/tipsHtmlData.json",function(content) {
                var d : Dynamic = WorkspaceApplication.getApplication().getActiveProgram();
                d.jsonTipsFile = haxe.Json.parse(content);

                WorkspaceApplication.getApplication().setMode(ScreenMode.SINGLE_APP);

                #if CHROMOHUB
                var d: Dynamic = WorkspaceApplication.getApplication();
                d.viewPoint.show();
                #end

            },function(err) {
                WorkspaceApplication.getApplication().debug(err);

                WorkspaceApplication.getApplication().setMode(ScreenMode.SINGLE_APP);

                #if CHROMOHUB
                var d: Dynamic = WorkspaceApplication.getApplication();
                d.viewPoint.show();
                #end
            });
        }

    }

    public function showTips(show:Bool){
        var cookies = untyped __js__('Cookies');
        if(show==true){
            //we need to show the Tip of the Day when startup

            var cookie = cookies.getJSON('tipday');

            if(cookie != null) cookies.remove('tipday');
        }else{
            cookies.set('tipday',false, {'expires': 14});
        }
    }

    function changeDefaultOption(newDef:Int, groupBtn:Int, btn:Int):Bool{

            jsonFile.btnGroup[groupBtn].buttons[btn].optionSelected[0]=newDef;

//when we select another suboption we need to be sure that the already got annotation is false, otherwise we don't get the data from the database if the user selects again the previous selected otpions
            var currentAnnot=jsonFile.btnGroup[groupBtn].buttons[btn].annotCode;
            var u =annotations[currentAnnot].optionSelected[0];
            if(u!=newDef){
                var alias= annotations[currentAnnot].options[u];
                if(this.alreadyGotAnnotation.exists(alias)==true){
                    this.alreadyGotAnnotation.remove(alias);
                }
            }
            annotations[jsonFile.btnGroup[groupBtn].buttons[btn].annotCode].optionSelected[0]=newDef;

            return true;
    }

}
