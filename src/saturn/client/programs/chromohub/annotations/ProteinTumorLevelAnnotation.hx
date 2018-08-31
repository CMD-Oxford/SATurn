package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.chromohub.ChromoHubAnnotation.HasAnnotationType;

class ProteinTumorLevelAnnotation {
    public function new() {

    }

    static function hasTumorLevel(target: String, data: Dynamic, selected:Int,annotList:Array<ChromoHubAnnotation>, item:String, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'#800080',used:true},defImage:0};

        callBack(r);
    }


    static function divTumorLevel(screenData: ChromoHubScreenData,x:String,y:String,tree_type:String, callBack : Dynamic->Void){
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


            var viewer = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);

            WorkspaceApplication.getApplication().getProvider().getByNamedQuery('tumorLevelAllDiv',{target : screenData.targetClean}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var ttext:Dynamic;
                    ttext = '';

                    for(i in 0... results.length){
                        ttext=ttext+'<tr><td>' + results[i].cancer_type + '</td>';
                        ttext=ttext+'<td>' + results[i].high + '</td>';
                        ttext=ttext+'<td>' + results[i].medium + '</td>';
                        ttext=ttext+'<td>' + results[i].low + '</td>';
                        ttext=ttext+'<td>' + results[i].not_detected + '</td></tr>';
                    }


                    var t = '<style type="text/css">
                                 table td:nth-child(1) { width: 40%; }
                                 table td:nth-child(2) { width: 15%; }
                                 table td:nth-child(3) { width: 15%; }
                                 table td:nth-child(4) { width: 15%; }
                                 table td:nth-child(5) { width: 15%; }
                                 table td { font-size: 12px; border: 1px solid #cccccc; padding: 5px;}
                                .divMainDiv4  { }
                                .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                                .divContent{padding:5px;}
                                .divMainDiv  a{ text-decoration:none!important;}

                                .interactionInfo{font-size:10px}
                                .interactionResult{padding:3px 10px ;}
                                </style>
                                <div class="divMainDiv">
                                <div class="divTitle">Protein Level in Tumors - '+screenData.target+' (numbers of patients are shown)</div>
                                <div class="divContent">
                                    <table>
                                        <tr class="first_tr" style="font-size:12">
                                            <th>Cancer Type</th>
                                            <th>High</th>
                                            <th>Medium</th>
                                            <th>Low</th>
                                            <th>Not Detected</th>
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

    static function tumorLevelFunction (annotation : Int, form : Dynamic, tree_type : String, family : String, searchGenes : Array<Dynamic>, viewer : ChromoHubViewer, cb : Dynamic->String->Void){
        var cancer_type:String;
        var proteinLevels = [];

        if(form != null){
            // We get here for tree annotation requests
            cancer_type = form.form.findField('cancer_type').lastValue;
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
        }else{
            // We get here for table annotation requests
            cancer_type="All";
        }

        var args = [{'treeType' : tree_type, 'familyTree' : family, 'cancer_type' : cancer_type, 'searchGenes' : searchGenes, 'protein_levels' :  proteinLevels}];

        WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookTumorLevels', args, null, false, function(db_results, error){
            if(error == null){
                if(db_results != null){

                    viewer.activeAnnotation[annotation] = true;

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

    static function hasTumorLevelPercentage(target: String, data: Dynamic, selected:Int,annotList:Array<ChromoHubAnnotation>, item:String, callBack : HasAnnotationType->Void){
        // TODO: To be implemented by Leo
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'#800080',used:true},defImage:0};

        callBack(r);
    }

    static function tumorLevelPercentageFunction (annotation : Int, form : Dynamic, tree_type : String, family : String, searchGenes : Array<Dynamic>, viewer : ChromoHubViewer, cb : Dynamic->String->Void){

        var proteinLevels = [];
        var percentage = null;

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

            percentage = form.form.findField('in_percentage').lastValue;

        }else{
            // We aren't planning to support table view for these UbiHub specific annotations
            throw new saturn.util.HaxeException('Table view not supported for ProteinTumorLevelAnnotation');
        }

        // Prepare web-service call
        var args = [{
            'treeType' : tree_type, 'familyTree' : family,
            'in_percentage': percentage,
            'searchGenes' : searchGenes, 'protein_levels' :  proteinLevels
        }];

        // Make web-service call
        WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookHasTumorLevelPercentage', args, null, false, function(db_results, error){
            if(error == null){
                if(db_results != null){

                    viewer.activeAnnotation[annotation] = true;

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
