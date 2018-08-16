package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.chromohub.ChromoHubAnnotation.HasAnnotationType;
import saturn.client.core.CommonCore;

class AntibodyAnnotation {

    public function new() {

    }

    static function hasAntibodies(target: String, data: Dynamic, selected:Int,annotList:Array<ChromoHubAnnotation>, item:String, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'',used:true},defImage:0};
        r.text=data.variant_index;
    }

    static function hasAntibodiesFab(target: String, data: Dynamic, selected:Int,annotList:Array<ChromoHubAnnotation>, item:String, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: false, text:'',color:{color:'',used:true},defImage:0};
        if(data!=null){
            var alias="";
            var alias2="";
            alias="antiFab"; alias2="antiFabProduct";

            if(alias!="" && Reflect.hasField(data, 'variant_pkey')){
                WorkspaceApplication.getApplication().getProvider().getByNamedQuery(alias,{param : data.variant_pkey}, null, true, function(db_results, error){
                    if(error == null) {
                        if((db_results.length==0)) {
                            r.text="";
                            r.hasAnnot=false;

                            callBack(r);
                        }
                        else{
                            r.hasAnnot=true;
                            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(alias2,{param : data.variant_pkey}, null, true, function(db_results:Dynamic, error){
                                if(error == null) {
                                    var htmlText='';
                                    if(db_results.length!=0) {
                                        htmlText="Products available <br>";
                                        var i=0;
                                        for(i in 0...db_results.length){
                                            htmlText=htmlText+"<a href='https://products.invitrogen.com/ivgn/product/"+db_results[i].fab_product+"' target='_blank'>IgG Product</a><br>";
                                        }
                                        r.text=htmlText;
                                        r.defImage=1;

                                    }
                                    else{
                                        r.text=htmlText;
                                    }
                                }
                                else {
                                    WorkspaceApplication.getApplication().debug(error);
                                }

                                callBack(r);
                            });
                        }
                    }
                    else {
                        WorkspaceApplication.getApplication().debug(error);
                    }
                });
            }
            else {
                callBack(r);
            }
        }
    }

    static function hasAntibodiesIgg(target: String, data: Dynamic, selected:Int,annotList:Array<ChromoHubAnnotation>, item:String, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: false, text:'',color:{color:'',used:true},defImage:0};
        if(data!=null){
            var alias="";
            var alias2="";
            alias="antiIgg"; alias2="antiIggProduct";

            if(alias!="" && Reflect.hasField(data, 'variant_pkey')){
                WorkspaceApplication.getApplication().getProvider().getByNamedQuery(alias,{param : data.variant_pkey}, null, true, function(db_results, error){
                    if(error == null) {
                        if((db_results.length==0)) {
                            r.text="";
                            r.hasAnnot=false;

                            callBack(r);
                        }
                        else{
                            r.hasAnnot=true;
                            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(alias2,{param : data.variant_pkey}, null, true, function(db_results:Dynamic, error){
                                if(error == null) {
                                    var htmlText='';
                                    if(db_results.length!=0) {
                                        htmlText="Products available <br>";
                                        var i=0;
                                        for(i in 0...db_results.length){
                                            htmlText=htmlText+"<a href='https://products.invitrogen.com/ivgn/product/"+db_results[i].igg_product+"' target='_blank'>IgG Product</a><br>";
                                        }
                                        r.text=htmlText;
                                        r.defImage=1;

                                    }
                                    else{
                                        r.text=htmlText;
                                    }
                                }
                                else {
                                    WorkspaceApplication.getApplication().debug(error);
                                }

                                callBack(r);
                            });
                        }

                    }
                    else {
                        WorkspaceApplication.getApplication().debug(error);
                    }
                });
            }
            else {
                callBack(r);
            }
        }
    }

    static function divAntibodies(screenData: ChromoHubScreenData,x:String,y:String,tree_type:String, callBack : Dynamic->Void){


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

            var al,auxtext,end:String;
            auxtext='';end='';
            al='antigen_images';auxtext='Antigen';


            var name:String;
            if (screenData.target.indexOf('(')!=-1) name=screenData.targetClean;
            else if (screenData.target.indexOf('-')!=-1) name=screenData.targetClean;
            else name=screenData.target;


            var fam='';
            var prog = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);
            if(prog.treeName!='') fam=prog.treeName;
            else{
                //the first family domain the target belong to, will be use as targetFamily. And it is stored in the leaf.targetFamily

                var leafaux:ChromoHubTreeNode;
                leafaux=prog.geneMap.get(screenData.targetClean);
                fam=leafaux.targetFamilyGene[0];
            }
            var imgSrc='';
            var num='-1';
            var dom='';
            if(tree_type=='domain'){
                if (screenData.target.indexOf('(')!=-1 || screenData.target.indexOf('-')!=-1){
                    var auxArray=screenData.target.split('');
                    var j:Int;
                    for(j in 0...auxArray.length){
                        if(auxArray[j]=='(') num+='_'+auxArray[j+1];
                        if(auxArray[j]=='-') num='-'+auxArray[j+1];
                    }
                }
                imgSrc=al+'/'+name+num+'_'+fam+'_DOMAIN'+end;
                dom='_domain';
            } else{
                imgSrc=al+'/'+name+num+'_'+fam+end;
                dom='';
            }


            var mapp='';



            CommonCore.getContent('http://apps.thesgc.org/resources/phylogenetic_trees/'+imgSrc+'.txt',function(filetext){
                mapp=filetext;

                var t = '<style type="text/css">
                    .divMainDiv12 { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv12 a{ text-decoration:none!important;}

                    .antibodiesInfo{font-size:10px}
                    .antibodiesResult{padding:3px 10px ;}
                    </style>
                    <div class="divMainDiv12">
                    <div class="divTitle">'+auxtext+' ('+screenData.target+')</div>
                    <div class="divContent">
                    <img  onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/'+imgSrc+'.png" usemap="#antigen_'+name+num+dom+'"><br>'+filetext+'
                    </div></div>
                ';
                //WorkspaceApplication.getApplication().debug(t);
                callBack(t);

            }, function(failmessage){
                WorkspaceApplication.getApplication().debug('Image map couldn\'t be accessed.');
                //If we have any problem with getting the image map, we show the image without hover functionality
                var t = '<style type="text/css">
                    .divMainDiv12 { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv12 a{ text-decoration:none!important;}

                    .antibodiesInfo{font-size:10px}
                    .antibodiesResult{padding:3px 10px ;}
                    </style>
                    <div class="divMainDiv12">
                    <div class="divTitle">'+auxtext+' ('+screenData.target+')</div>
                    <div class="divContent">
                    <img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/'+imgSrc+'.png"><br>
                    </div></div>
                ';
                // WorkspaceApplication.getApplication().debug(t);

                callBack(t);
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }

    static function divAntibodiesFabs(screenData: ChromoHubScreenData,x:String,y:String,tree_type:String, callBack : Dynamic->Void){

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

            var al,auxtext,end:String;
            auxtext='';
            al='fab_images';auxtext='FAb';end='_any_pub';

            var name:String;
            if (screenData.target.indexOf('(')!=-1) name=screenData.targetClean;
            else name=screenData.target;


            var fam='';
            var prog = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);
            if(prog.treeName!='') fam=prog.treeName;
            else{
                //the first family domain the target belong to, will be use as targetFamily. And it is stored in the leaf.targetFamily

                var leafaux:ChromoHubTreeNode;
                leafaux=prog.geneMap.get(screenData.targetClean);
                fam=leafaux.targetFamilyGene[0];
            }
            var imgSrc='';
            var num='-1';
            var dom='';
            if(tree_type=='domain'){
                if (screenData.target.indexOf('(')!=-1){
                    var auxArray=screenData.target.split('');
                    var j:Int;
                    for(j in 0...auxArray.length){
                        if(auxArray[j]=='(') num+='_'+auxArray[j+1];
                    }
                }
                else if (screenData.target.indexOf('-')!=-1) num='';
                imgSrc=al+'/'+name+num+'_'+fam+'_DOMAIN'+end;
                dom='_domain';
            } else{
                imgSrc=al+'/'+name+num+'_'+fam+end;
                dom='';
            }

            var products='';
            //check if there are products available
            if(screenData.annotation.text!=''){
                products="<div class='divProduct'>"+screenData.annotation.text+"</div>";
            }

            var mapp='';
            CommonCore.getContent('/static/resources/fab_images/'+name+num+'_'+fam+end+'_0.txt',function(filetext){
                mapp=filetext;
                var t = '<style type="text/css">
                            .divMainDiv13 { }
                            .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                            .divContent{padding:5px;widht:100%!important;}
                            .divMainDiv13 a{ text-decoration:none!important;}
                            .divProduct {}

                            .antibodiesInfo{font-size:10px}
                            .antibodiesResult{padding:3px 10px ;}
                            </style>
                            <div class="divMainDiv13">
                            <div class="divTitle">'+auxtext+' ('+screenData.target+')</div>'
                +products+'
                            <div class="divContent">
                            <img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/'+imgSrc+'.png" usemap="#fab_'+name+num+'"><br>'+filetext+'
                            </div></div>
                        ';

                callBack(t);

            }, function(failmessage){
                WorkspaceApplication.getApplication().debug('Image map couldn\'t be accessed.');
                //If we have any problem with getting the image map, we show the image without hover functionality
                var t = '<style type="text/css">
                            .divMainDiv13 { }
                            .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                            .divContent{padding:5px;widht:100%!important;}
                            .divMainDiv13 a{ text-decoration:none!important;}
                            .divProduct {}

                            .antibodiesInfo{font-size:10px}
                            .antibodiesResult{padding:3px 10px ;}
                            </style>
                            <div class="divMainDiv13">
                            <div class="divTitle">'+auxtext+' ('+screenData.target+')</div>'
                +products+'
                            <div class="divContent">
                            <img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/'+imgSrc+'.png"><br>
                            </div></div>
                        ';

                callBack(t);
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }

    static function divAntibodiesIgg(screenData: ChromoHubScreenData,x:String,y:String,tree_type:String, callBack : Dynamic->Void){


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

            var al,auxtext,end:String;
            auxtext='';
            al='igg_images';auxtext='IgG';end='_any_pub';

            var name:String;
            if (screenData.target.indexOf('(')!=-1) name=screenData.targetClean;
            else name=screenData.target;


            var fam='';
            var prog = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);
            if(prog.treeName!='') fam=prog.treeName;
            else{
                //the first family domain the target belong to, will be use as targetFamily. And it is stored in the leaf.targetFamily

                var leafaux:ChromoHubTreeNode;
                leafaux=prog.geneMap.get(screenData.targetClean);
                fam=leafaux.targetFamilyGene[0];
            }
            var imgSrc='';
            var num='-1';
            var dom='';
            if(tree_type=='domain'){
                if (screenData.target.indexOf('(')!=-1){
                    var auxArray=screenData.target.split('');
                    var j:Int;
                    for(j in 0...auxArray.length){
                        if(auxArray[j]=='(') num+='_'+auxArray[j+1];
                    }
                }
                else if (screenData.target.indexOf('-')!=-1) num='';
                imgSrc=al+'/'+name+num+'_'+fam+'_DOMAIN'+end;
                dom='_domain';
            } else{
                imgSrc=al+'/'+name+num+'_'+fam+end;
            }

            var products='';
            //check if there are products available
            if(screenData.annotation.text!=''){
                products="<div class='divProduct'>"+screenData.annotation.text+"</div>";
            }



            var mapp='';
            CommonCore.getContent('/static/resources/'+imgSrc+'_0.txt',function(filetext){
                mapp=filetext;
                var t = '<style type="text/css">
                        .divMainDiv14 { }
                        .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                        .divContent{padding:5px;widht:100%!important;}
                        .divMainDiv14 a{ text-decoration:none!important;}
                        .divProduct {}

                        .antibodiesInfo{font-size:10px}
                        .antibodiesResult{padding:3px 10px ;}
                        </style>
                        <div class="divMainDiv14">
                        <div class="divTitle">'+auxtext+' ('+screenData.target+')</div>'
                +products+'
                        <div class="divContent">
                        <img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/'+imgSrc+'.png" usemap="#igg_'+name+num+dom+'"><br>'+filetext+'
                        </div></div>
                    ';
                callBack(t);
            }, function(failmessage){
                WorkspaceApplication.getApplication().debug('Image map couldn\'t be accessed.');
                //If we have any problem with getting the image map, we show the image without hover functionality
                var t = '<style type="text/css">
                        .divMainDiv14 { }
                        .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                        .divContent{padding:5px;widht:100%!important;}
                        .divMainDiv14 a{ text-decoration:none!important;}
                        .divProduct {}

                        .antibodiesInfo{font-size:10px}
                        .antibodiesResult{padding:3px 10px ;}
                        </style>
                        <div class="divMainDiv14">
                        <div class="divTitle">'+auxtext+' ('+screenData.target+')</div>'
                +products+'
                        <div class="divContent">
                        <img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/'+imgSrc+'.png"><br>
                        </div></div>
                    ';

                callBack(t);
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }
}
