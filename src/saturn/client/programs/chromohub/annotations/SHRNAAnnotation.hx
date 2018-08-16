package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.chromohub.ChromoHubAnnotation.HasAnnotationType;
import saturn.client.core.CommonCore;

class SHRNAAnnotation {

    public function new() {

    }

    static function hasshRNA(target: String, data: Dynamic, selected:Int,annotList:Array<ChromoHubAnnotation>, item:String, cb : HasAnnotationType->Void){
        //copy
        if(data!=null){
            var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'#1c9d4f',used:true},defImage:100};
            cb(r); return;
        }

        cb(null);
    }

    static function divshRNA(screenData: ChromoHubScreenData,x:String,y:String,tree_type:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){


            var viewer = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);
            var shrna_results=new Map<String,Dynamic>();
            shrna_results=viewer.annotations[screenData.annot].fromresults[3];
            var shrna_num_cutoff=viewer.annotations[screenData.annot].fromresults[1];
            var shrna_cutoff=viewer.annotations[screenData.annot].fromresults[0];

            var table='';
            var fibrotable='';
            var t='';

            var cell_line_chk = 0;
            for(key in shrna_results.keys()){
                var c=shrna_results.get(key);
                var nameindexaux='';
                var variantindexaux='';

                if(screenData.targetClean!=screenData.target){
                    var auxArray=screenData.target.split('');
                    var j:Int;
                    for(j in 0...auxArray.length){
                        if(auxArray[j]=='(') {nameindexaux=auxArray[j+1]; variantindexaux='1';}
                        if(auxArray[j]=='-') {nameindexaux=null; variantindexaux=auxArray[j+1];}
                    }
                }
                var cont=true;

                if((screenData.targetClean!=screenData.target)&&((c[0].variant_index!=variantindexaux)||(c[0].name_index!=nameindexaux))) cont=false;
                if((c[0].target_id==screenData.targetClean)&&(cont==true)){
                    var results_chk = 1;
                    table = "<table style='font-size:12px'>
						    <tr><th width='1000'>Cancer Cell Lines</th></tr>
						 </table>
						<table style='font-size:12px'>
							<tr><th width='25%'>Cell line</th>
							<th width='28%'>Site</th>
							<th width='25%'>shRNA</th>
							<th width='25%'>log2 fold change</th>
							</tr>";
                    var fibrochk = 0;
                    var last_cell_line = "";
                    var maintid = null;

                    var list=shrna_results.get(key);
                    var i=0;
                    var fintable='';
                    for(i in 0...list.length){
                        var arr:Dynamic;
                        arr=list[i].arr;
                        var j=0;
                        // for(j in 0...arr.length){
                        var tid = arr[0];
                        var cell_line = arr[1];
                        var shrna = arr[2];
                        var log2 = arr[3];
                        var site = arr[4];
                        var maintid = tid;
                        var fibrotable='';
                        if (cell_line != 'Fibroblast'){
                            cell_line_chk =1;
                        }

                        if (cell_line == 'Fibroblast'){
                            if (fibrochk == 0){
                                fibrotable = "<table style='font-size:12px'>
											<tr><th width='1000'>Control Non-Transformed Cell Line: Fibroblast</th></tr>
											</table>
											<table style='font-size:12px'>
											<tr><th width='25%'>Cell line</th>
											<th width='28%'>Site</th>
											<th width='25%'>shRNA</th>
											<th width='25%'>log2 fold change</th>
											</tr>";
                                fibrochk++;
                            }
                            fibrotable=fibrotable+"<tr><td><a href='shrna.php?cell_line="+cell_line+"&target="+maintid+"' target='_blank'>"+cell_line+"</a></td>
												<td>"+site+"</td><td>"+shrna+"</td><td>"+log2+"</td></tr>";
                        }else{
                            if (last_cell_line!=null && last_cell_line != cell_line) {
                                table += "<tr><td colspan='5'><hr></td></tr>";
                            }
                            table += "<tr><td><a href='shrna.php?cell_line="+cell_line+"&target="+maintid+"' target='_blank'>"+cell_line+"</a></td>
												<td>"+site+"</td><td>"+shrna+"</td><td>"+log2+"</td></tr>";
                            last_cell_line = cell_line;
                        }
                        //}
                    }
                    table += "</table>";

                    if (fibrochk != 0){
                        fibrotable += "</table>";
                        fintable = fibrotable + table;
                    }else{
                        fintable = table;
                    }

                    //imagemap += "<area shape=\"circle\" coords=\"$x_center, $y_center, $r\"
                    //			onmouseover=\"xstooltip_show('shrna$tidWithVarIndex', 'pic', $x_rb, $y_rb);\"/>";
                    if (shrna_num_cutoff == 1 && cell_line_chk !=0){
                        t += "<style type='text/css'>
                            .divMainDiv21{ }
                            .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                            .divContent{padding:5px;widht:100%!important;}
                            .divMainDiv21 a{ text-decoration:none!important;}
                            .divExtraInfo{padding:5px;widht:100%!important; font-size:10px; margin-top:5px;}

                            .interactionInfo{font-size:10px}
                            .interactionResult{padding:3px 10px ;}
                            </style>
                            <div class='divMainDiv21'><div class='divTitle'> Vulnerability of Cancer Cell Lines to shRNA</div>
								<div class='divExtraInfo''>Effect of various "+maintid+" targeting shRNAs on 102 Cancer Cell Lines: data is shown if at least "+shrna_num_cutoff+" shRNA causes a log2 reduction of <= "+shrna_cutoff+" in cell viability</div>
								<div class='divContent'>
								"+fintable+"</div></div>";
                    }

                    if (shrna_num_cutoff != 1 && cell_line_chk !=0){
                        t += "<style type='text/css'>
                            .divMainDiv21 { }
                            .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                            .divContent{padding:5px;widht:100%!important;}
                            .divMainDiv21 a{ text-decoration:none!important;}
                            .divExtraInfo{padding:5px;widht:100%!important; font-size:10px; margin-top:5px;}

                            .interactionInfo{font-size:10px}
                            .interactionResult{padding:3px 10px ;}
                            </style>
                            <div class='divMainDiv21'><div class='divTitle'>Vulnerability of Cancer Cell Lines to shRNA</div>
								<div class='divExtraInfo''>Effect of various "+maintid+" targeting shRNAs on 102 Cancer Cell Lines: data is shown if at least "+shrna_num_cutoff+" shRNAs have a log2 reduction of <= "+shrna_cutoff+" in abundance</div>
								<div class='divContent'>
								"+fintable+"</div></div>";
                    }
                    cell_line_chk = 0;
                }
            }
            callBack(t);
        }
    }

    static function shRnaFunction (annotation:Int,form:Dynamic,tree_type:String, family:String,searchGenes:Array<Dynamic>,viewer:ChromoHubViewer,callback : Dynamic->String->Void){

        var aux:Dynamic;
        var shrna_flag=false;

        if(form!=null){
            aux=form.form.findField('shrna_flag');
            var flag=aux.lastValue;
            if(flag==true) shrna_flag=true;
        }

        viewer.annotations[annotation].fromresults[2]=shrna_flag;

        if(shrna_flag==true){
            var al='shRnaflaq';
            if(tree_type=="gene"){
                al="gene_"+al;
            }
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{param : family}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    if (results!=null){
                        shRnaContinueFunction (annotation,form,tree_type, family, searchGenes, viewer, results, function(db_results, error){
                            callback(db_results,null);
                        });
                    }
                }
            });

        }else{
            var results=new Array<Dynamic>();
            shRnaContinueFunction (annotation,form,tree_type, family, searchGenes, viewer, results, function(db_results, error){
                callback(db_results,null);
            });
        }
    }

    static function shRnaContinueFunction(annotation:Int,form:Dynamic,tree_type:String, family:String, searchGenes:Array<Dynamic>, viewer:ChromoHubViewer, flagresults: Array<Dynamic>,callback : Dynamic->String->Void){

        var shrna_cutoff:String;
        var shrna_num_cutoff:String;

        var aux:Dynamic;
        var shrna_flag=false;

        if(form!=null){
            aux=form.form.findField('shrna_flag');
            var flag=aux.lastValue;
            if(flag==true) shrna_flag=true;

            aux=form.form.findField('shrna_num_cutoff');
            shrna_num_cutoff=aux.lastValue;

            aux=form.form.findField('shrna_cutoff');
            shrna_cutoff=aux.lastValue;
        }
        else{
            shrna_num_cutoff='3';
            shrna_cutoff='-2';
        }

        viewer.annotations[annotation].fromresults[0]=shrna_cutoff;
        viewer.annotations[annotation].fromresults[1]=shrna_num_cutoff;
        viewer.annotations[annotation].fromresults[2]=shrna_flag;

        WorkspaceApplication.getApplication().getProvider().getByNamedQuery('hookshRna', [{'treeType':tree_type,'familyTree':family,'shrna_cutoff':shrna_cutoff,'shrna_num_cutoff':shrna_num_cutoff,'shrna_flag':shrna_flag,'flagresults':flagresults,'searchGenes':searchGenes}], null, false,function(db_results:Array<Dynamic>, error){
            if(error == null) {
                if (db_results!=null){
                    var represented_celllines=new Map<String,Int>();
                    var i=0;
                    for(i in 0...db_results.length){
                        represented_celllines.set(db_results[i].combo,db_results[i].value);
                    }

                    var t=represented_celllines['ddd'];

                    var params = null;
                    var al='shRnaMain';

                    if(tree_type=="gene"){
                        if(family!="") {
                            al="gene_"+al;
                            params={target:searchGenes, param:family};
                        }
                        else {
                            al = 'gene_shRnaMainAllFamilies';
                            params={target:searchGenes, param:''};
                        }
                    }

                    else {
                        if(family!="") {
                            params={target:searchGenes, param:family};
                        }
                    }

                    WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,params, null, true, function(results: Dynamic, error){
                        if(error == null) {
                            if (results!=null){
                                var i=0;
                                var g=flagresults;
                                var rep_celllines=represented_celllines;
                                var shrna_results=new Map<String,Dynamic>();
                                for(i in 0 ...results.length){
                                    var cell_line = results[i].cell_line;
                                    var tid = results[i].target_id;
                                    var variant_index = results[i].variant_index;
                                    var name_index = results[i].name_index;

                                    var combo = cell_line + "-" + tid + variant_index;
                                    var tidWithVarIndex  = tid + "-" + variant_index;
                                    if(name_index!=null) tidWithVarIndex  += "_" + name_index;

                                    if (cell_line != 'Fibroblast'){
                                        if (represented_celllines.exists(combo)==false){
                                            continue;
                                        }
                                        var num:Int;
                                        num=Std.parseInt(shrna_num_cutoff);
                                        if (represented_celllines.get(combo) < num){
                                            continue;
                                        }
                                    }

                                    var shrna = results[i].shrna;
                                    var log2 = results[i].log2;
                                    //log2 = number_format(log2,1);
                                    if (log2 == '-0.0') log2 = '0.0';
                                    var site = results[i].site;

                                    var current_cellline = cell_line;

                                    if (shrna_results.exists(tidWithVarIndex)==false){
                                        var v=new Array();
                                        shrna_results.set(tidWithVarIndex,v);
                                    }
                                    var auxArray=shrna_results.get(tidWithVarIndex);
                                    auxArray.push({target_id:results[i].target_id,cell_line:cell_line,arr:[tid, cell_line, shrna, log2, site], name_index:results[i].name_index, variant_index:results[i].variant_index});
                                    shrna_results.set(tidWithVarIndex,auxArray);
                                }

                                var fresults=new Array<Dynamic>();
                                if (shrna_flag ==true){
                                    var i=0;
                                    for(i in 0...flagresults.length){
                                        if(shrna_results.exists(flagresults[i])==true) continue;
                                        else {
                                            var resi=shrna_results.get(flagresults[i]);
                                            fresults.push({target_id:resi[0].target_id, target_name_index:resi[0].name_index, variant_index:resi[0].variant_index});
                                        }
                                    }
                                }
                                else{
                                    for(key in shrna_results.keys()){
                                        var resi=shrna_results.get(key);
                                        fresults.push({target_id:resi[0].target_id, target_name_index:resi[0].name_index, variant_index:resi[0].variant_index});
                                    }
                                }

                                viewer.annotations[annotation].fromresults[3]=shrna_results;
                                viewer.annotations[annotation].fromresults[0]=shrna_cutoff;
                                viewer.annotations[annotation].fromresults[1]=shrna_num_cutoff;
                                viewer.annotations[annotation].fromresults[2]=shrna_flag;
                                viewer.activeAnnotation[annotation]=true;
                                if(viewer.treeName==''){
                                    viewer.addAnnotDataGenes(fresults,annotation,function(){
                                        callback(db_results,null);
                                    });
                                }else{
                                    viewer.addAnnotData(fresults,annotation,0,function(){
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
            else {
                WorkspaceApplication.getApplication().debug(error);
                callback(null, error);
            }
        });

    }
}
