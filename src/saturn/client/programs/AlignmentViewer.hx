/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.client.core.CommonCore;
import saturn.core.molecule.Molecule;
import saturn.core.ClustalOmegaParser;
import saturn.client.workspace.ABITraceWO;
import saturn.client.programs.plugins.AlignmentGVPlugin;
import saturn.core.GridVar;
import saturn.client.workspace.GridVarWO;
import saturn.client.programs.SimpleExtJSProgram;
import saturn.core.domain.Alignment;

import bindings.Ext;

import saturn.core.DNA;
import saturn.client.WorkspaceApplication;
import saturn.client.workspace.Workspace;
import saturn.client.workspace.Workspace.WorkspaceListener;

import saturn.core.domain.Alignment;
import saturn.client.workspace.DNAWorkspaceObject;
import saturn.client.workspace.ProteinWorkspaceObject;

import saturn.client.workspace.AlignmentWorkspaceObject;
class AlignmentViewer extends SimpleExtJSProgram  {
	static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ AlignmentWorkspaceObject ];
	
    var theComponent : Dynamic;

    var internalFrameId : String;

    var icButton : Dynamic;

    public function new(){
        super();
    }

    override public function emptyInit() {
		super.emptyInit();

        this.internalFrameId = 'INTERNAL_ALN_FRAME';

        var self : AlignmentViewer  = this;

        theComponent = Ext.create('Ext.panel.Panel', {
            title: 'Alignment Viewer',
            width:'100%',
            height: '95%',
            autoScroll : true,
            layout : 'fit',
            items : [{
                        xtype : "component",
                        itemId : internalFrameId,
                        autoEl : {
                            tag : "pre"
                        }
                    }],
            listeners : { 
                'render' : function() { self.initialiseDOMComponent(); }
            },
            cls: 'x-aln-background'
        });

        registerDropFolder('Sequences', null, true);
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

        var self : AlignmentViewer = this;

        getApplication().getViewMenu().add({
            text : 'Update alignment',
            handler : function(){
                self.updateAlignment();
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
            iconCls :'x-btn-copy',
            text: 'Update',
            handler: function(){
                self.updateAlignment();
            },
            tooltip: {dismissDelay: 10000, text: 'Update alignment with current sequences'}
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text: 'Import Protein',
            handler: function(){
                self.addAllProteinSequencesFromWorkspace();
            },
            tooltip: {dismissDelay: 10000, text: 'Import all protein sequences from the workspace (click update to update alignment)'}
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text: 'Import DNA',
            handler: function(){
                self.addAllDNASequencesFromWorkspace();
            },
            tooltip: {dismissDelay: 10000, text: 'Import all DNA sequences from the workspace (click update to update alignment)'}
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-gridvar',
            text: 'Summary',
            handler: function(){
                self.generateSummary();
            },
            tooltip: {dismissDelay: 10000, text: 'View overlap summary plot'}
        });

        icButton = getApplication().getToolBar().add({
            iconCls :'x-btn-inverse-complement',
            text: 'IC',
            handler: function(){
                self.inverseComplement();
            },
            tooltip: {dismissDelay: 10000, text: 'Inverse complement'}
        });
    }

    public function inverseComplement(){
        var content = getActiveAlignmentObject().getAlignmentContent();
        if(content != null){
            var aln = ClustalOmegaParser.read(content);

            aln.inverseComplement();

            getActiveAlignmentObject().setAlignmentContent(aln.toString());

            render();
        }
    }

    public function generateSummary(){
        var aln : Alignment = getActiveObjectObject();

        if(aln.getAlignmentContent() != null){
            var msa = ClustalOmegaParser.read(aln.getAlignmentContent());
            var obj = msa.toGrid();

            var wo = new GridVarWO(obj, getActiveObjectName() + ' (Summary)');

            obj.padding = false;
            obj.showXLabels = false;
            obj.fit = true;

            getWorkspace().addObject(wo, true);
        }
    }
	
	public function addAllDNASequencesFromWorkspace() {
        registerAllFromWorkspace(DNAWorkspaceObject, 'Sequences');
	}
	
	public function addAllProteinSequencesFromWorkspace() {
        registerAllFromWorkspace(ProteinWorkspaceObject, 'Sequences');
	}

    public function getAlignmentContent(alignmentURL, cb){

    }

    public function setAlignmentURL(alignmentURL : String){
        this.getActiveAlignmentObject().setAlignmentURL(alignmentURL);

        haxe.Timer.delay(function(){
            CommonCore.getContent(alignmentURL, function(content){
                this.getActiveAlignmentObject().setAlignmentContent(content);

                render();
            });
        },1000);
    }

    public function render(){
        var pre : Dynamic = theComponent.getComponent(internalFrameId).getEl().dom;

        var content = this.getActiveAlignmentObject().getAlignmentContent();

        if (content == null || content == '') {
            theComponent.addCls('x-aln-background');
        }else{
            theComponent.removeCls('x-aln-background');
        }

        pre.innerHTML = content;
    }

    public function updateAlignment(){
        var self : AlignmentViewer = this;

        var alnObj : Alignment = getAlignmentObject();

        var objectIds : Array<String> = getState().getReferences('Sequences');

        objectIds.reverse();

        var strBuf : StringBuf = new StringBuf();

        var count = 0;

        var isDNA = false;

        for(objectId in objectIds) {
			var w0 : WorkspaceObject<Dynamic> = getWorkspace().getObject(objectId);
			
			if ( Std.is(w0, DNAWorkspaceObject) ) {
				var object : DNAWorkspaceObject<DNA> = getWorkspace().getObjectSafely(objectId, DNAWorkspaceObject);

                if(object.getObject().getSequence() != null){
                    strBuf.add('>'+w0.getName()+'\n'+object.getObject().getSequence()+'\n');

                    count +=1;

                    isDNA = true;
                }
			}else if ( Std.is(w0, ProteinWorkspaceObject) ) {
				var object : ProteinWorkspaceObject = cast(w0, ProteinWorkspaceObject);

                if(object.getObject().getSequence() != null){
                    strBuf.add('>'+w0.getName()+'\n'+object.getObject().getSequence()+'\n');

                    count +=1;
                }
			}else if ( Std.is(w0, ABITraceWO)) {
                var object : ABITraceWO = cast(w0, ABITraceWO);

                if(object.getObject().getSequence() != null){
                    strBuf.add('>'+w0.getName()+'\n'+object.getObject().getSequence()+'\n');

                    count +=1;
                }
            }else if(Std.is(w0, Molecule)){
                var mol = cast(w0, Molecule);
                if(mol.getSequence() != null){
                    strBuf.add('>'+mol.getName()+'\n'+mol.getSequence()+'\n');

                    count +=1;
                }
            }else{
                var d: Dynamic = w0;
                strBuf.add('>'+d.getName()+'\n'+d.getSequence()+'\n');
            }
        }

        if(count < 2){
            setAlignmentURL(null);
        }else{
            BioinformaticsServicesClient.getClient().sendClustalReportRequest(strBuf.toString(), function(response, error){
                if(error == null){
                    var clustalReport = response.json.clustalReport;
                    var location : js.html.Location = js.Browser.window.location;

                    var dstURL = location.protocol+'//'+location.hostname+':'+location.port+'/'+clustalReport;

                    self.setAlignmentURL(dstURL);
                }else{
                    getApplication().showMessage('Clustal Error', error);
                }
            });

            if(isDNA){
                icButton.enable();
            }else{
                icButton.disable();
            }
        }
    }

    public function getActiveAlignmentObject() : Alignment {
        var activeObject : WorkspaceObject<Dynamic> = super.getActiveObject(AlignmentWorkspaceObject);

        if(activeObject != null){
            var w0 : AlignmentWorkspaceObject = cast(activeObject, AlignmentWorkspaceObject);
    
            return w0.getObject();
        }else{
            return null;
        }
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        var wo : AlignmentWorkspaceObject = cast(super.getActiveObject(AlignmentWorkspaceObject), AlignmentWorkspaceObject);
        var alnObj : Alignment = wo.getObject();

        var alnUrl : String = alnObj.getAlignmentURL();
        var alnContent : String = alnObj.getAlignmentContent();

        if(alnContent != null){
            render();
        }else if(alnUrl != null){
            setAlignmentURL(alnUrl);
        }else if(wo.getReferences('Sequences').length > 0){
            updateAlignment();
        }

        setTitle(wo.getName());
    }

    public function getAlignmentObject() : Alignment{
        var w0 : AlignmentWorkspaceObject = cast(super.getActiveObject(AlignmentWorkspaceObject), AlignmentWorkspaceObject);
        return w0.getObject();
    }
	
	override
	public function openFile(file : Dynamic, asNew : Bool, ?asNewOpenProgram : Bool = true) : Void {
		//var fileReader : Dynamic = untyped __js__('new FileReader()');
		
        /*fileReader.onload = function(e) {
			var zip = new JSZip(e.target.result);
			
			var files : Array<Dynamic> = zip.file(untyped __js__('/\\.seq/'));
			
			for (file in files) {
				var seq = file.asText();
				
				var wO = new DNAWorkspaceObject(new DNA(seq),file.name);
				
				WorkspaceApplication.getApplication().getWorkspace().addObject(wO, true);
			}
		}
		fileReader.readAsArrayBuffer(file);*/


	}

    public static function parseFile(file : Dynamic, ?cb=null, ?asNewOpenProgram : Bool = true){
        var extension = CommonCore.getFileExtension(file.name);
        if(extension == 'pfam_aln'){
            CommonCore.getFileAsText(file, function(content){
                if(content != null){
                    var obj = new Alignment();
                    obj.setAlignmentContent(content);

                    var wo = new AlignmentWorkspaceObject(obj, 'Alignment');

                    WorkspaceApplication.getApplication().getWorkspace()._addObject(wo, true, true);
                }else{
                    WorkspaceApplication.getApplication().showMessage('Processing error','Unable to extract alignment');
                }
            });
        }else if(extension == 'aln'){
            CommonCore.getFileAsText(file, function(content){
                if(content != null){
                    var obj = new Alignment();
                    obj.setAlignmentContent(content);

                    var wo = new AlignmentWorkspaceObject(obj, 'Alignment');

                    WorkspaceApplication.getApplication().getWorkspace()._addObject(wo, true, true);
                }else{
                    WorkspaceApplication.getApplication().showMessage('Processing error','Unable to extract alignment');
                }
            });
        }
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-aln',
                html:'Alignment<br/>Viewer',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new AlignmentWorkspaceObject(new saturn.core.domain.Alignment(), "MSA"), true);
                },
                tooltip: {dismissDelay: 10000, text: 'Alignment viewer.<br/>Run CLUSTAL against DNA or Protein sequences.'}
            }
        ];
    }

    override public function saveObject(cb : String->Void){
        var wo = getWorkspaceObject();
        wo.getObject().setName(wo.getName());

        super.saveObject(cb);
    }
}
