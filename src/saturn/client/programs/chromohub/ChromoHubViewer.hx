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

package saturn.client.programs.chromohub;

import phylo.PhyloUtil;
import phylo.PhyloAnnotationManager;
import saturn.core.Table;
import saturn.core.domain.Alignment;
import js.html.Event;
import saturn.core.Util;

import saturn.client.programs.blocks.BaseTable;
import js.html.Uint8ClampedArray;
import phylo.PhyloScreenData;
import saturn.client.programs.SimpleExtJSProgram;
import saturn.util.StringUtils;
import js.html.CanvasElement;

import bindings.Ext;

import saturn.client.workspace.Workspace;
import saturn.client.workspace.Workspace.WorkspaceListener;

import saturn.client.workspace.ChromoHubWorkspaceObject;
import saturn.client.workspace.DNAWorkspaceObject;
import saturn.client.workspace.ProteinWorkspaceObject;

import phylo.PhyloRadialTreeLayout;
import phylo.PhyloCanvasRenderer;
import phylo.PhyloHubMath;
//import saturn.client.programs.ChromoHub.ChromoHubSVGRenderer;
import phylo.PhyloNewickParser;
import phylo.PhyloRendererI;
import phylo.PhyloTreeNode;
import phylo.PhyloAnnotation;

import saturn.core.DNA;
import saturn.client.programs.blocks.BaseTable;

import saturn.client.core.CommonCore;
import saturn.client.programs.chromohub.ChromoHubViewerHome;

import saturn.client.WorkspaceApplication;
typedef UndoLast = {
    var data: PhyloScreenData;
    var angle: Float;
    var x: Dynamic;
    var y: Dynamic;
    var clock: Bool;
}

