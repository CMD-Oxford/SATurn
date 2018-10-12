package saturn.client.programs.chromohub.annotations;

import phylo.PhyloAnnotation;
import phylo.PhyloScreenData;
import phylo.PhyloAnnotation.HasAnnotationType;
import phylo.PhyloTreeNode;
import saturn.client.core.CommonCore;

class ExpressionLineAnnotation {

    public function new() {

    }

    static function divExpressionLines(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;


            var al,auxtext:String;
            var prog = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);
            if (tree_type=='domain'){

                if(screenData.annotation.dbData==null){ //it comes from annotation table div

                    if(prog.treeName==''){
                        var leaf=prog.geneMap.get(screenData.target);
                        screenData.annotation.dbData=leaf.annotations[screenData.annot].dbData;
                    }else{
                        var leaf=prog.rootNode.leafNameToNode.get(screenData.target);
                        screenData.annotation.dbData=leaf.annotations[screenData.annot].dbData;
                    }

                }

                if(screenData.annotation.dbData.target_name_index==null) al='expressionLinesDomainDivIsNull';
                else al='expressionLinesDomainDiv';


            }
            else{
                if(screenData.annotation.dbData==null){ //it comes from annotation table div

                    if(prog.treeName==''){
                        var leaf=prog.geneMap.get(screenData.target);
                        screenData.annotation.dbData=leaf.annotations[screenData.annot].dbData;
                    }else{
                        var leaf=prog.rootNode.leafNameToNode.get(screenData.target);
                        screenData.annotation.dbData=leaf.annotations[screenData.annot].dbData;
                    }

                }
                al='expressionLinesGeneDiv';
            }

            var target_name_index='';
            if(screenData.annotation.dbData.target_name_index!=null){
                target_name_index=screenData.annotation.dbData.target_name_index;
            }
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{target : screenData.targetClean, indexx: target_name_index, variant: screenData.annotation.dbData.variant_index}, null, true, function(results: Dynamic, error){
                if(error == null) {

                    var ii:Int;
                    var ttext:String;
                    var source:String;
                    var added=false;
                    ttext="";source="";

                    var t = '<style type="text/css">
                    .divMainDiv19 { }
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;widht:100%!important;}
                    .divContent table{margin-bottom:10px;}
                    .divContent table td {border:1px solid #ccc; padding:5px;}
                    .divMainDiv19 a{ text-decoration:none!important;}
                    .divExtraInfo{padding:5px;widht:100%!important; font-size:10px; margin-top:5px;}

                    .orphanetResult{padding:3px 10px ;}
                    </style>
                    <div class="divMainDiv19">
                    <div class="divTitle"><a href="http://apps.thesgc.org/resources/phylogenetic_trees/cell_lines.php?target='+screenData.target+'" target="_blank">Cancer Cell Lines ('+screenData.target+')</a></div>
                    <div class="divContent">
                    <div class="orphanetResult">
                    ';

                    for(ii in 0...results.length){
                        if(source!=results[ii].source){
                            if(source!=''){
                                t+='</table>';
                            }
                            switch(results[ii].source){
                                case 'ccle_expression':
                                    t+="<b>mRNA expression level for the 10 cancer cell lines out of 967 where this gene is expressed most </b><br> data from <a href='http://www.broadinstitute.org/ccle/home' target='_blank'>Cancer Cell Line Encyclopedia</a>
									(PMID <a href='http://www.ncbi.nlm.nih.gov/pubmed/22460905' target='_blank'>22460905</a>)
									<br><table style='font-size:12px'><tr><th width='20%'>Cell line</th><th width='30%'>Site</th><th width='30%'>Subtype</th><th align=center width='20%'><a style='text-decoration: none; color:#FFFFFF' title='The Robust Multi-array Average (RMA) gives a measure of expression level'>RMA</a></th></tr>";

                                case 'ccle_copynumber':
                                    t+="<b>DNA copy number log2 ratio for the 10 cancer cell lines out of 972 where this gene has greatest log2 ratio</b> <br>data from <a href='http://www.broadinstitute.org/ccle/home' target='_blank'>Cancer Cell Line Encyclopedia</a>
									(PMID <a href='http://www.ncbi.nlm.nih.gov/pubmed/22460905' target='_blank'>22460905</a>)
									<br><table style='font-size:12px'><tr><th width='20%'>Cell line</th><th width='30%'>Site</th><th width='30%'>Subtype</th><th align=center width='20%'>log2 ratio</th></tr>";

                                case 'rx_copynumber':
                                    t+="<b>DNA copy number for the 10 cancer cell lines out of 773 where this gene has greatest copy number</b><br>data from <a href='http://www.cancerRXgene.org' target='_blank'>www.cancerRXgene.org</a>
									(PMID <a href='http://www.ncbi.nlm.nih.gov/pubmed/22460902' target='_blank'>22460902</a>)
									<br><table style='font-size:12px'><tr><th width='20%'>Cell line</th><th width='30%'>Site</th><th width='30%'>Subtype</th><th align=center width='20%'>Copy Number</th></tr>";
                            }
                            source=results[ii].source;
                        }
                        t+='<tr><td width="20%">'+results[ii].cell_line+'</td><td width="30%">'+results[ii].site+'</td><td width="35%">'+results[ii].subtype+'</td><td align=center width="15%">'+results[ii].score+'</td></tr>';
                    }

                    t+='</div>
                    </div>
                    <div class="divExtraInfo">Click title for title for details</div>
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
