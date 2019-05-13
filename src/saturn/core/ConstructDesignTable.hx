/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

import saturn.core.domain.SgcConstructPlate;
import saturn.core.domain.SgcAllelePlate;
import StringTools;
import saturn.core.domain.SgcConstruct;
import saturn.core.domain.SgcReversePrimer;
import saturn.core.domain.SgcForwardPrimer;
import saturn.core.domain.SgcUtil;
import saturn.db.query_lang.Or;
import saturn.db.query_lang.Value;
import saturn.core.domain.SgcAllele;
import saturn.db.query_lang.Field;
import saturn.db.query_lang.Query;
import saturn.core.domain.SgcRestrictionSite;
import saturn.db.Provider;
import saturn.client.WorkspaceApplication;
import saturn.util.HaxeException;
import saturn.core.DNA;
import saturn.core.domain.SgcEntryClone;
import saturn.core.domain.SgcEntryClone;
import saturn.core.domain.SgcVector;
import saturn.db.BatchFetch;

import saturn.util.MathUtils;

class ConstructDesignTable extends Table{
    var minTM : Float = 45;
    var maxTM : Float = 75;
    var minLength : Int = 18;
    var maxLength : Int = 50;

    var minTMExtended : Float = 60;
    var maxTMExtended : Float = 75;
    var minLengthExtended : Int = 32;

    var provider : Provider;

    public function new(useExample : Bool) {
        super();

        this.setErrorColumns(['Forward Error','Reverse Error', 'PCR Error', 'Construct Error']);

        var exampleData = null;

        if(useExample){
            exampleData = [
                {
                    'Select': true,
                    'Plate Name': 'BioTech15',
                    'Allele ID': 'BRD1A-a001',
                    'Allele Well': 'A01',
                    'Construct ID': 'BRD1A-c001',
                    'Construct Well': 'A01',
                    'Vector Name': 'pNIC28-Bsa4',
                    'Entry Clone': 'BRD1A-s001',
                    'Restriction Site 1': 'Lic5',
                    'Restriction Site 2': 'Lic3',
                    'Start position': 10,
                    'Stop position': 60,
                    'ELN ID': 'PAGE15-00001',
                    'Forward Primer': 'BRD1A-f001',
                    'Reverse Primer': 'BRD1A-r001',
                    'Forward Seq': '',
                    'Forward Error': '',
                    'Reverse Seq': '',
                    'Reverse Error': '',
                    'Allele DNA Sequence': '',
                    'Allele Protein Sequence': '',
                    'PCR Error': '',
                    'Construct Error': '',
                    'Construct DNA': '',
                    'Construct Protein': '',
                    'Construct Protein (no tag)': '',
                    'Construct Mass': '',
                    'Construct Mass (no tag)': '',
                    'Mutations': 'S11A:A12S',
                    'Mutation Forward Primer':'',
                    'Mutation Reverse Primer':''
                }
            ];
        }else{
            exampleData = [
                {
                    'Select': true,
                    'Plate Name': '',
                    'Allele ID': '',
                    'Allele Well': '',
                    'Construct ID': '',
                    'Construct Well': '',
                    'Vector Name': '',
                    'Entry Clone': '',
                    'Restriction Site 1': '',
                    'Restriction Site 2': '',
                    'Start position': 0 ,
                    'Stop position': 0,
                    'ELN ID': '',
                    'Forward Primer': '',
                    'Reverse Primer': '',
                    'Forward Seq': '',
                    'Forward Error': '',
                    'Reverse Seq': '',
                    'Reverse Error': '',
                    'Allele DNA Sequence': '',
                    'Allele Protein Sequence': '',
                    'PCR Error': '',
                    'Construct Error': '',
                    'Construct DNA': '',
                    'Construct Protein': '',
                    'Construct Protein (no tag)': '',
                    'Construct Mass': '',
                    'Construct Mass (no tag)': '',
                    'Mutations': '',
                    'Mutation Forward Primer':'',
                    'Mutation Reverse Primer':''
                }
            ];
        }

        this.setData(
            exampleData,
            {
                'Select': {
                    'xtype':'checkcolumn',
                    'name': 'checkbox_name',
                    'dataindex': 'Select'
                },
                'Plate Name':{'editor': 'textfield'},
                'Allele ID':{'editor': 'textfield'},
                'Allele Well':{'editor': 'textfield'},
                'Construct ID':{'editor': 'textfield'},
                'Construct Well':{'editor': 'textfield'},
                'Vector Name':{'editor': 'textfield'},
                'Entry Clone':{'editor': 'textfield'},
                'Start position':{'editor': 'textfield'},
                'Stop position':{'editor': 'textfield'},
                'ELN ID':{'editor': 'textfield'},
                'Forward Primer':{'editor': 'textfield'},
                'Reverse Primer':{'editor': 'textfield'},
                'Forward Seq':{'editor': 'textfield'},
                'Reverse Seq':{'editor': 'textfield'},
                'Forward Error':{'editor': 'textfield'},
                'Reverse Error':{'editor': 'textfield'},
                'Allele DNA Sequence': {'editor': 'textfield'},
                'Allele Protein Sequence': {'editor': 'textfield'},
                'PCR Error': {'editor': 'textfield'},
                'Restriction Site 1': {'editor': 'textfield'},
                'Restriction Site 2': {'editor': 'textfield'},
                'Construct DNA': {'editor': 'textfield'},
                'Construct Protein': {'editor': 'textfield'},
                'Construct Protein (no tag)': {'editor': 'textfield'},
                'Construct Mass': {'editor': 'textfield'},
                'Construct Mass (no tag)': {'editor': 'textfield'},
                'Mutations': {'editor': 'textfield'},
                'Mutation Forward Primer': {'editor': 'textfield'},
                'Mutation Reverse Primer': {'editor': 'textfield'}
            }
        );

        this.setName('Construct Plan');
    }

