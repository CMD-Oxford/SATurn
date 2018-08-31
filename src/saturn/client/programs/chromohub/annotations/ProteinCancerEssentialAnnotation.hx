package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.chromohub.ChromoHubAnnotation.HasAnnotationType;

class ProteinCancerEssentialAnnotation {
    public function new() {

    }

    static function hasCancerEssential(target: String, data: Dynamic, selected:Int,annotList:Array<ChromoHubAnnotation>, item:String, cb : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'red',used:true},defImage:0};

        // data.family_id
        // data.subfamily

        cb(r);
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

        WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookCancerEssential', args, null, false, function(db_results, error){
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
