package saturn.client.programs.chromohub.annotations;

import phylo.PhyloScreenData;
import phylo.PhyloAnnotation.HasAnnotationType;
import phylo.PhyloAnnotation;
import saturn.client.core.CommonCore;

class DomainAnnotation {
    public function new() {

    }

    static function hasDomain(target: String, data: Dynamic, selected:Int,annotList:Array<PhyloAnnotation>, item:String, cb : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'#2980d6',used:true},defImage:0};
        cb(r);
    }

    static function divDomain(screenData: PhyloScreenData,x:String,y:String,tree_type:String, callBack : Dynamic->Void){
        //ProteinSubFamilyAnnotation.divSubFamily(screenData, x, y, tree_type, callBack);

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

            var name:String;
            if (screenData.target.indexOf('(')!=-1) name=screenData.targetClean;
            else if (screenData.target.indexOf('-')!=-1) name=screenData.targetClean;
            else name=screenData.target;
            trace('Family:');

            var genePlusFamily = screenData.target + '_' + screenData.family  +  '.png';
            var path = '/static/pfam_images/' + genePlusFamily;
            var imgSrc = '<img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="' + path + '" usemap=\"#arch_' + screenData.target + '" />';

            var mapp='';
            CommonCore.getContent('/static/pfam_images/' + screenData.family + '/' + screenData.target + '.txt',function(filetext){
                mapp = '<map name="#arch_' + screenData.target + '">'+ filetext + '</map>';

                var t = '<style type="text/css">
                    .divMainDiv7  { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}div
                    .divMainDiv7  a{ text-decoration:none!important;}
                    .divExtraInfo{padding:5px; widht:100%!important; font-size:10px; margin-top:5px;}

                    .structureResult{padding:3px 10px ;}
                    </style>
                    <div class="divMainDiv7 ">
                    <div class="divTitle">Domain Architecture  - '+screenData.target+'</div>
                    <div class="divContent">'
                + imgSrc + mapp +
                '</div>
                ';
                callBack(t);
            });
        }
    }

    static function familyDomain(targetFamily: String,tree_type:String,callBack : Dynamic->Void){
        var aux="";
        if(tree_type=='domain') aux="_DOMAIN";


        var re_replaceIds =~/id="pfam_(\w+)\((\d+)\)"/g;

        var mapp='';
        CommonCore.getContent('/static/resources/static_text_files/'+targetFamily+aux+'.txt',function(filetext){
            mapp=filetext;

            mapp = re_replaceIds.replace(mapp, 'id="pfam_$1__$2__"');

            var jsfunctions ='
            <style type="text/css">
                .xstooltip {display: none;z-index: 5; border: solid 1px; background-color: white; border: 1px solid green;}
            </style>

            ';
            var imageUrl = '<img class="pfam_pic" src="http://apps.thesgc.org/resources/phylogenetic_trees/static_images/'+targetFamily+aux+'_tree.png"'+' usemap="#treeMap" />';

            var t = '<style type="text/css">
                    .divMainDiv33 { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv33 a{ text-decoration:none!important;}
                    .divExtraInfo{padding:5px;widht:100%!important; font-size:10px; margin-top:5px;}

                    .interactionInfo{font-size:10px}
                    .interactionResult{padding:3px 10px ;}
                    </style>'+jsfunctions+mapp+'
                    <div class="divMainDiv33">
                        <div class="divTitle">Domain Architecture for '+targetFamily+'</div>
                        <div class="divContent">'+imageUrl+'</div>
                    </div>';

            callBack(t);

        }, function(failmessage){
            WorkspaceApplication.getApplication().debug('Image map couldn\'t be accessed.');
            var jsfunctions ='
            <style type="text/css">
                .xstooltip {display: none;z-index: 5; border: solid 1px; background-color: white; border: 1px solid green;}
            </style>

            ';
            var imageUrl = '<img class="pfam_pic" src="http://apps.thesgc.org/resources/phylogenetic_trees/static_images/'+targetFamily+aux+'_tree.png"'+' usemap="#treeMap" />';

            var t = '<style type="text/css">
                    .divMainDiv33 { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv33 a{ text-decoration:none!important;}
                    .divExtraInfo{padding:5px;widht:100%!important; font-size:10px; margin-top:5px;}

                    .interactionInfo{font-size:10px}
                    .interactionResult{padding:3px 10px ;}
                    </style>'+jsfunctions+'
                    <div class="divMainDiv33">
                        <div class="divTitle">Domain Architecture for '+targetFamily+'</div>
                        <div class="divContent">'+imageUrl+'</div>
                    </div>';
            callBack(t);
        });
    }

    static function familyDomaintable(screenData: PhyloScreenData,x:String,y:String,targetFamily:String,tree_type:String, callBack : Dynamic->Void){
        if(screenData.divAccessed==false){
            screenData.divAccessed=true;

            var aux="";
            if(tree_type=='domain') aux="_DOMAIN";
            var mapp='';
            CommonCore.getContent('/static/resources/static_text_files/'+targetFamily+aux+'.txt',function(filetext){
                mapp=filetext;


                var t = '<style type="text/css">
                    .divMainDiv44 { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv44 a{ text-decoration:none!important;}
                    .divExtraInfo{padding:5px;widht:100%!important; font-size:10px; margin-top:5px;}

                    .interactionInfo{font-size:10px}
                    .interactionResult{padding:3px 10px ;}
                    </style>
                     <style type="text/css">
                        .xstooltip {display: none;z-index: 5; border: solid 1px; background-color: white; border: 1px solid green;}
                    </style>
                    <div class="divMainDiv44">
                        <div class="divTitle">Domain Architecture</div>
                        <div class="divContent">
                            <img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/static_images/'+targetFamily+aux+'_tree.png" usemap="#treemap"><br>'+filetext;

                t+='</div>
                    </div>';
                callBack(t);

            }, function(failmessage){
                WorkspaceApplication.getApplication().debug('Image map couldn\'t be accessed.');


                var t = '<style type="text/css">
                    .divMainDiv44 { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv44 a{ text-decoration:none!important;}
                    .divExtraInfo{padding:5px;widht:100%!important; font-size:10px; margin-top:5px;}

                    .interactionInfo{font-size:10px}
                    .interactionResult{padding:3px 10px ;}
                    </style>
                    <div class="divMainDiv44">
                        <div class="divTitle">Domain Architecture</div>
                        <div class="divContent">
                            <img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/static_images/'+targetFamily+aux+'_tree.png"><br>';

                t+='</div>
                    </div>';
                callBack(t);
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }
}