    public function getProvider() : Provider{
        if(provider != null){
            return provider;
        }else{
            return WorkspaceApplication.getApplication().getProvider();
        }
    }

    public function getMinTM() : Float{
        return minTM;
    }

    public function getMaxTM() : Float {
        return maxTM;
    }

    public function getMinLength() : Int {
        return minLength;
    }

    public function getMaxLength() : Int {
        return maxLength;
    }

    public function generateids(cb : String->Void){
        var data = getData();

        //Generate unique target list
        var targetSet = new Map<String,String>();

        for(row in data){
            var entryClone :String = Reflect.field(row, 'Entry Clone');

            var targetId = entryClone.split('-')[0];

            targetSet.set(targetId, '');
        }

        var targets = [for(targetId in targetSet.keys()) targetId];

        SgcUtil.generateNextID(getProvider(), targets, SgcAllele, function(alleleMap : Map<String,Int>, err : String){
            if(err == null){
                SgcUtil.generateNextID(getProvider(), targets, SgcForwardPrimer, function(fPrimers : Map<String,Int>, err : String){
                    if(err == null){
                        SgcUtil.generateNextID(getProvider(), targets, SgcReversePrimer, function(rPrimers : Map<String,Int>, err : String){
                            if(err == null){
                                SgcUtil.generateNextID(getProvider(), targets, SgcConstruct, function(constructs : Map<String,Int>, err : String){
                                    if(err == null){
                                        var forwardMap = new Map<String, String>();
                                        var reverseMap = new Map<String, String>();
                                        var pcrMap = new Map<String, String>();

                                        for(row in data){
                                            var entryClone :String = Reflect.field(row, 'Entry Clone');

                                            var targetId = entryClone.split('-')[0];

                                            var pcrKey = getPcrKey(row);

                                            if(!pcrMap.exists(pcrKey)){
                                                var alleleId = targetId + '-a' + StringTools.lpad(Std.string(alleleMap.get(targetId)),'0',3);

                                                alleleMap.set(targetId, alleleMap.get(targetId)+1);

                                                pcrMap.set(pcrKey, alleleId);
                                            }

                                            Reflect.setField(row, 'Allele ID', pcrMap.get(pcrKey));

                                            var forwardSeq = Reflect.field(row, 'Forward Seq');

                                            if(forwardMap.exists(forwardSeq)){
                                                Reflect.setField(row, 'Forward Primer', forwardMap.get(forwardSeq));
                                            }else{
                                                Reflect.setField(row, 'Forward Primer', targetId + '-f' + StringTools.lpad(Std.string(fPrimers.get(targetId)),'0',3));
                                                fPrimers.set(targetId, fPrimers.get(targetId)+1);

                                                forwardMap.set(forwardSeq, Reflect.field(row, 'Forward Primer'));
                                            }

                                            var reverseSeq = Reflect.field(row, 'Reverse Seq');

                                            if(reverseMap.exists(reverseSeq)){
                                                Reflect.setField(row, 'Reverse Primer', reverseMap.get(reverseSeq));
                                            }else{
                                                Reflect.setField(row, 'Reverse Primer', targetId + '-r' + StringTools.lpad(Std.string(rPrimers.get(targetId)),'0',3));
                                                rPrimers.set(targetId, rPrimers.get(targetId)+1);
                                            }

                                            Reflect.setField(row, 'Construct ID', targetId + '-c' + StringTools.lpad(Std.string(constructs.get(targetId)),'0',3));
                                            constructs.set(targetId, constructs.get(targetId)+1);
                                        }

                                        cb(null);
                                    }else{
                                        cb(err);
                                    }
                                });
                            }else{
                                cb(err);
                            }
                        });
                    }else{
                        cb(err);
                    }
                });
            }else{
                cb(err);
            }
        });
    }

