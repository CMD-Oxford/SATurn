package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.phylo.PhyloAnnotation;
import saturn.client.programs.phylo.PhyloScreenData;
import saturn.client.programs.phylo.PhyloAnnotation.HasAnnotationType;
import saturn.client.programs.phylo.PhyloTreeNode;
import saturn.client.core.CommonCore;

class InteractionAnnotation {

    public function new() {

    }

    static function divInteraction(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){

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

            var t = '<style type="text/css">
                    .divMainDiv6  { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv6  a{ text-decoration:none!important;}

                    .interactionInfo{font-size:10px}
                    .interactionResult{padding:3px 10px ;}
                    </style>
                    <div class="divMainDiv6 ">
                    <div class="divTitle">Protein Interaction ('+screenData.target+')</div>
                    <div class="divContent">
                    <img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/interaction/'+screenData.targetClean+'.png"><br>
                    <span class="interactionInfo">Image Source: http://string-db.org</span>
                    </div></div>
                ';

            callBack(t);
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }
}
