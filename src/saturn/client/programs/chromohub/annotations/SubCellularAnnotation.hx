package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.phylo.PhyloAnnotation;
import saturn.client.programs.phylo.PhyloScreenData;
import saturn.client.programs.phylo.PhyloAnnotation.HasAnnotationType;
import saturn.client.programs.phylo.PhyloTreeNode;
import saturn.client.core.CommonCore;

class SubCellularAnnotation {

    public function new() {

    }

    static function hasSubcellular(target: String, data: Dynamic, selected:Int, annotList:Array<PhyloAnnotation>, item:String, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'',used:false},defImage:100};


        if(data!=null){
            if(Reflect.hasField(data, 'location') ){
                if (data.location.indexOf('Nucleus')!=-1){
                    if (data.location.indexOf('Cytoplasm')!=-1){
                        r.defImage=2;
                    }
                    else{
                        r.defImage=0;
                    }
                }
                else r.defImage=1;

                callBack(r);
            }
        }
    }

    static function divSubcellular(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;


            var al,auxtext:String;
            WorkspaceApplication.getApplication().debug("access db");
            al='subcellularDiv';auxtext='';
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{target : screenData.targetClean}, null, true, function(results: Dynamic, error){
                if(error == null) {

                    var ii:Int;
                    var ttext:String;
                    var subs:String;
                    ttext=results[0].location+'<br>';


                    var t = '<style type="text/css">
                            .divMainDiv16 { }
                            .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                            .divContent{padding:5px;widht:100%!important;}
                            .divMainDiv16 a{ text-decoration:none!important;}
                            .divExtraInfo{padding:5px;widht:100%!important; font-size:10px; margin-top:5px;}
                            .subcellularResult{padding:3px 10px;}
                            </style>
                            <div class="divMainDiv16">
                            <div class="divTitle">'+'<a href="http://www.uniprot.org/uniprot/'+results[0].uniprot+'" target="_blank">'+screenData.target+'</a></div>
                            <div class="divContent">
                            <div class="subcellularResult">
                            '+ttext+'
                            </div></div>
                            <div class="divExtraInfo">Click title for Uniprot reference page</div>
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
