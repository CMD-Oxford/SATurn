package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.chromohub.ChromoHubAnnotation.HasAnnotationType;
import saturn.client.core.CommonCore;

class CancerAberrationAnnotation {

    public function new() {

    }

    static function divAberrationsCancer(screenData: ChromoHubScreenData,x:String,y:String,tree_type:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;



            var prog = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);
            if(screenData.annotation.dbData==null){ //it comes from annotation table div
                if(prog.treeName==''){
                    var leaf=prog.geneMap.get(screenData.target);
                    screenData.annotation.dbData=leaf.annotations[screenData.annot].dbData;
                }else{
                    var leaf=prog.rootNode.leafNameToNode.get(screenData.target);
                    screenData.annotation.dbData=leaf.annotations[screenData.annot].dbData;
                }
            }

            var t = '<style type="text/css">
                    .divMainDiv23 { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv23 a{ text-decoration:none!important;}
                    .divExtraInfo{padding:5px;widht:100%!important; font-size:10px; margin-top:5px;}

                    .interactionInfo{font-size:10px}
                    .interactionResult{padding:3px 10px ;}
                    </style>
                    <div class="divMainDiv23">
                    <div class="divTitle"><a href=\"http://cancer.sanger.ac.uk/cosmic/gene/overview?ln='+screenData.targetClean+'" target="_blank">
									Chromosomal aberrations ('+screenData.target+')</a>
									</div>
                    <div class="divContent">';

            if (screenData.annotation.dbData.tumor_type_somatic!=null) t+= '<b>Tumour types due to somatic aberrations:</b><br>'+screenData.annotation.dbData.tumor_type_somatic+'<br><br>';
            if (screenData.annotation.dbData.tumor_type_germline!=null) t+= '<b>Tumour types due to germline aberrations:</b><br>'+screenData.annotation.dbData.tumor_type_germline+'<br><br>';
            t+= '<b>Chromosomal aberration:</b><br>'+screenData.annotation.dbData.mutation_type+'<br><br>';
            if (screenData.annotation.dbData.translocation_partner!=null) t+= '<b>Translocation partner:</b><br>'+screenData.annotation.dbData.translocation_partner+'<br><br>';
            if (screenData.annotation.dbData.translocation_partner!=null) t+= '<b>Translocation partner:</b><br>'+screenData.annotation.dbData.translocation_partner+'<br><br>';
            if (screenData.annotation.dbData.other_germline_mutation!=null) t+= '<b>Other germline aberrations associated with:</b><br>'+screenData.annotation.dbData.other_disease+'<br><br>';

            t+= '</div>
                   <div class="divExtraInfo"><i>Click title for details</i></div>
                     </div>';

            callBack(t);
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }
}