    public static function getPcrKey(row : Dynamic) : String {
        var entryClone :String = Reflect.field(row, 'Entry Clone');
        var startPos : String = Reflect.field(row, 'Start position');
        var stopPos : String = Reflect.field(row, 'Stop position');

        return entryClone + '-' + startPos + '-' + stopPos;
    }

    public function _fetchAll(cb : Void->Void){
        var bFetch =  new BatchFetch(function(obj, err){
            WorkspaceApplication.getApplication().showMessage('Batch fetch failure', err);
        });

        var entryCloneSet = new Map<String, String>();
        var vectorSet = new Map<String, String>();
        var restrictionSet = new Map<String, String>();
        var constructSet = new Map<String, String>();
        var alleleSet = new Map<String, String>();
        var forwardPrimerSet = new Map<String, String>();
        var reversePrimerSet = new Map<String, String>();

        var data = getData();

        for(row in data){
            var entryClone = Reflect.field(row, 'Entry Clone');
            var vector = Reflect.field(row, 'Vector Name');
            var allele = Reflect.field(row, 'Allele ID');
            var construct = Reflect.field(row, 'Construct ID');
            var forwardPrimer = Reflect.field(row, 'Forward Primer');
            var reversePrimer = Reflect.field(row, 'Reverse Primer');

            restrictionSet.set(Reflect.field(row, 'Restriction Site 1'),'');
            restrictionSet.set(Reflect.field(row, 'Restriction Site 2'),'');

            entryCloneSet.set(entryClone,'');
            vectorSet.set(vector, '');
            alleleSet.set(allele, '');
            constructSet.set(construct,'');
            forwardPrimerSet.set(forwardPrimer,'');
            reversePrimerSet.set(reversePrimer,'');
        }

        var entryClones = new Array<String>();
        var vectors = new Array<String>();
        var sites = new Array<String>();
        var alleles = new Array<String>();
        var constructs = new Array<String>();
        var forwardPrimers = new Array<String>();
        var reversePrimers = new Array<String>();

        for(entryClone in entryCloneSet.keys()){
            entryClones.push(entryClone);
        }

        for(vector in vectorSet.keys()){
            vectors.push(vector);
        }

        for(site in restrictionSet.keys()){
            sites.push(site);
        }

        for(allele in alleleSet.keys()){
            alleles.push(allele);
        }

        for(construct in constructSet.keys()){
            constructs.push(construct);
        }

        for(forwardPrimer in forwardPrimerSet.keys()){
            forwardPrimers.push(forwardPrimer);
        }

        for(reversePrimer in reversePrimerSet.keys()){
            reversePrimers.push(reversePrimer);
        }

        bFetch.getByIds(vectors, SgcVector, '__IGNORE_ME__', null);
        bFetch.getByIds(sites, SgcRestrictionSite, '__IGNORE_ME__', null);

        bFetch.getByIds(entryClones, SgcEntryClone, '__IGNORE_ME__', null);
        bFetch.getByIds(alleles, SgcAllele, '__IGNORE_ME__', null);
        bFetch.getByIds(constructs, SgcConstruct, '__IGNORE_ME__', null);
        bFetch.getByIds(forwardPrimers, SgcForwardPrimer, '__IGNORE_ME__', null);
        bFetch.getByIds(reversePrimers, SgcReversePrimer, '__IGNORE_ME__', null);

        bFetch.onComplete = cb;

        bFetch.execute();
    }

    public function calculate(cb : Void->Void){
        _fetchAll(function(){
            _calculateFromCache(cb);
        });
    }
    
    public function saveNew(cb : String->Void){
        _saveNew(cb);
    }
    
