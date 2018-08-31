package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.chromohub.ChromoHubAnnotation.HasAnnotationType;

/**
* ProteinLevelNormalTissueAnnotation is responsible for processing protein tissue expression level annotations
**/
class ProteinLevelNormalTissuesAnnotation {
    public function new() {

    }

    static function hasNormalLevel(target: String, data: Dynamic, selected:Int,annotList:Array<ChromoHubAnnotation>, item:String, callBack : HasAnnotationType->Void){
        // TODO: To be implemented by Leo
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'#800080',used:true},defImage:0};

        callBack(r);
    }


    static function hasNormalLevelFunction (annotation : Int, form : Dynamic, tree_type : String, family : String, searchGenes : Array<Dynamic>, viewer : ChromoHubViewer, cb : Dynamic->String->Void){

        var proteinLevels = [];
        var reliability = [];
        var tissueTypes = [];
        var cellTypes = [];

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

        // Make web-service call
        WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookHasProteinNormalLevels', args, null, false, function(db_results, error){
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

    static function hasNormalLevelPercentage(target: String, data: Dynamic, selected:Int,annotList:Array<ChromoHubAnnotation>, item:String, callBack : HasAnnotationType->Void){
        // TODO: To be implemented by Leo
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'#800080',used:true},defImage:0};

        callBack(r);
    }

    static function hasNormalLevelPercentageFunction (annotation : Int, form : Dynamic, tree_type : String, family : String, searchGenes : Array<Dynamic>, viewer : ChromoHubViewer, cb : Dynamic->String->Void){

        var proteinLevels = [];
        var reliability = [];
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

        // Make web-service call
        WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookHasProteinNormalLevelsPercentage', args, null, false, function(db_results, error){
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
