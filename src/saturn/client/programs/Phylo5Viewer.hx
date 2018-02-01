/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.client.programs.SimpleExtJSProgram;
import saturn.util.StringUtils;

import bindings.Ext;

import saturn.client.workspace.Workspace;
import saturn.client.workspace.Workspace.WorkspaceListener;

import saturn.core.domain.Alignment;
import saturn.client.workspace.Phylo5WorkspaceObject;
import saturn.client.workspace.DNAWorkspaceObject;
import saturn.client.workspace.ProteinWorkspaceObject;

import saturn.core.DNA;

import saturn.client.WorkspaceApplication;

class Phylo5Viewer  extends SimpleExtJSProgram  {
	static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ Phylo5WorkspaceObject ];
	
    var theComponent : Dynamic;

    var internalFrameId : String;
	
	var canvas : Dynamic;
	
	var newickStr : String = '';
	
	static var newLineReg = ~/\n/g;
    static var carLineReg = ~/\r/g;
    static var whiteSpaceReg = ~/\s/g;

    public function new(){
        super();
    }

    override public function emptyInit() {
		super.emptyInit();

        this.internalFrameId = 'INTERNAL_ALN_FRAME';

        var self : Phylo5Viewer  = this;

        theComponent = Ext.create('Ext.panel.Panel', {
            title: 'Phylo5 Viewer',
            width:'100%',
            height: '95%',
            autoScroll : true,
            layout : 'fit',
            items : [{
                        xtype : "component",
                        itemId: internalFrameId,
                        autoEl : {
                            tag : "div"
                        },
						height : '100%',
						width : '100%'
			}],
            listeners : { 
                'render' : function() { self.initialiseDOMComponent(); },
                'keypress': {
                    element: 'el',
                    fn: function(){ 
                        js.Browser.alert('Hello');
                    }
                }
            },
            cls: 'x-tree-background'
        });

        registerDropFolder('Sequences', null, true);
    }
	
	public function setTree( tree : String ) {
		newickStr = tree;

        var w0 : Phylo5WorkspaceObject = cast(super.getActiveObject(Phylo5WorkspaceObject), Phylo5WorkspaceObject);

        w0.newickStr = tree;
		
		if (newickStr == null || newickStr == '') {
            theComponent.addCls('x-tree-background');

			return ;
		}else{
            theComponent.removeCls('x-tree-background');
        }
		
		newickStr = whiteSpaceReg.replace(newickStr, "");
        newickStr = newLineReg.replace(newickStr,"");
        newickStr = carLineReg.replace(newickStr, "");
		
		var newickParser = new Phylo5NewickParser();
		
        var rootNode = newickParser.parse(newickStr);
        rootNode.x = 0;
        rootNode.y = 0;
        rootNode.wedge = 2*Math.PI;
        rootNode.angle = 0;
            
        var dist : Int = 40;
        var ratio : Float = 0.6;
            
        rootNode.preOrderTraversal(dist, ratio);

        canvas = theComponent.down('component').getEl().dom;
            
        var parentWidth : Int = canvas.clientWidth;
        var parentHeight : Int = canvas.clientHeight;
            
        var minSize : Float = Math.min(parentWidth, parentHeight);
            
		canvas = new Phylo5SVGRenderer(parentWidth, parentHeight, canvas);
            
        var radialRendererObj  : Dynamic = new Phylo5RadialTreeLayout(parentWidth, parentHeight);
            
        radialRendererObj.render(rootNode, [], canvas);
		
		var self : Phylo5Viewer = this;
		
		// map one key by key code
		var map = new bindings.KeyMap(theComponent.getEl(), {
			key: '+',
			shift : true,
			fn: function() {
				zoomIn();
			}
		});
	}

    public function zoomIn(){
        canvas.zoomIn();
    }

    public function zoomOut(){
        canvas.zoomOut();
    }

    override public function setTitle(title : String){
        theComponent.setTitle(title);
    }

    override public function getComponent() : Dynamic {
        return theComponent;
    }

    override
    public function onFocus(){
        super.onFocus();

        getApplication().hideMiddleSouthPanel();

        var self : Phylo5Viewer = this;

        getApplication().getViewMenu().add({
            text : 'Update tree',
            handler : function(){
                self.updateAlignment();
            }
        });
		
		getApplication().getViewMenu().add({
            text : 'Zoom in',
            handler : function(){
                zoomIn();
            }
        });
		
		getApplication().getViewMenu().add({
            text : 'Zoom out',
            handler : function(){
                zoomOut();
            }
        });
		
		getApplication().getFileMenu().add({
            text : 'Import all Protein Sequences',
            handler : function(){
                self.addAllProteinSequencesFromWorkspace();
            }
        });
		
		getApplication().getFileMenu().add({
            text : 'Import all DNA Sequences',
            handler : function(){
                self.addAllDNASequencesFromWorkspace();
            }
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-export',
            text: 'Export',
            handler: function(){
                export();
            },
            tooltip: {dismissDelay: 10000, text: 'Export tree as SVG (open in Illustrator or Inkscape)'}
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text: 'Update',
            handler: function(){
                self.updateAlignment();
            },
            tooltip: {dismissDelay: 10000, text: 'Update tree with current sequences'}
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-magplus',
            text: 'Zoom In',
            handler: function(){
                self.canvas.zoomIn();
            },
            tooltip: {dismissDelay: 10000, text: 'Zoom in on tree (Ctrl + Left click)'}
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-magminus',
            text: 'Zoom Out',
            handler: function(){
                self.canvas.zoomOut();
            },
            tooltip: {dismissDelay: 10000, text: 'Zoom out of tree (Shift + Left click)'}
        });

         getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text: 'Import Protein',
            handler: function(){
                self.addAllProteinSequencesFromWorkspace();
            },
            tooltip: {dismissDelay: 10000, text: 'Import all protein sequences from the workspace (click update to update tree)'}
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text: 'Import DNA',
            handler: function(){
                self.addAllDNASequencesFromWorkspace();
            },
            tooltip: {dismissDelay: 10000, text: 'Import all DNA sequences from the workspace (click update to update tree)'}
        });
    }

    public function setAlignmentURL(alignmentURL : String){
        var frame : Dynamic = theComponent.getComponent(internalFrameId).getEl().dom;
        frame.src = alignmentURL;

        this.getActiveAlignmentObject().setAlignmentURL(alignmentURL);
    }

    public function updateAlignment(){
        var self : Phylo5Viewer = this;

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

                        self.setTree(obj);
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


    public function getActiveAlignmentObject() : Alignment {
        var activeObject : WorkspaceObject<Dynamic> = super.getActiveObject(Phylo5WorkspaceObject);

        if(activeObject != null){
            var w0 : Phylo5WorkspaceObject = cast(activeObject, Phylo5WorkspaceObject);
    
            return w0.getObject();
        }else{
            return null;
        }
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);


        var w0 : Phylo5WorkspaceObject = cast(super.getActiveObject(Phylo5WorkspaceObject), Phylo5WorkspaceObject);
        var alnObj : Alignment = w0.getObject();

        var alnUrl : String = alnObj.getAlignmentURL();

        if(alnUrl != null){
            this.setAlignmentURL(alnUrl);
        }

        setTitle(w0.getName());

        if(w0.newickStr != null){
            setTree(w0.newickStr);
        }
    }

    public function getAlignmentObject() : Alignment{
        var w0 : Phylo5WorkspaceObject = cast(super.getActiveObject(Phylo5WorkspaceObject), Phylo5WorkspaceObject);
        return w0.getObject();
    }

    public function export(){
        var domElem = theComponent.down('component').getEl().dom;

        /*var domElem = theComponent.down('panel').down('component[itemId=gridvar_container]').getEl().dom;

        var svgContainerElem = Ext.get(domElem).query('.nibr-gridVar-heatmap')[0];*/

        getApplication().saveTextFile(domElem.innerHTML, getActiveObjectName() + '.svg');
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-tree',
                html:'Phylogenetic<br/>Viewer',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new Phylo5WorkspaceObject(new Alignment(), "Tree"), true);
                },
                tooltip: {dismissDelay: 10000, text: 'Generate a phylogenetic tree from DNA or Protein sequences'}
            }
        ];
    }
}
