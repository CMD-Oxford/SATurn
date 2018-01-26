/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.core.ClustalOmegaParser;
import saturn.core.domain.SgcTarget;
import saturn.core.FastaEntity;
import saturn.core.Alignment.AlignmentType;
import saturn.core.domain.SgcEntryClone;
import saturn.client.workspace.AlignmentWorkspaceObject;
import saturn.core.domain.SgcConstruct;
import saturn.core.DNA;
import saturn.client.workspace.DNAWorkspaceObject;
import js.html.CanvasElement;
import js.html.HtmlElement;
import js.html.CanvasElement;
import saturn.client.WorkspaceApplication;
import saturn.client.programs.SimpleExtJSProgram;
import saturn.util.StringUtils;

import saturn.client.workspace.ABITrace;
import saturn.client.workspace.ABITraceWO;

import saturn.client.workspace.Workspace.WorkspaceObject;

import saturn.client.core.CommonCore;

import haxe.Json;

import bindings.Ext;

import js.Lib;
import js.html.ArrayBuffer;

import saturn.client.workspace.Alignment;

class ABITraceViewer extends SimpleExtJSProgram{
	static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ ABITraceWO ];
	
    var theComponent : Dynamic;
    var internalFrameId : String = 'INTERNAL_FRAME';
	
	var pageUrl : String = '';

    var defaultReadingSeparation = 2; //Pixel separation between readings on the x axis
    var defaultDrawingHeight = 300; //default drawing height of a canvas element
    var maximumCanvasWidth = 30000; //default drawing width of a canvas element

    var canvasElements : Array<CanvasElement> = new Array<CanvasElement>(); //canvas elements to draw on

    var drawingHeight = -1;
    var drawingWidth = -1;

    var lastPosition = 0;
    var traceData : ABITrace;

    //Margins
    var theMaxIntensity = -1;

    var theLeftMargin : Float;
    var theRightMargin : Float;
    var theTopMargin : Float;
    var theBottomMargin : Float;

    //Unit sizes
    var theXUnitSize : Float;
    var theYUnitSize : Float;

    //Dimensions
    var theGraphWidth : Float;
    var theGraphHeight : Float;
    var theTotalWidth : Float;

    //initialise channel list
    var theChannels = ['CH1','CH2', 'CH3', 'CH4'];

    //y axis interval divisions
    var theYIntervalDivisions : Float;

    //number of readings / x units
    var theReadingsCount : Int;

    //
    var theLastScrollBarXPos : Float;
    var theLastScrollBarYPos : Float;

    var theScrollBarBoxHeight : Float;
    var theScrollBarBoxWidth : Float;

    var theStartingXPosition : Float;

    var up : Bool = false;

    var graphCanvas : js.html.CanvasElement = null;
    var scrollCanvas : js.html.CanvasElement = null;
    var overlayCanvas : js.html.CanvasElement = null;

    var theSequence : String;

    var blastDatabases : Array<String>;

    var theDNAWO : DNAWorkspaceObject<DNA> = null;
    var theDNAWOIC : DNAWorkspaceObject<DNA> = null;

    var lineX1RealPosition : Int = -1;
    var lineX2RealPosition : Int = -1;

    var theUndoTrimMenuItem : Dynamic = null;
    var theTrimMenuItem : Dynamic = null;

    var traceWO : ABITraceWO = null;

    var theBlastResultLmit : Int = 10;

    var theViewPortXUnits : Int = 0;
    var theLastXPosition : Int = 0;

    var annotationIdToPosition : Map<String, Int>;

    var svgMode : Bool = false;

    public function new(){
        super();
    }

    override public function emptyInit() {
		super.emptyInit();

        var self : ABITraceViewer  = this;

        var items :Array<Dynamic>=  [
            {
                region : 'center',
                xtype : 'button',
                text : 'Next',
                handler : function() {
                    render(traceData, lastPosition+1);
                },
                style: {
                    display : 'block'
                }
            }
        ];

        theComponent = Ext.create('Ext.panel.Panel', {
            width: '100%',
            height: '300',
            autoScroll : false,
            region:'center',
            //layout : 'fit',
            //items : items,
            //items: items,
            listeners : { 
                'afterrender' : function() { self.initialiseDOMComponent(); },
                'resize': function(){var a= 10; redraw();}
            },
            autoEl: { tag: 'div', html: ""	},
            cls: 'x-trace-background'
        });      
    }
	
	override public function initialiseDOMComponent() {
		super.initialiseDOMComponent();

        up = true;

        getApplication().getMiddleSouthPanel().addCls('seq-breaking');

        //createCanvasElements();

        redraw();


	}

    public function recreateCanvasElements(){
        removeCanvasElements();
        createCanvasElements();
    }

    public function redraw(){
        recreateCanvasElements();

        if(traceData != null){
            updateTrace(traceData);
        }
    }

    public function createCanvasElements(){
        var element : js.html.Element = getDomElement();

        graphCanvas = cast js.Browser.document.createElement('canvas');

        var width = element.style.width;

        graphCanvas.width = getContainerWidth();
        graphCanvas.height = 300;

        overlayCanvas = cast js.Browser.document.createElement('canvas');
        overlayCanvas.width = getContainerWidth();
        overlayCanvas.height = 300;
        overlayCanvas.style.position = 'relative';
        overlayCanvas.style.top = '-330px';

        scrollCanvas = cast js.Browser.document.createElement('canvas');

        scrollCanvas.width = getContainerWidth();
        scrollCanvas.height = 30;
        scrollCanvas.style.display = 'block';

        element.appendChild(graphCanvas);
        element.appendChild(scrollCanvas);
        element.appendChild(overlayCanvas);
    }

    public function removeCanvasElements(){
        var element : js.html.Element = getDomElement();

        if(getGraphCanvas() != null){
            element.removeChild(getGraphCanvas());
        }

        if(getScrollCanvas() != null){
            element.removeChild(getScrollCanvas());
        }

        if(getOverlayCanvas() != null){
            element.removeChild(getOverlayCanvas());
        }
    }

    public function getOverlayCanvas(){
        return overlayCanvas;
    }

    public function getGraphCanvas(){
        return graphCanvas;
    }

    public function getScrollCanvas(){
        return scrollCanvas;
    }

    public function getDomElement() : js.html.Element{
        return theComponent.getEl().down('div[id*=innerCt]').dom;
    }

    public function getContainerWidth() : Int{
        return theComponent.getEl().dom.clientWidth;
    }

    override public function setTitle(title : String){
        if(theComponent.tab != null){
            theComponent.tab.setText(title);
        }
    }

    override public function getComponent() : Dynamic {
        return theComponent;
    }

    public static function processABIFile(base64 : String, load: Bool, ?cb=null, fileName : String){
        BioinformaticsServicesClient.getClient().sendABIReportRequest(base64, function(data : Dynamic, error : String){
            var json = Json.parse(data.json);

            var obj = new ABITrace();
            obj.setData(json);

            var wo = new ABITraceWO(obj, fileName);

            WorkspaceApplication.getApplication().getWorkspace()._addObject(wo, load, true);
        });
    }

    override public function openFile(file : Dynamic, asNew : Bool, ? asNewOpenProgram : Bool = true) : Void{
        parseFile(file, function(contents){
            var entities = FastaEntity.parseFasta(contents);

            if(entities.length > 0){
                _alignToTrace(entities[0].getSequence());
            }
        });
    }

    public static function parseFile(file : Dynamic, ?cb=null, ?asNewOpenProgram : Bool = true){

        var extension = CommonCore.getFileExtension(file.name);
        if(extension == 'ab1'){
            CommonCore.getFileAsArrayBuffer(file, function(content : ArrayBuffer){
                var base64 = CommonCore.convertArrayBufferToBase64(content);

                processABIFile(base64, asNewOpenProgram, cb, file.name);
            });
        }else if(extension == 'fasta'){
            CommonCore.getFileAsText(file, function(contents){
                if(contents != null){
                    cb(contents);
                }
            });
        }
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        traceWO = cast(super.getActiveObject(ABITraceWO), ABITraceWO);
        var trace : ABITrace = cast(traceWO.getObject(), ABITrace);

        traceData = trace;

        if(up && traceData != null){
            updateTrace(traceData);
        }

        setTitle(traceWO.getName());

        for(blastDatabase in blastDatabases){
            if(!traceWO.blastDBtoHitName.exists(blastDatabase)){
                traceWO.blastDBtoHitName.set(blastDatabase, new Array<String>());
            }
        }

        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');

        for(blastDatabase in traceWO.blastDBtoHitName.keys()){
            var node : Dynamic = dataStore.getNodeById(blastDatabase);

            if(node != null){
                node.removeAll();

                for(hit in traceWO.blastDBtoHitName.get(blastDatabase)){
                    node.appendChild({
                    text : hit,
                    leaf : true,
                    id : hit,
                    type: 'BLAST_HIT'
                    });
                }
            }
        }
    }

    public function updateTrace(traceData : Dynamic){
        this.traceData = traceData;

        preprocessTrace();

        calculateAnnotations();

        if(theMaxIntensity == -1){
            return;
        }

        render(traceData);

        showSequence();

        renderScrollBar();

        installScrollBarListeners();

        if(this.traceWO.previousTraces.length > 0){
            theUndoTrimMenuItem.setVisible(true);
        }
    }

    public function showSequence(){
        var nucs = new Array<String>();

        //fetch x axis labels
        var labels :Array<String> = traceData.LABELS;

        for(i in 0...labels.length){
            var label = labels[i];

            //skip empty labels
            if(label != ''){
                nucs.push(label);
            }
        }

        getApplication().setInformationPanelText(getSequence(), false);
    }

    override
    public function onBlur(){
        super.onBlur();

        getApplication().setInformationPanelText('', false);
    }

    override
    public function onFocus(){
        super.onFocus();

        if(traceData != null){
            showSequence();
        }

        var viewMenu = getApplication().getViewMenu();

        var blastMenu = Ext.create('Ext.menu.Menu', {margin: '0 0 10 0','z-index': 1000000});

        viewMenu.add({
            text: 'BLAST',
            hidden : false,
            handler: function(){
                blastAll();
            }
        });

        getApplication().getToolBar().add({
            html: 'BLAST',
            handler: function(){
                blastAll();
            },
            iconCls: 'x-btn-blast',
            tooltip: {dismissDelay: 10000, text: 'BLAST trace sequence'}
        });

        theTrimMenuItem = getApplication().getEditMenu().add({
            text: 'Trim',
            hidden: false,
            handler: function(){
                trim();
            }
        });

        getApplication().getToolBar().add({
            html: 'Trim',
            handler: function(){
                trim();
            },
            iconCls: 'x-btn-copy',
            tooltip: {dismissDelay: 10000, text: 'Trim trace (click at start and end of region you wish to keep then click trim<br/>Clicking a trim boundary line removes it<br/>'}
        });

        var hideUndo = traceWO != null && traceWO.previousTraces.length > 0 ? false : true;

        theUndoTrimMenuItem = getApplication().getEditMenu().add({
            text: 'Undo trim / alignment',
            hidden: hideUndo,
            handler: function(){
                detrim();
            }
        });

        getApplication().getToolBar().add({
            html: 'Undo trim / alignment',
            handler: function(){
                detrim();
            },
            iconCls: 'x-btn-copy',
            tooltip: {dismissDelay: 10000, text: 'Undo trim or alignment'}
        });

        getApplication().getEditMenu().add({
            text: 'Import trace sequence',
            hidden: false,
            handler: function(){
                importTraceSequence();
            }
        });



        initialiseOutlinePanel();

        getApplication().getExportMenu().add({
            text: 'Trace to PNG',
            handler: function(){
                getApplication().saveCanvasToFile(getGraphCanvas(), getActiveObjectName() + '.png');
            }
        });

        getApplication().getExportMenu().add({
            text: 'Trace to SVG',
            handler: function(){
                exportToSVG();
            }
        });

        getApplication().getToolBar().add({
            html: 'Export PNG',
            handler: function(){
                getApplication().saveCanvasToFile(getGraphCanvas(), getActiveObjectName() + '.png');
            },
            iconCls: 'x-btn-export',
            tooltip: {dismissDelay: 10000, text: 'Export view as PNG'}
        });

        getApplication().getToolBar().add({
            html: 'Export SVG',
            handler: function(){
                exportToSVG();
            },
            iconCls: 'x-btn-export',
            tooltip: {dismissDelay: 10000, text: 'Export view as SVG (better for Illustrator or Inkscape)'}
        });
    }

    public function exportToSVG(){
        var width = theGraphWidth + theLeftMargin;
        var height = theGraphHeight  + theTopMargin + theBottomMargin ;

        var svgGraphCanvas = untyped __js__('new C2S(width,height)');

        var originalCanvas = graphCanvas;

        graphCanvas = svgGraphCanvas;

        svgMode = true;

        render(traceData, lastPosition);

        svgMode = false;

        graphCanvas = originalCanvas;

        var d : Dynamic = cast svgGraphCanvas;

        WorkspaceApplication.getApplication().saveTextFile(d.getSerializedSvg(true), getActiveObjectName() + '.svg');
    }

    public function getGraphContext() : js.html.CanvasRenderingContext2D{
        if(svgMode){
            return cast graphCanvas;
        }else{
            return graphCanvas.getContext2d();
        }
    }

    function trim(){
        if(lineX1RealPosition != -1 && lineX2RealPosition != -1){
            theUndoTrimMenuItem.setVisible(true);

            var start = Std.int(Math.min(lineX1RealPosition, lineX2RealPosition));
            var stop = Std.int(Math.max(lineX1RealPosition, lineX2RealPosition));

            traceData = traceWO.trim(start, stop);

            lastPosition = 0;

            lineX1RealPosition = -1;
            lineX2RealPosition = -1;

            redraw();
        }else{

        }
    }

    function detrim(){
        if(traceWO.previousTraces.length > 0){
            traceData = traceWO.untrim();

            lastPosition = 0;

            lineX1RealPosition = -1;
            lineX2RealPosition = -1;

            redraw();

            if(traceWO.previousTraces.length == 0){
                theUndoTrimMenuItem.setVisible(false);
            }
        }
    }

    public function initialiseOutlinePanel() {
        getApplication().installOutlineTree('DEFAULT', true, false, null);

        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');

        var rootNode : Dynamic = dataStore.getRootNode();

        var annotationsNode : Dynamic = rootNode.appendChild({
            text : 'Annotations',
            leaf : false,
            expanded : false,
            id : 'Annotations'
        });

        var blastResultsNode : Dynamic = rootNode.appendChild({
            text : 'BLAST Results',
            leaf : false,
            expanded : false,
            id : 'BLAST Results'
        });



        if(blastDatabases == null){
            blastDatabases = new Array<String>();
            for(blastDatabase in Reflect.fields(BioinformaticsServicesClient.getClient(null).getBlastList().DNA)){
                blastDatabases.push(blastDatabase);
            }
        }

        var contextMenu = function(view : Dynamic, record : Dynamic,
                                   item : Dynamic, index : Dynamic, event : Dynamic){
            var self = this;
            var id = record.get('id');

            if(traceWO.blastResultMap.exists(id)){
                var contextMenu : Dynamic = Ext.create('Ext.menu.Menu',{
                    items: [
                        {
                            text : 'Run Clustal',
                            handler : function(){
                                runClustal(id);
                            }
                        }, {
                            text : 'Align to trace',
                            handler : function(){
                                alignToTrace(id);
                            }
                        },{
                            text : 'Import',
                            handler : function(){
                                importSequence(id);
                            }
                        }
                    ]
                });

                contextMenu.showAt(event.getXY());

                event.stopEvent();
            }
        };

        getApplication().getOutlineTree('DEFAULT').on('itemclick' ,
            function(view, rec, item, index, event) {
                if (event.ctrlKey) {
                    contextMenu(view, rec, item, index, event);
                }else{
                    var id = rec.get('id');

                    //Check if tree item is a annotation
                    if(annotationIdToPosition.exists(id)){
                        //calculate starting position on the x axis to center annotation
                        var position :Int = annotationIdToPosition.get(id);

                        position -= Std.int(theViewPortXUnits / 2);

                        if(position < 0){
                            //Can't center annotations to the left of the center line
                            position = 0;
                        }

                        lastPosition = position;

                        redraw();
                    }
                }
            }, this
        );

        getApplication().getOutlineTree('DEFAULT').on('itemcontextmenu', contextMenu,this);

        for(blastDatabase in blastDatabases){
            var dbNode = blastResultsNode.appendChild({
                text : blastDatabase,
                leaf : false,
                expanded : false,
                id : blastDatabase
            });
        }

        if(traceWO != null){
            WorkspaceApplication.suspendUpdates(true);

            for(blastDatabase in blastDatabases){
                var node : Dynamic = dataStore.getNodeById(blastDatabase);
                for(item in traceWO.blastDBtoHitName.get(blastDatabase)){
                    node.appendChild({
                        text : item,
                        id : item,
                        leaf: true,
                        type: 'BLAST_HIT'
                    });
                }
            }

            blastResultsNode.expand(true);

            WorkspaceApplication.resumeUpdates(true, true);
        }else{
            blastResultsNode.expand(true);
            for(blastDatabase in blastDatabases){
                var node : Dynamic = dataStore.getNodeById(blastDatabase);
                node.expand(true);
            }
        }

        calculateAnnotations();
    }

    public function alignToTrace(sequenceId : String){
        getSequenceFromDatabase(sequenceId, function(sequence, id){
            _alignToTrace(sequence);
        });
    }

    public function _alignToTrace(sequence : String){
        var mode = 'CLUSTAL';

        if(mode == 'LOCAL'){
            var faln = new saturn.core.Alignment(sequence, getSequence());
            faln.align();

            var raln = new saturn.core.Alignment(new DNA(sequence).getInverseComplement(), getSequence());
            raln.align();

            var isF = faln.getSeqAId() > raln.getSeqAId();

            var newTrace = traceWO.align(isF ? faln : raln, isF);

            updateTrace(newTrace);
        }else{
            alignWithClustal(sequence, true, function(msa1){
                var d :Dynamic = js.Browser.window;

                d.msa1 = msa1;

                alignWithClustal(sequence, false, function(msa2){
                    d.msa2 = msa2;

                    var newTrace = traceWO.align(msa1.getPSI() > msa2.getPSI() ? msa1 : msa2, msa1.getPSI() > msa2.getPSI());

                    updateTrace(newTrace);
                });
            });
        }
    }


    public function alignWithClustal(sequence : String, forward : Bool, cb){
        sequence = forward ? sequence : new DNA(sequence).getInverseComplement();

        //var templateSequence = forward ? getSequence() : new DNA(getSequence()).getInverseComplement();
        var templateSequence = getSequence();

        templateSequence = StringTools.replace(templateSequence,'-','');

        var fasta = ">trace\n"+templateSequence+"\n>template\n" + sequence ;

        BioinformaticsServicesClient.getClient().sendClustalReportRequest(fasta, function(response, error){
            if(error != null){

            }else{
                var clustalReport = response.json.clustalReport;
                var location : js.html.Location = js.Browser.window.location;

                var dstURL = location.protocol+'//'+location.hostname+':'+location.port+'/'+clustalReport;

                CommonCore.getContent(dstURL, function(content){
                    var msa = ClustalOmegaParser.read(content);

                    cb(msa);


                });
            }
        });
    }

    public function getAlignment(sequence : String, forward : Bool) : saturn.core.Alignment{
        var templateSequence = forward ? getSequence() : new DNA(getSequence()).getInverseComplement();

        templateSequence = StringTools.replace(templateSequence,'-','');

        var aln = new saturn.core.Alignment(templateSequence, sequence);
        aln.setAlignmentType(AlignmentType.NW);

        aln.align();

        return aln;
    }

    public function runClustal(sequenceId : String){
        getSequenceFromDatabase(sequenceId, function(sequence, id){
            _runClustal(sequence, id);
        });
    }

    public function getSequenceFromDatabase(sequenceId : String , cb){
        getSequenceEntity(sequenceId, function(obj){
            if(Std.is(obj, SgcConstruct)){
                cb(obj.dnaSeq, obj.constructId);
            }else if(Std.is(obj, SgcEntryClone)){
                cb(obj.dnaSeq, obj.entryCloneId);
            }else if(Std.is(obj, SgcTarget)){
                cb(obj.dnaSeq, obj.dnaId);
            }
        });
    }

    public function getSequenceEntity(sequenceId : String, cb : Dynamic->Void){
        if(sequenceId.indexOf('-c') != -1){
            getProvider().getById(sequenceId, SgcConstruct, function(construct : SgcConstruct, exception){
                if(exception == null && construct != null){
                    cb(construct);
                }else if(exception != null){
                    getApplication().showMessage('Lookup exception',exception.message);
                }
            });
        }else if(sequenceId.indexOf('-s') != -1){
            getProvider().getById(sequenceId, SgcEntryClone, function(entryClone : SgcEntryClone, exception){
                if(exception == null && entryClone != null){
                    cb(entryClone);
                }else if(exception != null){
                    getApplication().showMessage('Lookup exception',exception.message);
                }
            });
        }else{
            getProvider().getById(sequenceId, SgcTarget, function(dnaObj : SgcTarget, exception){
                if(exception == null && dnaObj != null){
                    cb(dnaObj);
                }else if(exception != null){
                    getApplication().showMessage('Lookup exception',exception.message);
                }
            });
        }
    }

    public function importSequence(id){
        getSequenceFromDatabase(id, function(dnaSeq, id){
            getWorkspace().addObject(new DNAWorkspaceObject(new DNA(dnaSeq), id), true);
        });
    }

    public function isSameOrientation(sequence){
        var forward = getAlignment(sequence, true);
        var reverse = getAlignment(sequence, false);

        return forward.getSeqAId() > reverse.getSeqAId();
    }

    public function _runClustal(sequence, name){
        var icSequence = !isSameOrientation(sequence);

        var dnaObj = new DNAWorkspaceObject(new DNA(sequence), name+ ' (DNA)');

        getWorkspace()._addObject(dnaObj, false, false);

        var selfDNAWO :DNAWorkspaceObject<DNA> = null;
        if(icSequence){
            if(theDNAWOIC == null){
                addDNAToWorkspace(false, icSequence);
            }

            selfDNAWO = theDNAWOIC;
        }else{
            if(theDNAWOIC == null){
                addDNAToWorkspace(false, false);
            }

            selfDNAWO = theDNAWO;
        }

        var aln = new Alignment();

        aln.setAlignmentObjectIds([selfDNAWO.getUUID(), dnaObj.getUUID()]);

        var abiWO : ABITraceWO = cast(getActiveObject(ABITraceWO), ABITraceWO);

        var wo = new AlignmentWorkspaceObject(aln , abiWO.getName() + ' Clustal');
        wo.addReference('Sequences', selfDNAWO.getUUID());
        wo.addReference('Sequences', dnaObj.getUUID());


        getWorkspace()._addObject(wo, true, false);

        getWorkspace().reloadWorkspace();
    }


    public function addDNAToWorkspace(autoOpen, icSequence){
        var dnaObj = new DNA(getSequence());

        var abiWO : ABITraceWO = cast(super.getActiveObject(ABITraceWO), ABITraceWO);

        if(icSequence){
            theDNAWOIC = new DNAWorkspaceObject(new DNA(dnaObj.getInverseComplement()), abiWO.getName() + ' (DNA IC)');
            getWorkspace()._addObject(theDNAWOIC, autoOpen, false);
        }else{
            theDNAWO = new DNAWorkspaceObject(dnaObj, abiWO.getName() + ' (DNA)');
            getWorkspace()._addObject(theDNAWO, autoOpen, false);
        }
    }

    public function blastAll(){
        for(key in traceWO.blastResultMap.keys()){
            traceWO.blastResultMap.remove(key);
        }

        for(key in traceWO.blastDBtoHitName.keys()){
            for(item in traceWO.blastDBtoHitName.get(key)){
                traceWO.blastDBtoHitName.get(key).remove(item);
            }
        }

        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');

        for(databaseName in blastDatabases){
            var node : Dynamic = dataStore.getNodeById(databaseName);
            node.removeAll();
        }

        var seq = getSequence();

        if(seq == null || seq == ''){
            return;
        }

        for(databaseName in blastDatabases){
            blastSequence(seq, databaseName, databaseName);
        }
    }

    public function blastSequence(theSequence : String, database : String, blastName : String){
        BioinformaticsServicesClient.getClient().sendBlastReportRequest(theSequence,blastName, database, function(response,error){
            if(error == null){
                var reportFile = response.json.reportFile;

                var location : js.html.Location = js.Browser.window.location;

                var dstURL = location.protocol+'//'+location.hostname+':'+location.port+'/'+reportFile;

                Ext.Ajax.request({
                    url: dstURL,
                    success: function(response, opts) {
                        var obj = response.responseText;

                        var topHits = extractTopHits(obj);

                        updateBlastResults(topHits, blastName);
                    },
                    failure: function(response, opts) {
                        //response.status
                    }
                });

            }else{
                getApplication().showMessage('BLAST Error', error);
            }
        });
    }

    public function updateBlastResults(hits : Array<String>, folderName){
        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');

        var node : Dynamic = dataStore.getNodeById(folderName);

        node.removeAll();

        WorkspaceApplication.suspendUpdates(true);

        var i = 0;

        for(hit in hits){
            traceWO.blastResultMap.set(hit, folderName);

            traceWO.blastDBtoHitName.get(folderName).push(hit);

            node.appendChild({
                text : hit,
                leaf : true,
                id : hit,
                type: 'BLAST_HIT'
            });

            i++;

            if(i >= theBlastResultLmit){
                break;
            }
        }

        WorkspaceApplication.resumeUpdates(true, true);

        //WorkspaceApplication.resumeUpdates(true);
    }

    public function extractTopHits(resultString : String) : Array<String>{
        var lines = resultString.split('\n');

        var inResultTable = false;

        var re_extractTarget = ~/^\s*([^ ]+)/;

        var targets = new Array<String>();

        var blankLineCount = 0;

        var re_whiteSpace = ~/^\s+$/;

        var i = 0;
        while(i < lines.length){
            var line = lines[i++];

            if(line.indexOf('Sequences producing significant alignments') != -1){
                inResultTable = true;
                i++;
            }else if(inResultTable){
                if((!re_whiteSpace.match(line)) && re_extractTarget.match(line)){
                    var targetName = re_extractTarget.matched(1);

                    if(targetName != ''){
                        targets.push(targetName);
                    }
                }else{
                    break;
                }
            }
        }
        return targets;
    }

    public function renderScrollBar(?moveX : Float, ?forwards : Bool){
        //fetch dimensions
        var width = scrollCanvas.width;
        var height = scrollCanvas.height;

        var ctx = scrollCanvas.getContext2d();

        ctx.clearRect(0,0, width, height);

        if(theGraphWidth >= theTotalWidth){
            return;
        }

        var shownRatio = theGraphWidth / theTotalWidth;

        var padding = 5;

        var rectWidth = (theGraphWidth-(padding*2)) * shownRatio;

        ctx.save();
        ctx.beginPath();
        ctx.strokeStyle = 'black';
        ctx.rect(theLeftMargin,0, theGraphWidth, height);
        ctx.stroke();
        ctx.restore();

        theScrollBarBoxWidth = rectWidth;
        theScrollBarBoxHeight = height-(padding*2);

        var leftStop = padding + theLeftMargin;
        var rightStop = width - theRightMargin - theScrollBarBoxWidth - padding;

        if(moveX != null){
            if(forwards){
                theLastScrollBarXPos = theLastScrollBarXPos + moveX;
            }else{
                theLastScrollBarXPos = theLastScrollBarXPos - moveX;
            }

            if(theLastScrollBarXPos < leftStop){
                theLastScrollBarXPos = leftStop;
            }else if(theLastScrollBarXPos > rightStop){
                theLastScrollBarXPos = rightStop;
            }
        }else{
            if(lastPosition > 0){
                var progress = lastPosition / theReadingsCount;

                theLastScrollBarXPos = (theGraphWidth * progress) + theLeftMargin;
                theLastScrollBarYPos = padding;
            }else{
                theLastScrollBarXPos = leftStop;
                theLastScrollBarYPos = padding;
            }
        }

        ctx.save();
        ctx.beginPath();
        ctx.strokeStyle = 'blue';
        ctx.rect(theLastScrollBarXPos,theLastScrollBarYPos,theScrollBarBoxWidth, theScrollBarBoxHeight);
        ctx.fill();
        ctx.restore();
    }

    public function installScrollBarListeners(){
        var isInHitBox = function(e){
            return e.offsetX >= theLastScrollBarXPos && e.offsetX <= theLastScrollBarXPos + theScrollBarBoxWidth &&
                    e.offsetY >= theLastScrollBarYPos && e.offsetY <= theLastScrollBarYPos + theScrollBarBoxHeight;
        }

        var lastX : Float = theLeftMargin;//theLeftMargin;
        var lastY : Float = 0;



        var onMouseMove = function(e : Dynamic){
            e = getNormalisedEvent(e);
            //if(isInHitBox(e)){
                var forwards = true;

                var diff = theReadingsCount - lastPosition;

                if(e.offsetX < lastX){
                    forwards = false;
                }else{
                    if(theXUnitSize * diff <= theGraphWidth){
                        return;
                    }
                }

                var xMove = Math.abs(lastX - e.offsetX);

                renderScrollBar(xMove, forwards);

                lastX = e.offsetX;
                lastY = e.offsetY;

                var xScrollUnits = (theGraphWidth-10) / theReadingsCount;

                var numRequested = Std.int(xMove/xScrollUnits);

                var oldLastPosition = lastPosition;

                if(forwards){
                    lastPosition += numRequested;
                }else{
                    lastPosition -= numRequested;
                }

                if(lastPosition < 0){
                    lastPosition =0;
                }/*else if(lastPosition > a){
                    lastPosition = a;
                }*/

                if(lastPosition != oldLastPosition){
                    render(traceData);
                }
            //}
        }

        scrollCanvas.onmousedown = function(evt){
            var e = getNormalisedEvent(evt);

            if(isInHitBox(e)){
                lastX = e.offsetX;
                lastY = e.offsetY;

                scrollCanvas.onmousemove = onMouseMove;
            }else{
                onMouseMove(evt);
            }
        };

        scrollCanvas.onmouseup = function(e){
            scrollCanvas.onmousemove = null;
        };


    }


    public function preprocessTrace(){
        //fetch dimensions
        var width = graphCanvas.width;
        var height = graphCanvas.height;

        //initialise maximum intensity
        theMaxIntensity = -1;

        //set reading count
        theReadingsCount = traceData.CH1.length;

        //initialise channel list
        var channels = ['CH1','CH2', 'CH3', 'CH4'];

        //determine maximum intensity across all four channels
        for(channel in channels){
            //get channel readings
            var readings :Array<Dynamic> = Reflect.field(traceData, channel);
            for(reading in readings){
                if(reading > theMaxIntensity){
                    //store new maximum intensity
                    theMaxIntensity = reading;
                }
            }
        }

        //fetch canvas context
        var ctx = getGraphContext();

        //fetch text metrics for largetest y axis label
        var yTextMetrics = ctx.measureText(Std.string(theMaxIntensity));

        //initialise margins
        theTopMargin = 20;
        theBottomMargin = 30;

        //initialise left margin and allow for y axis label
        theLeftMargin = 5 + yTextMetrics.width + 2;
        theRightMargin = 20;

        //initialise graphing area height
        theGraphHeight = height - theTopMargin - theBottomMargin;

        //initialise graphing area weidth
        theGraphWidth = width - theLeftMargin - theRightMargin;

        //determine y axis interval
        var exponent = Std.int(Math.log(theMaxIntensity) / Math.log(10));
        var magnitude = Math.pow(10, exponent);

        var timesIn = Std.int(theMaxIntensity / magnitude);

        if(theMaxIntensity % magnitude > 0){
            timesIn++;
        }

        var maximumYValue = magnitude * timesIn;

        theYIntervalDivisions = maximumYValue / 10;

        //determine pixels per y unit
        theYUnitSize = theGraphHeight / cast(maximumYValue, Float);

        theXUnitSize = defaultReadingSeparation;

        theTotalWidth = theXUnitSize * theReadingsCount;

        theSequence = '';

        var labels :Array<String> = traceData.LABELS;

        for(i in lastPosition...labels.length){
            var label = labels[i];

            if(label != '' && label != '-'){
                theSequence += label;
            }
        }

        theViewPortXUnits = Std.int(theGraphWidth / theXUnitSize);
        theLastXPosition = Std.int(theReadingsCount - theViewPortXUnits);

        if(theLastXPosition < 0){
            theLastXPosition = 0;
        }
    }

    public function calculateAnnotations(){
        var webApp : WorkspaceApplication = WorkspaceApplication.getApplication();

        var dataStore :Dynamic = webApp.getOutlineDataStore('DEFAULT');

        var node : Dynamic = dataStore.getNodeById('Annotations');

        /**
        * resize event can trigger this method before the outline panel has been
        * configured when the tab is activated
        **/
        if(node == null || traceData == null){
            return;
        }

        traceData.ANNOTATIONS = new Array<String>();

        annotationIdToPosition = new Map<String, Int>();

        var k = 0;
        for(i in 0...traceData.ALN_LABELS.length){
            var l = traceData.ALN_LABELS[i];

            if(l != '-' && l != ''){
                k++;

                if(l != traceData.LABELS[i]){
                    var id = l + Std.string(k) + traceData.LABELS[i];
                    traceData.ANNOTATIONS.push(id);

                    annotationIdToPosition.set(id, i);
                }
            }
        }



        var a = 0;

       // Ext.suspendLayouts();


        node.removeAll();

        for(i in 0...traceData.ANNOTATIONS.length){
            var annotation = traceData.ANNOTATIONS[i];

            node.appendChild({
            text : annotation,
            id : annotation,
            leaf: true,
            type: 'ANNOTATION'
            });

            if(a > 20){
                node.appendChild({
                text : 'Too many to show',
                id : 'Too many to show',
                leaf: true,
                type: 'ANNOTATION'
                });

                break;
            }
            a++;
        }


       // Ext.resumeLayouts(true);
    }

    public function getSequence(){
        return theSequence;
    }

    public function importTraceSequence(){
        getWorkspace().addObject(new DNAWorkspaceObject(new DNA(getSequence()), traceWO.getName() + ' (DNA)'), true);
    }

    public function calculatePages(){

    }

    public function render(traceData : ABITrace,?i:Int =0){
        theComponent.removeCls('x-trace-background');

        if(lastPosition > theLastXPosition){
            lastPosition = theLastXPosition;
        }

        //fetch dimensions
        var width = graphCanvas.width;
        var height = graphCanvas.height;

        //fetch canvas context
        var ctx = getGraphContext();

        ctx.clearRect(0,0, width, height);

        //channel colours
        var channelColours = ['CH1'=> 'RED', 'CH2'=> 'GREEN', 'CH3'=> 'BLUE', 'CH4'=> 'ORANGE'];

        var lastIPosition = 0;

        var lineX1 :Float = -1;
        var lineY1 :Float = -1;

        var lineX2 :Float  = -1;
        var lineY2 :Float = -1;

        var overlayCtx = overlayCanvas.getContext2d();
        overlayCtx.clearRect(0,0, overlayCanvas.width, overlayCanvas.height);

        var overlayLineX1Done = false;
        var overlayLineX2Done = false;

        //plot channels
        for(channel in theChannels){
            //get channel stroke colour
            var stroke_colour = channelColours[channel];

            //get readings
            var readings :Array<Float> = Reflect.field(traceData, channel);

            //start new path
            ctx.save();

            //set stroke colour
            ctx.strokeStyle = stroke_colour;
            ctx.lineWidth = 2;
            ctx.beginPath();

            var lastSplinePoints :Dynamic = null;

            var lastYValue : Float = null;

            var inGapBlock = false;

            for(i in lastPosition...readings.length){
                var correctedI = i - lastPosition;
                var x_pixel_pos = cast((theXUnitSize * correctedI)  + theLeftMargin, Float);

                if(x_pixel_pos > theGraphWidth + theLeftMargin){
                    break;
                }

                if(! overlayLineX1Done && i == lineX1RealPosition){
                    overlayCtx.beginPath();
                    overlayCtx.moveTo(x_pixel_pos, theTopMargin + 3);
                    overlayCtx.lineTo(x_pixel_pos, theGraphHeight + theTopMargin + 2);
                    overlayCtx.stroke();
                    overlayCtx.closePath();

                    lineX1 = x_pixel_pos;

                    overlayLineX1Done = true;
                }if(! overlayLineX2Done && i == lineX2RealPosition){
                    overlayCtx.beginPath();
                    overlayCtx.moveTo(x_pixel_pos, theTopMargin + 3);
                    overlayCtx.lineTo(x_pixel_pos, theGraphHeight + theTopMargin + 2);
                    overlayCtx.stroke();
                    overlayCtx.closePath();

                    lineX2 = x_pixel_pos;

                    overlayLineX2Done = true;
                }

                var y_pixel_pos = cast(theTopMargin + theGraphHeight -(theYUnitSize * readings[i]), Float);

                if(readings[i] == -1){
                    //in gap block
                    inGapBlock = true;

                    continue;
                }

                if(correctedI > 0){
                    var currentSplinePoints = null;

                    var x_pixel_pos_last = cast((theXUnitSize * (correctedI-1)) + theLeftMargin, Float);
                    var y_pixel_pos_last = cast(theTopMargin + theGraphHeight - (theYUnitSize * lastYValue), Float);//readings[(i-1)]

                    var x_pixel_pos_next = cast((theXUnitSize * (correctedI+1)) + theLeftMargin, Float);
                    var y_pixel_pos_next = cast(theTopMargin + theGraphHeight - (theYUnitSize * readings[(i+1)]), Float);

                    if(i >= readings.length -1){
                        currentSplinePoints = splineCurve(x_pixel_pos_last, y_pixel_pos_last, x_pixel_pos, y_pixel_pos, x_pixel_pos, y_pixel_pos, 0);
                    }else{
                        currentSplinePoints = splineCurve(x_pixel_pos_last, y_pixel_pos_last, x_pixel_pos, y_pixel_pos, x_pixel_pos_next, y_pixel_pos_next, 1);
                    }

                    if(inGapBlock){
                        //restart trace
                        ctx.moveTo(x_pixel_pos_last, y_pixel_pos_last);

                        inGapBlock = false;

                        lastSplinePoints = splineCurve(x_pixel_pos, y_pixel_pos, x_pixel_pos, y_pixel_pos, x_pixel_pos_next, y_pixel_pos_next, 0);
                    }else{
                        ctx.bezierCurveTo(
                            lastSplinePoints.outer.x,
                            lastSplinePoints.outer.y,
                            currentSplinePoints.inner.x,
                            currentSplinePoints.inner.y,
                            x_pixel_pos,
                            y_pixel_pos
                        );
                    }

                    //When the trace restarts from a gap region we need to know the last y trace value
                    lastYValue = readings[i];

                    lastSplinePoints = currentSplinePoints;
                }else{
                    ctx.moveTo(x_pixel_pos, y_pixel_pos);

                    var x_pixel_pos_next = cast((theXUnitSize * (correctedI+1)) + theLeftMargin, Float);
                    var y_pixel_pos_next = cast(theTopMargin + theGraphHeight - (theYUnitSize * readings[(i+1)]), Float);

                    lastSplinePoints = splineCurve(x_pixel_pos, y_pixel_pos, x_pixel_pos, y_pixel_pos, x_pixel_pos_next, y_pixel_pos_next, 0);

                    //When the trace restarts from a gap region we need to know the last y trace value
                    lastYValue = readings[i];
                }
            }

            ctx.stroke();

            ctx.restore();
        }

        //render axis labels
        ctx.save();

        //set label colour
        ctx.strokeStyle = 'BLACK';

        //get metrics of an A
        var aMetrics = ctx.measureText('A');

        //fetch x axis labels
        var labels :Array<String> = traceData.LABELS;

        //var nucs = new Array<String>();

        //render labels
        for(i in lastPosition...labels.length){
            var label = labels[i];

            //skip empty labels
            if(label != ''){
                var correctedI = i - lastPosition;

                //determine x position of label
                var x_pixel_pos = theXUnitSize * correctedI;

                if(x_pixel_pos + theLeftMargin > theGraphWidth + theLeftMargin){
                    break;
                }

                var highlight = false;

                if(traceData.ALN_LABELS.length > 0){
                    if(traceData.ALN_LABELS[i] != label){
                        highlight = true;
                    }
                }

                if(label == '-'){
                    highlight = true;
                }

                //render label
                if(highlight){
                    ctx.beginPath();
                    ctx.strokeStyle = 'red';
                    //+2 has no logic other than it appears required (more alignments need inspecting)
                    //+3 to remove overhang caused by x being 2px wide
                    ctx.moveTo(theLeftMargin + x_pixel_pos + 2, theTopMargin + 3);
                    //+2 for 2px line width
                    ctx.lineTo(theLeftMargin + x_pixel_pos + 2, theGraphHeight + theTopMargin + 2);
                    ctx.stroke();
                    ctx.strokeStyle = 'black';
                    ctx.closePath();

                    ctx.fillStyle = 'red';
                    ctx.fillText(label, theLeftMargin + x_pixel_pos, theTopMargin + theGraphHeight + 10 + 2);
                    ctx.fillStyle = 'black';
                }else{
                    ctx.fillText(label, theLeftMargin + x_pixel_pos, theTopMargin + theGraphHeight + 10 + 2);
                }


                //nucs.push(label);
            }
        }

        if(traceData.ALN_LABELS.length > 0){
            for(i in lastPosition...labels.length){
                var correctedI = i - lastPosition;

                //determine x position of label
                var x_pixel_pos = theXUnitSize * correctedI;

                if(x_pixel_pos + theLeftMargin > theGraphWidth + theLeftMargin){
                    break;
                }

                var label = traceData.ALN_LABELS[i];

                //skip empty labels
                if(label != ''){
                    //render label
                    ctx.fillText(label, theLeftMargin + x_pixel_pos, theTopMargin + theGraphHeight + 20 + 2);
                }
            }
        }

        var mHeight =  ctx.measureText('M').width;

        //render y axis labels
        for(i in 0...11){
            var y_label = theYIntervalDivisions * i;
            var y_pos = theYUnitSize * (y_label);

            var yLabelMetrics = ctx.measureText(Std.string(y_label));

            //x -2 to account for shift in y axis by -2px across
            //y -2 to account for shift in y axis by -2 px down
            //y -2 as theLeftMargin has an extra 2 px to push trace zero point next to y line and not on it
            ctx.fillText(Std.string(y_label), theLeftMargin - yLabelMetrics.width -2 -2, theGraphHeight + theTopMargin - y_pos + (mHeight/2)+2);
        }

        ctx.restore();

        overlayCanvas.onmouseup = function(e){
            var ne = getNormalisedEvent(e);

            if(ne.offsetX >= lineX1 -2 && e.offsetX <= lineX1 +2){
                overlayCtx.clearRect(0,0,overlayCanvas.width, overlayCanvas.height);

                lineX1 = -1;

                if(lineX2RealPosition != -1){
                    overlayCtx.beginPath();

                    overlayCtx.moveTo(lineX2, theTopMargin);
                    overlayCtx.lineTo(lineX2, theGraphHeight + theTopMargin);
                    overlayCtx.stroke();
                    overlayCtx.closePath();
                }

                lineX1RealPosition = -1;
            }else if(ne.offsetX >= lineX2 -2 && e.offsetX <= lineX2 +2){
                overlayCtx.clearRect(0,0,overlayCanvas.width, overlayCanvas.height);

                lineX2 = -1;

                if(lineX1RealPosition != -1){
                    overlayCtx.beginPath();

                    overlayCtx.moveTo(lineX1, theTopMargin);
                    overlayCtx.lineTo(lineX1, theGraphHeight + theTopMargin);
                    overlayCtx.stroke();
                    overlayCtx.closePath();
                }

                lineX2RealPosition = -1;
            }else{
                if(lineX1RealPosition == -1){
                    lineX1 = ne.offsetX;

                    lineX1RealPosition = convertXToPosition(lineX1);
                }else if(lineX2RealPosition == -1){
                    lineX2 = ne.offsetX;
                    lineX2RealPosition = convertXToPosition(lineX2);
                }else{
                    return;
                }

                overlayCtx.beginPath();

                overlayCtx.moveTo(ne.offsetX, theTopMargin);
                overlayCtx.lineTo(ne.offsetX, theGraphHeight + theTopMargin);
                overlayCtx.stroke();
                overlayCtx.closePath();
            }


        }

        //render y axis
        ctx.save();
        ctx.beginPath();
        ctx.lineWidth = 2;

        //+3 to remove overhang caused by x being 2px wide
        //-2 as theLeftMargin has an extra 2 px to push trace zero point next to y line and not on it
        ctx.moveTo(theLeftMargin -2,theTopMargin + 3);
        ctx.lineTo(theLeftMargin -2, theGraphHeight + theTopMargin + 3);
        ctx.stroke();
        ctx.restore();

        //render x axis
        ctx.save();
        ctx.beginPath();
        ctx.lineWidth = 2;
        ctx.moveTo(theLeftMargin -1, theTopMargin + theGraphHeight + 2); //-1 to remove overhang caused by y being 2px wide
        ctx.lineTo(theLeftMargin + theGraphWidth -1, theTopMargin + theGraphHeight + 2);
        ctx.stroke();
        ctx.restore();
    }

    function updateSelected(cX1 : Int , cX2 : Int){
        var sequence = '';

        var labels = traceData.LABELS;

        for(i in cX1...cX2){
            if(labels[i] != ''){
                sequence += labels[i];
            }
        }

        WorkspaceApplication.getApplication().setCentralInfoPanelText('Selected: '+cX1+"-"+ cX2+"  "+sequence);
    }

    function convertXToPosition(xPos : Float){
        var position : Int = Std.int((xPos - theLeftMargin) / theXUnitSize);

        position += lastPosition;

        return position;
    }

    /**
    * getNormalisedEvent returns event x, y positions of the event normalised
    * to account for differences between web-browsers implementations of clientX
    **/
    static inline function getNormalisedEvent(e : Dynamic){
        var normalisedEvent = {offsetX:0., offsetY:0.};

        if(e == null){
            e = new js.html.Event('');
        }

        //http://www.jacklmoore.com/notes/mouse-position/
        var target :Dynamic = e.target ? e.target : e.srcElement;

        var rect = target.getBoundingClientRect();

        normalisedEvent.offsetX = e.clientX - rect.left;
        normalisedEvent.offsetY = e.clientY - rect.top;

        return normalisedEvent;
    }

    /**
    * Calculate spline points
    **/
    static inline function splineCurve(firstPoint_x : Float, firstPoint_y : Float, middlePoint_x : Float, middlePoint_y : Float, afterPoint_x : Float, afterPoint_y : Float, tension : Float){
        var d01=Math.sqrt(Math.pow(middlePoint_x-firstPoint_x,2)+Math.pow(middlePoint_y - firstPoint_y,2));
        var d12=Math.sqrt(Math.pow(afterPoint_x-middlePoint_x,2)+Math.pow(afterPoint_y-middlePoint_y,2));
        var fa=tension*d01/(d01+d12);
        var fb=tension*d12/(d01+d12);
        return {
            inner : {
                x : middlePoint_x-fa*(afterPoint_x-firstPoint_x),
                y : middlePoint_y-fa*(afterPoint_y-firstPoint_y)
            },
            outer : {
                x: middlePoint_x+fb*(afterPoint_x-firstPoint_x),
                y : middlePoint_y+fb*(afterPoint_y-firstPoint_y)
            }
        };
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-trace',
                html:'Sequencing<br/>Viewer',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new ABITraceWO(new ABITrace(), "Sequencing"), true);
                },
                tooltip: {dismissDelay: 10000, text: 'View DNA sequencing traces'}
            }
        ];
    }
}


