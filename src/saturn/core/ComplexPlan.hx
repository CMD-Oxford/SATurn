package saturn.core;
import saturn.core.domain.SgcConstructPlate;
import saturn.core.domain.SgcAllelePlate;
import saturn.core.domain.SgcVector;
import saturn.core.domain.SgcConstruct;
import saturn.core.domain.SgcAllele;
import saturn.core.domain.SgcEntryClone;
import saturn.core.domain.SgcTarget;
import haxe.ds.HashMap;
import saturn.db.query_lang.Cast;
import saturn.db.query_lang.Value;
import saturn.db.query_lang.Concat;
import saturn.db.query_lang.RegexpLike;
import saturn.core.domain.SgcUtil;
import saturn.db.Provider;
import saturn.client.core.CommonCore;
import saturn.db.query_lang.Field;
import saturn.db.query_lang.Substr;
import saturn.db.query_lang.Trim;
import saturn.db.query_lang.Max;
import saturn.db.query_lang.Query;

import saturn.client.WorkspaceApplication;

class ComplexPlan extends Table{
    var provider : Provider;

    public function new(useExample : Bool = false) {
        super();

        this.setErrorColumns([]);

        var exampleData = null;

        if(useExample){
            exampleData = [
                {
                    'Select': true,
                    'Construct ID 1': 'XXXXXX-c265',
                    'Construct ID 2': 'XXXXXX-c009',
                    'Construct ID 3': '',
                    'Construct ID 4': '',
                    'ELN ID': '',
                    'Plate Name': 'MultiBac-Plate-3',
                    'Plate Well': 'H05',
                    'Target ID': '',
                    'Entry Clone ID': '',
                    'Allele ID': '',
                    'Construct ID': ''
                }

            ];
        }else{
            exampleData = [
                {
                    'Select': true,
                    'Construct ID 1': '',
                    'Construct ID 2': '',
                    'Construct ID 3': '',
                    'Construct ID 4': '',
                    'ELN ID': '',
                    'Target ID': '',
                    'Entry Clone ID': '',
                    'Allele ID': '',
                    'Construct ID': '',
                    'Plate Name': '',
                    'Plate Well': '',
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
                'Construct ID 1':{'editor': 'textfield'},
                'Construct ID 2':{'editor': 'textfield'},
                'Construct ID 3':{'editor': 'textfield'},
                'Construct ID 4':{'editor': 'textfield'},
                'Target ID':{'editor': 'textfield'},
                'Entry Clone ID':{'editor': 'textfield'},
                'Allele ID':{'editor': 'textfield'},
                'Construct ID':{'editor': 'textfield'},
                'ELN ID':{'editor': 'textfield'},
                'Plate Name':{'editor': 'textfield'},
                'Plate Well':{'editor': 'textfield'},
            }
        );

        this.setName('Complex Plan');
    }

    public function getProvider() : Provider{
        if(provider != null){
            return provider;
        }else{
            return WorkspaceApplication.getApplication().getProvider();
        }
    }

    public function save(cb : String->Void){
        var data = getData();

        var targetSet = new Map<String, String>();

        for(row in data){
            var targetId = Reflect.field(row, 'Construct ID 1').split('-')[0];
            targetSet.set(targetId, null);
        }

        var targetIds = new Array<String>();

        for(targetId in targetSet.keys()){
            targetIds.push(targetId);
        }

        var provider = getProvider();

        provider.getByIds(targetIds, SgcTarget, function(targets : Array<SgcTarget>, err : String){
            if(err != null){
                cb(err);
            }else{
                var targetIdToTarget = new Map<String, SgcTarget>();

                for(target in targets){
                    targetIdToTarget.set(target.targetId, target);
                }

                var complexTargets = new Array<SgcTarget>();
                var complexEntryClones = new Array<SgcEntryClone>();
                var complexAlleles = new Array<SgcAllele>();
                var complexConstructs = new Array<SgcConstruct>();

                var defaultVector = new SgcVector();
                defaultVector.vectorId = 'Mock-receptable-vector';

                for(row in data){
                    var targetId = Reflect.field(row, 'Construct ID 1').split('-')[0];
                    var eln = Reflect.field(row, 'ELN');
                    var targetObj = targetIdToTarget.get(targetId);

                    var complexTargetId = Reflect.field(row, 'Target ID');

                    var complexTargetObj = new SgcTarget();
                    complexTargetObj.targetId = complexTargetId;
                    complexTargetObj.pi = targetObj.pi;
                    complexTargetObj.geneId = targetObj.geneId;
                    complexTargetObj.activeStatus = '10: Complex';
                    complexTargetObj.complexOverride = '20f99f97-6e0d-46ba-8010-e4bd7880d591';

                    var complexComponents = [];

                    var maxComponents = 4;
                    for(i in 1...4){
                        complexComponents.push(Reflect.field(row, 'Construct ID ' + Std.string(i)));
                    }

                    complexTargetObj.complexComments = complexComponents.join(',');

                    complexTargetObj.complex = 'Yes';
                    complexTargetObj.eln = eln;

                    var complexEntryClone = new SgcEntryClone();
                    complexEntryClone.target = complexTargetObj;
                    complexEntryClone.entryCloneId = Reflect.field(row, 'Entry Clone ID');
                    complexEntryClone.elnId = eln;
                    complexEntryClone.complex = 'Yes';
                    complexEntryClone.seqSource = 'NA';
                    complexEntryClone.sequenceConfirmed = 'NA';

                    var complexAllele = new SgcAllele();
                    complexAllele.elnId = eln;
                    complexAllele.alleleId = Reflect.field(row, 'Allele ID');
                    complexAllele.status = 'NA';
                    complexAllele.complex = 'Yes';
                    complexAllele.entryClone = complexEntryClone;

                    var allelePlate = new SgcAllelePlate();
                    allelePlate.plateName = Reflect.field(row, 'Plate Name');

                    complexAllele.plate = allelePlate;
                    complexAllele.plateWell = Reflect.field(row, 'Plate Well');

                    var complexConstruct = new SgcConstruct();
                    complexConstruct.allele = complexAllele;
                    complexConstruct.constructId = Reflect.field(row, 'Construct ID');
                    complexConstruct.elnId = eln;
                    complexConstruct.complex = 'Yes';
                    complexConstruct.vector = defaultVector;

                    var constructPlate = new SgcConstructPlate();
                    constructPlate.plateName = allelePlate.plateName;

                    complexConstruct.constructPlate = constructPlate;
                    complexConstruct.wellId = complexAllele.plateWell;


                    complexTargets.push(complexTargetObj);
                    complexEntryClones.push(complexEntryClone);
                    complexAlleles.push(complexAllele);
                    complexConstructs.push(complexConstruct);
                }

                provider.insertOrUpdate(complexTargets, function(err : String){
                    if(err == null){
                        provider.insertOrUpdate(complexEntryClones, function(err : String){
                            if(err == null){
                                provider.insertOrUpdate(complexAlleles, function(err : String){
                                    if(err == null){
                                        provider.insertOrUpdate(complexConstructs, function(err : String){
                                            cb(err);
                                        }, true);
                                    }else{
                                        cb(err);
                                    }
                                }, true);
                            }else{
                                cb(err);
                            }
                        }, true);
                    }else{
			cb(err);
		    }	
                }, true);

            }
        });
    }

    public function generateIds(cb : String->Void){
        var data = getData();

        var targetToNextId = new Map<String, Int>();

        for(row in data){
            var constructId = Reflect.field(row, 'Construct ID 1');
            var targetId = constructId.split('-')[0];

            targetToNextId.set(targetId, 0);
        }

        var targetList = new Array<String>();
        for(targetId in targetToNextId.keys()){
            targetList.push(targetId);
        }

        var next = null;

        next = function(){
            if(targetList.length == 0){
                for(row in data){
                    var constructId = Reflect.field(row, 'Construct ID 1');
                    var targetId = constructId.split('-')[0];

                    var nextId = targetToNextId.get(targetId) ;

                    var complexTargetId = 'XX' + StringTools.lpad(Std.string(nextId),'0',2) + targetId;

                    Reflect.setField(row, 'Target ID', complexTargetId);
                    Reflect.setField(row, 'Entry Clone ID', complexTargetId + '-s001');
                    Reflect.setField(row, 'Allele ID', complexTargetId + '-a001');
                    Reflect.setField(row, 'Construct ID', complexTargetId + '-c001');

                    targetToNextId.set(targetId, ++nextId);
                }

                cb(null);

                return;
            }

            var targetId = targetList.pop();

            // Note that because of the lack of REGEX support in SQLite we do some of the pattern matching in Haxe
            var clazz = Type.resolveClass('saturn.core.domain.SgcTarget');

            var query = new Query(getProvider());

            query.fetchRawResults();

            query.getSelect().add(new Field(clazz,'targetId').as('targetId'));

            query.getWhere().add(new Field(clazz,'targetId').like(new Value('%').concat(targetId)));

            query.run(function(targets : Array<Dynamic>, err : String){
                if(err != null){
                    cb(err);
                }else{
                    var regex = new EReg("XX(\\d\\d)" + targetId, '');
                    var leadingZeroRegEx = new EReg('^0+', '');

                    var maxValue = 0;

                    for(target in targets){
                        if(regex.match(target.targetId)){
                            var digit = regex.matched(1);

                            var digitInt = Std.parseInt(leadingZeroRegEx.replace(digit, ''));

                            if(digitInt > maxValue){
                                maxValue = digitInt;
                            }
                        }
                    }

                    targetToNextId.set(targetId, ++maxValue);

                    next();
                }
            });
        }

        next();
    }
}
