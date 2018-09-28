package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.phylo.PhyloAnnotation;
import saturn.client.programs.phylo.PhyloScreenData;
import saturn.client.programs.phylo.PhyloAnnotation.HasAnnotationType;
import saturn.client.programs.phylo.PhyloTreeNode;

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
                                    <div class="divTitle">Essentiality in Cancer - '+screenData.target+'</div>
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

    static function cancerEssentialFunction (annotation : Int, form : Dynamic, tree_type : String, family : String, searchGenes : Array<Dynamic>, viewer : ChromoHubViewer, cb : Dynamic->String->Void){
        var cancerScore = null;
        var cancerTypes = null;

        if(form != null){
            // We get here for tree annotation requests
            cancerScore = form.form.findField('cancer_score').lastValue;

            cancerTypes = form.form.findField('cancer_types').lastValue;
        }else{

        }

        var args = [{'treeType' : tree_type, 'familyTree' : family, 'cancer_score' : cancerScore, 'searchGenes' : searchGenes, 'cancer_types' :  cancerTypes}];
        viewer.annotationManager.setSelectedAnnotationOptions(annotation, args);

        WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookCancerEssential', args, null, false, function(db_results, error){
            if(error == null){
                if(db_results != null){

                    viewer.annotationManager.activeAnnotation[annotation] = true;

                    if(viewer.treeName == ''){
                        // We get here for table view
                        viewer.addAnnotDataGenes(db_results, annotation, function(){
                            cb(db_results, null);
                        });
                    }else{
                        // We get here for tree view
                        viewer.addAnnotData(db_results, annotation, 0, function(){
                            viewer.newposition(0, 0);

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