/*public function installOverlayListeners(){

        var width = overlayCanvas.width;
        var height = overlayCanvas.height;

        //fetch canvas context
        var ctx = overlayCanvas.getContext2d();

        var xStart : Float = -1;
        var yStart : Float = -1;

        var xBackStep : Float = 0;

        var drawRectangle =  function(e){
            var ne = getNormalisedEvent(e);

            ctx.clearRect(0, 0, width, height);

            var x1;
            var y1;
            var width;
            var height;

            var forwards;

            if(xStart > ne.offsetX){
                x1 = ne.offsetX;
                width = xStart - x1;

                forwards = false;
            }else{
                x1 = xStart;
                width = ne.offsetX - x1;

                forwards = true;
            }

            if(yStart > ne.offsetY){
                y1 = ne.offsetY;
                height = yStart - y1;
            }else{
                y1 = yStart;
                height = ne.offsetY - y1;
            }

            if(forwards && x1+width > theGraphWidth){
                lastPosition += 20;

                render(traceData);

                xBackStep += theXUnitSize * 20;

                var lX1 = x1 - xBackStep;

                if(lX1 < theLeftMargin){
                    lX1 = theLeftMargin;
                }

                js.Browser.window.console.log(x1 + '/' + xBackStep);

                ctx.setStrokeColor(0,255,0,1);
                ctx.strokeRect(lX1, y1, width + xBackStep, height);

                var cX1 = convertXToPosition(lX1);
                var cX2 = convertXToPosition(lX1 + width);

                updateSelected(cX1, cX2);
            }else if(!forwards && x1 <= theLeftMargin){
                lastPosition -= 5;

                if(lastPosition >= 0){
                    render(traceData);

                    xBackStep -= theXUnitSize * 20;

                    var lX1 = x1 - xBackStep;

                    if(lX1 < theLeftMargin){
                        lX1 = theLeftMargin;
                    }

                    js.Browser.window.console.log(x1 + '/' + xBackStep);

                    ctx.setStrokeColor(0,255,0,1);
                    ctx.strokeRect(lX1, y1, width + xBackStep, height);

                    var cX1 = convertXToPosition(lX1);
                    var cX2 = convertXToPosition(lX1 + width);

                    updateSelected(cX1, cX2);
                }else{
                    lastPosition = 0;
                }
            }else{
                ctx.setStrokeColor(255,0,0,1);
                ctx.strokeRect(x1, y1, width, height);

                var cX1 = convertXToPosition(x1);
                var cX2 = convertXToPosition(x1 + width);

                updateSelected(cX1, cX2);
            }
        }

        overlayCanvas.onmousedown = function(e){
            overlayCanvas.onmousemove = drawRectangle;
            var ne = getNormalisedEvent(e);

            xStart = ne.offsetX;
            yStart = ne.offsetY;
        };

        overlayCanvas.onmouseup = function(e){
            overlayCanvas.onmousemove = null;

            ctx.clearRect(0, 0, width, height);
        };
    }*/

