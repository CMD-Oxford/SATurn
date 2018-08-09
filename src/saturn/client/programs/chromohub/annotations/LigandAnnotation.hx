package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.chromohub.ChromoHubAnnotation.HasAnnotationType;
import saturn.client.programs.chromohub.ChromoHubAnnotationMethods.LigandType;
import saturn.client.programs.chromohub.ChromoHubAnnotationMethods.PdbType;
import saturn.client.core.CommonCore;

class LigandAnnotation {

    public function new() {

    }

    static function hasLigands(target: String, data: Dynamic, selected:Int,annotList:Array<ChromoHubAnnotation>, item:String, callBack : HasAnnotationType->Void){
        if(data!=null){
            if(Reflect.hasField(data, 'variant_pkey')){
                var r : HasAnnotationType = {hasAnnot: true, text:data.variant_pkey,color:{color:'#68229d',used:true},defImage:100};
                callBack(r);
            }
        }
    }

    static function divLigands(screenData: ChromoHubScreenData,x:String,y:String,tree_type:String, callBack : Dynamic->Void){


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
            var al,auxtext:String;

            al='';
            switch(screenData.suboption){
                case 1:al='ligands95Div';
                case 2:al='ligands95BestDiv';
                case 3:al='ligands40Div';
                default: al='ligands95Div';
            }

            auxtext='';
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
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{pkey : screenData.annotation.text}, null, true, function(results: Dynamic, error){
                if(error == null) {

                    var ii:Int;
                    var ttext:String;
                    ttext="";

                    var k:Int;
                    var myArray: Array<LigandType>;
                    var keyArray: Array<Int>;
                    myArray=new Array();
                    keyArray=new Array();
                    var kt=0; var pdbi=0;
                    ii=0;
                    for(ii in 0...results.length){
                        k=results[ii].lig_pkey;
                        if(myArray[k]==null){
                            keyArray[kt]=k; //we need to save the list of pkeys used
                            kt++;
                            myArray[k] = {
                                pkey:results[ii].lig_pkey,
                                id:results[ii].lig_id,
                                formula:results[ii].lig_formula,
                                name:results[ii].lig_name,
                                title:results[ii].title,
                                pdbs:new Array(),
                                pdb:new Map()
                            }
                            pdbi=0;
                            myArray[k].pdbs[pdbi]=results[ii].pdb_id; pdbi++;
                            var h:PdbType;
                            h={percent:results[ii].percent_id,title:results[ii].title};
                            myArray[k].pdb.set(results[ii].pdb_id,h);
                        }
                        if(myArray[k].pdb.exists(results[ii].pdb_id)==false) {
                            var h:PdbType;
                            h={percent:results[ii].percent_id,title:results[ii].title};
                            myArray[k].pdb.set(results[ii].pdb_id,h);
                            myArray[k].pdbs[pdbi]=results[ii].pdb_id; pdbi++;
                        }
                        else {
                            var pd=myArray[k].pdb.get(results[ii].pdb_id);
                            var per:Int;
                            per=pd.percent;
                            var h:PdbType;
                            h={percent:results[ii].percent_id,title:results[ii].title};
                            if (results[ii].percent_id>per) myArray[k].pdb.set(results[ii].pdb_id,h);
                        }
                    }
                    var lig:Dynamic;



                    for(kt in 0...keyArray.length){
                        var a=keyArray[kt];
                        ttext=ttext+'<div class="ligandRes"><img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/pdb_ligand_images/'+myArray[a].id+'.gif" width="200px"><br>
                        '+myArray[a].id+'<br>structures:';

                        for(pdbi in 0...myArray[a].pdbs.length){
                            var pdbb=myArray[a].pdb.get(myArray[a].pdbs[pdbi]);
                            var tit=pdbb.title;
                            var cent=pdbb.percent;

                            ttext=ttext+'<a href="http://www.rcsb.org/pdb/explore/explore.do?structureId='+myArray[a].pdbs[pdbi]+'" alt="'+tit+'" target="_blank">'+myArray[a].pdbs[pdbi]+'</a>('+cent+'%) - ';
                        }
                        ttext=ttext+'</div>';
                    }

                    var t = '<style type="text/css">
                    .divMainDiv10  { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv10  a{ text-decoration:none!important;}
                    .divExtraInfo{padding:5px;widht:100%!important; font-size:10px; margin-top:5px;}

                    .inhibitorsTitle{background-color:#eee; padding:5px 15px; }
                    .inhibitorsInfo{font-size:10px}
                    .inhibitorsResult{padding:3px 10px ; display:table;}
                    .ligandRes{width:250px;float:left;border:1px solid #eee; padding:10px;}
                    </style>
                    <div class="divMainDiv10 ">
                    <div class="divTitle">'+screenData.target+'</div>
                    <div class="divContent">
                    <div class="inhibitorsResult">
                    '+ttext+'
                    </div>
                    </div>
                    <div class="divExtraInfo"> </div>
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
