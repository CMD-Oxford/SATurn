/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.client.programs.AlignmentViewer;
import saturn.core.domain.SgcTarget;
import saturn.client.core.ClientCore;
import saturn.client.programs.blocks.TargetSummary;
import saturn.core.domain.SgcConstruct;
import saturn.core.ConstructSet;
import saturn.util.MathUtils;
import saturn.util.HaxeException;
import saturn.core.FastaEntity;
import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.core.domain.SgcConstruct;
import saturn.client.workspace.MultiConstructHelperWO;

import saturn.db.Model;
import saturn.core.domain.SgcVector;
import saturn.core.domain.SgcRestrictionSite;
import saturn.core.domain.SgcAllele;
import saturn.core.domain.SgcConstructPlate;

import saturn.core.Ligation;
import saturn.core.DoubleDigest;
import saturn.core.RestrictionSite;
import saturn.core.CleavageSite;
import saturn.core.DNA;
import saturn.core.CutProductDirection;
import saturn.core.Protein;
import bindings.Ext;

import saturn.core.ClustalOmegaParser;
import saturn.client.core.CommonCore;

import saturn.db.BatchFetch;
import saturn.client.workspace.DNAWorkspaceObject;
import saturn.client.workspace.ProteinWorkspaceObject;

import saturn.client.WorkspaceApplication;