    public function _saveNew(cb : String->Void){
        var p = getProvider();
        var data = getData();
        
        var forwardPrimerSet = new Map<String,SgcForwardPrimer>();
        var reversePrimerSet = new Map<String, SgcReversePrimer>();
        var allelePlates = new Array<SgcAllelePlate>();
        var constructPlates = new Array<SgcConstructPlate>();
        var alleleSet = new Map<String,SgcAllele>();
        var constructs = new Array<SgcConstruct>();
        
        for(row in data){
            var pcrKey = getPcrKey(row);
            
            var allelePlate = new SgcAllelePlate();
            var constructPlate = new SgcConstructPlate();
            
            var construct = new SgcConstruct();

            var forwardPrimer : SgcForwardPrimer = null;
            var forwardPrimerId = Reflect.field(row, 'Forward Primer');
            
            if(forwardPrimerSet.exists(forwardPrimerId)){
                forwardPrimer = forwardPrimerSet.get(forwardPrimerId);
            }else{
                forwardPrimer = new SgcForwardPrimer();
                forwardPrimer.setSequence(Reflect.field(row, 'Forward Seq'));
                forwardPrimer.primerId = forwardPrimerId;
                
                forwardPrimerSet.set(forwardPrimerId, forwardPrimer);
            }

            var reversePrimer : SgcReversePrimer = null;
            var reversePrimerId = Reflect.field(row, 'Reverse Primer');

            if(reversePrimerSet.exists(reversePrimerId)){
                reversePrimer = reversePrimerSet.get(reversePrimerId);
            }else{
                reversePrimer = new SgcReversePrimer();
                reversePrimer.setSequence(Reflect.field(row, 'Reverse Seq'));
                reversePrimer.primerId = reversePrimerId;

                reversePrimerSet.set(reversePrimerId, reversePrimer);
            }

            allelePlate.plateName = Reflect.field(row, 'Plate Name');
            constructPlate.plateName = Reflect.field(row, 'Plate Name');

            var allele : SgcAllele = null;
            if(alleleSet.exists(pcrKey)){
                allele = alleleSet.get(pcrKey);
            }else{
                allele = new SgcAllele();
                allele.entryClone = new SgcEntryClone();
                allele.entryClone.entryCloneId = Reflect.field(row, 'Entry Clone');
                allele.plateWell = Reflect.field(row, 'Allele Well');
                allele.alleleId = Reflect.field(row, 'Allele ID');
                allele.dnaSeq = Reflect.field(row, 'Allele DNA Sequence');
                allele.proteinSeq = Reflect.field(row, 'Allele Protein Sequence');
                allele.forwardPrimer = forwardPrimer;
                allele.reversePrimer = reversePrimer;
                allele.plate = allelePlate;
                
                alleleSet.set(pcrKey, allele);
            }

            construct.constructId = Reflect.field(row, 'Construct ID');
            construct.wellId = Reflect.field(row, 'Construct Well');
            construct.vector = new SgcVector();
            construct.vector.vectorId = Reflect.field(row, 'Vector Name');
            construct.dnaSeq = Reflect.field(row, 'Construct DNA');
            construct.proteinSeq = Reflect.field(row, 'Construct Protein');
            construct.proteinSeqNoTag = Reflect.field(row, 'Construct Protein (no tag)');
            construct.expectedMass = Reflect.field(row, 'Construct Mass');
            construct.expectedMassNoTag = Reflect.field(row, 'Construct Mass (no tag)');
            construct.res1 = new SgcRestrictionSite();
            construct.res1.enzymeName = Reflect.field(row, 'Restriction Site 1');
            construct.res2 = new SgcRestrictionSite();
            construct.res2.enzymeName = Reflect.field(row, 'Restriction Site 2');
            construct.allele = allele;
            construct.constructPlate = constructPlate;
            construct.constructStart = Reflect.field(row, 'Start position');
            construct.constructStop = Reflect.field(row, 'Stop position');

            allelePlates.push(allelePlate);
            constructPlates.push(constructPlate);
            constructs.push(construct);
        }
        
        var alleles = new Array<SgcAllele>();
        for(pcrKey in alleleSet.keys()){
            alleles.push(alleleSet.get(pcrKey));
        }
        
        var forwardPrimers = new Array<SgcForwardPrimer>();
        for(forwardPrimerId in forwardPrimerSet.keys()){
            forwardPrimers.push(forwardPrimerSet.get(forwardPrimerId));
        }

        var reversePrimers = new Array<SgcReversePrimer>();
        for(reversePrimerId in reversePrimerSet.keys()){
            reversePrimers.push(reversePrimerSet.get(reversePrimerId));
        }

        p.insertOrUpdate(forwardPrimers, function(err: String){
            if(err != null){
                cb(err);
                return;
            }

            p.insertOrUpdate(reversePrimers, function(err: String){
                if(err != null){
                    cb(err);
                    return;
                }

                p.insertOrUpdate(allelePlates, function(err: String){
                    if(err != null){
                        cb(err);
                        return;
                    }

                    p.insertOrUpdate(constructPlates, function(err: String){
                        if(err != null){
                            cb(err);
                            return;
                        }

                        p.insertOrUpdate(alleles, function(err: String){
                            if(err != null){
                                cb(err);
                                return;
                            }

                            p.insertOrUpdate(constructs, function(err: String){
                                if(err != null){
                                    cb(err);
                                    return;
                                }else{
                                    cb(null);
                                }
                            }, true);
                        }, true);
                    }, true);
                }, true);
            }, true);
        }, true);
    }

