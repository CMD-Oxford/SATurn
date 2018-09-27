package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.phylo.PhyloAnnotation;
import saturn.client.programs.phylo.PhyloScreenData;
import saturn.client.programs.phylo.PhyloAnnotation.HasAnnotationType;
import saturn.client.programs.phylo.PhyloTreeNode;
import saturn.client.core.CommonCore;

class OrphanetAnnotation {

    public function new() {

    }

    static function divOrphanet(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){


            screenData.divAccessed=true;
            var al,auxtext:String;
            WorkspaceApplication.getApplication().debug("access db");
            al='orphanetDiv';auxtext='';
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{target : screenData.targetClean}, null, true, function(results: Dynamic, error){
                if(error == null) {

                    var ii:Int;
                    var ttext:String;
                    var geneid:String;
                    ttext="";geneid="";

                    for(ii in 0...results.length){
                        ttext=ttext+results[ii].disorder_gene_assoc_type+' '+results[ii].disorder_name+' ('+results[ii].disorder_gene_assoc_status+')<br><br>';
                        geneid=results[ii].geneid;
                    }

                    var t = '<style type="text/css">
                    .divMainDiv18 { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv18 a{ text-decoration:none!important;}
                    .divExtraInfo{padding:3px;widht:100%!important; font-size:10px; margin-top:5px; margin-bottom:5px;}

                    .orphanetResult{padding:3px 10px ;}
                    </style>
                    <div class="divMainDiv18">
                        <div class="divTitle"><a href="http://www.orpha.net/consor/cgi-bin/Disease_Genes.php?lng=EN&data_id='+geneid+'" target="_blank">'+screenData.target+'</a></div>
                        <div class="divContent">
                            <div class="divExtraInfo">Click title for Orphanet reference page</div>
                            <div class="orphanetResult">
                            '+ttext+'
                            </div>
                        </div>
                    </div>';       // here we'll create whatever we need for each annotation

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
