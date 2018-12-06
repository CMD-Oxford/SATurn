package saturn.client.programs.chromohub.annotations;

import phylo.PhyloAnnotationManager;
import phylo.PhyloAnnotation;
import phylo.PhyloScreenData;
import phylo.PhyloAnnotation.HasAnnotationType;
import phylo.PhyloTreeNode;

class ProteinCancerEssentialAnnotation {
    public function new() {

    }

    static function hasCancerEssential(target: String, data: Dynamic, selected:Int, annotList:Array<PhyloAnnotation>, item:String, cb : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'#793ff3',used:true},defImage:0};

        // data.family_id
        // data.subfamily

        cb(r);
    }

    static function divCancerEssential(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){
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
            var score = selectedAnnotations[0].cancer_score;
            var cancer_type = selectedAnnotations[0].cancer_types;
            var alias;

            if(cancer_type[0] != 'All'){
                alias = 'gene_cancerEssentialDiv';
            } else {
                alias = 'gene_cancerEssentialAllDiv';
            }

            var args = {target : screenData.targetClean, score : score, type : cancer_type};

            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(alias, args, null, false,function(db_results:Dynamic, error){
                if(error == null) {
                    var ttext:Dynamic;
                    ttext = '';

                    for(i in 0... db_results.length){
                        ttext=ttext+'<tr><td>' + db_results[i].primary_disease + '</td>';
                        ttext=ttext+'<td>' + db_results[i].median_score + '</td>';
                        ttext=ttext+'<td>' + db_results[i].nof_scores + '</td></tr>';
                    }

                    var t = '<style type="text/css">
                                     table td:nth-child(1) { width: 40%; }
                                     table td:nth-child(2) { width: 30%; }
                                     table td:nth-child(3) { width: 30%; }
                                     table td { font-size: 12px; border: 1px solid #cccccc; padding: 5px;}
                                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                                    .divContent{padding:5px;}
                                    .divMainDiv  a{ text-decoration:none!important;}

                                    .interactionInfo{font-size:10px}
                                    .interactionResult{padding:3px 10px ;}
                                    </style>
                                    <div class="divMainDiv">
                                    <div class="divTitle">Essentiality in Cancer (CRISPR) - '+screenData.target+'</div>
                                    <div class="divContent">
                                        <table>
                                            <tr class="first_tr" style="font-size:12">
                                                <th>Cancer Type</th>
										        <th>Median Score</th>
										        <th>Number of cell lines</th>
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

    static function cancerEssentialFunction (annotation : Int, form : Dynamic, tree_type : String, family : String, searchGenes : Array<Dynamic>, annotationManager : ChromoHubAnnotationManager, cb : Dynamic->String->Void){
        var cancerScore = null;
        var cancerTypes = null;

        if(form.form.findField('essentiality_rnai').lastValue){
            annotationManager.cleanAnnotResults(31);
            cancerEssentialRNAiFunction(31, form, tree_type, family, searchGenes, annotationManager, cb);
            annotationManager.activeAnnotation[annotation] = true;
            annotationManager.skipCurrentLegend[annotation] = true;
            annotationManager.activeAnnotation[31] = true;
            WorkspaceApplication.getApplication().getSingleAppContainer().addImageToLegend(annotationManager.annotations[31].legend, 31);

        } else {
            annotationManager.activeAnnotation[31] = false;
            annotationManager.cleanAnnotResults(31);
        }

        if(form.form.findField('essentiality_crispr').lastValue){
            annotationManager.activeAnnotation[annotation] = true;
            WorkspaceApplication.getApplication().getSingleAppContainer().addImageToLegend(annotationManager.annotations[annotation].legend, annotation);


            if(form != null){
                // We get here for tree annotation requests
                cancerScore = form.form.findField('cancer_score').lastValue;
                cancerTypes = form.form.findField('cancer_types').lastValue;
            }else{

            }

            var args = [{'treeType' : tree_type, 'familyTree' : family, 'cancer_score' : cancerScore, 'searchGenes' : searchGenes, 'cancer_types' :  cancerTypes}];
            annotationManager.setSelectedAnnotationOptions(annotation, args);

            WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookCancerEssential', args, null, false, function(db_results, error){
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
            annotationManager.cleanAnnotResults(annotation);
        }
    }

    static function hasCancerEssentialRNAi(target: String, data: Dynamic, selected:Int, annotList:Array<PhyloAnnotation>, item:String, cb : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'#f07828',used:true},defImage:0};

        cb(r);
    }

    static function divCancerEssentialRNAi(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){
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
            var score = selectedAnnotations[0].cancer_score;
            var cancer_type = selectedAnnotations[0].cancer_types;
            var alias;

            if(cancer_type[0] != 'All'){
                alias = 'gene_cancerEssentialRNAiDiv';
            } else {
                alias = 'gene_cancerEssentialRNAiAllDiv';
            }

            var args = {target : screenData.targetClean, score : score, type : cancer_type};

            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(alias, args, null, false,function(db_results:Dynamic, error){
                if(error == null) {
                    var ttext:Dynamic;
                    ttext = '';

                    for(i in 0... db_results.length){
                        ttext=ttext+'<tr><td>' + db_results[i].primary_disease + '</td>';
                        ttext=ttext+'<td>' + db_results[i].median_score + '</td>';
                        ttext=ttext+'<td>' + db_results[i].nof_celllines + '</td></tr>';
                    }

                    var t = '<style type="text/css">
                                     table td:nth-child(1) { width: 40%; }
                                     table td:nth-child(2) { width: 30%; }
                                     table td:nth-child(3) { width: 30%; }
                                     table td { font-size: 12px; border: 1px solid #cccccc; padding: 5px;}
                                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                                    .divContent{padding:5px;}
                                    .divMainDiv  a{ text-decoration:none!important;}

                                    .interactionInfo{font-size:10px}
                                    .interactionResult{padding:3px 10px ;}
                                    </style>
                                    <div class="divMainDiv">
                                    <div class="divTitle">Essentiality in Cancer (RNAi) - '+screenData.target+'</div>
                                    <div class="divContent">
                                        <table>
                                            <tr class="first_tr" style="font-size:12">
                                                <th>Cancer Type</th>
										        <th>Median Score</th>
										        <th>Number of cell lines</th>
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

    static function cancerEssentialRNAiFunction (annotation : Int, form : Dynamic, tree_type : String, family : String, searchGenes : Array<Dynamic>, annotationManager : ChromoHubAnnotationManager, cb : Dynamic->String->Void){
        var cancerScore = null;
        var cancerTypes = null;

        if(form != null){
            // We get here for tree annotation requests
            cancerScore = form.form.findField('cancer_score_rnai').lastValue;

            cancerTypes = form.form.findField('cancer_types_rnai').lastValue;
        }else{

        }

        var args = [{'treeType' : tree_type, 'familyTree' : family, 'cancer_score' : cancerScore, 'searchGenes' : searchGenes, 'cancer_types' :  cancerTypes}];
        annotationManager.setSelectedAnnotationOptions(annotation, args);

        WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookCancerEssentialRNAi', args, null, false, function(db_results, error){
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