class MultiConstructHelper extends TableHelper{
    static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ MultiConstructHelperWO ];

    public function new(){
        theTitle = 'Construct Helper';

        super(SgcConstruct);
    }

    override public function getButtonPanelConfiguration() : Array<Dynamic>{
        //var me : MultiConstructHelper  = this;

        var baseButtons = super.getButtonPanelConfiguration();

        baseButtons.push({
            region : 'center',
            xtype : 'button',
            text : 'Calculate',
            handler : function() {
                calculate();
            }
        });

        return baseButtons;
    }

    override public function getContextMenuItems(modelColumn : String, rowIndex : Int) : Array<Dynamic>{
        //var me :MultiConstructHelper = this;

        var items = super.getContextMenuItems(modelColumn, rowIndex);
        if(modelColumn == 'dnaSeq'){
            items.push({
                text : "Import DNA",
                handler : function() {
                    var model = getStore().getAt(rowIndex);
                    var dnaObj = new DNA(model.get(modelColumn));

                    var dnawo = new DNAWorkspaceObject(dnaObj,model.get('constructId')+' (DNA) ');

                    getApplication().getWorkspace().addObject(dnawo,true);
                }
            });
        }else if(modelColumn == 'proteinSeq' || modelColumn == 'proteinSeqNoTag'){
            items.push({
                text : "Import Protein",
                handler : function() {
                    var model = getStore().getAt(rowIndex);
                    var label = model.get('constructId');
                    if(modelColumn == 'proteinSeqNoTag'){
                        label = label + ' (Cleaved) ';
                    }else{
                        label = label + ' (Tagged) ';
                    }
                    var proteinObj = new Protein(model.get(modelColumn));

                    var proteinwo = new ProteinWorkspaceObject(proteinObj,label);

                    getApplication().getWorkspace().addObject(proteinwo,true);
                }
            });
        }else if(modelColumn == 'allele.alleleId'){
           items.push({
                text : "Import Allele",
                handler : function() {
                    var model = getStore().getAt(rowIndex);
                    var alleleId = model.get('allele.alleleId');

                    getProvider().getById(alleleId, SgcAllele, function(allele : SgcAllele, exception){
                        if(exception != null){
                            getApplication().showMessage('Fetch error', exception);
                        }else{
                            var dna = new DNA(allele.dnaSeq);

                            var wo = new DNAWorkspaceObject(dna, alleleId);

                            getApplication().getWorkspace().addObject(wo,true);
                        }
                    });
                }
            });
        }else if(modelColumn == 'vector.vectorId'){
            items.push({
            text : "Import Vector",
            handler : function() {
                var model = getStore().getAt(rowIndex);
                var vectorId = model.get('vector.vectorId');

                getProvider().getById(vectorId, SgcVector, function(vector : SgcVector, exception){
                    if(exception != null){
                        getApplication().showMessage('Fetch error', exception);
                    }else{
                        var dna = new DNA(vector.getSequence());

                        var wo = new DNAWorkspaceObject(dna, vectorId);

                        getApplication().getWorkspace().addObject(wo,true);
                    }
                });
            }
            });
        }else if(modelColumn == 'constructId'){
            items.push({
            text : "Show construct alignment",
            handler : function() {
                var model = getStore().getAt(rowIndex);
                var constructId = model.get('constructId');

                var target = constructId.split('-')[0];

                showConstructAlignment(target);
            }
            });
        }

        return items;
    }

    /****
    *Aligns construct protein sequences whith target protein sequence and determines the start and end positions of the
    *construct relative to the target
    ****/

    public function doAlignments(){
        //Becomes fasta strong of construct and target protein sequences
        var fasta : String = '';
        //Fetches the datastore, the data behind the datagrid as displayed to the users.
        var constructStore = getStore();
        //Determine the number of constructs constructStore
        var constructCount :Int = constructStore.count() -1;

        //iterate through each construct (SgcConstruct) in the constructStore
        for(i in 0...constructCount){
            //Fetch the consturct data from constructStore
            var constructModel : Dynamic = constructStore.getAt(i);

            //Fetch the consturct protein sequence (minus any tags) from the SgcConsturct
            var constructSequence = constructModel.get('proteinSeqNoTag');

            //Fetch the constructId from the SgcConsturct and get the target Id by removing the hyphen onwards
            var targetId = constructModel.get('constructId').split('-')[0];

            //Generates SQL query, looking up the targetId, returning an SgcTarget object.
            //The mappings to the database column names are defined in SGC.hx.
            getProvider().getById(targetId, SgcTarget, function(target : SgcTarget, databaseError){
                if(databaseError != null){
                    getApplication().showMessage('Database Fetch Error', databaseError);
                }else{
                    //Extract the proteinSeq from the SgcTarget object
                    var targetProteinSeq : String = target.proteinSeq;

                    //Create fasta file containing both the construct and target protein sequences
                    var fasta = '>' + constructModel.get('constructId') + '\n' + constructSequence + '\n' + '>'
                    + targetId + '\n' + targetProteinSeq + '\n';

                    //Pass the fatsa file containing the construct and target protein sequnces to clustal
                    BioinformaticsServicesClient.getClient().sendClustalReportRequest(fasta, function(response, clustalError){
                        if(clustalError == null){
                            //Clustal report
                            var clustalReport = response.json.clustalReport;
                            //Defined location of the .txt file of the returned Clustal report
                            var location : js.html.Location = js.Browser.window.location;
                            var URL = location.protocol+'//'+location.hostname+':'+location.port+'/'+clustalReport;


                            CommonCore.getContent(URL, function(content){
                                //Passes the clustal file to the readStartStop method, which returns an array of Ints
                                var startStopPos = ClustalOmegaParser.readStartStop(content);
                                //Sets the consturctModel parameters to the startStopPos array. 1 is added to convert
                                //from index position to sequence postion
                                constructModel.set('constructStart', startStopPos[0] + 1);
                                constructModel.set('constructStop', startStopPos[1] + 1);
                            });
                        }else{
                            getApplication().showMessage('Clustal Error', clustalError);
                        }
                    });
                }
            });
        }
    }

    public function showConstructAlignment(target : String){
        var objectId = getActiveObjectId();

        var parentFolder = getWorkspace().getParentFolder(objectId);

        var folder = parentFolder.findChild('text', target);
        if(folder != null){
            getWorkspace().removeItem(folder.getId());
        }

        folder = getWorkspace()._addFolder(target, parentFolder);

        var constructs = new Array<SgcConstruct>();

        var n : Int = Std.int(getStore().data.length-1);
        for(i in 0...n){
            var model :Dynamic = getStore().getAt(i);
            var constructId :String = model.get('constructId');
            if(constructId.split('-')[0] == target){
                var seq = model.get('proteinSeqNoTag');
                var protObj = new Protein(seq);
                protObj.setMoleculeName(constructId);

                var construct = new SgcConstruct();
                construct.constructId = constructId;
                construct.proteinSeqNoTag = seq;
                construct.status = model.get('status');

                constructs.push(construct);

                getWorkspace().addObject(protObj, false, folder);
            }
        }

        var sum = new TargetSummary(target);
        sum.setSequences(constructs);
        sum.setParentFolder(folder);
        sum.getTargetSequence();
    }

    public function calculate(){
        getApplication().showMessage('Please wait','Please wait.....');

        var constructStore = getStore();
        var constructCount :Int = constructStore.count() -1;

        var allelesMap = new Map<String,String>();
        var vectorMap = new Map<String,String>();

        var resMap = new Map<String,String>();

        for(i in 0...constructCount){
            var constructModel : Dynamic = constructStore.getAt(i);

            var alleleId = constructModel.get('allele.alleleId');
            var vectorId = constructModel.get('vector.vectorId');

            if(isNullOrEmpty(alleleId)){
                setRecordValid(constructModel, 'Allele is missing');
                continue;
            }

            if(isNullOrEmpty(vectorId)){
                setRecordValid(constructModel, 'Vector is missing');
                continue;
            }

            allelesMap.set(alleleId,'');
            vectorMap.set(vectorId,'');

            var resId1 = constructModel.get('res1.enzymeName');
            var resId2 = constructModel.get('res2.enzymeName');

            if(resId1 != null && resId1 != ''){
                resMap.set(resId1,'');
            }

            if(resId2 != null && resId2 != ''){
                resMap.set(resId2,'');
            }
        }

        var alleles = new Array<String>();
        for(allele in allelesMap.keys()){
            alleles.push(allele);
        }

        var vectors = new Array<String>();
        for(vector in vectorMap.keys()){
            vectors.push(vector);
        }

        var resSites = new Array<String>();
        for(res in resMap.keys()){
            resSites.push(res);
        }

        var batchFetch = new BatchFetch(function(obj, err){
            getApplication().showMessage('Batch fetch failure', err);
        });

        batchFetch.getByIds(alleles, SgcAllele,'ALLELES',null);
        batchFetch.getByIds(vectors, SgcVector,'VECTORS',null);

        if(resSites.length>0){
            batchFetch.getByIds(resSites, SgcRestrictionSite,'RESS',null);
        }

        batchFetch.onComplete=function(){
            var vectorResSites = new Map<String,String>();

            var alleles : Array<SgcAllele> = batchFetch.getObject('ALLELES');
            var vectors : Array<SgcVector> = batchFetch.getObject('VECTORS');
            var ress : Array<SgcRestrictionSite> = batchFetch.getObject('RESS');
            for(vector in vectors){
                vectorResSites.set(Std.string(vector.res1Id),'');
                vectorResSites.set(Std.string(vector.res2Id),'');
            }

            var vResSites = new Array<String>();
            for(vResSite in vectorResSites.keys()){
                vResSites.push(vResSite);
            }

            batchFetch.getByPkeys(vResSites,SgcRestrictionSite,'VSITES',null);

            batchFetch.onComplete=function(){
                var alleleToObj = new Map<String,SgcAllele>();
                var vectorToObj = new Map<String, SgcVector>();
                var resToObj = new Map<String, SgcRestrictionSite>();
                var vresToObj = new Map<Int, SgcRestrictionSite>();

                for(allele in alleles){
                    alleleToObj.set(allele.alleleId,allele);
                }

                for(vector in vectors){
                    vectorToObj.set(vector.vectorId,vector);
                }

                if(ress != null){
                    for(res in ress){
                        resToObj.set(res.enzymeName,res);
                    }
                }

                var vSites :Array<SgcRestrictionSite> = batchFetch.getObject('VSITES');
                for(vSite in vSites){
                    vresToObj.set(vSite.id,vSite);
                }

                WorkspaceApplication.suspendUpdates();
                for(i in 0...constructCount){
                    var constructModel : Dynamic = constructStore.getAt(i);

                    var alleleId = constructModel.get('allele.alleleId');
                    var vectorId = constructModel.get('vector.vectorId');
                    var resId1 = constructModel.get('res1.enzymeName');
                    var resId2 = constructModel.get('res2.enzymeName');

                    // Check for missing or empty values
                    var skip = false;
                    var values = [alleleId, vectorId];
                    for(value in values){
                        if(value == null || value == ''){
                            //theTable.getView().addRowCls(constructModel,'molbio-invalid-row');
                            //var row : JQuery = new JQuery(theTable.getView().getNode(constructModel));
                            //row.addClass('molbio-invalid-row');
                            skip = true;
                        }
                    }

                    if(skip){
                        continue;
                    }

                    var allele : SgcAllele = alleleToObj.get(alleleId);
                    if(allele == null){
                        setRecordValid(constructModel, 'Allele ' + alleleId + ' is missing');
                        continue;
                    }

                    var vector : SgcVector = vectorToObj.get(vectorId);
                    if(vector == null){
                        setRecordValid(constructModel, 'Vector ' + vectorId + ' is missing');
                        continue;
                    }


                    var vRes1 : SgcRestrictionSite = vresToObj.get(vector.res1Id);
                    if(vRes1 == null){
                        setRecordValid(constructModel, 'Restriction Site: ' + vRes1 + ' not found');
                        continue;
                    }

                    var vRes2 : SgcRestrictionSite = vresToObj.get(vector.res2Id);
                    if(vRes2 == null){
                        setRecordValid(constructModel, 'Restriction Site: ' + vRes2 + ' not found');
                        continue;
                    }

                    var res1 : SgcRestrictionSite;
                    var res2 : SgcRestrictionSite;

                    if(resId1 != null && resId1 != ''){
                        res1 = resToObj.get(resId1);

                        if(res1 == null){
                            setRecordValid(constructModel, 'Restriction Site: ' + resId1 + ' not found');
                            continue;
                        }
                    }else{
                        res1 = vRes1;

                        constructModel.set('res1.enzymeName',vRes1.enzymeName);
                    }

                    if(resId2 != null && resId2 != ''){
                        res2 = resToObj.get(resId2);

                        if(res2 == null){
                            setRecordValid(constructModel, 'Restriction Site: ' + resId2 + ' not found');
                            continue;
                        }
                    }else{
                        res2 = vRes2;
                        constructModel.set('res2.enzymeName',vRes2.enzymeName);
                    }

                    try{
                        // Initiate objects from Scarab values
                        var alleleSequence = new DNA(allele.dnaSeq);
                        var res1Seq = new RestrictionSite(res1.cutSequence);
                        var res2Seq = new RestrictionSite(res2.cutSequence);

                        var v_res1Seq = new RestrictionSite(vRes1.cutSequence);
                        var v_res2Seq = new RestrictionSite(vRes2.cutSequence);

                        var vectorSequence = new DNA(vector.getSequence());

                        var proteaseCutSeq = new CleavageSite(vector.proteaseCutSequence);
                        var proteaseProduct = vector.proteaseProduct;

                        // Check that direction value is valid
                        var direction : CutProductDirection;

                        if(proteaseProduct == 'UPSTREAM'){
                            direction = CutProductDirection.UPSTREAM;
                        }else if(proteaseProduct == 'DOWNSTREAM'){
                            direction = CutProductDirection.DOWNSTREAM;
                        }else if(proteaseProduct == 'UPDOWN'){
                            direction = CutProductDirection.UPDOWN;
                        }else{
                            setRecordValid(constructModel,'Invalid value for Vector field protease product direction should be either UPSTREAM or DOWNSTREAM');
                            continue;
                        }

                        var alleleDigest = new DoubleDigest(alleleSequence,res1Seq,res2Seq); // Digest Allele
                        var vectorDigest = new DoubleDigest(vectorSequence,v_res1Seq,v_res2Seq); // Digest Vector

                        var ligation = new Ligation(vectorDigest, alleleDigest); // Setup ligation

                        ligation.calculateProduct(); // Ligate Allele and Vector digests

                        // Find first start codon in ligated product
                        var startCodonPosition = ligation.getFirstStartCodonPosition(GeneticCodes.STANDARD);
                        if(startCodonPosition == -1){
                            setRecordValid(constructModel,'Ligation product is missing a start codon');
                            continue;
                        }

                        // Get translation of ligation product
                        var uncutSequence = new Protein(ligation.getTranslation(GeneticCodes.STANDARD,startCodonPosition, true));

                        // Digest the protein with the protease and retrieve the sequence either upstream or downstream of the cut
                        var cutSequence = proteaseCutSeq.getCutProduct(uncutSequence,direction);

                        // Calculate and store MW of cut and uncut proteins
                        constructModel.set('expectedMass', MathUtils.sigFigs(uncutSequence.getMW(),4));
                        constructModel.set('expectedMassNoTag', MathUtils.sigFigs(new Protein(cutSequence).getMW(),4));
                        constructModel.set('dnaSeq',ligation.getSequence());
                        constructModel.set('proteinSeq',uncutSequence.getSequence());
                        constructModel.set('proteinSeqNoTag', cutSequence);

                        //constructModel.commit(); // Commit so that red markers aren't shown
                    }catch(ex: HaxeException){
                        setRecordValid(constructModel, ex.getMessage());
                    }catch(e: Dynamic){
                        setRecordValid(constructModel, 'Unknown exception');
                    }
                }


                theTable.getView().refresh();
                //theTable.store.update();
                getApplication().showMessage('Finished','Calculation finished');
                WorkspaceApplication.resumeUpdates(false);
            };

            batchFetch.execute();
        };

        batchFetch.execute();
    }

    override public function insertOrDeletePerformed(){
        var wo = getWorkspace().getObjectSafely(getActiveObjectId(), MultiConstructHelperWO);

        if(wo != null){
            var plateName = wo.getObject().getPlateName();

            if(plateName != null){
                getProvider().evictNamedQuery('FETCH_CONSTRUCT_PLATE',[plateName]);
            }
        }
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        var wo = getWorkspace().getObjectSafely(objectId, MultiConstructHelperWO);

        if(wo != null){
            setTitle(wo.getName());

            if(!loadedExisting){
                var plateName = wo.getObject().getPlateName();

                if(plateName != null){
                    if(viewReady){
                        queryLoad();
                    }else{
                        loadRequired = true;
                    }
                }
            }
        }
    }

    override public function queryLoad(){
        var wo = getWorkspace().getObjectSafely(getActiveObjectId(), MultiConstructHelperWO);

        if(wo != null){
            var plateName = wo.getObject().getPlateName();

            if(plateName != null){
                getProvider().getByNamedQuery('FETCH_CONSTRUCT_PLATE',[plateName],SgcConstruct, true, function(objs: Array<SgcConstruct>,exception){
                    if(exception == null && objs != null){
                        loadObjects(objs);
                    }else{
                        getApplication().showMessage('Construct plate fetch failure','Unable to fetch constructs for ' + plateName);
                    }
                });
            }
        }
    }

    override public function setTitle(title : String){
        getApplication().setProgramTabTitle(this, title);
    }

    override public function onFocus() : Void{
        super.onFocus();

        var exportMenu = getApplication().getExportMenu();

        exportMenu.add({
            text: 'Construct (DNA) to FASTA',
            hidden : false,
            handler: function(){
                var entityStore = getStore();
                var entityCount :Int = entityStore.count();

                var strBuf = new StringBuf();

                var fields = theModel.getFields();
                var priField = theModel.getPrimaryKey();

                for(i in 0...entityCount){
                    var entityModel : Dynamic = entityStore.getAt(i);

                    var dnaStr = entityModel.get('dnaSeq');
                    if(dnaStr != null && dnaStr != ''){
                        strBuf.add(FastaEntity.formatFastaFile(entityModel.get('constructId'), dnaStr));
                    }
                }

                var wo : WorkspaceObject<Dynamic> = getActiveObject(WorkspaceObject);

                getApplication().saveTextFile(strBuf.toString(), wo.getName() + '-constructs-dna.fasta');
            }
        });

        exportMenu.add({
            text: 'Construct (Protein) to FASTA',
            hidden : false,
            handler: function(){
                var entityStore = getStore();
                var entityCount :Int = entityStore.count();

                var strBuf = new StringBuf();

                var fields = theModel.getFields();
                var priField = theModel.getPrimaryKey();

                for(i in 0...entityCount){
                    var entityModel : Dynamic = entityStore.getAt(i);

                    var protStr = entityModel.get('proteinSeq');
                    if(protStr != null && protStr != ''){
                        strBuf.add(FastaEntity.formatFastaFile(entityModel.get('constructId'), protStr));
                    }

                    //strBuf.add('>' + entityModel.get('constructId')  + '\n' + entityModel.get('proteinSeq') + '\n');
                }

                var wo : WorkspaceObject<Dynamic> = getActiveObject(WorkspaceObject);

                getApplication().saveTextFile(strBuf.toString(), wo.getName() + '-constructs-protein.fasta');
            }
        });

        exportMenu.add({
            text: 'Construct (Protein No Tag) to FASTA',
            hidden : false,
            handler: function(){
                var entityStore = getStore();
                var entityCount :Int = entityStore.count();

                var strBuf = new StringBuf();

                var fields = theModel.getFields();
                var priField = theModel.getPrimaryKey();

                for(i in 0...entityCount){
                    var entityModel : Dynamic = entityStore.getAt(i);

                    var protStr = entityModel.get('proteinSeqNoTag');
                    if(protStr != null && protStr != ''){
                        strBuf.add(FastaEntity.formatFastaFile(entityModel.get('constructId'), protStr));
                    }
                }

                var wo : WorkspaceObject<Dynamic> = getActiveObject(WorkspaceObject);

                getApplication().saveTextFile(strBuf.toString(), wo.getName() + '-constructs-protein-no-tag.fasta');
            }
        });

        getApplication().getImportMenu().add({
            text: 'Import all Constructs (DNA)',
            handler: function(){
                loadAllConstructDNA();
            }
        });

        getApplication().getImportMenu().add({
            text: 'Import all Constructs (Protein)',
            handler: function(){
                loadAllConstructProtein();
            }
        });

        getApplication().getImportMenu().add({
            text: 'Import all Constructs (Protein No Tag)',
            handler: function(){
                loadAllConstructProteinNoTag();
            }
        });

        getApplication().getImportMenu().add({
            text: 'Import all alleles (DNA)',
            handler: function(){
                loadAllAllelesDNA();
            }
        });

        getApplication().getImportMenu().add({
            text: 'Import all alleles (Protein)',
            handler: function(){
                loadAllAllelesDNA();
            }
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-calculate',
            text: 'Calculate',
            handler: function(){
                calculate();
            },
            tooltip: {dismissDelay: 10000, text: 'Calculate DNA/Protein sequences and MW'}
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-calculate',
            text: 'Calculate Positions',
            handler: function(){
                doAlignments();
            },
            tooltip: {dismissDelay: 10000, text: 'Calculate start/end positions of construct on target'}
        });

        getApplication().getToolBar().add({
            text: 'Save<br/>Primer Report',
            iconCls :'x-btn-copy',
            handler: function(){
                savePrimerReport();
            },
            tooltip: {dismissDelay: 10000, text: 'Saves unique list of primers in a format that can be sent to MWG'}
        });

        getApplication().getToolBar().add({
            text: 'Email<br/>Primer Order',
            iconCls :'x-btn-copy',
            handler: function(){
                promptSendPrimerReport();
            },
            tooltip: {dismissDelay: 10000, text: 'Email BioTech and yourself with a unique list of primers to order from MWG<br/>(CSV format can be uploaded straight to the MWG web-site)'}
        });
    }

    public function loadAllAllelesDNA(){
        var bFetch =  new BatchFetch(function(obj, err){
            getApplication().showMessage('Batch fetch failure', err);
        });

        var alleleStore = getStore();
        var alleleCount :Int = alleleStore.count();

        var alleleSet = new Map<String,String>();
        var rIdset = new Map<String,String>();

        for(i in 0...alleleCount){
            var alleleModel : Dynamic = alleleStore.getAt(i);

            var alleleId = alleleModel.get('allele.alleleId');

            if(alleleId != null && alleleId != ''){
                alleleSet.set(alleleId,'');
            }
        }

        var alleleIds = new Array<String>();
        for(alleleId in alleleSet.keys()){
            alleleIds.push(alleleId);
        }

        bFetch.getByIds(alleleIds, SgcAllele,'__IGNORE_ME__', null);

        bFetch.onComplete = function(){
            for(alleleId in alleleIds){
                var obj = getProvider().getObjectFromCache(SgcAllele, 'alleleId', alleleId);

                if(obj != null){
                    var dna = new DNA(obj.dnaSeq);
                    var wo = new DNAWorkspaceObject(dna, alleleId);

                    getWorkspace()._addObject(wo, false, false);
                }
            }

            getWorkspace().reloadWorkspace();
        };

        bFetch.execute();
    }

    public function loadAllAllelesProtein(){
        var bFetch =  new BatchFetch(function(obj, err){
            getApplication().showMessage('Batch fetch failure', err);
        });

        var alleleStore = getStore();
        var alleleCount :Int = alleleStore.count();

        var alleleSet = new Map<String,String>();
        var rIdset = new Map<String,String>();

        for(i in 0...alleleCount){
            var alleleModel : Dynamic = alleleStore.getAt(i);

            var alleleId = alleleModel.get('allele.alleleId');

            if(alleleId != null && alleleId != ''){
                alleleSet.set(alleleId,'');
            }
        }

        var alleleIds = new Array<String>();
        for(alleleId in alleleSet.keys()){
            alleleIds.push(alleleId);
        }

        bFetch.getByIds(alleleIds, SgcAllele,'__IGNORE_ME__', null);

        bFetch.onComplete = function(){
            for(alleleId in alleleIds){
                var obj = getProvider().getObjectFromCache(SgcAllele, 'alleleId', alleleId);

                if(obj != null){
                    var protein = new Protein(obj.proteinSeq);
                    var wo = new ProteinWorkspaceObject(protein, alleleId);

                    getWorkspace()._addObject(wo, false, false);
                }
            }

            getWorkspace().reloadWorkspace();
        };

        bFetch.execute();
    }

    public function loadAllConstructDNA(){
        var alleleStore = getStore();
        var alleleCount :Int = alleleStore.count();

        for(i in 0...alleleCount){
            var alleleModel : Dynamic = alleleStore.getAt(i);

            var constructId = alleleModel.get('constructId');

            if(constructId != null && constructId != ''){
                var dna = new DNA(alleleModel.get('dnaSeq'));
                var wo = new DNAWorkspaceObject(dna, constructId);

                getWorkspace()._addObject(wo, false, false);
            }
        }

        getWorkspace().reloadWorkspace();
    }

    public function loadAllConstructProtein(){
        var alleleStore = getStore();
        var alleleCount :Int = alleleStore.count();

        for(i in 0...alleleCount){
            var alleleModel : Dynamic = alleleStore.getAt(i);

            var constructId = alleleModel.get('constructId');

            if(constructId != null && constructId != ''){
                var dna = new DNA(alleleModel.get('proteinSeq'));
                var wo = new DNAWorkspaceObject(dna, constructId);

                getWorkspace()._addObject(wo, false, false);
            }
        }

        getWorkspace().reloadWorkspace();
    }

    public function loadAllConstructProteinNoTag(){
        var alleleStore = getStore();
        var alleleCount :Int = alleleStore.count();

        for(i in 0...alleleCount){
            var alleleModel : Dynamic = alleleStore.getAt(i);

            var constructId = alleleModel.get('constructId');

            if(constructId != null && constructId != ''){
                var dna = new DNA(alleleModel.get('proteinSeqNoTag'));
                var wo = new DNAWorkspaceObject(dna, constructId);

                getWorkspace()._addObject(wo, false, false);
            }
        }

        getWorkspace().reloadWorkspace();
    }

    public function getConstructList() : Array<String>{
        var constructStore = getStore();
        var constructCount :Int = constructStore.count();

        var constructIds = new Array<String>();

        for(i in 0...constructCount){
            var constructModel : Dynamic = constructStore.getAt(i);

            var constructId = constructModel.get('constructId');

            if(constructId != null && constructId != ''){
                constructIds.push(constructId);
            }
        }

        return constructIds;
    }

    public function generatePrimerReport(cb: String->Void) {
       /* SgcConstruct.getByIds(getConstructList(), function(constructs : Array<SgcConstruct>, error : Dynamic){
            if(error != null){
                getApplication().showMessage('Retrieval failure', 'Failure to retrieve constructs');
            }else{
                getProvider().activate(constructs, 3, function(error){
                    if(error != null){
                        getApplication().showMessage('Retrieval failure', 'Failure to retrieve constructs');
                    }else{
                        var report = new ConstructSet(constructs);

                        //report.setConstructs();

                        var content = report.generatePrimerReport();

                        cb(content);
                    }
                });
            }
        });*/
    }

    public function savePrimerReport(){
        generatePrimerReport(function(content){
            getApplication().saveTextFile(content, getActiveObjectName() + '.csv');
        });
    }

    public function promptSendPrimerReport(){
        getApplication().userPrompt('Send report?', 'Are you sure you wish to email the primer report?', function(){
            sendPrimerReport();
        });
    }

    public function sendPrimerReport(){
        generatePrimerReport(function(content){
            ClientCore.getClientCore().sendRequest('_email_.sgc_primer_email', {
                fileName:  getActiveObjectName() + '.csv',
                content: content,
                description: getActiveObjectName()
            }, function(data, err){
                if(err != null){
                    getApplication().showMessage('Error', err);
                }else{
                    getApplication().showMessage('Success', 'Report sent - check your inbox');
                }
            });
        });
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-conical-dna',
                html:'Construct<br/>Plate',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new MultiConstructHelperWO(null, 'Constructs'), true);
                },
                tooltip: {dismissDelay: 10000, text: 'Edit existing constructs or enter new ones.'}
            }
        ];
    }
}

