package saturn.client.programs.chromohub.annotations;

import phylo.PhyloAnnotation;
import phylo.PhyloScreenData;
import phylo.PhyloAnnotation.HasAnnotationType;
import phylo.PhyloTreeNode;
import saturn.client.core.CommonCore;

class DiseaseAnnotation {
    public function new() {

    }

    static function hasDisease(target: String, data: Dynamic, selected:Int, annotList:Array<PhyloAnnotation>, item:String, callBack : HasAnnotationType->Void){

        var annotcode=1;

        var numMax=annotList[1].fromresults[1];
        var prog = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);
        var leaf:PhyloTreeNode;

        var pos:Int;
        var ntarget=target;
        var r : HasAnnotationType;
        // First of all, we need to check if that image has been already generated (
        var prog = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);
        if(target.indexOf('(')!=-1 || target.indexOf('-')!=-1){
            var auxArray=target.split('');
            var j:Int;
            var name='';
            for(j in 0...auxArray.length){
                if (auxArray[j]=='(' || auxArray[j]=='-') {

                    break;
                }
                name+=auxArray[j];
            }
            ntarget=name;
        }
        if(prog.treeName!='') leaf=prog.rootNode.leafNameToNode.get(item);
        else leaf=prog.geneMap.get(item);

        WorkspaceApplication.getApplication().getProvider().getByNamedQuery("diseaseAssociationDiv",{target : ntarget}, null, true, function(results: Dynamic, error){
            if(error == null) {

                var infN:Int =0; var cancerN:Int =0; var virInfN:Int =0; var neuDisN:Int =0; var metDisN:Int =0; var immDisN:Int =0; var regMedN:Int =0;

                var pmids = new Array();
                var i:Int;
                var mapResults: Map<String, Int>;
                mapResults=new Map();

                for(i in 0... results.length){
                    var aux:Dynamic;
                    aux=results[i].pmid_list;
                    var aux2=aux.split(';');
                    pmids[i] = aux2.length;
                    mapResults.set(results[i].id, pmids[i]);
                    switch(results[i].id){
                        case 'Inflammation':infN=pmids[i];
                        case 'Cancer':cancerN=pmids[i];
                        case 'Viral Infections':virInfN=pmids[i];
                        case 'Neurological Diseases':neuDisN=pmids[i];
                        case 'Metabolic Disorders':metDisN=pmids[i];
                        case 'Immune Disorders':immDisN=pmids[i];
                        case 'Regenerative Medicine':regMedN=pmids[i];
                    }
                }

                leaf.results=[numMax,infN,cancerN,virInfN,neuDisN,metDisN,immDisN,regMedN];
                for(i in 1...leaf.results.length){
                    leaf.results[i]=Math.round((leaf.results[i]*10)/leaf.results[0]);
                }
                leaf.results[9]=0;

                r= {hasAnnot: true, text:'',color:{color:'#efefef',used:false},defImage:0};
                callBack(r);
            }
            else {
                WorkspaceApplication.getApplication().debug(error);
            }
        });

    }

    static function divDiseaseAssociation(screenData: PhyloScreenData, x:String, y:String, tree_type:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;



            WorkspaceApplication.getApplication().getProvider().getByNamedQuery("diseaseAssociationDiv",{target : screenData.targetClean}, null, true, function(results: Dynamic, error){
                if(error == null) {

                    var name:String;
                    if (screenData.target.indexOf('(')!=-1) name=screenData.target;
                    else name=screenData.targetClean;

                    var numMax, numMid:Float;
                    var numMidt:String;
                    var infH:Int =150; var cancerH:Int =150; var virInfH:Int =150; var neuDisH:Int =150; var metDisH:Int =150; var immDisH:Int =150; var regMedH:Int =150;
                    var infN:Int =0; var cancerN:Int =0; var virInfN:Int =0; var neuDisN:Int =0; var metDisN:Int =0; var immDisN:Int =0; var regMedN:Int =0;
                    var infNt,cancerNt,virInfNt,neuDisNt,metDisNt,immDisNt,regMedNt:String;
                    var pmids = new Array();
                    var br=5;
                    var bw=25;

                    var i:Int;
                    var mapResults: Map<String, Int>;
                    mapResults=new Map();

                    for(i in 0... results.length){
                        var aux:Dynamic;
                        aux=results[i].pmid_list;
                        var aux2=aux.split(';');
                        pmids[i] = aux2.length;
                        mapResults.set(results[i].id, pmids[i]);
                        switch(results[i].id){
                            case 'Inflammation':infN=pmids[i];
                            case 'Cancer':cancerN=pmids[i];
                            case 'Viral Infections':virInfN=pmids[i];
                            case 'Neurological Diseases':neuDisN=pmids[i];
                            case 'Metabolic Disorders':metDisN=pmids[i];
                            case 'Immune Disorders':immDisN=pmids[i];
                            case 'Regenerative Medicine':regMedN=pmids[i];
                        }
                    }

                    numMax=pmids[0];
                    for (i in 1 ... pmids.length){
                        if (pmids[i]>numMax) numMax=pmids[i];
                    }
                    if (numMax!=1){
                        var a=numMax/2;
                        numMid=Math.round(a);
                        numMidt=''+numMid;
                    }else numMidt='';

                    infH=Math.round((150*infN)/numMax);
                    cancerH=Math.round((150*cancerN)/numMax);
                    virInfH=Math.round((150*virInfN)/numMax);
                    neuDisH=Math.round((150*neuDisN)/numMax);
                    metDisH=Math.round((150*metDisN)/numMax);
                    immDisH=Math.round((150*immDisN)/numMax);
                    regMedH=Math.round((150*regMedN)/numMax);

                    if ((infH<10)||(infN==0)) infNt=''; else infNt=""+infN+"";
                    if ((cancerH<10)||(cancerN==0)) cancerNt=''; else cancerNt=""+cancerN+"";
                    if ((virInfH<10)||(virInfN==0)) virInfNt=''; else virInfNt=""+virInfN+"";
                    if ((neuDisH<10)||(neuDisN==0)) neuDisNt=''; else neuDisNt=""+neuDisN+"";
                    if ((metDisH<10)||(metDisN==0)) metDisNt=''; else metDisNt=""+metDisN+"";
                    if ((immDisH<10)||(immDisN==0)) immDisNt=''; else immDisNt=""+immDisN+"";
                    if ((regMedH<10)||(regMedN==0)) regMedNt=''; else regMedNt=""+regMedN+"";

                    var nom='';
                    if(screenData.targetClean.indexOf('/')!=-1){
                        var auxArray=screenData.targetClean.split('');
                        var j:Int;
                        for(j in 0...auxArray.length){
                            if(auxArray[j]!='/') nom+=auxArray[j];
                        }
                    }else nom=screenData.targetClean;

                    var t = '<style type="text/css">
                    .divMainDiv1  {width:300px; background-color:#ffffff; border:1px solid #cccccc;}
                    .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                    .divContent{padding:5px;}
                    .divMainDiv1 a{ text-decoration:none!important;}

                    .disAsTable  {border-collapse:collapse;border-spacing:0; border-bottom:1px solid #000;}
                    .disAsTable th{vertical-align: bottom!important;}
                    .disAsTablePreText{margin-top:30px;padding:0 3px; float:left;-webkit-transform: rotate(-90deg); -moz-transform: rotate(-90deg);-ms-transform: rotate(-90deg);-o-transform: rotate(-90deg);transform: rotate(-90deg); font-size:11px;}
                    .disAsTableNum{float:left;width:25px;border-right:1px solid #000;}
                    .disAsTableNum {}
                    .disAsTableNum .disAsTableTop {height:70px;}
                    .disAsTableNum .disAsTableMiddle {height:70px;}
                    .disAsTableNum .disAsTableBottom {}
                    .disAsTable .disAsTableInf'+nom+' {font-size:10px;background-color:#2980d6;width:20px;height:'+infH+'px;}
                    .disAsTable .disAsTableCancer'+nom+' {font-size:10px;background-color:#bf0000;width:20px;height:'+cancerH+'px;}
                    .disAsTable .disAsTableVirInf'+nom+' {font-size:10px;background-color:#63cf1b;width:20px;height:'+virInfH+'px;}
                    .disAsTable .disAsTableNeuDis'+nom+' {font-size:10px;background-color:#ff8000;width:20px;height:'+neuDisH+'px;}
                    .disAsTable .disAsTableMetDis'+nom+' {font-size:10px;background-color:#c05691;width:20px;height:'+metDisH+'px;}
                    .disAsTable .disAsTableImmDis'+nom+' {font-size:10px;background-color:#ffcc00;width:20px;height:'+immDisH+'px;}
                    .disAsTable .disAsTableRegMed'+nom+' {font-size:10px;background-color:#793ff3;width:20px;height:'+regMedH+'px;}
                    </style>


                    <div class="divMainDiv1 ">
                    <div class="divTitle">Disease Association ('+name+')</div>
                    <div class="divContent">
                        <div class="disAsTablePreText"># of Articles</div>
                        <div class="disAsTableNum"> <div class="disAsTableTop">'+numMax+'</div><div class="disAsTableMiddle">'+numMidt+'</div><div class="disAsTableBottom">0</div></div>
                        <table class="disAsTable">
                          <tr>
                            <th><a href="http://apps.thesgc.org/resources/phylogenetic_trees/disease.php?target='+screenData.targetClean+'&disease=1" target="_blank" title="Inflammation"><div class="disAsTableInf'+nom+'">'+infNt+'</div></a></th>
                            <th><a href="http://apps.thesgc.org/resources/phylogenetic_trees/disease.php?target='+screenData.targetClean+'&disease=2" target="_blank" title="Cancer"><div class="disAsTableCancer'+nom+'">'+cancerNt+'</div></a></th>
                            <th><a href="http://apps.thesgc.org/resources/phylogenetic_trees/disease.php?target='+screenData.targetClean+'&disease=3" target="_blank" title="Viral Infections"><div class="disAsTableVirInf'+nom+'">'+virInfNt+'</div></a></th>
                            <th><a href="http://apps.thesgc.org/resources/phylogenetic_trees/disease.php?target='+screenData.targetClean+'&disease=4" target="_blank" title="Neurological Diseases"><div class="disAsTableNeuDis'+nom+'">'+neuDisNt+'</div></a></th>
                            <th><a href="http://apps.thesgc.org/resources/phylogenetic_trees/disease.php?target='+screenData.targetClean+'&disease=5" target="_blank" title="Metabolic Disorders"><div class="disAsTableMetDis'+nom+'">'+metDisNt+'</div></a></th>
                            <th><a href="http://apps.thesgc.org/resources/phylogenetic_trees/disease.php?target='+screenData.targetClean+'&disease=6" target="_blank" title="Immune Disorders"><div class="disAsTableImmDis'+nom+'">'+immDisNt+'</div></a></th>
                            <th><a href="http://apps.thesgc.org/resources/phylogenetic_trees/disease.php?target='+screenData.targetClean+'&disease=7" target="_blank" title="Regenerative Medicine"><div class="disAsTableRegMed'+nom+'">'+regMedNt+'</div></a></th>
                          </tr>
                        </table>
                    </div>
                    </div>
                    ';       // here we'll create whatever we need for each annotation

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
