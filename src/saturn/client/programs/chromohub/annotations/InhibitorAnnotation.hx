package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.chromohub.ChromoHubAnnotation.HasAnnotationType;
import saturn.client.core.CommonCore;

class InhibitorAnnotation {

    public function new() {

    }

    static function hasInhibitors(target: String, data: Dynamic, selected:Int,annotList:Array<ChromoHubAnnotation>, item:String, callBack : HasAnnotationType->Void){
        if(data!=null) {
            var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'#707ee7',used:true},defImage:100};
            callBack(r);
        }
    }

    static function divInhibitors(screenData: ChromoHubScreenData,x:String,y:String,tree_type:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;


            var al,auxtext:String;
            WorkspaceApplication.getApplication().debug("access db");
            al='';
            var viewer = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);
            var chemi_sel=viewer.annotations[10].fromresults[1];
            var ligand_select=viewer.annotations[10].fromresults[0];

            var params = null;

            //annotation -> just target
            //family -> both parameters

            if(screenData.family!=null){
                params={target:screenData.targetClean, param:screenData.family};

                if(chemi_sel==false){
                    switch(ligand_select){
                        case 1:al='inhibitorsAllDiv';
                        case 5:al='inhibitors5nDiv';
                        case 2:al='inhibitors2nDiv';
                        case 0:al='inhibitors05nDiv';
                        default:al='inhibitorsAllDiv';
                    }
                }else{
                    switch(ligand_select){
                        case 1:al='chemicalAllDiv';
                        case 5:al='chemical5nDiv';
                        case 2:al='chemical2nDiv';
                        case 0:al='chemical05nDiv';
                        default:al='chemicalAllDiv';
                    }
                }
            }
            else {
                params={target:screenData.targetClean, param:''};
                al='chemicalAllDivAllFamilies';
            }
            auxtext='';

            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al, params, null, true, function(results: Dynamic, error){
                if(error == null) {

                    var ii:Int;
                    var ttext:String;
                    ttext="";

                    ii=0;
                    for(ii in 0...results.length){
                        ttext=ttext+'<div class="inhibitorsRes"><img onload="app.getSingleAppContainer().annotWindowDoLayout()" src="http://apps.thesgc.org/resources/phylogenetic_trees/ligands_images/ligand'+results[ii].pkey+'.png" width="150px"><br>
                        '+results[ii].name+'<br>';
                        if(results[ii].ic50!=null)ttext=ttext+'IC50/Kd/Ki: '+results[ii].ic50+'&microM<br>';
                        if((results[ii].pmid!=null)||(results[ii].pmid!='')) ttext=ttext+'Pubmed ID: <a href="http://www.ncbi.nlm.nih.gov/pubmed/'+results[ii].pmid+'" target="_blank">'+results[ii].pmid+'</a>';
                        if((results[ii].ref!=null)&&(results[ii].ref!='')) ttext=ttext+results[ii].ref+'<br>';
                        ttext=ttext+'</div>';
                    }

                    var l:Int;
                    l=(ii+1)*310;

                    var t = '<style type="text/css">
                    .divMainDiv11  { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divMainDiv11 a{ text-decoration:none!important;}
                    .divExtraInfo{padding:5px;widht:100%!important; font-size:10px; margin-top:5px;}

                    .inhibitorsInfo{font-size:10px}
                    .inhibitorsResult{padding:3px 10px;display:table;}
                    .inhibitorsRes{width:250px;float:left;border:1px solid #eee; padding:10px;}
                    </style>
                    <div class="divMainDiv11">
                    <div class="divTitle">'+screenData.target+'</div>
                    <div class="divContent">
                    <span class="inhibitorsInfo">Activity indicated is that reported by authors, but does not necessarily indicate an examination of the mechanism of action of the compound</span>
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

    static function inhibitorsFunction (annotation:Int,form:Dynamic,tree_type:String, family:String,searchGenes:Array<Dynamic>,viewer:ChromoHubViewer,callback : Dynamic->String->Void){

        var ligand_select:String;
        var chemi_sel=true;

        var aux:Dynamic;

        if(form!=null){
            aux=form.form.findField('ligand_select');
            ligand_select=aux.lastValue.inhibitors;

            aux=form.form.findField('chemi_sel');
            var a=form.items.items[1].lastValue;
            if(a==false) chemi_sel=false;
        }
        else{
            ligand_select='1';
        }

        viewer.annotations[annotation].fromresults[0]=ligand_select;
        viewer.annotations[annotation].fromresults[1]=chemi_sel;

        WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookInhibitors',[{'treeType':tree_type,'familyTree':family,'ligand_select':ligand_select,'chemi_sel':chemi_sel,'searchGenes':searchGenes}], null, false,function(db_results, error){
            if(error == null) {
                if (db_results!=null){
                    viewer.activeAnnotation[annotation]=true;
                    if(viewer.treeName==''){
                        viewer.addAnnotDataGenes(db_results,annotation,function(){
                            callback(db_results,null);
                        });
                    }else{
                        viewer.addAnnotData(db_results,annotation,0,function(){
                            viewer.newposition(0,0);
                            callback(db_results,null);
                        });
                    }
                }
            }else {
                WorkspaceApplication.getApplication().debug(error);
                callback(null, error);
            }
        });

    }
}