    public function fetchall(cb : Void->Void){
        _fetchAll(function(){
            var p = getProvider();
            var data = getData();

            for(row in data){
                var entryCloneId = Reflect.field(row, 'Entry Clone');
                var vectorId = Reflect.field(row, 'Vector Name');
                var res1Id = Reflect.field(row, 'Restriction Site 1');
                var res2Id = Reflect.field(row, 'Restriction Site 2');
                var forwardPrimerId = Reflect.field(row, 'Forward Primer');
                var reversePrimerId = Reflect.field(row, 'Reverse Primer');
                var alleleId = Reflect.field(row, 'Allele ID');
                var constructId = Reflect.field(row, 'Construct ID');

                var entryClone : SgcEntryClone = p.getObjectFromCache(SgcEntryClone,'entryCloneId',entryCloneId);
                var vector : SgcVector = p.getObjectFromCache(SgcVector,'vectorId',vectorId);
                var allele : SgcAllele = p.getObjectFromCache(SgcAllele,'alleleId',alleleId);
                var construct : SgcConstruct = p.getObjectFromCache(SgcConstruct,'constructId',constructId);
                var forwardPrimer : SgcForwardPrimer = p.getObjectFromCache(SgcForwardPrimer,'primerId',forwardPrimerId);
                var reversePrimer : SgcReversePrimer = p.getObjectFromCache(SgcReversePrimer,'primerId',reversePrimerId);

                if(allele != null){
                    Reflect.setField(row, 'Allele Well', allele.plateWell);

                    if(allele.plate != null){
                        Reflect.setField(row, 'Plate Name', allele.plate.plateName);
                    }

                    Reflect.setField(row, 'Allele Well', allele.plateWell);

                    if(allele.entryClone != null){
                        Reflect.setField(row, 'Entry Clone', allele.entryClone.entryCloneId);
                    }

                    Reflect.setField(row, 'Allele DNA Sequence', allele.dnaSeq);

                    Reflect.setField(row, 'Allele Protein Sequence', allele.proteinSeq);

                    if(allele.forwardPrimer != null){
                        Reflect.setField(row, 'Forward Primer', allele.forwardPrimer.primerId);
                        Reflect.setField(row, 'Forward Seq', allele.forwardPrimer.dnaSequence);
                    }

                    if(allele.reversePrimer != null){
                        Reflect.setField(row, 'Reverse Primer', allele.reversePrimer.primerId);
                        Reflect.setField(row, 'Reverse Seq', allele.reversePrimer.dnaSequence);
                    }
                }

                if(construct != null){
                    Reflect.setField(row, 'Construct Well', construct.wellId);

                    if(construct.vector != null){
                        Reflect.setField(row, 'Vector Name', construct.vector.vectorId);
                    }

                    if(construct.res1 != null){
                        Reflect.setField(row, 'Restriction Site 1', construct.res1.enzymeName);
                    }

                    if(construct.res2 != null){
                        Reflect.setField(row, 'Restriction Site 2', construct.res2.enzymeName);
                    }

                    Reflect.setField(row, 'Construct DNA', construct.dnaSeq);
                    Reflect.setField(row, 'Construct Protein', construct.proteinSeq);
                    Reflect.setField(row, 'Construct Protein (no tag)', construct.proteinSeqNoTag);
                    Reflect.setField(row, 'Construct Mass', construct.expectedMass);
                    Reflect.setField(row, 'Construct Mass (no tag)', construct.expectedMassNoTag);

                }

                cb();

                /*
                if(forwardPrimer != null){
                    Reflect.setField(row, 'Forward Seq', forwardPrimer.dnaSequence);
                }

                if(reversePrimer != null){
                    Reflect.setField(row, 'Reverse Seq', reversePrimer.dnaSequence);
                }*/
            }
        });
    }

