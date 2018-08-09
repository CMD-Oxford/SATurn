package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.chromohub.ChromoHubAnnotation.HasAnnotationType;
import saturn.client.core.CommonCore;

class FundingAnnotation {

    public function new() {

    }

    static function hasFunding(target: String, data: Dynamic, selected:Int,annotList:Array<ChromoHubAnnotation>, item:String, callBack : HasAnnotationType->Void){

        var r : HasAnnotationType = {hasAnnot: false, text:'',color:{color:'',used:false},defImage:100};

        if(data!=null){
            if(Reflect.hasField(data, 'funds')){
                if (data.funds > 15000000){
                    r.text="$$$";
                    r.color={color:'#f60808',used:true};
                    r.hasAnnot= true;
                }
                else if (data.funds > 5000000){
                    r.text="$$";
                    r.color={color:'#f69908',used:true};
                    r.hasAnnot= true;
                }
                else if (data.funds > 500000) {
                    r.text="$";
                    r.color={color:'#085cf6',used:true};
                    r.hasAnnot= true;
                    r.hasAnnot= true;
                }

                callBack(r);
            }
        }
    }

    static function divFunding(screenData: ChromoHubScreenData,x:String,y:String,tree_type:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){

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
            screenData.divAccessed=true;
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery('fundSyn',{target : screenData.targetClean}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var syn='';
                    if(results.length!=0){
                        syn=' (a.k.a';
                    }
                    for(i in 0... results.length){
                        syn=syn+' '+results[i].synonym_id;
                    }
                    if(results.length!=0){
                        syn=syn+')';
                    }


                    CommonCore.getContent('/static/resources/funding_pub_images/'+screenData.targetClean+'_all.txt',function(filetext){
                        var mapp=filetext;

                        var t = '<style type="text/css">
                            .divMainDiv3  { }
                            .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                            .divContent{padding:5px;}
                            .divMainDiv3  a{ text-decoration:none!important;}

                            .interactionInfo{font-size:10px}
                            .interactionResult{padding:3px 10px ;}
                            </style>
                            <div class="divMainDiv3 ">
                            <div class="divTitle">Funding/Pubmed: '+screenData.targetClean+' '+syn+'</div>
                            <div class="divContent">
                            <img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/funding_pub_images/'+screenData.targetClean+'_all.png" usemap="#funding_pub_'+screenData.targetClean+'_all"><br>'+filetext+'
                            </div></div>
                        ';

                        callBack(t);


                    }, function(failmessage){
                        WorkspaceApplication.getApplication().debug('Image map couldn\'t be accessed.');
//If we have any problem with getting the image map, we show the image without hover functionality
                        var t = '<style type="text/css">
                            .divMainDiv3  { }
                            .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                            .divContent{padding:5px;}
                            .divMainDiv3  a{ text-decoration:none!important;}

                            .interactionInfo{font-size:10px}
                            .interactionResult{padding:3px 10px ;}
                            </style>
                            <div class="divMainDiv3 ">
                            <div class="divTitle">Funding/Pubmed: '+screenData.targetClean+' '+syn+'</div>
                            <div class="divContent">
                            <img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/funding_pub_images/'+screenData.targetClean+'_all.png"><br>
                            </div></div>
                        ';

                        callBack(t);
                    });
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
