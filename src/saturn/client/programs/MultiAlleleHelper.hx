/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.client.programs.blocks.TargetSummary;
import saturn.util.HaxeException;
import saturn.core.FastaEntity;
import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.core.PrimerRegistry;
import saturn.core.Primer;
import saturn.core.PCRProduct;
import saturn.core.domain.SgcEntryClone;
import saturn.core.domain.SgcReversePrimer;
import saturn.core.domain.SgcForwardPrimer;
import saturn.core.domain.SgcConstruct;
import saturn.client.workspace.MultiAlleleHelperWO;

import saturn.db.Model;
import saturn.core.domain.SgcVector;
import saturn.core.domain.SgcRestrictionSite;
import saturn.core.domain.SgcAllele;
import saturn.core.domain.SgcConstructPlate;
import saturn.core.domain.SgcAllelePlate;

import saturn.core.Ligation;
import saturn.core.DoubleDigest;
import saturn.core.RestrictionSite;
import saturn.core.CleavageSite;
import saturn.core.DNA;
import saturn.core.CutProductDirection;
import saturn.core.Protein;
import bindings.Ext;

import saturn.db.BatchFetch;
import saturn.client.workspace.DNAWorkspaceObject;
import saturn.client.workspace.ProteinWorkspaceObject;

import saturn.client.WorkspaceApplication;

