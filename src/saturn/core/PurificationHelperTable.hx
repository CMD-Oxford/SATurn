/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

import saturn.core.domain.SgcExpression;
import saturn.core.domain.SgcClone;
import saturn.core.domain.SgcPurification;
import saturn.core.domain.SgcConstructPlate;
import saturn.core.domain.SgcAllelePlate;
import StringTools;
import saturn.core.domain.SgcConstruct;
import saturn.core.domain.SgcReversePrimer;
import saturn.core.domain.SgcForwardPrimer;
import saturn.core.domain.SgcUtil;
import saturn.core.domain.SgcAllele;
import saturn.core.domain.SgcRestrictionSite;
import saturn.db.Provider;
import saturn.client.WorkspaceApplication;
import saturn.util.HaxeException;
import saturn.core.DNA;
import saturn.core.domain.SgcEntryClone;
import saturn.core.domain.SgcVector;
import saturn.db.BatchFetch;

import saturn.util.MathUtils;

class PurificationHelperTable extends Table{

    var provider : Provider;

    public function new() {
        super();

        this.setErrorColumns(['Error']);

        this.setData(
            [
                {
                    'Sample (1)':'',
                    '2nd Index (2)':'',
                    '3rd Index (3)':'',
                    'Construct (4)':'',
                    'Klone IDs (5)':'',
                    'Celline (6)':'',
                    'Construct IDs (7)':'',
                    'Expression IDs (8)':'',
                    'Break 1 (9)':'',
                    'Clone IDs (10)':'',
                    'Expression Scale (11)':'',
                    'Purification IDs (12)':'',
                    'Volume (13)':'',
                    'Expression IDs (14)':'',
                    'Yield (15)':'',
                    'Location (16)':'',
                    'Cleaved (17)':'',
                    'conc. (18)':'',
                    'concentrator (19)':'',
                    'Volume (20)':'',
                    'Aliquot size (21)':'',
                    'Buffer (22)':'',
                    'pH (23)':'',
                    'Break 2 (24)':'',
                    'Break 3 (25)':'',
                    'Column 1 (26)':'',
                    '2.0 (27)':'',
                    '3.0 (28)':'',
                    '4.0 (29)':'',
                    'Sample (30)':'',
                    'Construct (31)':'',
                    'Column (32)':'',
                    'Volume (33)':'',
                    'Abs (34)':'',
                    'Extcoeff uncut (35)':'',
                    'Weight uncut (36)':'',
                    'Gel location (37)':'',
                    'NanoSpectrum Location (38)':'',
                    'conc. (39)':'',
                    'Yield (40)':'',
                    'Column (41)':'',
                    'Volume (42)':'',
                    'Abs (43)':'',
                    'Extcoeff cut (44)':'',
                    'Weight cut (45)':'',
                    'Gel location (46)':'',
                    'NanoSpectrum Location (47)':'',
                    'conc. (48)':'',
                    'Yield (49)':'',
                    'Column (50)':'',
                    'Volume (51)':'',
                    'Abs (52)':'',
                    'Extcoeff cut (53)':'',
                    'Weight cut (54)':'',
                    'Gel location (55)':'',
                    'NanoSpectrum Location (56)':'',
                    'conc. (57)':'',
                    'Yield (58)':'',
                    'Chromatograph location (59)':'',
                    'MS result location (60)':'',
                    'MS Molecular weight (61)':'',
                    'Discrepancy (62)':'',
                    'Sample (63)':'',
                    'Construct (64)':'',
                    'MW kDa (65)':'',
                    'Yield (66)':'',
                    'Comments (67)':'',
                    'Break 4 (68)':'',
                    'Sample (69)':'',
                    'Construct (70)':'',
                    'MW kDa (71)':'',
                    'Yield (72)':'',
                    'Comments (73)':''
                }
            ],
            {
                'Sample (1)':{'editor': 'textfield'},
                '2nd Index (2)':{'editor': 'textfield'},
                '3rd Index (3)':{'editor': 'textfield'},
                'Construct (4)':{'editor': 'textfield'},
                'Klone IDs (5)':{'editor': 'textfield'},
                'Celline (6)':{'editor': 'textfield'},
                'Construct IDs (7)':{'editor': 'textfield'},
                'Expression IDs (8)':{'editor': 'textfield'},
                'Break 1 (9)':{'editor': 'textfield'},
                'Clone IDs (10)':{'editor': 'textfield'},
                'Expression Scale (11)':{'editor': 'textfield'},
                'Purification IDs (12)':{'editor': 'textfield'},
                'Volume (13)':{'editor': 'textfield'},
                'Expression IDs (14)':{'editor': 'textfield'},
                'Yield (15)':{'editor': 'textfield'},
                'Location (16)':{'editor': 'textfield'},
                'Cleaved (17)':{'editor': 'textfield'},
                'conc. (18)':{'editor': 'textfield'},
                'concentrator (19)':{'editor': 'textfield'},
                'Volume (20)':{'editor': 'textfield'},
                'Aliquot size (21)':{'editor': 'textfield'},
                'Buffer (22)':{'editor': 'textfield'},
                'pH (23)':{'editor': 'textfield'},
                'Break 2 (24)':{'editor': 'textfield'},
                'Break 3 (25)':{'editor': 'textfield'},
                'Column 1 (26)':{'editor': 'textfield'},
                '2.0 (27)':{'editor': 'textfield'},
                '3.0 (28)':{'editor': 'textfield'},
                '4.0 (29)':{'editor': 'textfield'},
                'Sample (30)':{'editor': 'textfield'},
                'Construct (31)':{'editor': 'textfield'},
                'Column (32)':{'editor': 'textfield'},
                'Volume (33)':{'editor': 'textfield'},
                'Abs (34)':{'editor': 'textfield'},
                'Extcoeff uncut (35)':{'editor': 'textfield'},
                'Weight uncut (36)':{'editor': 'textfield'},
                'Gel location (37)':{'editor': 'textfield'},
                'NanoSpectrum Location (38)':{'editor': 'textfield'},
                'conc. (39)':{'editor': 'textfield'},
                'Yield (40)':{'editor': 'textfield'},
                'Column (41)':{'editor': 'textfield'},
                'Volume (42)':{'editor': 'textfield'},
                'Abs (43)':{'editor': 'textfield'},
                'Extcoeff cut (44)':{'editor': 'textfield'},
                'Weight cut (45)':{'editor': 'textfield'},
                'Gel location (46)':{'editor': 'textfield'},
                'NanoSpectrum Location (47)':{'editor': 'textfield'},
                'conc. (48)':{'editor': 'textfield'},
                'Yield (49)':{'editor': 'textfield'},
                'Column (50)':{'editor': 'textfield'},
                'Volume (51)':{'editor': 'textfield'},
                'Abs (52)':{'editor': 'textfield'},
                'Extcoeff cut (53)':{'editor': 'textfield'},
                'Weight cut (54)':{'editor': 'textfield'},
                'Gel location (55)':{'editor': 'textfield'},
                'NanoSpectrum Location (56)':{'editor': 'textfield'},
                'conc. (57)':{'editor': 'textfield'},
                'Yield (58)':{'editor': 'textfield'},
                'Chromatograph location (59)':{'editor': 'textfield'},
                'MS result location (60)':{'editor': 'textfield'},
                'MS Molecular weight (61)':{'editor': 'textfield'},
                'Discrepancy (62)':{'editor': 'textfield'},
                'Sample (63)':{'editor': 'textfield'},
                'Construct (64)':{'editor': 'textfield'},
                'MW kDa (65)':{'editor': 'textfield'},
                'Yield (66)':{'editor': 'textfield'},
                'Comments (67)':{'editor': 'textfield'},
                'Break 4 (68)':{'editor': 'textfield'},
                'Sample (69)':{'editor': 'textfield'},
                'Construct (70)':{'editor': 'textfield'},
                'MW kDa (71)':{'editor': 'textfield'},
                'Yield (72)':{'editor': 'textfield'},
                'Comments (73)':{'editor': 'textfield'}
            }
        );

        this.setName('PrepX');
    }