    private function _calculateFromCache(cb : Void->Void){
        var p = getProvider();
        var data = getData();

        var primerReg = PrimerRegistry.getDefaultInstance();

        for(row in data){
            var entryCloneId = Reflect.field(row, 'Entry Clone');
            var vectorId = Reflect.field(row, 'Vector Name');
            var startPosition = Reflect.field(row, 'Start position');
            var stopPosition = Reflect.field(row, 'Stop position');
            var res1Id = Reflect.field(row, 'Restriction Site 1');
            var res2Id = Reflect.field(row, 'Restriction Site 2');

            var entryClone : SgcEntryClone = p.getObjectFromCache(SgcEntryClone,'entryCloneId',entryCloneId);
            var vector : SgcVector = p.getObjectFromCache(SgcVector,'vectorId',vectorId);

            var pcrErrors = [];

            if(entryClone == null){
                pcrErrors.push(entryCloneId + ' invalid');
            }

            var res1 : SgcRestrictionSite = null;
            var res2 : SgcRestrictionSite = null;

            if(vector == null){
                if(vectorId == null || vectorId == ''){
                    pcrErrors.push('Missing vector');
                }else{
                    pcrErrors.push(vectorId + ' invalid');
                }
            }else{
                if(res1Id == null || res1Id == ''){
                    res1 = vector.res1;
                }

                if(res2Id == null || res2Id == ''){
                    res2 = vector.res2;
                }
            }

            if(res1 == null && res1Id != null){
                res1 = p.getObjectFromCache(SgcRestrictionSite,'enzymeName',res1Id);
            }

            if(res2 == null && res2Id != null){
                res2 = p.getObjectFromCache(SgcRestrictionSite,'enzymeName',res2Id);
            }

            if(res1 == null){
                if(res1Id == null || res1Id == ''){
                    pcrErrors.push('5` restriction site missing');
                }else{
                    pcrErrors.push(res1Id + ' invalid');
                }

            }

            if(res2 == null){
                if(res2Id == null || res2Id == ''){
                    pcrErrors.push('3` restriction site missing');
                }else{
                    pcrErrors.push(res2Id + ' invalid');
                }
            }

            if(pcrErrors.length > 0){
                Reflect.setField(row, 'PCR Error', pcrErrors.join(' / '));
                continue;
            }

            Reflect.setField(row,'Forward Seq','');
            Reflect.setField(row,'Reverse Seq','');
            Reflect.setField(row,'Forward Error','');
            Reflect.setField(row,'Reverse Error','');
            Reflect.setField(row,'PCR Error','');
            Reflect.setField(row, 'Allele DNA Sequence','');
            Reflect.setField(row, 'Allele Protein Sequence', '');
            Reflect.setField(row, 'Construct Protein', '');
            Reflect.setField(row, 'Construct Protein (no tag)', '');
            Reflect.setField(row, 'Construct DNA', '');
            Reflect.setField(row, 'Construct Mass', '');
            Reflect.setField(row, 'Construct Mass (no tag)', '');
            Reflect.setField(row, 'Construct Error', '');

            var forwardExtensionLength = 0;
            var reverseExtensionLength = 0;

            var registry : GeneticCodeRegistry = GeneticCodeRegistry.getRegistry();
            var geneticCode : GeneticCode = registry.getGeneticCodeByEnum(GeneticCodes.STANDARD);

            var template = new DNA(entryClone.dnaSeq);

            var mutant_template = new DNA(entryClone.dnaSeq);
            var translation = new Protein(mutant_template.getTranslation(GeneticCodes.STANDARD,0,true));

            try {
                var nucPosition = template.getCodonStartPosition(Frame.ONE, startPosition);

                var forwardSeq :String = template.getRegion(nucPosition, template.getLength());
                var forwardObj = new DNA(forwardSeq);

                var extensionSeq : String = '';

                if(vector.requiredForwardExtension != null){
                    extensionSeq = vector.requiredForwardExtension;

                    if(forwardSeq.substr(0,3) == 'ATG'){
                        if(extensionSeq.substr(extensionSeq.length-3,3) == 'ATG'){
                            extensionSeq = extensionSeq.substr(0, extensionSeq.length-3);
                        }
                    }else{
                        if(extensionSeq.substr(extensionSeq.length-3,3) != 'ATG'){
                            extensionSeq = extensionSeq + 'ATG';

                            forwardExtensionLength += 3;
                        }
                    }

                    forwardExtensionLength += extensionSeq.length;
                }

                Reflect.setField(row,'Forward Seq',extensionSeq + forwardObj.findPrimer(1, minLength, maxLength, minTM, maxTM, extensionSeq, minLengthExtended, minTMExtended, maxTMExtended));
            }catch(ex : HaxeException){
                Reflect.setField(row, 'Forward Error', ex);
                continue;
            }

            try {
                var nucPosition = template.getCodonStopPosition(Frame.ONE, stopPosition);

                var reverseSeq = new DNA(template.getRegion(1, nucPosition)).getInverseComplement();
                var icCut = new DNA(reverseSeq);

                var extensionSeq = '';

                if(vector.requiredReverseExtension != null){
                    extensionSeq = vector.requiredReverseExtension;

                    reverseExtensionLength += extensionSeq.length;
                }

                if(vector.addStopCodon == 'yes'){
                    extensionSeq += 'TCA';

                    reverseExtensionLength += 3;
                }

                Reflect.setField(row,'Reverse Seq',extensionSeq + icCut.findPrimer(1, minLength, maxLength, minTM, maxTM, extensionSeq, minLengthExtended, minTMExtended, maxTMExtended));
            }catch(ex : HaxeException){
                Reflect.setField(row, 'Reverse Error', ex);
                continue;
            }

            var mutationStr = Reflect.field(row,'Mutations');
            if(mutationStr != null && mutationStr != ''){
                var mut_pattern :EReg =~/([A-Z]{1})(\d+)([A-Z]{1})/;
                var mutations = mutationStr.split(':');

                var minPos = null;
                var maxPos = null;

                var continueFlag = false;

                for(mutation in mutations){
                    mutation = mutation.toUpperCase();

                    if(mut_pattern.match(mutation)){
                        var aa = mut_pattern.matched(1);
                        var pos = Std.parseInt(mut_pattern.matched(2));
                        var toAA = mut_pattern.matched(3);

                        if(pos > template.getLength()){
                            Reflect.setField(row, 'Construct Error', 'Mutation pos ' + pos + ' is out of range');

                            continueFlag = true;
                            break;
                        }

                        if(!geneticCode.isAA(toAA)){
                            Reflect.setField(row, 'Construct Error', 'Amino acid ' + toAA + ' is not valid');

                            continueFlag = true;
                            break;
                        }

                        if(translation.getAtPosition(pos-1) != aa){
                            Reflect.setField(row, 'Construct Error', 'Amino acid at position ' + pos + ' does not match amino acid ' + aa);

                            continueFlag = true;
                            break;
                        }

                        mutant_template = new DNA(mutant_template.mutateResidue(Frame.ONE, GeneticCodes.STANDARD,pos, toAA));

                        if(minPos == null || pos < minPos){
                            minPos = pos;
                        }

                        if(maxPos == null || pos > maxPos){
                            maxPos = pos;
                        }
                    }else{
                        Reflect.setField(row, 'Construct Error', 'Mutation definition -' + mutation + '- is not valid');

                        continueFlag = true;
                        break;
                    }
                }

                if(continueFlag){
                    clearPrimers(row);
                    continue;
                }

                if(maxPos != minPos && maxPos - minPos + 1 > 20){
                    Reflect.setField(row, 'Construct Error', 'Mutations are greater than 20 residues apart from each other and so can not be included on the same primer');

                    clearPrimers(row);
                    continue;
                }

                if (minPos > 7 && maxPos < translation.getLength() - 7){
                    var mutantStartPosition = (minPos -1) * 3 - 19;

                    var mutantPrimerLength = (maxPos - minPos + 1) * 3 + 40;

                    var forwardMutationPrimer = mutant_template.getRegion(mutantStartPosition, mutantStartPosition + mutantPrimerLength - 1);
                    var reverseMutationPrimer = new DNA(forwardMutationPrimer).getInverseComplement();

                    Reflect.setField(row, 'Mutation Forward Primer', forwardMutationPrimer);
                    Reflect.setField(row, 'Mutation Reverse Primer', reverseMutationPrimer);
                }

                if (minPos <= 7) {
                    var mutantStartPosition = 1;
                    var mutantPrimerLength = maxPos * 3 + 20;
                    var forwardMutationPrimer = mutant_template.getRegion(mutantStartPosition, mutantStartPosition + mutantPrimerLength - 1);
                    forwardMutationPrimer = vector.requiredForwardExtension + forwardMutationPrimer;

                    Reflect.setField(row, 'Forward Seq', forwardMutationPrimer);

                    Reflect.setField(row, 'Mutation Forward Primer', forwardMutationPrimer);
                    Reflect.setField(row, 'Mutation Reverse Primer', '');
                }

                if (maxPos >= translation.getLength() - 7) {
                    var mutantPrimerLength = (translation.getLength() - minPos + 1) * 3 + 20;
                    var mutantStartPosition = translation.getLength() * 3 - mutantPrimerLength + 1;
                    var forwardMutationPrimer = mutant_template.getRegion(mutantStartPosition, mutantStartPosition + mutantPrimerLength - 1);
                    var reverseMutationPrimer = new DNA(forwardMutationPrimer).getInverseComplement();
                    reverseMutationPrimer = vector.requiredReverseExtension + reverseMutationPrimer;

                    Reflect.setField(row, 'Mutation Forward Primer', '');
                    Reflect.setField(row, 'Mutation Reverse Primer', reverseMutationPrimer);

                    Reflect.setField(row, 'Reverse Seq', reverseMutationPrimer);
                }

                template = mutant_template;
            }

            //Calculate PCR product
            var forwardSeq = Reflect.field(row, 'Forward Seq');
            var reverseSeq = Reflect.field(row, 'Reverse Seq');

            if(forwardSeq != null && forwardSeq != '' && reverseSeq != null && reverseSeq != ''){
                try{
                    var forwardPrimer = new Primer(forwardSeq);
                    forwardPrimer.set5PrimeExtensionLength(forwardExtensionLength);

                    var reversePrimer = new Primer(reverseSeq);
                    reversePrimer.set5PrimeExtensionLength(reverseExtensionLength);

                    var pcr = new PCRProduct(template, forwardPrimer, reversePrimer);

                    var product = new DNA(pcr.getPCRProduct(true));

                    var pos = product.getFirstStartCodonPosition(GeneticCodes.STANDARD);

                    Reflect.setField(row, 'Allele DNA Sequence', product.getSequence());
                    Reflect.setField(row, 'Allele Protein Sequence', product.getTranslation(GeneticCodes.STANDARD, pos, true));
                }catch(ex : HaxeException){
                    Reflect.setField(row, 'PCR Error', ex);
                    continue;
                }

                // Calculate Construct
                try{
                    // Initiate objects from Scarab values
                    var alleleSequence = new DNA(Reflect.field(row,'Allele DNA Sequence'));
                    var res1Seq = new RestrictionSite(res1.cutSequence);
                    var res2Seq = new RestrictionSite(res2.cutSequence);

                    var v_res1Seq = new RestrictionSite(vector.res1.cutSequence);
                    var v_res2Seq = new RestrictionSite(vector.res2.cutSequence);

                    var vectorSequence = new DNA(vector.getSequence());

                    var proteaseCutSeq = new CleavageSite(vector.proteaseCutSequence);
                    var proteaseProduct = vector.proteaseProduct;

                    // Check that direction value is valid
                    var direction : CutProductDirection;

                    if(proteaseProduct == 'UPSTREAM'){
                        direction = CutProductDirection.UPSTREAM;
                    }else if(proteaseProduct == 'DOWNSTREAM'){
                        direction = CutProductDirection.DOWNSTREAM;
                    }else{
                        Reflect.setField(row, 'Construct Error', 'Invalid value for Vector field protease product direction should be either UPSTREAM or DOWNSTREAM');

                        clearPrimers(row);
                        continue;
                    }

                    var alleleDigest = new DoubleDigest(alleleSequence,res1Seq,res2Seq); // Digest Allele
                    var vectorDigest = new DoubleDigest(vectorSequence,v_res1Seq,v_res2Seq); // Digest Vector

                    var ligation = new Ligation(vectorDigest, alleleDigest); // Setup ligation

                    ligation.calculateProduct(); // Ligate Allele and Vector digests

                    // Find first start codon in ligated product
                    var startCodonPosition = ligation.getFirstStartCodonPosition(GeneticCodes.STANDARD);
                    if(startCodonPosition == -1){
                        Reflect.setField(row, 'Construct Error', 'Ligation product is missing a start codon');

                        clearPrimers(row);
                        continue;
                    }

                    // Get translation of ligation product
                    var uncutSequence = new Protein(ligation.getTranslation(GeneticCodes.STANDARD,startCodonPosition, true));

                    // Digest the protein with the protease and retrieve the sequence either upstream or downstream of the cut
                    var cutSequence = proteaseCutSeq.getCutProduct(uncutSequence,direction);

                    // Calculate and store MW of cut and uncut proteins
                    Reflect.setField(row, 'Construct Mass',MathUtils.sigFigs(uncutSequence.getMW(),4));
                    Reflect.setField(row, 'Construct Mass (no tag)', MathUtils.sigFigs(new Protein(cutSequence).getMW(),4));
                    Reflect.setField(row, 'Construct DNA',ligation.getSequence());
                    Reflect.setField(row, 'Construct Protein',uncutSequence.getSequence());
                    Reflect.setField(row, 'Construct Protein (no tag)',cutSequence);
                }catch(ex: HaxeException){
                    Reflect.setField(row, 'Construct Error', ex);
                }catch(e: Dynamic){
                    Reflect.setField(row, 'Construct Error', e);
                }
            }
        }

        cb();
    }

