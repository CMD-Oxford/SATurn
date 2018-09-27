package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.phylo.PhyloAnnotation;
import saturn.client.programs.phylo.PhyloScreenData;
import saturn.client.programs.phylo.PhyloAnnotation.HasAnnotationType;
import saturn.client.programs.phylo.PhyloTreeNode;
import saturn.client.core.CommonCore;

class SummaryAnnotation {

    public function new() {

    }

    static function divSummary(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;


            var al,auxtext:String;
            WorkspaceApplication.getApplication().debug("access db");
            al='summaryDiv';auxtext='';
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{target : screenData.targetClean}, null, true, function(results: Dynamic, error){
                if(error == null) {

                    var ii:Int;
                    var ttext:String;
                    var uniprot:String;
                    ttext="";uniprot="";

                    for(ii in 0...results.length){
                        ttext=ttext+results[ii].fun+'<br><br>';
                        uniprot=results[ii].uniprot;
                    }
                    if((ttext=='null<br><br>')||(ttext=='<br><br>')) ttext="No Summary Available";


                    var t = '<style type="text/css">
                    .divMainDiv9  { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv9  a{ text-decoration:none!important;}
                    .divExtraInfo{padding:5px;widht:100%!important; font-size:10px; margin-top:5px;}

                    .summaryResult{padding:3px 10px ;}
                    </style>
                    <div class="divMainDiv9 ">
                    <div class="divTitle"><a href="http://www.uniprot.org/uniprot/'+uniprot+'" target="_blank">'+screenData.target+'</a></div>
                    <div class="divContent">
                    <div class="summaryResult">
                    '+ttext+'
                    </div>
                    </div>
                    <div class="divExtraInfo">Click title for Uniprot reference page</div>
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
