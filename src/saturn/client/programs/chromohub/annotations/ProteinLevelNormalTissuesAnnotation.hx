package saturn.client.programs.chromohub.annotations;

import phylo.PhyloAnnotationManager;
import phylo.PhyloAnnotation;
import phylo.PhyloScreenData;
import phylo.PhyloAnnotation.HasAnnotationType;
import phylo.PhyloTreeNode;

/**
* ProteinLevelNormalTissueAnnotation is responsible for processing protein tissue expression level annotations
**/
class ProteinLevelNormalTissuesAnnotation {
    public function new() {

    }

    static function hasNormalLevel(target: String, data: Dynamic, selected:Int, annotList:Array<PhyloAnnotation>, item:String, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'#793ff3',used:true},defImage:0};

        callBack(r);
    }

    static function divNormalLevel(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){
        if(screenData.divAccessed==false){
            screenData.divAccessed=true;

            if(screenData.targetClean.indexOf('/')!=-1){
                var auxArray=screenData.targetClean.split('');
                var j:Int;
                var nom='';
                for(j in 0...auxArray.length){
                    if(auxArray[j]!='/') nom+=auxArray[j];
                }
                screenData.targetClean=nom;
            }
            if(screenData.target.indexOf('/')!=-1){
                var auxArray=screenData.target.split('');
                var j:Int;
                var nom='';
                for(j in 0...auxArray.length){
                    if(auxArray[j]!='/') nom+=auxArray[j];
                }
                screenData.target=nom;
            }

            var name:String;
            if (screenData.target.indexOf('(')!=-1) name=screenData.targetClean;
            else if (screenData.target.indexOf('-')!=-1) name=screenData.targetClean;
            else name=screenData.target;
            trace('Family:');

            var viewer = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);

            var selectedAnnotations = viewer.annotationManager.getSelectedAnnotationOptions(screenData.annot);

            var proteinLevels = [];
            proteinLevels = selectedAnnotations[0].protein_levels;
            var reliability = [];
            reliability = selectedAnnotations[0].reliabilities;
            var tissueTypes = [];
            tissueTypes = selectedAnnotations[0].tissue_types;
            var cellTypes = [];
            cellTypes = selectedAnnotations[0].cell_types;

            //searchGenes -> If you have the family name use it otherwise throw an exception.
            var searchGenes = [];
            searchGenes.push(screenData.targetClean);

            // Prepare web-service call
            var args = [{'treeType' : tree_type, 'familyTree' : screenData.family, 'tissue_types' : tissueTypes, 'cell_types' : cellTypes, 'searchGenes' : searchGenes, 'protein_levels' :  proteinLevels, 'reliabilities': reliability}];

            WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookProteinNormalLevelsDiv', args, null, false,function(db_results:Dynamic, error){
                if(error == null) {
                    var ttext:Dynamic;
                    ttext = '';

                    for(i in 0... db_results.length){
                        ttext=ttext+'<tr><td>' + db_results[i].tissue + '</td>';
                        ttext=ttext+'<td>' + db_results[i].cell_type + '</td>';
                        ttext=ttext+'<td>' + db_results[i].protein_level + '</td>';
                        ttext=ttext+'<td>' + db_results[i].reliability + '</td>';
                    }

                    var t = '<style type="text/css">
                                 table td:nth-child(1) { width: 25%; }
                                 table td:nth-child(2) { width: 25%; }
                                 table td:nth-child(3) { width: 25%; }
                                 table td:nth-child(4) { width: 25%; }
                                 table td { font-size: 12px; border: 1px solid #cccccc; padding: 5px;}
                                .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                                .divContent{padding:5px;}
                                .divMainDiv  a{ text-decoration:none!important;}

                                .interactionInfo{font-size:10px}
                                .interactionResult{padding:3px 10px ;}
                                </style>
                                <div class="divMainDiv">
                                <div class="divTitle">Protein Level in Normal Tissue - '+screenData.target+'</div>
                                <div class="divContent">
                                    <table>
                                        <tr class="first_tr" style="font-size:12">
                                            <th>Tissue</th>
                                            <th>Cell Type</th>
                                            <th>Protein Level</th>
                                            <th>Reliability</th>
                                        </tr>
                                        <tr>
                                        '+ttext+'
                                        </tr>
                                    </table>
                                </div>
                            </div>';

                    callBack(t);
                }
            });
        }
    }

    static function hasNormalLevelFunction (annotation : Int, form : Dynamic, tree_type : String, family : String, searchGenes : Array<Dynamic>, annotationManager : ChromoHubAnnotationManager, cb : Dynamic->String->Void){
        var proteinLevels = [];
        var reliability = [];
        var tissueTypes = [];
        var cellTypes = [];


        var cancer_type:String;

        if(form.form.findField('perc_protein_option').lastValue){
            hasNormalLevelPercentageFunction(29, form, tree_type, family, searchGenes, annotationManager, cb);
            annotationManager.activeAnnotation[annotation] = true;
        } else {
            annotationManager.cleanAnnotResults(29);
        }

        if(form.form.findField('protein_option').lastValue){
            annotationManager.skipAnnotation[annotation] = false;

            if(form != null){
                // We get here for tree annotation requests

                // Process protein levels
                if(form.form.findField('protein_level_high').lastValue){
                    proteinLevels.push('High');
                }

                if(form.form.findField('protein_level_medium').lastValue){
                    proteinLevels.push('Medium');
                }

                if(form.form.findField('protein_level_low').lastValue){
                    proteinLevels.push('Low');
                }

                if(form.form.findField('protein_level_not_detected').lastValue){
                    proteinLevels.push('Not detected');
                }

                // Process reliability
                if(form.form.findField('protein_reliability_approved').lastValue){
                    reliability.push('Approved');
                }

                if(form.form.findField('protein_reliability_enhanced').lastValue){
                    reliability.push('Enhanced');
                }

                if(form.form.findField('protein_reliability_supported').lastValue){
                    reliability.push('Supported');
                }

                if(form.form.findField('protein_reliability_uncertain').lastValue){
                    reliability.push('Uncertain');
                }

                // Obtain list of selected tissue types
                tissueTypes = form.form.findField('tissues').lastValue;
                // Obtain list of selected cell types
                cellTypes = form.form.findField('cell_types').lastValue;
            }else{
                // We aren't planning to support table view for these UbiHub specific annotations
                throw new saturn.util.HaxeException('Table view not supported for ProteinLevelNormalTissueAnnotation');
            }

            // Prepare web-service call
            var args = [{
                'treeType' : tree_type, 'familyTree' : family,
                'tissue_types' : tissueTypes, 'cell_types' : cellTypes,
                'searchGenes' : searchGenes, 'protein_levels' :  proteinLevels,
                'reliabilities': reliability
            }];
            annotationManager.setSelectedAnnotationOptions(annotation, args);

            // Make web-service call
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookProteinNormalLevels', args, null, false, function(db_results, error){
                if(error == null){
                    if(db_results != null){

                        annotationManager.activeAnnotation[annotation] = true;

                        if(annotationManager.treeName == ''){
                            // We get here for table view
                            annotationManager.addAnnotDataGenes(db_results, annotation, function(){
                                cb(db_results, null);
                            });
                        }else{
                            // We get here for tree view
                            annotationManager.addAnnotData(db_results, annotation, 0, function(){
                                annotationManager.canvas.redraw();

                                cb(db_results, null);
                            });
                        }
                    }
                }else{
                    cb(null,error);
                }
            });
        } else{
            annotationManager.skipAnnotation[annotation] = true;
            return;
        }
    }

    static function hasNormalLevelPercentage(target: String, data: Dynamic, selected:Int, annotList:Array<PhyloAnnotation>, item:String, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'#793ff3',used:true},defImage:0};

        callBack(r);
    }

    static function divNormalLevelPercentage(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){
        if(screenData.divAccessed==false){
            screenData.divAccessed=true;

            if(screenData.targetClean.indexOf('/')!=-1){
                var auxArray=screenData.targetClean.split('');
                var j:Int;
                var nom='';
                for(j in 0...auxArray.length){
                    if(auxArray[j]!='/') nom+=auxArray[j];
                }
                screenData.targetClean=nom;
            }
            if(screenData.target.indexOf('/')!=-1){
                var auxArray=screenData.target.split('');
                var j:Int;
                var nom='';
                for(j in 0...auxArray.length){
                    if(auxArray[j]!='/') nom+=auxArray[j];
                }
                screenData.target=nom;
            }

            var name:String;
            if (screenData.target.indexOf('(')!=-1) name=screenData.targetClean;
            else if (screenData.target.indexOf('-')!=-1) name=screenData.targetClean;
            else name=screenData.target;
            trace('Family:');

            var viewer = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);

            var selectedAnnotations = viewer.annotationManager.getSelectedAnnotationOptions(screenData.annot);

            var proteinLevels = [];
            proteinLevels = selectedAnnotations[0].protein_levels;
            var reliability = [];
            reliability = selectedAnnotations[0].reliabilities;
            var percentage = selectedAnnotations[0].in_percentage;

            //searchGenes -> If you have the family name use it otherwise throw an exception.
            var searchGenes = [];
            searchGenes.push(screenData.targetClean);

            // Prepare web-service call
            var args = [{'treeType' : tree_type, 'familyTree' : screenData.family, 'searchGenes' : searchGenes, 'protein_levels' :  proteinLevels, 'reliabilities': reliability, 'in_percentage': percentage}];

            WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookProteinNormalLevelsPercentageDiv', args, null, false,function(db_results:Dynamic, error){
                if(error == null) {
                    var ttext:Dynamic;
                    ttext = '';

                    for(i in 0... db_results.length){
                        ttext=ttext+'<tr><td>' + db_results[i].tissue + '</td>';
                        ttext=ttext+'<td>' + db_results[i].cell_type + '</td>';
                        ttext=ttext+'<td>' + db_results[i].protein_level + '</td>';
                        ttext=ttext+'<td>' + db_results[i].reliability + '</td>';
                    }

                    var t = '<style type="text/css">
                                 table td:nth-child(1) { width: 25%; }
                                 table td:nth-child(2) { width: 25%; }
                                 table td:nth-child(3) { width: 25%; }
                                 table td:nth-child(4) { width: 25%; }
                                 table td { font-size: 12px; border: 1px solid #cccccc; padding: 5px;}
                                .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                                .divContent{padding:5px;}
                                .divMainDiv  a{ text-decoration:none!important;}

                                .interactionInfo{font-size:10px}
                                .interactionResult{padding:3px 10px ;}
                                </style>
                                <div class="divMainDiv">
                                <div class="divTitle">Protein Level in Normal Tissue - '+screenData.target+'</div>
                                <div class="divContent">
                                    <table>
                                        <tr class="first_tr" style="font-size:12">
                                            <th>Tissue</th>
                                            <th>Cell Type</th>
                                            <th>Protein Level</th>
                                            <th>Reliability</th>
                                        </tr>
                                        <tr>
                                        '+ttext+'
                                        </tr>
                                    </table>
                                </div>
                            </div>';

                    callBack(t);
                }
            });
        }
    }

    static function hasNormalLevelPercentageFunction (annotation : Int, form : Dynamic, tree_type : String, family : String, searchGenes : Array<Dynamic>, annotationManager : ChromoHubAnnotationManager, cb : Dynamic->String->Void){

        var proteinLevels = [];
        var reliability = [];
        var percentage = null;

        if(form != null){
            // We get here for tree annotation requests

            // Process protein levels
            if(form.form.findField('perc_protein_level_high').lastValue){
                proteinLevels.push('High');
            }

            if(form.form.findField('perc_protein_level_medium').lastValue){
                proteinLevels.push('Medium');
            }

            if(form.form.findField('perc_protein_level_low').lastValue){
                proteinLevels.push('Low');
            }

            // Process reliability
            if(form.form.findField('perc_protein_reliability_approved').lastValue){
                reliability.push('Approved');
            }

            if(form.form.findField('perc_protein_reliability_enhanced').lastValue){
                reliability.push('Enhanced');
            }

            if(form.form.findField('perc_protein_reliability_supported').lastValue){
                reliability.push('Supported');
            }

            if(form.form.findField('perc_protein_reliability_uncertain').lastValue){
                reliability.push('Uncertain');
            }

            percentage = form.form.findField('in_percentage').lastValue;

        }else{
            // We aren't planning to support table view for these UbiHub specific annotations
            throw new saturn.util.HaxeException('Table view not supported for ProteinLevelNormalTissueAnnotation');
        }

        // Prepare web-service call
        var args = [{
            'treeType' : tree_type, 'familyTree' : family,
            'in_percentage': percentage,
            'searchGenes' : searchGenes, 'protein_levels' :  proteinLevels,
            'reliabilities': reliability
        }];
        annotationManager.setSelectedAnnotationOptions(annotation, args);

        // Make web-service call
        WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookProteinNormalLevelsPercentage', args, null, false, function(db_results, error){
            if(error == null){
                if(db_results != null){

                    annotationManager.activeAnnotation[annotation] = true;

                    if(annotationManager.treeName == ''){
                        // We get here for table view
                        annotationManager.addAnnotDataGenes(db_results, annotation, function(){
                            cb(db_results, null);
                        });
                    }else{
                        // We get here for tree view
                        annotationManager.addAnnotData(db_results, annotation, 0, function(){
                            annotationManager.canvas.redraw();

                            cb(db_results, null);
                        });
                    }
                }
            }else{
                cb(null,error);
            }
        });
    }
}
