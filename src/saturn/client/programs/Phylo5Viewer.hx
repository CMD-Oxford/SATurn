/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import phylo.PhyloUtil;
import phylo.PhyloCanvasRenderer;
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

	var canvas : PhyloCanvasRenderer;

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

        getApplication().hideMiddleSouthPanel();

        theComponent = Ext.create('Ext.panel.Panel', {
            title: 'Phylo5 Viewer',
            width:'100%',
            height: '95%',
            autoScroll : true,
            layout : 'fit',

            listeners : {
                'render' : function() { self.initialiseDOMComponent(); }
            },
            cls: 'x-tree-background'
        });

        registerDropFolder('Sequences', null, true);
    }

    override public function initialiseDOMComponent() {
        super.initialiseDOMComponent();

        var parent : js.html.Element = getComponent().getEl().dom.firstChild;

        newickStr = '((UFSP1:0.00,UFSP2:0.00):0.77,((((SENP1:0.00,SENP2:0.00):0.70,(SENP3:0.00,SENP5:0.00):0.73):0.82,SENP8:0.00):0.99,(SENP6:0.00,SENP7:0.00):0.77):1.00,((((((((((FAM105B:0.00,(OTUD6A:0.00,OTUD6B:0.00):0.46):0.92,(OTUB1:0.00,OTUB2:0.00):0.55):0.99,OTUD1:0.00):0.99,YOD1:0.00):0.99,(OTUD3:0.00,OTUD5:0.00):0.86):0.99,OTUD4:0.00):0.99,ZRANB1:0.00):0.99,TNFAIP3:0.00):0.99,(OTUD7A:0.00,OTUD7B:0.00):0.48):0.99,VCPIP1:0.00):1.00,(((KHNYN:0.00,NYNRIN:0.00):0.65,N4BP1:0.00):0.86,((ZC3H12A:0.00,(ZC3H12B:0.00,ZC3H12C:0.00):0.53):0.64,ZC3H12D:0.00):0.65):0.94,(BAP1:0.00,((UCHL1:0.00,UCHL3:0.00):0.46,UCHL5:0.00):0.82):0.99,(DESI1:0.00,DESI2:0.00):0.82,(((((((BRCC3:0.00,(COPS5:0.00,PSMD14:0.00):0.74):0.93,(COPS6:0.00,(EIF3F:0.00,PSMD7:0.00):0.79):0.81):0.95,EIF3H:0.00):0.99,MPND:0.00):0.99,(STAMBP:0.00,STAMBPL1:0.00):0.43):0.99,MYSM1:0.00):0.99,PRPF8:0.00):0.99,((ATXN3:0.00,ATXN3L:0.00):0.30,(JOSD1:0.00,JOSD2:0.00):0.51):0.99,((ATG4A:0.00,ATG4B:0.00):0.53,(ATG4C:0.00,ATG4D:0.00):0.63):0.80);';

        var parser = new phylo.PhyloNewickParser();

        var rootNode = parser.parse(newickStr);

        rootNode.calculateScale();

        rootNode.postOrderTraversal();

        rootNode.preOrderTraversal(1);

        var parentWidth = getComponent().getEl().getWidth();
        var parentHeight = getComponent().getEl().getHeight();

        var config = new PhyloCanvasConfiguration();

        config.enableTools = true;
        config.enableToolbar = true;
        config.enableZoom = true;


        canvas = new phylo.PhyloCanvasRenderer(parentWidth, parentHeight, parent, rootNode, config, null);
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

		canvas.setNewickString(newickStr);
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
		
		/*getApplication().getViewMenu().add({
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
        });*/
		
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

        /*getApplication().getToolBar().add({
            iconCls :'x-btn-export',
            text: 'Export',
            handler: function(){
                export();
            },
            tooltip: {dismissDelay: 10000, text: 'Export tree as SVG (open in Illustrator or Inkscape)'}
        });*/

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text: 'Update',
            handler: function(){
                self.updateAlignment();
            },
            tooltip: {dismissDelay: 10000, text: 'Update tree with current sequences'}
        });

        /*getApplication().getToolBar().add({
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
        });*/

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
