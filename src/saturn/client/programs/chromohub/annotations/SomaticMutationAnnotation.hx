package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.chromohub.annotations.SomaticMutationAnnotation;
import haxe.ds.StringMap;
import haxe.ds.HashMap;
import saturn.client.programs.chromohub.ChromoHubAnnotationMethods;
import saturn.client.programs.chromohub.ChromoHubAnnotationMethods;
import saturn.client.programs.chromohub.ChromoHubAnnotationMethods;
import saturn.client.programs.phylo.PhyloAnnotation;
import saturn.client.programs.phylo.PhyloScreenData;
import saturn.client.programs.phylo.PhyloAnnotation.HasAnnotationType;
import saturn.client.programs.phylo.PhyloTreeNode;
import saturn.client.core.CommonCore;

class SomaticMutationAnnotation {
    static var firstRun = true;
    static var diseaseSourceToDescription : Map<String,String>;

    public function new() {

    }

    static public function updateSomaticDiseaseList(cb : String->Void){
        #if PHYLO5

        #else
        WorkspaceApplication.getApplication().getProvider().getByNamedQuery("sm_name_all",[], null, true, function(results: Array<Dynamic>, error){
            if(error != null){
                cb(error);
            }else{
                diseaseSourceToDescription = new Map<String, String>();

                for(row in results){
                    diseaseSourceToDescription.set(row.name + '/' + row.source, row.description);
                }

                cb(null);
            }
        });
        #end
    }