    public function clearPrimers(row : Dynamic){
        Reflect.setField(row, 'Mutation Forward Primer', '');
        Reflect.setField(row, 'Mutation Reverse Primer', '');
        Reflect.setField(row, 'Forward Seq', '');
        Reflect.setField(row, 'Reverse Seq', '');
    }

    public function duplicateAndChangeVector(newVectorName : String, cb : Void->Void){
        var data = getData();

        for(row in data){
            var selected = Reflect.field(row, 'Select');
            if(selected){
                var newRow = Util.clone(row);

                Reflect.setField(newRow, 'Vector Name', newVectorName);
                Reflect.setField(newRow, 'Select', false);

                data.push(newRow);
            }
        }

        cb();
    }

    public function assignWells(cb : String->Void){
        var data = getData();

        var pcrKeyToAlleleWell = new Map<String, String>();

        var ai  = 65;
        var aj = 1;

        var ci = 65;
        var cj = 1;

        for(row in data){
            var pcrKey = getPcrKey(row);

            if(!pcrKeyToAlleleWell.exists(pcrKey)){
                var alleleWell = String.fromCharCode(ai) + StringTools.lpad(Std.string(aj), '0', 2);

                aj++;

                if(aj > 12){
                    ai++;
                    aj=1;
                }

                pcrKeyToAlleleWell.set(pcrKey, alleleWell);
            }

            var constructWell = String.fromCharCode(ci) + StringTools.lpad(Std.string(cj), '0', 2);

            cj++;

            if(cj > 12){
                ci++;
                cj=1;
            }


            Reflect.setField(row, 'Allele Well', pcrKeyToAlleleWell.get(pcrKey));
            Reflect.setField(row, 'Construct Well', constructWell);
        }

        cb(null);
    }

    public function prepare(cb : String->Void){
        calculate(function(){
            generateids(function(err : String){
                if(err != null){
                    cb(err);
                }else{
                    assignWells(cb);
                }
            });
        });
    }
}