class MultiAlleleHelper extends TableHelper{
    static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ MultiAlleleHelperWO ];

    public function new(){
        //theModelClass = SgcAllele;
        theTitle = 'Allele Helper';

        super(SgcAllele);
    }

    override public function getButtonPanelConfiguration() : Array<Dynamic>{
        var me : MultiAlleleHelper  = this;

        var baseButtons = super.getButtonPanelConfiguration();

        baseButtons.push({
            region : 'center',
            xtype : 'button',
            text : 'Calculate',
            handler : function() {
                me.calculate();
            },
            iconCls: 'x-btn-calculate'
        });

        return baseButtons;
    }

    override public function getContextMenuItems(modelColumn : String, rowIndex : Int) : Array<Dynamic>{
        var me :MultiAlleleHelper = this;

        var items = super.getContextMenuItems(modelColumn, rowIndex);
        if(modelColumn == 'dnaSeq'){
            items.push({
                text : "Import DNA",
                handler : function() {
                    var model = getStore().getAt(rowIndex);
                    var dnaObj = new DNA(model.get(modelColumn));

                    var dnawo = new DNAWorkspaceObject(dnaObj,model.get('alleleId')+' (DNA) ');

                    me.getApplication().getWorkspace().addObject(dnawo,true);
                }
            });
        }else if(modelColumn == 'proteinSeq'){
            items.push({
                text : "Import Protein",
                handler : function() {
                    var model = getStore().getAt(rowIndex);
                    var label = model.get('alleleId');

                    var proteinObj = new Protein(model.get(modelColumn));

                    var proteinwo = new ProteinWorkspaceObject(proteinObj,label);

                    me.getApplication().getWorkspace().addObject(proteinwo,true);
                }
            });
        }else if(modelColumn == 'forwardPrimer.primerId'){
            items.push({
                text : "Import Primer",
                handler : function() {
                    var model = getStore().getAt(rowIndex);
                    var primerId = model.get('forwardPrimer.primerId');

                    getProvider().getById(primerId, SgcForwardPrimer, function(primer : SgcForwardPrimer, exception){
                        if(exception != null){
                            getApplication().showMessage('Fetch error', exception);
                        }else{
                            var dna = new DNA(primer.dnaSequence);

                            var wo = new DNAWorkspaceObject(dna, primerId);

                            me.getApplication().getWorkspace().addObject(wo,true);
                        }
                    });
                }
            });
        }else if(modelColumn == 'reversePrimer.primerId'){
            items.push({
                text : "Import Primer",
                handler : function() {
                    var model = getStore().getAt(rowIndex);
                    var primerId = model.get('reversePrimer.primerId');

                    getProvider().getById(primerId, SgcReversePrimer, function(primer : SgcReversePrimer, exception){
                        if(exception != null){
                            getApplication().showMessage('Fetch error', exception);
                        }else{
                            var dna = new DNA(primer.dnaSequence);

                            var wo = new DNAWorkspaceObject(dna, primerId);

                            me.getApplication().getWorkspace().addObject(wo,true);
                        }
                    });
                }
            });
        }else if(modelColumn == 'entryClone.entryCloneId'){
            items.push({
                text : "Import Entry Clone",
                handler : function() {
                    var model = getStore().getAt(rowIndex);
                    var entryCloneId = model.get('entryClone.entryCloneId');

                    getProvider().getById(entryCloneId, SgcEntryClone, function(entryClone : SgcEntryClone, exception){
                        if(exception != null){
                            getApplication().showMessage('Fetch error', exception);
                        }else{
                            var dna = new DNA(entryClone.dnaSeq);

                            var wo = new DNAWorkspaceObject(dna, entryCloneId);

                            me.getApplication().getWorkspace().addObject(wo,true);
                        }
                    });
                }
            });
        }else if(modelColumn == 'alleleId'){
            items.push({
                text : "Show allele alignment",
                handler : function() {
                    var model = getStore().getAt(rowIndex);
                    var alleleId = model.get('alleleId');

                    var target = alleleId.split('-')[0];

                    showAlleleAlignment(target);
                }
            });
        }

        return items;
    }

    public function showAlleleAlignment(target : String){
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
            var alleleId :String = model.get('alleleId');
            if(alleleId.split('-')[0] == target){
                var seq = model.get('proteinSeq');
                var protObj = new Protein(seq);
                protObj.setMoleculeName(alleleId);

                var construct = new SgcConstruct();
                construct.constructId = alleleId;
                construct.proteinSeqNoTag = seq;
                construct.status = 'No progress';

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

        var alleleStore = getStore();
        var alleleCount :Int = alleleStore.count() -1;

        var entryCloneMap = new Map<String,String>();
        var fPrimerMap = new Map<String,String>();
        var rPrimerMap = new Map<String,String>();

        for(i in 0...alleleCount){
            var alleleModel : Dynamic = alleleStore.getAt(i);

            var fPrimerId = alleleModel.get('forwardPrimer.primerId');
            var rPrimerId = alleleModel.get('reversePrimer.primerId');
            var entryCloneId = alleleModel.get('entryClone.entryCloneId');

            if(isNullOrEmpty(fPrimerId)){
                setRecordValid(alleleModel, 'Missing forward primer');
                continue;
            }

            if(isNullOrEmpty(rPrimerId)){
                setRecordValid(alleleModel, 'Missing reverse primer');
                continue;
            }

            if(isNullOrEmpty(entryCloneId)){
                setRecordValid(alleleModel, 'Missing entry clone');
                continue;
            }

            entryCloneMap.set(entryCloneId,'');
            fPrimerMap.set(fPrimerId,'');
            rPrimerMap.set(rPrimerId,'');
        }

        var fPrimers = new Array<String>();
        var rPrimers = new Array<String>();
        var entryClones = new Array<String>();

        for(fPrimerId in fPrimerMap.keys()){
            fPrimers.push(fPrimerId);
        }

        for(rPrimerId in rPrimerMap.keys()){
            rPrimers.push(rPrimerId);
        }

        for(entryCloneId in entryCloneMap.keys()){
            entryClones.push(entryCloneId);
        }

        var bFetch =  new BatchFetch(function(obj, err){
            getApplication().showMessage('Batch fetch failure', err);
        });

        bFetch.getByIds(fPrimers, SgcForwardPrimer, '__IGNORE_ME__', null);
        bFetch.getByIds(rPrimers, SgcReversePrimer, '__IGNORE_ME__', null);
        bFetch.getByIds(entryClones, SgcEntryClone, '__IGNORE_ME__', null);

        bFetch.onComplete = function(){
            WorkspaceApplication.suspendUpdates();
            var primerReg = PrimerRegistry.getDefaultInstance();

            for(i in 0...alleleCount){
                var alleleModel : Dynamic = alleleStore.getAt(i);

                var alleleId = alleleModel.get('alleleId');
                var fPrimerId = alleleModel.get('forwardPrimer.primerId');
                var rPrimerId = alleleModel.get('reversePrimer.primerId');
                var entryCloneId = alleleModel.get('entryClone.entryCloneId');

                if(fPrimerId != null && fPrimerId != '' &&
                    rPrimerId != null && rPrimerId != '' &&
                    entryCloneId != null && entryCloneId != ''){

                    var entryClone = getProvider().getObjectFromCache(SgcEntryClone,'entryCloneId',entryCloneId);
                    var fPrimer = getProvider().getObjectFromCache(SgcForwardPrimer,'primerId',fPrimerId);
                    var rPrimer = getProvider().getObjectFromCache(SgcReversePrimer,'primerId',rPrimerId);

                    if(entryClone == null){
                        setRecordValid(alleleModel, 'Entry clone ' + entryCloneId + ' is missing for ' + alleleId);
                        continue;
                    }

                    if(fPrimer == null){
                        setRecordValid(alleleModel, 'Forward primer ' + fPrimerId + ' is missing for ' + alleleId);
                        continue;
                    }

                    if(rPrimer == null){
                        setRecordValid(alleleModel,  'Reverse primer ' + rPrimerId + ' is missing for ' + alleleId);
                        continue;
                    }

                    var ecDNA = new DNA(entryClone.dnaSeq);
                    var fPrimerDNA = new Primer(fPrimer.dnaSequence);
                    var rPrimerDNA = new Primer(rPrimer.dnaSequence);

                    primerReg.autoConfigurePrimer(fPrimerDNA);
                    primerReg.autoConfigurePrimer(rPrimerDNA);

                    // Temporary fall back mode for SGC primers
                    if(fPrimerDNA.get5PrimeExtensionLength() == -1){
                        fPrimerDNA.set5PrimeExtensionLength(fPrimerDNA.getLength()-14);
                    }

                    if(rPrimerDNA.get5PrimeExtensionLength() == -1){
                        rPrimerDNA.set5PrimeExtensionLength(rPrimerDNA.getLength()-14);
                    }

                    try{
                        var pcrProduct = new PCRProduct(ecDNA,fPrimerDNA,rPrimerDNA);

                        pcrProduct.calculateProduct();

                        var pos = pcrProduct.getFirstStartCodonPosition(GeneticCodes.STANDARD);

                        alleleModel.set('dnaSeq', pcrProduct.getSequence());
                        alleleModel.set('dnaSeqLen',pcrProduct.getLength());

                        if(pos > -1){
                            var translation = pcrProduct.getTranslation(GeneticCodes.STANDARD,pos,true);

                            alleleModel.set('proteinSeq', translation);

                            setRecordValid(alleleModel, '');
                        }else{
                            setRecordValid(alleleModel,'Unable to find start codon');
                        }

                        //alleleModel.commit();
                    }catch(e : HaxeException){
                        setRecordValid(alleleModel,e.getMessage());
                    }catch(e : Dynamic){
                        setRecordValid(alleleModel, 'Unknown exception');
                    }
                }
            }
            WorkspaceApplication.resumeUpdates(true);

            theTable.getView().refresh();

            getApplication().showMessage('Finished','Calculation finished');
        }

        bFetch.execute();
    }

    override public function insertOrDeletePerformed(){
        var wo : MultiAlleleHelperWO= getWorkspace().getObjectSafely(getActiveObjectId(), MultiAlleleHelperWO);

        if(wo != null){
            var plateName = wo.getObject().getPlateName();

            if(plateName != null){
                getProvider().evictNamedQuery('FETCH_ALLELE_PLATE',[plateName]);
            }
        }
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        var wo : MultiAlleleHelperWO= getWorkspace().getObjectSafely(objectId, MultiAlleleHelperWO);

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
        var wo : MultiAlleleHelperWO= getWorkspace().getObjectSafely(getActiveObjectId(), MultiAlleleHelperWO);

        if(wo != null){
            var plateName = wo.getObject().getPlateName();

            if(plateName != null){
                getProvider().getByNamedQuery('FETCH_ALLELE_PLATE',[plateName],SgcAllele, true, function(objs: Array<SgcAllele>,exception){
                    if(exception == null && objs != null){
                        loadObjects(objs);
                    }else{
                        getApplication().showMessage('Allele plate fetch failure','Unable to fetch alleles for ' + plateName);
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
            text: 'Allele (DNA) to FASTA',
            hidden : false,
            handler: function(){
                var entityStore = getStore();
                var entityCount :Int = entityStore.count();

                var strBuf = new StringBuf();

                var fields = theModel.getFields();
                var priField = theModel.getPrimaryKey();

                for(i in 0...entityCount){
                    var entityModel : Dynamic = entityStore.getAt(i);

                    var protStr = entityModel.get('dnaSeq');
                    if(protStr != null && protStr != ''){
                        strBuf.add(FastaEntity.formatFastaFile(entityModel.get('alleleId'), protStr));
                    }
                }

                var wo : WorkspaceObject<Dynamic> = getActiveObject(WorkspaceObject);

                getApplication().saveTextFile(strBuf.toString(), wo.getName() + '-alleles-dna.fasta');
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
                loadAllAllelesProtein();
            }
        });

        getApplication().getImportMenu().add({
            text: 'Import all entry clones (DNA)',
            handler: function(){
                loadAllEntryClonesDNA();
            }
        });

        getApplication().getImportMenu().add({
            text: 'Import all primers',
            handler: function(){
                loadAllPrimers();
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
            iconCls :'x-btn-import',
            text: 'Alleles (DNA)',
            handler: function(){
                loadAllAllelesDNA();
            },
            tooltip: {dismissDelay: 10000, text: 'Import all allele DNA sequence from table into Workspace'}
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-import',
            text: 'Alleles (Protein)',
            handler: function(){
                loadAllAllelesProtein();
            },
            tooltip: {dismissDelay: 10000, text: 'Import all allele protein sequence from table into Workspace'}
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-import',
            text: 'Entry Clones',
            handler: function(){
                loadAllEntryClonesDNA();
            },
            tooltip: {dismissDelay: 10000, text: 'Import all entry clone DNA sequence from table into Workspace'}
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-import',
            text: 'Primers',
            handler: function(){
                loadAllPrimers();
            },
            tooltip: {dismissDelay: 10000, text: 'Import all primers from table into Workspace'}
        });
    }

    public function loadAllPrimers(){
        var bFetch =  new BatchFetch(function(obj, err){
            getApplication().showMessage('Batch fetch failure', err);
        });

        var alleleStore = getStore();
        var alleleCount :Int = alleleStore.count();

        var fIdset = new Map<String,String>();
        var rIdset = new Map<String,String>();

        for(i in 0...alleleCount){
            var alleleModel : Dynamic = alleleStore.getAt(i);

            var fId = alleleModel.get('forwardPrimer.primerId');
            var rId = alleleModel.get('reversePrimer.primerId');

            if(fId != null && fId != ''){
                fIdset.set(fId,'');
            }

            if(rId != null && rId != ''){
                rIdset.set(rId,'');
            }
        }

        var fIds = new Array<String>();
        for(fId in fIdset.keys()){
            fIds.push(fId);
        }

        var rIds = new Array<String>();
        for(rId in rIdset.keys()){
            rIds.push(rId);
        }

        bFetch.getByIds(fIds, SgcForwardPrimer,'__IGNORE_ME__', null);
        bFetch.getByIds(rIds, SgcReversePrimer,'__IGNORE_ME__', null);

        bFetch.onComplete = function(){
            for(fId in fIds){
                var obj = getProvider().getObjectFromCache(SgcForwardPrimer, 'primerId', fId);

                if(obj != null){
                    var dna = new DNA(obj.dnaSequence);
                    var wo = new DNAWorkspaceObject(dna, fId);

                    getWorkspace()._addObject(wo, false, false);
                }
            }

            for(rId in rIds){
                var obj = getProvider().getObjectFromCache(SgcReversePrimer, 'primerId', rId);

                if(obj != null){
                    var dna = new DNA(obj.dnaSequence);
                    var wo = new DNAWorkspaceObject(dna, rId);

                    getWorkspace()._addObject(wo, false, false);
                }
            }

            getWorkspace().reloadWorkspace();
        };

        bFetch.execute();
    }

    public function loadAllAllelesDNA(){
        var alleleStore = getStore();
        var alleleCount :Int = alleleStore.count();

        var folderName = getActiveObjectName() + ' (Allele DNA)';
        var folder = getWorkspace()._addFolder(folderName, null);

        Ext.suspendLayouts();
        getWorkspace().getTreeStore().suspendEvents();

        for(i in 0...alleleCount){
            var alleleModel : Dynamic = alleleStore.getAt(i);

            var alleleId = alleleModel.get('alleleId');

            if(alleleId != null && alleleId != ''){
                var dna = new DNA(alleleModel.get('dnaSeq'));
                var wo = new DNAWorkspaceObject(dna, alleleId);

                getWorkspace()._addObject(wo, false, false, folder);
            }
        }

        getWorkspace().reloadWorkspace();
    }

    public function loadAllAllelesProtein(){
        var alleleStore = getStore();
        var alleleCount :Int = alleleStore.count();

        for(i in 0...alleleCount){
            var alleleModel : Dynamic = alleleStore.getAt(i);

            var alleleId = alleleModel.get('alleleId');

            if(alleleId != null && alleleId != ''){
                var dna = new DNA(alleleModel.get('proteinSeq'));
                var wo = new DNAWorkspaceObject(dna, alleleId);

                getWorkspace()._addObject(wo, false, false);
            }
        }

        getWorkspace().reloadWorkspace();
    }

    public function loadAllEntryClonesDNA(){
        var bFetch =  new BatchFetch(function(obj, err){
            getApplication().showMessage('Batch fetch failure', err);
        });

        var alleleStore = getStore();
        var alleleCount :Int = alleleStore.count();

        var entryCloneSet = new Map<String,String>();

        for(i in 0...alleleCount){
            var alleleModel : Dynamic = alleleStore.getAt(i);

            var entryCloneId = alleleModel.get('entryClone.entryCloneId');

            if(entryCloneId != null && entryCloneId != ''){
                entryCloneSet.set(entryCloneId,'');
            }
        }

        var entryCloneIds = new Array<String>();
        for(entryCloneId in entryCloneSet.keys()){
            entryCloneIds.push(entryCloneId);
        }

        bFetch.getByIds(entryCloneIds, SgcEntryClone,'__IGNORE_ME__', null);

        bFetch.onComplete = function(){
            for(entryCloneId in entryCloneIds){
                var obj = getProvider().getObjectFromCache(SgcEntryClone, 'entryCloneId', entryCloneId);

                if(obj != null){
                    var dna = new DNA(obj.dnaSeq);
                    var wo = new DNAWorkspaceObject(dna, entryCloneId);

                    getWorkspace()._addObject(wo, false, false);
                }
            }

            getWorkspace().reloadWorkspace();
        };

        bFetch.execute();
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-conical-dna',
                html:'Allele<br/>Entry',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new MultiAlleleHelperWO(null, 'Alleles'), true);
                },
                tooltip: {dismissDelay: 10000, text: 'Edit existing alleles or enter new ones. (requires login)'}
            }
        ];
    }
}