    static function hasSomaticMut(target: String, data: Dynamic, selected:Int, annotList:Array<PhyloAnnotation>, item:String, cb : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'#000000',used:true},defImage:0};
        var family=ChromoHubAnnotationMethods.getFamilyTree();
        if(data!=null){

            var annotation=24;
            var viewer = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);
            var family=viewer.treeName;
            var somatic_mutations_list: Map<String,Dynamic>;
            somatic_mutations_list=viewer.annotationManager.annotations[annotation].fromresults[8];

            var key:String;
            var finalResult=null;
            for(key in somatic_mutations_list.keys()){
                var auxResult=somatic_mutations_list.get(key);
                if(target!=auxResult[0][4]) continue;
                else finalResult=somatic_mutations_list.get(key);
            }

            var res:Dynamic;
            var sm_col='';

            if(finalResult!=null){
                var pos=finalResult[0][2];
                var i=0;
                for(i in 0...finalResult.length){
                    var aux=finalResult[i][2];
                    if(Std.parseInt(aux)>Std.parseInt(pos)) pos=aux;
                }

                var freq_to_write=Math.fround(Std.parseFloat(pos));

                if (2<=freq_to_write && freq_to_write<4){
                    sm_col = '#dddddd';
                }else if (4<=freq_to_write && freq_to_write<7){
                    sm_col = '#ffc800';
                }else if (7<=freq_to_write && freq_to_write<10){
                    sm_col = '#ff6400';
                }else if (freq_to_write>=10){
                    sm_col = '#ff0000';
                }

                var somatic_mutations_list: Map<String,Dynamic> = viewer.annotationManager.annotations[annotation].fromresults[8];

                // TODO - Why is this hard-coded!
                var annotation=24;

                for(key in somatic_mutations_list.keys()){
                    var auxResult=somatic_mutations_list.get(key);
                    var i=0;
                    for( i in 0 ... auxResult.length){
                        var disease=auxResult[i][1];
                        var source=auxResult[i][8];

                        var description = SomaticMutationAnnotation.diseaseSourceToDescription.get(disease + '/' + source);

                        auxResult[i][11]=description;
                        somatic_mutations_list.set(key,auxResult);
                        viewer.annotationManager.annotations[annotation].fromresults[8]=somatic_mutations_list;
                    }
                }

                r = {hasAnnot: true, text:freq_to_write+'%',color:{color:sm_col,used:true},defImage:100};
            }else{
                r = {hasAnnot: false, text:'',color:{color:'',used:true},defImage:100};
            }

            cb(r);
        }
    }

    static function divSomatic(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){

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
            var annotation=24;
            //var storedata={tid:data.target_id, disease:data.disease, freq:data.freq, count:data.count, total:data.total, gene_name:data.gene_name, chromosome:data.chromosome, qvalue:db_results[i].qvalue, source:data.source}

            var viewer = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);
            var somatic_mutations_list:Map<String,Array<Dynamic>>;
            somatic_mutations_list=viewer.annotationManager.annotations[annotation].fromresults[8];

            var key:Dynamic;
            var l=new Array<Dynamic>();
            for(key in somatic_mutations_list.keys()){
                var arrayAux=somatic_mutations_list.get(key);
                var p=arrayAux[0][4];
                var pp=screenData.targetClean;
                if(p!=pp) continue;
                else l=somatic_mutations_list.get(key);
            }

            var sm_page:String;
            var patient_cutoff=viewer.annotationManager.annotations[annotation].fromresults[4];
            var sm_mutated_cutoff=viewer.annotationManager.annotations[annotation].fromresults[3];
            var validated=viewer.annotationManager.annotations[annotation].fromresults[7];
            var nonsilent=viewer.annotationManager.annotations[annotation].fromresults[6];
            var sm_mutated_dynamic=viewer.annotationManager.annotations[annotation].fromresults[1];
            var sm_mutated_cutoff_box=viewer.annotationManager.annotations[annotation].fromresults[2];

            if(sm_mutated_dynamic==true) {
                sm_page =  "somatic_mutations_dynamic.php";
                if(viewer.treeName == 'rna'){
                    sm_page = 'somatic_mutations_dynamic_methsome.php';
                }
            }else if(sm_mutated_cutoff_box==true) {
                sm_page =  "somatic_mutations.php";
                if(viewer.treeName == 'rna'){
                    sm_page = 'somatic_mutations_methsome.php';
                }
            }else{
                sm_page =  "somatic_mutations.php";
            }

            if(sm_mutated_cutoff == true){
                sm_page =  "somatic_mutations.php";
            }
            var t = '<style type="text/css">
                    .divMainDiv4  { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;}
                    .divMainDiv4  a{ text-decoration:none!important;}

                    .interactionInfo{font-size:10px}
                    .interactionResult{padding:3px 10px ;}
                    </style>
                    <div class="divMainDiv4 ">
                    <div class="divTitle">Somatic Mutations ('+screenData.target+')</div>
                    <div class="divContent">
                        <table style="font-size:12px"><tr>
                            <td style="width:30%;"><b>Disease</b></td>
                            <td tyle="width:20%;""><b>Frequency</b></td>
                            <td tyle="width:50%;"><b>Patients with '+screenData.target+' mutation / <br>Total Patients</b></td>
                            <td tyle="width:50%;""><b>MutSigCv q-value</td>
                            <td tyle="width:50%;"><b>Source</td>
                        </tr>';
            var i=0;
            for(i in 0... l.length){

                //[tid, disease, freq, count+"/"+total, gene_name, description, chromosome, qvalue, source, variant_index,name_index]

                t =t+ "<tr><td tyle='width:30%;'><a href=http://apps.thesgc.org/resources/phylogenetic_trees"+sm_page+"?disease="+l[i][1]+"&target="+l[i][4]+"&source="+l[i][8]+"&patients_cutoff="+patient_cutoff+"&mutated_cutoff="+sm_mutated_cutoff+validated+nonsilent+"' target='_blank'>"+l[i][11]+"</a></td>
											<td tyle='width:20%;'>"+l[i][2]+"</td>
											<td tyle='width:50%;'>"+l[i][3]+"</td>
											<td tyle='width:50%;'>"+l[i][7]+"</td>
											<td tyle='width:50%;'>"+l[i][8]+"</td></tr>";
            }

            t= t+'</table></div>
                    <div class="divExtraInfo"><i>Click disease name for details</i></div>
                    </div>
                ';

            callBack(t);

        }
    }

    static function somaticMutFunction (annotation:Int,form:Dynamic,tree_type:String, family:String,searchGenes:Array<Dynamic>,viewer:ChromoHubViewer,callback : Dynamic->String->Void) {

        if (family=='') {
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery('sm_sig_arr_all_families',{'gene' : searchGenes}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var i=0;
                    var mut_sig_arr=new Map<String,Int>();
                    for (i in 0...results.length){
                        var gene = results[i].gene;
                        var disease = results[i].disease;
                        var qvalue = results[i].qvalue;
                        mut_sig_arr.set(disease+'-'+gene,qvalue);
                    }

                    somaticMutFunctionContinue (annotation,form,tree_type, family, searchGenes,viewer,mut_sig_arr, function(db_results,error){
                        callback(db_results,error);
                    });
                }else{
                    callback(results, error);
                }
            });
        }else {
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery('sm_sig_arr',{param : family}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var i=0;
                    var mut_sig_arr=new Map<String,Int>();
                    for (i in 0...results.length){
                        var gene = results[i].gene;
                        var disease = results[i].disease;
                        var qvalue = results[i].qvalue;
                        mut_sig_arr.set(disease+'-'+gene,qvalue);
                    }
                    somaticMutFunctionContinue (annotation,form,tree_type, family, searchGenes,viewer,mut_sig_arr, function(db_results,error){
                        callback(db_results,error);
                    });
                }else{
                    callback(results, error);
                }
            });
        }
    }

    static function somaticMutFunctionContinue (annotation:Int,form:Dynamic,tree_type:String, family:String, searchGenes:Array<Dynamic>,viewer:ChromoHubViewer,mut_sig_arr:Map<String,Int>,callback : Dynamic->String->Void){

        var mutsig=false;
        var mutated_dynamic=false;
        var mutated_cutoff_box=false;

        var mutated_cutoff:String;
        var patient_cutoff:Int;
        var results_cutoff:Int;
        var nonsilent=false;
        var validated=false;

        var aux:Dynamic;

        if(form!=null){
            aux=form.form.findField('sm_mutated_select');
            switch (aux.lastValue.structure){
                case 1: mutsig=true;
                case 2: mutated_dynamic=true;
                case 3: mutated_cutoff_box=true;
            }

            aux=form.form.findField('mutated_cutoff');
            mutated_cutoff=aux.lastValue;

            aux=form.form.findField('patient_cutoff');
            patient_cutoff=Std.int(aux.lastValue);
            if(patient_cutoff==null) patient_cutoff=50;

            aux=form.form.findField('results_cutoff');
            results_cutoff=Std.int(aux.lastValue);
            if(results_cutoff==null) results_cutoff=2;

            aux=form.form.findField('nonsilent');
            var non=aux.lastValue;
            if(non==true) nonsilent=true;

            aux=form.form.findField('validated');
            var val=aux.lastValue;
            if(val==true) validated=true;
        }
        else{
            mutsig=true;
            mutated_cutoff='200';
            patient_cutoff=50;
            results_cutoff=2;
        }

        viewer.annotationManager.annotations[annotation].fromresults[0]=mutsig;
        viewer.annotationManager.annotations[annotation].fromresults[1]=mutated_dynamic;
        viewer.annotationManager.annotations[annotation].fromresults[2]=mutated_cutoff_box;
        viewer.annotationManager.annotations[annotation].fromresults[3]=mutated_cutoff;
        viewer.annotationManager.annotations[annotation].fromresults[4]=patient_cutoff;
        viewer.annotationManager.annotations[annotation].fromresults[5]=results_cutoff;
        viewer.annotationManager.annotations[annotation].fromresults[6]=nonsilent;
        viewer.annotationManager.annotations[annotation].fromresults[7]=validated;

        WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookSomaticMutations', [{'treeType':tree_type,'familyTree':family,'sm_mutsig':mutsig,'sm_mutated_dynamic':mutated_dynamic,'sm_mutated_cutoff_box':mutated_cutoff_box,
            'sm_mutated_cutoff':mutated_cutoff,'sm_patient_cutoff':patient_cutoff,'sm_results_cutoff':results_cutoff,'sm_nonsilent':nonsilent,'sm_validated':validated,'searchGenes':searchGenes}], null, false,function(db_results:Dynamic, error){
            if(error == null) {
                if (db_results!=null){
                    var i=0;
                    var max_freq=0;
                    var somatic_mutations_list= new Map<String, Dynamic>();
                    var assigned=false;
                    for(i in 0 ... db_results.length){
                        if(assigned==false){
                            if(db_results[i].freq!=null){
                                max_freq=db_results[i].freq;
                                assigned=true;
                            }
                        }
                        var description = db_results[i].disease;
                        var source = db_results[i].source;
                        var cancer_group = db_results[i].cancer_group;
                        //var cancer_group = str_replace(' ', '_', $cancer_group);
                        var gene_name = db_results[i].gene_name;
                        var chromosome = db_results[i].chromosome;
                        var tid = db_results[i].target_id;
                        // var tidNoSlash = str_replace("/", "", $tid);
                        var name_index=db_results[i].name_index;
                        var variant_index=db_results[i].variant_index;
                        var disease=db_results[i].disease;
                        var qvalue:Int;

                        if(mut_sig_arr.exists(disease+'-'+gene_name)==true){
                            qvalue = mut_sig_arr.get(disease+'-'+gene_name);
                            if(mutsig == true){
                                if(qvalue > 0.1){
                                    continue;
                                }
                            }
                        }
                        else{
                            continue;
                        }
                        if(mutated_dynamic == true && (disease == 'SKCM')){
                            continue;

                        }
                        var freq=db_results[i].freq;
                        var count=db_results[i].count;
                        var total=db_results[i].total;

                        if (count < results_cutoff){
                            continue;
                        }
                        //name and variant indices if domain based
                        var tidWithVarIndex  = tid + "-" + variant_index;
                        if(name_index!=null) tidWithVarIndex  += "_" +name_index;

                        if (somatic_mutations_list.exists(tidWithVarIndex)) {
                            var arrayAux:Array<Dynamic>;
                            arrayAux=somatic_mutations_list.get(tidWithVarIndex);
                            arrayAux.push([tid, disease, freq, count+"/"+total, gene_name, description, chromosome, qvalue, source, variant_index,name_index]);
                            somatic_mutations_list.set(tidWithVarIndex,arrayAux);
                        } else {
                            var arrayAux=new Array<Dynamic>();
                            arrayAux.push([tid, disease, freq, count+"/"+total, gene_name, description, chromosome, qvalue, source, variant_index,name_index]);
                            somatic_mutations_list.set(tidWithVarIndex,arrayAux);

                        }
                        if(max_freq<freq){
                            max_freq=freq;
                        }
                    }
                    var key:Dynamic;
                    var fresults=new Array<Dynamic>();
                    for(key in somatic_mutations_list.keys()){
                        var arrayAux=somatic_mutations_list.get(key);
                        var tid=arrayAux[0][0];
                        var gene_name=arrayAux[0][4];
                        var freq_to_write=arrayAux[0][2] + "%";
                        fresults.push({target_id:gene_name, target_name_index:arrayAux[0][10], variant_index:arrayAux[0][9]});
                    }


                    viewer.annotationManager.annotations[annotation].fromresults[8]=somatic_mutations_list;
                    viewer.annotationManager.activeAnnotation[annotation]=true;
                    if(viewer.treeName==''){
                        viewer.annotationManager.addAnnotDataGenes(fresults,annotation,function(){
                            callback(db_results,null);
                        });
                    }else{
                        viewer.annotationManager.addAnnotData(fresults,annotation,0,function(){
                            viewer.newposition(0,0);
                            callback(db_results,null);
                        });
                    }
                }
            }
            else {
                WorkspaceApplication.getApplication().debug(error);
                callback(null, error);
            }
        });
    }
}
