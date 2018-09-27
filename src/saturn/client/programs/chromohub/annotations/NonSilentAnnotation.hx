package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.phylo.PhyloAnnotation;
import saturn.client.programs.phylo.PhyloScreenData;
import saturn.client.programs.phylo.PhyloAnnotation.HasAnnotationType;
import saturn.client.programs.phylo.PhyloTreeNode;
import saturn.client.core.CommonCore;

class NonSilentAnnotation {

    public function new() {

    }

    static function hasNonSilent(target: String, data: Dynamic, selected:Int, annotList:Array<PhyloAnnotation>, item:String, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: false, text:'',color:{color:'#2492c6',used:true},defImage:100};

        if(data!=null){
            if(Reflect.hasField(data, 'uniprot') && Reflect.hasField(data, 'variant_pkey')){

                WorkspaceApplication.getApplication().getProvider().getByNamedQuery("nonSilentSPNsPoly",{uniprot : data.uniprot, pkey: data.variant_pkey}, null, true, function(db_results, error){
                    if(error == null) {
                        if((db_results[0].num_total==null)||(db_results[0].num_total=='0')) {

                            r.text="";
                            r.hasAnnot=false;
                        }
                        else{
                            r.text=''+db_results[0].num_total+'';
                            r.hasAnnot=true;
                            if((db_results[0].is_disease=='Disease')&&(db_results[0].num_dom!=0)) r.color={color:'#9026b3',used:true};
                            else if (db_results[0].is_disease=='Disease') r.color={color:'#e60841',used:true};
                            else if (db_results[0].num_dom!=0) r.color={color:'#06fff7',used:true};
                            else r.color={color:'#000000',used:true};
                        }
                        callBack(r);
                    }
                    else {
                        WorkspaceApplication.getApplication().debug(error);
                    }
                });

            };

        }

    }

    static function divNonSilent(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){

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

            var name:String;
            if (screenData.target.indexOf('(')!=-1) name=screenData.target;
            else name=screenData.targetClean;

            var imgSrc='';
            var num='-1';
            var dom='';

            var family='';
            var prog = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);
            if(prog.treeName!='') family=prog.treeName;
            else{
                //the first family domain the target belong to, will be use as targetFamily. And it is stored in the leaf.targetFamily

                var leafaux:PhyloTreeNode;
                leafaux=prog.geneMap.get(screenData.targetClean);
                family=leafaux.targetFamilyGene[0];

            }
            if(tree_type=='domain'){
                if (screenData.target.indexOf('(')!=-1){
                    var auxArray=screenData.target.split('');
                    var j:Int;
                    for(j in 0...auxArray.length){
                        if(auxArray[j]=='(') num+='_'+auxArray[j+1];
                    }
                }
                imgSrc=family+'_DOMAIN/'+screenData.targetClean+num+'_'+family+'_DOMAIN.png';
                dom="_DOMAIN";
            } else{
                imgSrc=family+'/'+screenData.targetClean+'-1_'+family+'.png';
            }

            screenData.divAccessed=true;


            //CommonCore.getContent('/static/annot/'+screenData.root.targetFamily+'.txt',function(filetext){
            CommonCore.getContent('/static/resources/polymorphism_images/'+family+dom+'/'+screenData.targetClean+num+'_'+family+dom+'.txt',function(filetext){
                var mapp=filetext;

                var t = '<style type="text/css">
                    .divMainDiv5  { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;}
                    .divMainDiv5  a{ text-decoration:none!important;}

                    .interactionInfo{font-size:10px}
                    .interactionResult{padding:3px 10px ;}
                    </style>
                    <div class="divMainDiv5 ">
                    <div class="divTitle">Non-silent SNPs ('+name+')</div>
                    <div class="divContent">
                    <img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/polymorphism_images/'+imgSrc+'" usemap="#poly_'+name+num+'"><br>'+filetext+'
                    </div></div>
                ';

                callBack(t);


            }, function(failmessage){
                WorkspaceApplication.getApplication().debug('Image map couldn\'t be accessed.');
//If we have any problem with getting the image map, we show the image without hover functionality
                var t = '<style type="text/css">
                    .divMainDiv5  { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;}
                    .divMainDiv5  a{ text-decoration:none!important;}

                    .interactionInfo{font-size:10px}
                    .interactionResult{padding:3px 10px ;}
                    </style>
                    <div class="divMainDiv5 ">
                    <div class="divTitle">Non-silent SNPs ('+name+')</div>
                    <div class="divContent">
                    <img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/polymorphism_images/'+imgSrc+'"><br>
                    </div></div>
                ';

                callBack(t);
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }
}
