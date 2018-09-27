package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.phylo.PhyloAnnotation;
import saturn.client.programs.phylo.PhyloScreenData;
import saturn.client.programs.phylo.PhyloAnnotation.HasAnnotationType;
import saturn.client.programs.phylo.PhyloTreeNode;
import saturn.client.core.CommonCore;

class GeneFusionAnnotation {

    public function new() {

    }

    static function hasGeneFusions(target: String, data: Dynamic, selected:Int, annotList:Array<PhyloAnnotation>, item:String, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:''+data.count+'',color:{color:'#2492c6',used:false},defImage:100};

        callBack(r);

    }

    static function divGeneFusions(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;



            var t = '<style type="text/css">
                    .divMainDiv20 { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv20 a{ text-decoration:none!important;}

                    .interactionInfo{font-size:10px}
                    .interactionResult{padding:3px 10px ;}
                    </style>
                    <div class="divMainDiv20">
                    <div class="divTitle">'+screenData.target+' - Gene Fusions in Cancer</div>
                    <div class="divContent">
                    Access to '+screenData.annotation.text+' Articles <a href="http://apps.thesgc.org/resources/phylogenetic_trees/gene_fusion.php?tid='+screenData.targetClean+'" target="_blank">here</a><br>

                    </div></div>
                ';
            callBack(t);
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }
}