    public function getProvider() : Provider{
        if(provider != null){
            return provider;
        }else{
            return WorkspaceApplication.getApplication().getProvider();
        }
    }

    public function generateids(cb : String->Void){
        var data = getData();

        //Generate unique target list
        var targetSet = new Map<String,String>();

        for(row in data){
            var constructId :String = Reflect.field(row, 'Construct (4)');

            var targetId = constructId.split('-')[0];

            targetSet.set(targetId, '');
        }

        var targets = [for(targetId in targetSet.keys()) targetId];

        SgcUtil.generateNextID(getProvider(), targets, SgcClone, function(cloneMap : Map<String,Int>, err : String){
            if(err == null){
                SgcUtil.generateNextID(getProvider(), targets, SgcExpression, function(expressionMap : Map<String,Int>, err : String){
                    if(err == null){
                        SgcUtil.generateNextID(getProvider(), targets, SgcPurification, function(purificationMap : Map<String,Int>, err : String){
                            if(err == null){
                                for(row in data){
                                    var constructId :String = Reflect.field(row, 'Construct');

                                    var targetId = constructId.split('-')[0];

                                    Reflect.setField(row, 'Clone ID', targetId + '-k' + StringTools.lpad(Std.string(cloneMap.get(targetId)),'0',3));
                                    cloneMap.set(targetId, cloneMap.get(targetId)+1);


                                    Reflect.setField(row, 'Expression ID', targetId + '-e' + StringTools.lpad(Std.string(expressionMap.get(targetId)),'0',3));
                                    expressionMap.set(targetId, expressionMap.get(targetId)+1);

                                    Reflect.setField(row, 'Purification ID', targetId + '-p' + StringTools.lpad(Std.string(purificationMap.get(targetId)),'0',3));
                                    purificationMap.set(targetId, purificationMap.get(targetId)+1);

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
    }
    
    public function saveNew(cb : String->Void){
        _saveNew(cb);
    }
    
    public function _saveNew(cb : String->Void){
        var p = getProvider();
        var data = getData();

        var clones = new Array<SgcClone>();
        var expressions = new Array<SgcExpression>();
        var purifications = new Array<SgcPurification>();
        
        for(row in data){
            var clone = new SgcClone();

            clone.cloneId = Reflect.field(row, 'Clone ID');
            clone.construct = new SgcConstruct();
            clone.construct.constructId = Reflect.field(row, 'Construct (4)');
            clone.elnId = Reflect.field(row, 'ELN ID');

            var expression = new SgcExpression();
            expression.expressionId = Reflect.field(row, 'Expression ID');
            expression.clone = clone;
            expression.elnId = Reflect.field(row, 'ELN ID');

            var purification = new SgcPurification();
            purification.purificationId = Reflect.field(row, 'Purification ID');
            purification.expression = expression;
            purification.column = Reflect.field(row, 'Column');
            purification.elnId = Reflect.field(row, 'ELN ID');


            clones.push(clone);
            expressions.push(expression);
            purifications.push(purification);
        }

        p.insertOrUpdate(clones, function(err: String){
            if(err != null){
                cb(err);
                return;
            }

            p.insertOrUpdate(expressions, function(err: String){
                if(err != null){
                    cb(err);
                    return;
                }

                p.insertOrUpdate(purifications, function(err: String){
                    if(err != null){
                        cb(err);
                        return;
                    }else{
                        cb(null);
                    }
                }, true);
            }, true);
        }, true);
    }

    public function fetchall(cb : String->Void){
        var p = getProvider();
        var data = getData();

        var ids = new Array<String>();
        var constructIdToRow = new Map<String, Dynamic>();

        for(row in data){
            var constructId = Reflect.field(row, 'Construct (4)');
            ids.push(constructId);

            constructIdToRow.set(constructId, row);

        }

        p.getByIds(ids, saturn.core.domain.SgcConstruct, function(objs : Array<SgcConstruct>, err : String){
            if(err == null){
                for(obj in objs){
                    var constructId = obj.constructId;
                    var row = constructIdToRow.get(constructId);
                    //Reflect.setField(row, 'MW', obj.getProtein().getMW());
                }

                cb(null);
            }else{
                cb(err);
            }
        });
    }

    public function runStage0(prepXRun : String,  cb : String->Void){
        runStage(prepXRun, '0', function(err : String){
            if(err != null){
                cb(err);
            }else{
                fetchall(function(err : String){
                    if(err != null){
                        cb(err);
                    }else{
                        runStage1(prepXRun, cb);
                    }
                });
            }
        });
    }

    public function runStage1(prepXRun : String,  cb : String->Void){
        runStage(prepXRun, '1', function(err : String){
            if(err != null){
                cb(err);
            }else{
                Util.debug('Step 1 finished');

                runStage2(prepXRun, cb);
            }
        });
    }

    public function runStage2(prepXRun : String,  cb : String->Void){
        runStage(prepXRun, '2', function(err : String){
            if(err != null){
                cb(err);
            }else{
                Util.debug('Step 2 finished');

                runStage3(prepXRun, cb);
            }
        });
    }

    public function runStage3(prepXRun : String,  cb : String->Void){
        runStage(prepXRun, '3', function(err : String){
            if(err != null){
                cb(err);
            }else{
                cb(err);
                Util.debug('Step 3 finished');
            }
        });
    }

    public function runStage(prepXRun : String, stage : String, cb : String->Void){
        getProvider().getByNamedQuery('saturn.server.plugins.informatics.PurificationHelperPlugin.runStage', [{'runname': prepXRun, 'stage': stage, 'table': getData()}], null, false, function(objs, err){
            if(err != null){
                cb(err);
            }else{
                updateData(objs[0].table);

                cb(null);
            }
        });
    }
}