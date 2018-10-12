package saturn.client.programs.chromohub.annotations;

import phylo.PhyloAnnotation;
import phylo.PhyloScreenData;
import phylo.PhyloAnnotation.HasAnnotationType;
import phylo.PhyloTreeNode;
import saturn.client.core.CommonCore;

class HighlightAnnotation {

    public function new() {

    }

    static function hasHighlight(target: String, data: Dynamic, selected:Int, annotList:Array<PhyloAnnotation>, item:String, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: false, text:'',color:{color:'',used:false},defImage:100};

        var year:Int;

        var current_year=Date.now().getFullYear();

        year=current_year - selected - 1;
        var tg=target;

        //First check Funding

        WorkspaceApplication.getApplication().getProvider().getByNamedQuery("highlightJumpInLastYear",{target : tg, year: year}, null, true, function(db_results, error){
            if(error == null) {
                if (db_results!=null){
                    var prev_amount = 0;
                    var i,amount,prev_amount,curr_amount:Int;
                    /*for(i in 0...db_results.length){

                        var myyear = db_results[i].year;
						if (myyear == 0) {
							amount = db_results[i].funds;
						} else {
							curr_amount = db_results[i].funds;
							if (myyear == year) {
                                prev_amount = curr_amount; 	continue;
                            }

							if ( (prev_amount > 2000000 && curr_amount/prev_amount >= 2) ||
                                 (prev_amount > 100000 && curr_amount/prev_amount >= 4) ||
								 (prev_amount > 500000 && curr_amount/prev_amount >= 6) ||
								 (prev_amount > 0 && curr_amount/prev_amount > 9) ||
								 (prev_amount == 0 && curr_amount > 500000) ){
										r.hasAnnot = true;
										//$funding_diff = max($curr_amount - $prev_amount, $funding_diff);
									}
									prev_amount = curr_amount;

                        }
                    }*/
                }
            }
            else {
                WorkspaceApplication.getApplication().debug(error);
            }
        });

        //Second we check Pubmed
        WorkspaceApplication.getApplication().getProvider().getByNamedQuery("highlightJumpInLasYearPub",{target : tg, year: year}, null, true, function(db_results, error){
            if(error == null) {
                if (db_results!=null){

                }
            }
            else {
                WorkspaceApplication.getApplication().debug(error);
            }
        });
        r.defImage=0;
        r.hasAnnot=true;
        callBack(r);
    }
}
