package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.phylo.PhyloAnnotation;
import saturn.client.programs.phylo.PhyloScreenData;
import saturn.client.programs.phylo.PhyloAnnotation.HasAnnotationType;
import saturn.client.programs.phylo.PhyloTreeNode;
import saturn.client.core.CommonCore;

class InteractomeAnnotation {

    public function new() {

    }

    static function divInteractome(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;


            var al,auxtext:String;
            WorkspaceApplication.getApplication().debug("access db");
            al='interactomeDiv';auxtext='';
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{target : screenData.targetClean}, null, true, function(results: Dynamic, error){
                if(error == null) {

                    var ii:Int;
                    var ttext:String;
                    var subs:String;
                    ttext="";

                    for(ii in 0...results.length){
                        ttext=ttext+'<a href="http://www.ncbi.nlm.nih.gov/gene/?term='+results[ii].geneid_b+'" target="_blank">'+results[ii].target_id_b+'</a><br>';
                    }

                    var t = '<style type="text/css">
                    .divMainDiv17 { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv17 a{ text-decoration:none!important;}

                    .divExtraInfo{padding:5px;widht:100%!important; font-size:10px; margin-top:5px;}

                    .interactomeResult{padding:5px 0px 10px 0px; ;}
                    </style>
                    <div class="divMainDiv17">
                    <div class="divTitle"> Protein Interactome ('+screenData.target+')</div>
                    <div class="divContent">
                    <div class="interactomeResult">
                    '+ttext+'
                    </div>
                    </div><div class="divExtraInfo"> </div>
                    </div>';

                    callBack(t);
                }
                else {
                    WorkspaceApplication.getApplication().debug(error);
                }
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }
}
