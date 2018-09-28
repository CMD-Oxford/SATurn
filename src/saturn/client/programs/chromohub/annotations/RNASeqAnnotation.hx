package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.phylo.PhyloAnnotation;
import saturn.client.programs.phylo.PhyloScreenData;
import saturn.client.programs.phylo.PhyloAnnotation.HasAnnotationType;
import saturn.client.programs.phylo.PhyloTreeNode;
import saturn.client.core.CommonCore;

class RNASeqAnnotation {
    public function new() {

    }

    static function hasRNASeq(target: String, data: Dynamic, selected:Int, annotList:Array<PhyloAnnotation>, item:String, callBack : HasAnnotationType->Void){

        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'',used:false},defImage:100};

        if(data!=null){
            if(Reflect.hasField(data, 'freq')){
                var freq=data.freq;
                if (freq < 25){
                    r.color={color:'#ffffff',used:true};
                }else if (25 <= freq && freq <= 50){
                    r.color={color:'#00e6ff',used:true};
                }else if (50 < freq && freq <= 75){
                    r.color={color:'#0096ff',used:true};
                }else if (freq > 75){
                    r.color={color:'#000064',used:true};
                }

                callBack(r);
            }
        }
    }

    static function divRNASeq(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){


            var viewer = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);
            var all_results:Dynamic;
            all_results=viewer.annotationManager.annotations[screenData.annot].fromresults[0];
            var w=0;
            var diseaselist=new Array();
            var mapauxx=new Map<String,Bool>();
            for(w in 0 ... all_results.length){
                if(all_results[w].target_id!=screenData.targetClean) continue;
                if(mapauxx.exists(all_results[w].disease)==false){
                    diseaselist.push(all_results[w].disease);
                }
            }

            WorkspaceApplication.getApplication().getProvider().getByNamedQuery('cancerdisease',{diseaselist : diseaselist}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var i=0;
                    var shown_disease=new Map<String,String>();
                    for (i in 0...results.length){
                        shown_disease.set(results[i].name,results[i].description);
                    }
                    screenData.divAccessed=true;

                    var viewer = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);
                    var all_results:Dynamic;
                    all_results=viewer.annotationManager.annotations[screenData.annot].fromresults[0];
                    var seqexp_fc_cutoff=viewer.annotationManager.annotations[screenData.annot].fromresults[1];
                    var seq_evaluator=viewer.annotationManager.annotations[screenData.annot].fromresults[2];

                    var table = "<table style='font-size:12px'>
                      <tr><th width='33%'>Cancer Type</th>
                          <th width='33%'>Frequency</th>
                          <th width='33%'>Rank among genes with a log2 fold change "+seq_evaluator+" "+seqexp_fc_cutoff+" for "+screenData.targetClean+"</th>
                      </tr>";
                    var line = 0;

                    var table_arr = new Array();

                    var w=0;
                    var table_arr= new Map<String,String>();
                    for(w in 0 ... all_results.length){
                        // $drawn_circ_seq_keys = array_keys($drawn_circ_seq);
                        var tid = all_results[w].target_id;
                        if(tid!=screenData.targetClean) continue;

                        var disease = all_results[w].disease;
                        var freq = all_results[w].freq;
                        var count_cutoff = all_results[w].count;
                        var count_all = all_results[w].total;
                        var rank = all_results[w].rank;
                        var total_genes = all_results[w].total_genes;
                        var table_mid:Dynamic;


                        var expression = 'over expressed';
                        if(seq_evaluator =='<=') expression = 'under expressed';

                        var descrip=shown_disease.get(disease);
                        table_mid = "<tr><td><a href='matched_seq_fc_plot.php?gene="+screenData.targetClean+"&disease="+disease+"' target='_blank'>"+descrip+" ("+tid+")</a></td>
                                    <td><b>"+freq+"%</b>  ("+count_cutoff+" / "+count_all+") </td>
                        <td>Out of <b>"+total_genes+"</b> genes <b>"+rank+"</b> gene(s) is/are more frequently "+expression+" </td>
                        </tr>";
                        table_arr.set(freq+disease+tid,table_mid);
                    }

                    for (key in table_arr.keys()) {

                        table += table_arr.get(key);
                    }

                    table += "</table>";

                    var t = '<style type="text/css">
                            .divMainDiv22 { }
                            .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                            .divContent{padding:5px;widht:100%!important;}
                            .divMainDiv22 a{ text-decoration:none!important;}
                            .divExtraInfo{padding:5px;widht:100%!important; font-size:10px; margin-top:5px;}

                            .interactionInfo{font-size:10px}
                            .interactionResult{padding:3px 10px ;}
                            </style>
                            <div class="divMainDiv22">

                                <div class="divTitle">Frequency of Log2 Fold Change '+seq_evaluator+' '+seqexp_fc_cutoff+' for '+screenData.targetClean+' in various cancer types
											<div class="divExtraInfo">Fold Changes derived from control and tumor tissue sample from the same patient</div></div>
								<div class="divContent">'+table+'</div>
                            </div>';
                    callBack(t);
                }
            });
        }
    }

    static function rnaSeqFunction (annotation:Int,form:Dynamic,tree_type:String, family:String,searchGenes:Array<Dynamic>,viewer:ChromoHubViewer,callback : Dynamic->String->Void){
        //we get the form values
        //type

        var aux:Dynamic;
        var seq_evaluator,seqexp_fc_cutoff,seqexp_freq_cutoff,patient_seq_cutoff,seqexp_rank_cutoff:String;

        if(form==null){
            // it means the function is called from the annotations table, so we need to use the default values
            seq_evaluator='>=';
            seqexp_fc_cutoff='2';
            seqexp_freq_cutoff='20';
            patient_seq_cutoff='10';
            seqexp_rank_cutoff='1000';
        }else{
            aux=form.form.findField('seq_evaluator');
            seq_evaluator = aux.lastValue;

            aux=form.form.findField('seqexp_fc_cutoff');
            seqexp_fc_cutoff = aux.lastValue;

            aux=form.form.findField('seqexp_freq_cutoff');
            seqexp_freq_cutoff = aux.lastValue;
            if(seqexp_freq_cutoff==null) seqexp_freq_cutoff='20';

            aux=form.form.findField('patient_seq_cutoff');
            patient_seq_cutoff = aux.lastValue;
            if(patient_seq_cutoff==null) patient_seq_cutoff='10';

            aux=form.form.findField('seqexp_rank_cutoff');
            seqexp_rank_cutoff = aux.lastValue;
            if(seqexp_rank_cutoff==null) seqexp_rank_cutoff='1000';
        }



        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'',used:true},defImage:100};

        WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookRnaSeq', [{'treeType':tree_type,'familyTree':family,'seq_evaluator':seq_evaluator,'seqexp_fc_cutoff':seqexp_fc_cutoff,'seqexp_freq_cutoff':seqexp_freq_cutoff,'patient_seq_cutoff':patient_seq_cutoff,'seqexp_rank_cutoff':seqexp_rank_cutoff,'searchGenes':searchGenes}], null, false,function(db_results:Dynamic, error){
            if(error == null) {
                if (db_results!=null){
                    var z=0;
                    var j=0;
                    var l=0;
                    var check_results=new Array();
                    var all_results=new Array();
                    var mapaux= new Map<String,Float>();
                    var mapaux2= new Map<String,Int>();
                    for (z in 0...db_results.length){
                        var count_cutoff = db_results[z].count;
                        var count_all = db_results[z].total;
                        var freq = Math.round(100*(count_cutoff / count_all));
                        db_results[z].freq=freq;
                        if((freq < db_results[z].seqexp_freq_cutoff)||(count_cutoff < db_results[z].patient_seq_cutoff)){
                            var donothing='';
                        }
                        else{
                            //as I see in polymorph version, we need to get the one with the highest freq adn with same variant_index
                            all_results[l]=db_results[z];
                            l++;
                            var auxi=db_results[z].target_id+'_'+db_results[z].variant_index;
                            if(mapaux.exists(auxi)==false) {
                                mapaux.set(auxi,freq);
                                mapaux2.set(auxi,j);
                                check_results[j]=db_results[z];
                                j++;
                            }
                            else{
                                var a=mapaux.get(auxi);

                                if(a<freq){
                                    check_results[mapaux2.get(auxi)]=db_results[z];

                                }
                            }
                        }
                    }
                    viewer.annotationManager.activeAnnotation[annotation]=true;
                    viewer.annotationManager.annotations[annotation].fromresults[0]=all_results;
                    viewer.annotationManager.annotations[annotation].fromresults[1]=seqexp_fc_cutoff;
                    viewer.annotationManager.annotations[annotation].fromresults[2]=seq_evaluator;
                    if(viewer.treeName==''){
                        viewer.addAnnotDataGenes(check_results,annotation,function(){
                            callback(db_results,null);
                        });
                    }else{
                        viewer.addAnnotData(check_results,annotation,0,function(){
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
