package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.phylo.PhyloAnnotation;
import saturn.client.programs.phylo.PhyloScreenData;
import saturn.client.programs.phylo.PhyloAnnotation.HasAnnotationType;
import saturn.client.programs.phylo.PhyloTreeNode;
import saturn.client.core.CommonCore;

class SubstrateAnnotation {

    public function new() {

    }

    static function hasSubstrate(target: String, data: Dynamic, selected:Int, annotList:Array<PhyloAnnotation>, item:String, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:data.sub,color:{color:'',used:false},defImage:100};
        if(data!=null){
            if(Reflect.hasField(data, 'sub')){
                var res=annotList[4].auxMap.exists(data.sub);

                if(res==true){
                    var c=annotList[4].auxMap.get(data.sub);
                    r.color={color:c,used:true};
                }
                else{
                    var k:Int;
                    var c:String;
                    for (k in 0... annotList[4].color.length){
                        var g=annotList[4].color[k].used;
                        if (g==false) {
                            c=annotList[4].color[k].color;
                            annotList[4].color[k].used=true;
                            annotList[4].auxMap.set(data.sub,c);//auxMAp should be a ChromoHubViewer variable not in rootNode
                            r.color={color:c,used:true};
                            break;
                        }
                    }
                }

                callBack(r);
            }
        }
    }

    static function divSubstrate(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;


            var al,auxtext:String;

            al='substrateDiv';auxtext='';
            var prog = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);

            if(screenData.annotation.text==''){ //it comes from annotation table div
                if(prog.treeName==''){
                    var leaf=prog.geneMap.get(screenData.target);
                    screenData.annotation.text=leaf.annotations[screenData.annot].text;
                }else{
                    var leaf=prog.rootNode.leafNameToNode.get(screenData.target);
                    screenData.annotation.text=leaf.annotations[screenData.annot].text;
                }
            }


            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{target : screenData.targetClean, subb: screenData.annotation.text}, null, true, function(results: Dynamic, error){
                if(error == null) {

                    var ii:Int;
                    var ttext:String;
                    var subs:String;
                    ttext="Pubmed Ids: <br>";subs="";

                    for(ii in 0...results.length){
                        ttext=ttext+'<a href="http://www.ncbi.nlm.nih.gov/pubmed/'+results[ii].pmid_list+'" target="_blank">'+results[ii].pmid_list+'</a><br><br>';
                        subs=results[ii].sub;
                        break;
                    }

                    var t = '<style type="text/css">
                    .divMainDiv15 { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv15 a{ text-decoration:none!important;}

                    .substrateResult{padding:3px 10px ;}
                    </style>
                    <div class="divMainDiv15">
                    <div class="divTitle">'+screenData.target+' ('+subs+')</div>
                    <div class="divContent">
                    <div class="substrateResult">
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