class ChromoHubViewer  extends SimpleExtJSProgram  {
	static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ ChromoHubWorkspaceObject ];

    public var rootNode : PhyloTreeNode;
    public var theComponent : Dynamic;
    public var radialR  : Dynamic;
    var internalFrameId : String;
    public var currentView: Int; // 0 = Landing page, 1 = Tree View, 2 = Annotation Table View

	var canvas : Dynamic;
    public var dom : Dynamic;

    /*var centrex: Dynamic;
    var centrey: Dynamic;
    var zoom: Dynamic;*/

	public var newickStr : String = '';




    public var geneMap:Map<String,PhyloTreeNode>;

    var viewOptionsActive : Bool;
    var controlToolsActive : Bool;
    public var tableActive : Bool;



    var jsonTipsFile : Dynamic;
    public var tableAnnot :Table;
    public var baseTable :BaseTable;

    public var tips: Array<Dynamic>;
    public var tipActive=0;

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



    var undolist: Array<UndoLast>;
    var updatedlist: Array<UndoLast>;
    var recovered=false;
    var tipOfDay=true;

    var standaloneMode = false;
    var singleAppContainer : SingleAppContainer;

    var enableEditMode = true;



    var currentAdjustmentColour = null;
    var enableColourAdjust = false;

    var subtreeName = null;

    var drawingMode = ChromoHubDrawingMode.CIRCULAR;

    public var config = new PhyloCanvasConfiguration();

    var enableColourAdjustWedge : Bool = false;
    var currentWedgeColour : String = null;

    public var annotationManager : ChromoHubAnnotationManager;

    public function new(){
        super();
    }

    override public function emptyInit() {
        super.emptyInit();


        annotationManager = new ChromoHubAnnotationManager(this);

        config.enableTools = true;
        config.enableZoom = true;
        config.enableToolbar = true;

        //currentView = 1;

        //init structures
        undolist=new Array();
        updatedlist=new Array();

        config.highlightedGenes=new Map<String, Bool>();

        geneMap=new Map<String, PhyloTreeNode>();

        #if UBIHUB
        treeType='gene';

        annotationManager.treeType = treeType;

        #else
        treeType='domain';


        annotationManager.treeType = treeType;

        #end
        treeName='';

        annotationManager.treeName = treeName;

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
                /*'keypress': {
                    element: 'el',
                    fn: function(){
                        js.Browser.alert('Hello');
                    }
                }*/
            },
            cls: 'x-tree-background'
        });

        //if(!standaloneMode){
        //    singleAppContainer = PhyloScreenData SingleAppContainer();
        //    singleAppContainer.setProgram(this);
        //}

        registerDropFolder('Sequences', WorkspaceObject, true);
    }

    private function afterRender(panel) {

        var moving : String = 'No';
        var leaving=false;
        var current_x,current_y, current_mx, current_my, new_x,new_y, new_mx, new_my: Dynamic;

    }

    public function newposition(new_x:Dynamic, new_y:Dynamic){
        this.canvas.newPosition(new_x, new_y);

        return;
    }

    public function redraw(){
        if(this.canvas == null){
            //too early
            return;
        }else{
            this.canvas.redraw();
        }
    }

	public function setTreeFromNewickStr( myNewickStr : String ) {
        if(myNewickStr == '' || myNewickStr == null){
            return;
        }

        getObject().newickStr = myNewickStr;

        newickStr = myNewickStr;

        var parent = theComponent.down('component').getEl().dom;

        canvas = PhyloUtil.drawRadialFromNewick(newickStr, parent,config, annotationManager);

        rootNode = canvas.rootNode;
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
        if(annotationManager.jsonFile.btnGroup.length==0){
            a.debug('No buttons groups defined in JSON File');
            m.showMessage('Alert','Annotations JSon file is not correct.');
            return false;
        }
        while(i< annotationManager.jsonFile.btnGroup.length){
            j=0;
            while(j<annotationManager.jsonFile.btnGroup[i].buttons.length){
                atLeastOneBtn=true;
                var btn=annotationManager.jsonFile.btnGroup[i].buttons[j];

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
                                btn.optionSelected=PhyloScreenData Array();
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
        if(annotationManager.annotations[currentAnnot].legend!=''){
            if(activate==false){
                //we need to show the legend of that annotation
                getApplication().getSingleAppContainer().addImageToLegend(annotationManager.annotations[currentAnnot].legend, currentAnnot);

            }
            else{
                // we need to remove the legend of that annotation
                getApplication().getSingleAppContainer().removeComponentFromLegend(currentAnnot);
            }
        }
    }

    public function zoomIn(activeAnnotation:Dynamic){
        if(standaloneMode){
            var container = getApplication().getSingleAppContainer();
            annotationManager.closeAnnotWindows();
            container.hideHelpingDiv();
        }

        this.canvas.zoomIn();

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
            annotationManager.closeAnnotWindows();
        }

        this.canvas.zoomOut();
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
        if(annotationManager.jsonFile != null){
            var res=checkAnnotationJSonData();
            if (res==false){
                WorkspaceApplication.getApplication().showMessage('Alert','Annotations JSon file is not correct.');
                return;
            }else {
                annotationManager.fillAnnotationwithJSonData();
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
               // if(undolist.length>0) moveNode(undolist[undolist.length-1].data,true, true);
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
                                        config.editmode=false;
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
                                config.editmode=false;
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
                                config.editmode=false;
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

        config.editmode=false;
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

    private function addControlBtnsToCentralPanel(){
        if(standaloneMode){
            var text:String;
            if(this.treeType=='domain'){
                text=' tree based on alignment of the '+this.treeName+' domain';
            }else{
                text=' tree based on alignment of full-length proteins';
            }
            if(this.treeName!=null ) text=this.treeName+text;

            config.title = text;

            var container=getApplication().getSingleAppContainer();

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
                    zoomIn(annotationManager.activeAnnotation);
                },
                tooltip: {dismissDelay: 10000, text: 'Zoom in on tree'}
            });

            addCanvasButton({
                cls:'x-btn-magminus',
                xtype: 'button',
                handler: function(){
                    zoomOut(annotationManager.activeAnnotation);
                },
                tooltip: {dismissDelay: 10000, text: 'Zoom out of tree'}
            });
        }
    }

    public function redrawTree(){
        setTreeFromNewickStr(newickStr);
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
                    getApplication().showMessage('Alert','Please select a family');
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
                        //this.canvas.parent.removeChild( this.canvas.canvas);//otherwise, we'll get two trees
                        this.canvas.destroy();
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
                        //this.activeAnnotation=PhyloScreenData Array();//improve it

                        annotationManager.createViewOptions();
                        container.clearOptionsToolBar();
                        container.addElemToOptionsToolBar(annotationManager.viewOptions);
                        container.optionsToolBar.doLayout();
                        container.showOptionsToolBar();
                    }
                    container.legendPanel=null;
                    container.createLegendPanel();
                    var i:Int;
                    var needToExpandLegend=false;
                    for (i in 0...annotationManager.activeAnnotation.length){
                        if (annotationManager.activeAnnotation[i]==true){
                            needToExpandLegend=true;
                            container.addImageToLegend(annotationManager.annotations[i].legend, i);
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
        else if(config.editmode==true) return true;
        else return false;
    }

    public function renderTable(){
        if(!standaloneMode){
            return;
        }

        var container=getApplication().getSingleAppContainer();
        //while(undolist.length>0){
        //    moveNode(null,true, true);//if we are undoing actions, the undolist is doing pop so increasing its length
       // }
        config.editmode=false;
        //container.viewClose(true);
        container.hideEditToolBar();
        undolist=new Array();
        currentView=2;

        if(this.canvas!=null){
            this.canvas.destroy();
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

        annotationManager.closeAnnotWindows();

        if(currentView!=2){

            if( annotationManager.annotations[1]!=null && annotationManager.annotations[1].fromresults!=null) annotationManager.annotations[1].fromresults[1]=0;
            if(treeName==''){
                if(annotationManager.searchedGenes.length==0) WorkspaceApplication.getApplication().showMessage('Alert','Use the search box on your righ to add genes.');
                else{
                    renderTable();
                }
            }
            else{
                var keepgoing=false;
                if(config.editmode==true){
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
        annotationManager.fillInDataInAnnotTable(type,function(d, error){
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
                    annotationManager.closeAnnotWindows();
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

        //while(undolist.length>0){
        //    moveNode(null,true, true);//if we are undoing actions, the undolist is doing pop so increasing its length
        //}

        config.editmode=false;
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
            this.canvas.destroy();
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

                    annotationManager.closeAnnotWindows();
                    if( annotationManager.annotations[1]!=null &&  annotationManager.annotations[1].fromresults!=null)  annotationManager.annotations[1].fromresults[1]=0;
                    var keepgoing=false;
                    if(config.editmode==true){
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
                        getApplication().showMessage('Alert','Please select a family');
                    }
                    else if(currentView==2){ //annotations table
                        // The user has listed her own genes, and want to generate the tree
                        WorkspaceApplication.getApplication().showMessage('Alert','This functionality is not available. Please select a family domain from Home page.');
                    }
                }else{
                    annotationManager.menuScroll=0;
                    if( annotationManager.annotations[1]!=null &&  annotationManager.annotations[1].fromresults!=null)  annotationManager.annotations[1].fromresults[1]=0;
                    showTree(newickStr);
                    /*var parentWidth : Int = this.dom.clientWidth;
                    var parentHeight : Int = this.dom.clientHeight;
                    this.centrex=Math.round(parentWidth/2);
                    this.centrey=Math.round(parentHeight/2);
                    centerCanvas();*/
                    var elem=js.Browser.document.getElementById('optionToolBarId');
                    elem.scrollTop=annotationManager.menuScroll;
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
            if(config.editmode==true){
                if(undolist.length>0){
                    WorkspaceApplication.getApplication().userPrompt('Question', 'You are going to lose your changes. Do you want to continue?', function(){
                        keepgoing=false;
                        //while(undolist.length>0){
                         //   moveNode(null,true, true);//if we are undoing actions, the undolist is doing pop so increasing its length
                        //}
                        config.editmode=false;
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

               // while(undolist.length>0){
                //    moveNode(null,true, true);//if we are undoing actions, the undolist is doing pop so increasing its length
                //}
                config.editmode=false;
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
            leaves= canvas.rootNode.targets;
        }else{
            leaves=annotationManager.searchedGenes;
        }

        var d=annotationManager.dataforTable(annotationManager.annotations, leaves);

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
            annotationManager.closeAnnotWindows();
        });

        var tt=baseTable.getComponent();
        tt.addCls('x-tableAnnot');

        var container=getApplication().getSingleAppContainer();

        container.setCentralComponent(theComponent);
        container.addComponentToCentralPanel(tt);
        this.theComponent.doLayout();
        container.hideProgressBar();
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
            annotationManager.searchedGenes=new Array();
            geneMap=new Map<String, PhyloTreeNode>();
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
        var title = 'Search/Add Genes';

        #if UBIHUB
        title = 'Search in trees';
        #end

        centralTargetPanel.add({
            xtype: 'label',
            text: title,
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
        /*if(standaloneMode){
            var container = getApplication().getSingleAppContainer();
            container.hideExportSubMenu();
            container.hideHelpingDiv();

            annotationManager.closeAnnotWindows();
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

        this.radialR= new PhyloRadialTreeLayout(this.canvas.canvas.width, this.canvas.canvas.height);

        if(drawingMode == ChromoHubDrawingMode.STRAIGHT){
            this.radialR.render(this.rootNode, this.canvas, annotationManager.activeAnnotation,annotationManager.annotations);
        }else if(drawingMode == ChromoHubDrawingMode.CIRCULAR){
            this.rootNode.dist = 50;
            this.rootNode.ratio = 0.00006;

            this.radialR.renderCircle(this.rootNode, this.canvas, annotationManager.activeAnnotation,annotationManager.annotations);
        }

        this.canvas.cx=this.centrex;
        this.canvas.cy=this.centrey;
        ctx.restore();

        this.canvas.canvas.toBlob(function (blob) {
            WorkspaceApplication.getApplication().saveFile(blob, this.treeName+'_'+this.treeType+'_tree.png');
        });

        newposition(0,0);*/
    }

    public function exportSVG(){
        /*if(standaloneMode){
            var container = getApplication().getSingleAppContainer();
            container.hideExportSubMenu();
            container.hideHelpingDiv();

            annotationManager.closeAnnotWindows();
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

        this.radialR= new PhyloRadialTreeLayout(width, height);

        if(drawingMode == ChromoHubDrawingMode.STRAIGHT){
            this.radialR.render(this.rootNode, this.canvas, annotationManager.activeAnnotation,annotationManager.annotations);
        }else if(drawingMode == ChromoHubDrawingMode.CIRCULAR){
            this.rootNode.dist = 50;
            this.rootNode.ratio = 0.00006;

            this.radialR.renderCircle(this.rootNode, this.canvas, annotationManager.activeAnnotation,annotationManager.annotations);
        }

        this.canvas.ctx = originalCanvas;
        newposition(0,0);

        var d : Dynamic = cast svgGraphCanvas;

        WorkspaceApplication.getApplication().saveTextFile(d.getSerializedSvg(true), this.treeName+'_'+this.treeType+'_tree.svg');*/

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

            annotationManager.closeAnnotWindows();
        }

        var keepgoing=false;
        if(recovered==true){
            keepgoing=true;
        }else if(config.editmode==true){
            if(undolist.length>0){
                WorkspaceApplication.getApplication().userPrompt('Question', 'You are going to lose your changes. Do you want to continue?', function(){
                    keepgoing=false;
                    //while(undolist.length>0){
                    //    moveNode(null,true, true);//if we are undoing actions, the undolist is doing pop so increasing its length
                    //}
                    config.editmode=false;
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
                    annotationManager.activeAnnotation=new Array();
                    var go=treeViewInterface(); //return true if we can show the tree
                    if(go==true){
                        var a=annotationManager.annotations;
                        setTreeFromNewickStr(myNewickStr);
                        this.rootNode.targetFamily=this.treeName;
                    }
                    newposition(0,0);

                    var elem=js.Browser.document.getElementById('optionToolBarId');
                    elem.scrollTop=annotationManager.menuScroll;
                });
            }else keepgoing=true;
        }else keepgoing=true;

        if(keepgoing==true){

            if(recovered==false){
                //while(undolist.length>0){
                //    moveNode(null,true, true);//if we are undoing actions, the undolist is doing pop so increasing its length
                //}
                undolist=new Array();
                if(viewOptionsActive==false){
                    viewOptionsActive=true;
                    if(standaloneMode){
                        container.showOptionsToolBar();
                    }

                    var elem=js.Browser.document.getElementById('optionToolBarId');
                    elem.scrollTop=annotationManager.menuScroll;
                }
            }

            annotationManager.activeAnnotation=new Array();
            var go=treeViewInterface(); //return true if we can show the tree
            if(recovered==false){
                config.editmode=false;

                if(standaloneMode){
                    container.hideEditToolBar();
                }
            }

            if(go==true){
                var a=annotationManager.annotations;
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

                elem.scrollTop=annotationManager.menuScroll;
            }
        }
    }

    public function showSearchedGenes(targetId :String){
        if(currentView==0){
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery("getFamilies",{gene: '%'+targetId+'%'}, null, true, function(db_results, error){

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

        annotationManager.treeName = '';

        this.treeType='gene';
        this.newickStr='';

        if(geneMap.exists(targetId)==true){
            WorkspaceApplication.getApplication().showMessage('Alert','This gene already exists in the gene list.');
        }else{
            annotationManager.searchedGenes[annotationManager.searchedGenes.length]=targetId;

//we need to create a TreeNode and add it into our geneMap structure
            var geneNode=new PhyloTreeNode(null, targetId, true, 0);

            geneNode.l =1;
            geneNode.annotations= new Array();
            geneNode.activeAnnotation= new Array();

            geneMap.set(targetId,geneNode);

            if(currentView==0){
                treeName='';

                annotationManager.treeName = '';

                tableViewFunction();
            }
            else if(currentView==2){
                generateAnnotTable();
            }
        }

    }

    private function generateTree(name: String, type:String, subtreeName : String = null){
        annotationManager.treeName = name;
        annotationManager.subtreeName = subtreeName;
        annotationManager.treeType = treeType;

        config.drawingMode = PhyloDrawingMode.CIRCULAR;

        WorkspaceApplication.getApplication().debug(name);
        annotationManager.searchedGenes=new Array();
        this.config.highlightedGenes=new Map<String, Bool>();
        this.geneMap=new Map<String, PhyloTreeNode>();

        if(((name=='KAT')||(name=='E1')||(name=='E2')||(name=='NON_USP')||(name=='USP')||(name=='Histone')||(name=='MACRO')||(name=='WDR')||(name=='NUDIX'))&&(type=='domain')){
           // WorkspaceApplication.getApplication().showMessage('Alert','There is no domain-based alignment for this family. This phylogenetic tree is based on full-length alignment.');

            if(userDomainMessage==true){
                #if !UBIHUB
                var container=getApplication().getSingleAppContainer();
                container.showMessageDomainWindow();
                #end
            }
            this.treeType='gene';

            annotationManager.treeType = treeType;

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

                    annotationManager.treeName = this.treeName;
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
                            var node:PhyloTreeNode;
                            var alpha:Float;
                            var n:Dynamic;
                            var auxpop=auxlist.pop();
                            var z=0;
                            var d:PhyloScreenData;
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

                                if(drawingMode == ChromoHubDrawingMode.STRAIGHT){
                                    node.children[i].preOrderTraversal2(0);
                                }else if(drawingMode == ChromoHubDrawingMode.CIRCULAR){
                                    node.children[i].preOrderTraversal(0);
                                }


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

            /*var parentWidth : Int = this.dom.clientWidth;
            var parentHeight : Int = this.dom.clientHeight;
            this.centrex=Math.round(parentWidth/2);
            this.centrey=Math.round(parentHeight/2);
            centerCanvas();*/
        }
    }

    /***************************
     We create here the arrays of all target buttons
    ************************************/



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

                                       annotationManager.treeType = treeType;
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

                                       annotationManager.treeType = treeType;
                                   }
                               }
                           }
                       ],
                       listeners: {
                           change: function (field, newValue, oldValue) {
                               treeType=newValue.type;

                               annotationManager.treeType = treeType;

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
                 margin: '0 0 5 0',
                 style:{
                     color: '#4d749f'
                 }
             },
             {
                 xtype:'panel',
                 layout:'hbox',
                 items:[
                     {
                         margin: '0 15 15 0',
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
                         margin: '0 15 15 0',
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
                 xtype:'panel',
                 layout:'hbox',
                 items:[
                    {
                     xtype: 'component',
                     html:'
                         <form>
                             <fieldset>
                                 <div style="width:100%; padding:10px 0;">
                                    <span>Show only E3 ligases involved in UPS with confidence <label>&gt=1</label><input type="radio" name="usp_confidence" value="1" />;&nbsp;&nbsp;<label>&gt=2</label><input type="radio" name="usp_confidence" value="2" checked />;&nbsp;&nbsp;<label>&gt=3</label><input type="radio" name="usp_confidence" value="3" />;&nbsp;&nbsp;<label>show all</label><input type="radio" name="usp_confidence" value="Cluster" /> <span class="tooltip">?<span class="tooltiptext">Indicates the confidence level that a protein is involved in the ubiquitin proteasome system. "degrad" found in Uniprot function: 1 point. "degrad" found in Reactome pathway(s): 1 point. "degrad" found in a Reactome pathway enriched among biogrid interactors [pathway must be found in at least 3 interactors and enriched at least 3 fold compared with proteome]: 1 point</span></span>
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
                 xtype:'label',
                 text:'E3 ligases',
                 margin: '0 0 5 0',
                 style:{
                     color: '#4d749f'
                 }
             },
             {
                 xtype:'panel',
                 layout:'hbox',
                 items:[
                     {
                         margin: '0 15 15 0',
                         xtype : 'button',
                         cls : if (mapFam.exists('E3_Complex') == true && treeType == 'domain')'x-btn-target-found x-btn-target-e3-complex' else if (mapFam.exists('E3_Complex') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-e3-complex-gene' else if (mapFam.exists('E3_Complex') == false && treeType == 'domain') 'x-btn-target-e3-complex' else 'x-btn-target-e3-complex-gene',
                         handler: function() {
                             treeName = 'E3_Complex';

                             var d : Dynamic = js.Browser.document.querySelector('input[name="usp_confidence"]:checked');

                             subtreeName = treeName + '_' + d.value;

                             generateTree(treeName, treeType,subtreeName);
                         },
                         tooltip: {dismissDelay: 10000, text: if (treeType == 'gene') 'Multi-subunit E3 ligases' else 'There is no domain-based alignment for this family. Select "full length proteins" above to see access this tree.'}
                     },
                     {
                         margin: '0 15 15 0',
                         xtype : 'button',
                         cls : if (mapFam.exists('E3_Ligase') == true && treeType == 'domain')'x-btn-target-found x-btn-target-e3-simple' else if (mapFam.exists('E3_Ligase') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-e3-simple-gene' else if (mapFam.exists('E3_Ligase') == false && treeType == 'domain') 'x-btn-target-e3-simple' else 'x-btn-target-e3-simple-gene',
                         handler: function() {
                             treeName = 'E3_Ligase';

                             var d : Dynamic = js.Browser.document.querySelector('input[name="usp_confidence"]:checked');

                             subtreeName = treeName + '_' + d.value;

                             generateTree(treeName, treeType,subtreeName);
                         },
                         tooltip: {dismissDelay: 10000, text: if (treeType == 'gene') 'Simple E3 ligases' else 'There is no domain-based alignment for this family. Select "full length proteins" above to see access this tree.'}
                     }
                 ]
             }
        ];

        var level4Items :Array<Dynamic> =[
             {
                 xtype:'label',
                 text:'DUBs',
                 margin: '0 0 5 0',
                 style:{
                     color: '#4d749f'
                 }
             },
             {
                 xtype:'panel',
                 layout:'hbox',
                 items:[
                     {
                         margin: '0 15 15 0',
                         xtype : 'button',
                         cls : if (mapFam.exists('NON_USP') == true && treeType == 'domain')'x-btn-target-found x-btn-target-non-usp' else if (mapFam.exists('NON_USP') == true && treeType == 'gene') 'x-btn-target-found x-btn-target-non-usp-gene' else if (mapFam.exists('NON_USP') == false && treeType == 'domain') 'x-btn-target-non-usp' else 'x-btn-target-non-usp-gene',
                         handler: function() {
                             treeName = 'NON_USP';

                             subtreeName = treeName;

                             generateTree(treeName, treeType);
                         },
                         tooltip: {dismissDelay: 10000, text: if (treeType == 'gene') 'NON-USP' else 'There is no domain-based alignment for this family. Select "full length proteins" above to see access this tree.'}
                     },
                     {
                         margin: '0 15 15 0',
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
                         items: level3Items
                     },
                     {
                         xtype: 'panel',
                         layout:'hbox',
                         items:level2Items
                    },
                     {
                         xtype: 'panel',
                         layout: 'vbox',
                         items: level4Items
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

/************ View Options Array  from JSON file****/

    function getJSonViewOptions(){
        #if CHROMOHUB
        standaloneMode = true;
        #end

        CommonCore.getContent(
            "/static/json/ViewOptionsBtns.json",function(content) {
                var d : Dynamic = WorkspaceApplication.getApplication().getActiveProgram();
                d.annotationManager.jsonFile = haxe.Json.parse(content);


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



}

enum ChromoHubDrawingMode{
    STRAIGHT;
    CIRCULAR;
}

