/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.phylo5;

import haxe.ds.ArraySort;
import saturn.client.programs.phylo5.Phylo5Annotation.HasAnnotationType;
import saturn.core.Util;
import saturn.client.programs.phylo5.Phylo5Annotation;
import bindings.Ext;

typedef LigandType = {
    var pkey: Int;
    var id: Int;
    var formula: String;
    var name: String;
    var title: String;
    var pdbs:Array<String>;
    var pdb: Map<String, PdbType>;
}
typedef PdbType ={
    var percent:Int;
    var title:String;
}


class Phylo5AnnotationMethods {

    public function new(){

    }

    static function hasPubmed(target: String, data: Dynamic, root:Phylo5TreeNode, callBack : HasAnnotationType->Void){

        var r : HasAnnotationType = {hasAnnot: true, text:'',color:'',defImage:100};


        if(data.pubs<10) r.defImage=0;
        else if((data.pubs>=10)&&(data.pubs<20)) r.defImage=1;
        else if((data.pubs>=20)&&(data.pubs<50)) r.defImage=2;
        else if((data.pubs>=50)&&(data.pubs<100)) r.defImage=3;
        else if(data.pubs>=100) r.defImage=4;

        callBack(r);
    }

    static function hasFunding(target: String, data: Dynamic, root:Phylo5TreeNode, callBack : HasAnnotationType->Void){

        var r : HasAnnotationType = {hasAnnot: false, text:'',color:'',defImage:100};

        if (data.funds > 15000000){
            r.text="$$$";
            r.color="#f60808";
            r.hasAnnot= true;
        }
        else if (data.funds > 5000000){
            r.text="$$";
            r.color="#f69908";
            r.hasAnnot= true;
        }
        else if (data.funds > 500000) {
            r.text="$";
            r.color="#085cf6";
            r.hasAnnot= true;
        }

        callBack(r);
    }

    static function hasSubstrate(target: String, data: Dynamic, root:Phylo5TreeNode, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:data.sub,color:'',defImage:100};

        if(root.auxMap.exists(data.sub)) r.color=root.auxMap.get(data.sub);
        else{
            var k:Int;
            var c:String;
            for (k in 0... root.annotations[4].color.length){
                var g=root.annotations[4].color[k].used;
                if (g==false) {
                    c=root.annotations[4].color[k].color;
                    root.annotations[4].color[k].used=true;
                    root.auxMap.set(data.sub,c);
                    r.color=c;
                    break;
                }
            }
        }

        callBack(r);
    }
    static function hasSubcellular(target: String, data: Dynamic, root:Phylo5TreeNode, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:'',defImage:100};

        if (data.location.indexOf('Nucleus')!=-1) r.defImage=0;
        else r.defImage=1;

        callBack(r);
    }

    static function hasHighlight(target: String, data: Dynamic, root:Phylo5TreeNode, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: false, text:'',color:'',defImage:100};

        var year=root.annotations[17].optionSelected;
        var tg=target;
        WorkspaceApplication.getApplication().getProvider().getByNamedQuery("highlightJumpInLast1",{target_id : tg, year: year}, null, true, function(db_results, error){
            if(error == null) {
                if (db_results!=null){
                    r.defImage=0;
                    r.hasAnnot=true;
                    callBack(r);
                }
            }
            else {
                WorkspaceApplication.getApplication().debug(error);
            }
        });
    }

    static function hasNonSilent(target: String, data: Dynamic, root:Phylo5TreeNode, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: false, text:'',color:'',defImage:100};

        WorkspaceApplication.getApplication().getProvider().getByNamedQuery("nonSilentSPNsPoly",{uniprot : data.uniprot, pkey: data.variant_pkey}, null, true, function(db_results, error){
            if(error == null) {
                if((db_results[0].num_total==null)||(db_results[0].num_total=='0')) {
                    r.text="";
                    r.hasAnnot=false;
                }
                else{
                    r.text=''+db_results[0].num_total+'';
                    r.hasAnnot=true;
                    if((db_results[0].is_disease=='Disease')&&(db_results[0].num_dom!=0)) r.color='#9026b3';
                    else if (db_results[0].is_disease=='Disease') r.color='#e60841';
                    else if (db_results[0].num_dom!=0) r.color='#06fff7';
                    else r.color='#000000';
                }
                callBack(r);
            }
            else {
                WorkspaceApplication.getApplication().debug(error);
            }
        });

    }

    static function hasLigands(target: String, data: Dynamic, root:Phylo5TreeNode, callBack : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:data.variant_pkey,color:'#68229d',defImage:100};

        callBack(r);
    }

/***** methods that will create the DIV ******************/
    static function divDiseaseAssociation(screenData: Phylo5ScreenData,x:String,y:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;
            WorkspaceApplication.getApplication().debug("access db");
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery("diseaseAssociationDiv",{target : screenData.target}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var div = js.Browser.document.createElement('div');        // Create DIV element


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

                    if (infN==0) infNt=''; else infNt=""+infN+"";
                    if (cancerN==0) cancerNt=''; else cancerNt=""+cancerN+"";
                    if (virInfN==0) virInfNt=''; else virInfNt=""+virInfN+"";
                    if (neuDisN==0) neuDisNt=''; else neuDisNt=""+neuDisN+"";
                    if (metDisN==0) metDisNt=''; else metDisNt=""+metDisN+"";
                    if (immDisN==0) immDisNt=''; else immDisNt=""+immDisN+"";
                    if (regMedN==0) regMedNt=''; else regMedNt=""+regMedN+"";

                    var t = '<style type="text/css">
                    .disAsTableContent {width:300px; background-color:#ffffff; border:1px solid #cccccc; padding:5px;}
                    .disAsTable  {border-collapse:collapse;border-spacing:0;}
                    .disAsTable th{vertical-align: bottom!important;}
                    .disAsTablePreText{margin-top:30px;padding:0 3px; float:left;-webkit-transform: rotate(-90deg); -moz-transform: rotate(-90deg);-ms-transform: rotate(-90deg);-o-transform: rotate(-90deg);transform: rotate(-90deg); font-size:11px;}
                    .disAsTableNum{float:left;width:25px;border-right:1px solid #000;}
                    .disAsTableNum {}
                    .disAsTableNum .disAsTableTop {height:70px;}
                    .disAsTableNum .disAsTableMiddle {height:70px;}
                    .disAsTableNum .disAsTableBottom {}
                    .disAsTable .disAsTableInf {font-size:10px;background-color:#2980d6;width:20px;height:'+infH+'px;}
                    .disAsTable .disAsTableCancer {font-size:10px;background-color:#bf0000;width:20px;height:'+cancerH+'px;}
                    .disAsTable .disAsTableVirInf {font-size:10px;background-color:#63cf1b;width:20px;height:'+virInfH+'px;}
                    .disAsTable .disAsTableNeuDis {font-size:10px;background-color:#ff8000;width:20px;height:'+neuDisH+'px;}
                    .disAsTable .disAsTableMetDis {font-size:10px;background-color:#c05691;width:20px;height:'+metDisH+'px;}
                    .disAsTable .disAsTableImmDis {font-size:10px;background-color:#ffcc00;width:20px;height:'+immDisH+'px;}
                    .disAsTable .disAsTableRegMed {font-size:10px;background-color:#793ff3;width:20px;height:'+regMedH+'px;}
                    </style>
                    <div class="disAsTableContent">
                    <h3>Disease Association ('+screenData.target+')</h3>
                    <div class="disAsTablePreText"># of Articles</div>
                    <div class="disAsTableNum"> <div class="disAsTableTop">'+numMax+'</div><div class="disAsTableMiddle">'+numMidt+'</div><div class="disAsTableBottom">0</div></div>
                    <table class="disAsTable">
                      <tr>
                        <th><div class="disAsTableInf">'+infNt+'</div></th>
                        <th><div class="disAsTableCancer">'+cancerNt+'</div></th>
                        <th><div class="disAsTableVirInf">'+virInfNt+'</div></th>
                        <th><div class="disAsTableNeuDis">'+neuDisNt+'</div></th>
                        <th><div class="disAsTableMetDis">'+metDisNt+'</div></th>
                        <th><div class="disAsTableImmDis">'+immDisNt+'</div></th>
                        <th><div class="disAsTableRegMed">'+regMedNt+'</div></th>
                      </tr>
                    </table>
                    </div>
                    ';       // here we'll create whatever we need for each annotation

                    div.innerHTML=t;
                    div.id='divAnnotTable';
                    div.style.cssText = 'position:fixed;width:50px;left:'+x+';top:'+y+';-moz-border-radius:100px;border:1px  solid #ddd;-moz-box-shadow: 0px 0px 8px  #fff;';

                    callBack(div);
                }
                else {
                    WorkspaceApplication.getApplication().debug(error);
                }
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }

    static function divPubmed(screenData: Phylo5ScreenData,x:String,y:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;
            var al,auxtext:String;
            WorkspaceApplication.getApplication().debug("access db");
            al='pubmedAllDiv';auxtext='';
            if (screenData.suboption==1){ al='pubmedCSNDiv'; auxtext="in Cell/Science/Nature";}
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{target : screenData.target}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var div = js.Browser.document.createElement('div');        // Create DIV element
                    div.id = "box";

                    var numMax, numMid:Float;
                    var numMidt:String='';
                    var numArray: Array<String>;
                    var heightArray:Array<Int>;
                    numArray=new Array();
                    heightArray=new Array();

                    if (results[0]!=null){
                        numMax=results[0].pubs;
                        for (i in 1 ... results.length){
                            if (results[i].pubs>numMax) numMax=results[i].pubs;
                        }
                        var a=numMax/2;
                        if (numMax!=1){
                            var a=numMax/2;
                            numMid=Math.round(a);
                            numMidt=''+numMid;
                        }else numMidt='';

                        for (i in 0 ... results.length){
                            heightArray[i]=Math.round((150*results[i].pubs)/numMax);
                            if ((results[i].pubs==0)) numArray[i]='';
                            else numArray[i]=''+results[i].pubs+'';
                        }
                    }
                    else {numMax=1;numArray[0]='0';heightArray[0]=0;numMidt=''+'';}
                    var totalwidth=results.length*35 +180;
                    var t = '<style type="text/css">
                    .pubmedTableContent {width:'+totalwidth+'px; background-color:#ffffff; border:1px solid #cccccc; padding:5px; }
                    .pubmedTable  {border-collapse:collapse;border-spacing:0;}
                    .pubmedTableN2  {margin-left:117px; margin-top:8px;}
                    .pubmedTable th{vertical-align: bottom!important;}
                    .pubmedTablePreText{margin-top:30px;padding:0 3px; float:left;-webkit-transform: rotate(-90deg); -moz-transform: rotate(-90deg);-ms-transform: rotate(-90deg);-o-transform: rotate(-90deg);transform: rotate(-90deg); font-size:11px;}
                    .pubmedTableNum{float:left;width:25px;border-right:1px solid #000;}
                    .pubmedTable th a {text-decoration:none!important;}
                    .pubmedTableNum .pubmedTableTop {height:70px;}
                    .pubmedTableNum .pubmedTableMiddle {height:70px;}
                    .pubmedTableNum .pubmedTableBottom {}
                    .pubmedTableYear{width:18px; -webkit-transform: rotate(-90deg); -moz-transform: rotate(-90deg);-ms-transform: rotate(-90deg);-o-transform: rotate(-90deg);transform: rotate(-90deg); font-size:9px;}';

                    for (i in 0 ...numArray.length){
                        t=t+'.pubmedTable .pubmedTable'+i+' {font-size:10px;background-color:#2980d6;width:20px;height:'+heightArray[i]+'px;}';
                    }
                    t=t+'
                    </style>
                    <div class="pubmedTableContent">
                    <h3>Pubmed for '+screenData.target+' '+auxtext+'</h3>
                    <div class="pubmedTablePreText"># of Publications</div>
                    <div class="pubmedTableNum"> <div class="pubmedTableTop">'+numMax+'</div><div class="pubmedTableMiddle">'+numMidt+'</div><div class="pubmedTableBottom">0</div></div>
                    <table class="pubmedTable">
                      <tr>';
                    for (i in 0 ...numArray.length){
                        t=t+'<th><a href="http://www.google.com" target="_blank"><div class="pubmedTable'+i+'">'+numArray[i]+'</div></a></th>';
                    }
                    t=t+'
                      </tr>
                    </table>
                    <table class="pubmedTableN2">
                      <tr>';
                    for (i in 0 ...results.length){
                        t=t+'<th><div class="pubmedTableYear">'+results[i].year+'</div></th>';
                    }
                    t=t+'
                      </tr>
                    </table>
                    </div>
                    ';       // here we'll create whatever we need for each annotation

                    div.innerHTML=t;
                    div.id='divAnnotTable';
                    div.style.cssText = 'position:fixed;width:50px;left:'+x+';top:'+y+';-moz-border-radius:100px;border:1px  solid #ddd;-moz-box-shadow: 0px 0px 8px  #fff;';

                    callBack(div);
                }
                else {
                    WorkspaceApplication.getApplication().debug(error);
                }
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }


    static function divNonSilent(screenData: Phylo5ScreenData,x:String,y:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;
            var div = js.Browser.document.createElement('div');        // Create DIV element
            div.id = "box";

            var t = '<style type="text/css">
                    .interactionContent {width:500px; background-color:#ffffff; border:1px solid #cccccc;}
                    .interactionTitle{background-color:#eee; padding:5px 15px; }
                    .interactionInfo{font-size:10px}
                    .interactionResult{padding:3px 10px ;}
                    </style>
                    <div class="interactionContent">
                    <div class="interactionTitle">
                    <h3>Non-silent SNPs ('+screenData.target+')</h3>
                    <img src="http://apps.thesgc.org/resources/phylogenetic_trees/polymorphism_images/'+screenData.root.targetFamily+'/'+screenData.target+'-1_'+screenData.root.targetFamily+'.png"><br>
                    </div></div>
                ';
            div.innerHTML=t;
            div.id='divAnnotTable';
            div.style.cssText = 'position:fixed;width:50px;left:'+x+';top:'+y+';-moz-border-radius:100px;border:1px  solid #ddd;-moz-box-shadow: 0px 0px 8px  #fff;';

            callBack(div);
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }

    static function divInteraction(screenData: Phylo5ScreenData,x:String,y:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;
            var div = js.Browser.document.createElement('div');        // Create DIV element
            div.id = "box";

            var t = '<style type="text/css">
                    .interactionContent {width:500px; background-color:#ffffff; border:1px solid #cccccc;}
                    .interactionTitle{background-color:#eee; padding:5px 15px; }
                    .interactionInfo{font-size:10px}
                    .interactionResult{padding:3px 10px ;}
                    </style>
                    <div class="interactionContent">
                    <div class="interactionTitle">
                    <h3>Protein Interaction ('+screenData.target+')</h3>
                    <img src="http://apps.thesgc.org/resources/phylogenetic_trees/interaction/'+screenData.target+'.png"><br>
                    <span class="interactionInfo">Image Source: http://string-db.org</span>
                    </div></div>
                ';
            div.innerHTML=t;
            div.id='divAnnotTable';
            div.style.cssText = 'position:fixed;width:50px;left:'+x+';top:'+y+';-moz-border-radius:100px;border:1px  solid #ddd;-moz-box-shadow: 0px 0px 8px  #fff;';

            callBack(div);


        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }

    static function divSummary(screenData: Phylo5ScreenData,x:String,y:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;
            var al,auxtext:String;
            WorkspaceApplication.getApplication().debug("access db");
            al='summaryDiv';auxtext='';
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{target : screenData.target}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var div = js.Browser.document.createElement('div');        // Create DIV element
                    div.id = "box";

                    var ii:Int;
                    var ttext:String;
                    var uniprot:String;
                    ttext="";uniprot="";

                    for(ii in 0...results.length){
                        ttext=ttext+results[ii].fun+'<br><br>';
                        uniprot=results[ii].uniprot;
                    }
                    if((ttext=='null<br><br>')||(ttext=='<br><br>')) ttext="No Summary Available";

                    var t = '<style type="text/css">
                    .summaryContent {width:300px; background-color:#ffffff; border:1px solid #cccccc;}
                    .summaryTitle{background-color:#eee; padding:5px 15px; }
                    .summaryInfo{font-size:10px}
                    .summaryResult{padding:3px 10px ;}
                    </style>
                    <div class="summaryContent">
                    <div class="summaryTitle">
                    <h3><a href="http://www.uniprot.org/uniprot/'+uniprot+'" target="_blank">'+screenData.target+'</a></h3>
                    <span class="summaryInfo">Click title for Uniprot reference page</span>
                    </div><br><br>
                    <div class="summaryResult">
                    '+ttext+'
                    </div>
                    </div>';       // here we'll create whatever we need for each annotation

                    div.innerHTML=t;
                    div.id='divAnnotTable';
                    div.style.cssText = 'position:fixed;width:50px;left:'+x+';top:'+y+';-moz-border-radius:100px;border:1px  solid #ddd;-moz-box-shadow: 0px 0px 8px  #fff;';

                    callBack(div);
                }
                else {
                    WorkspaceApplication.getApplication().debug(error);
                }
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }

    static function divChemicalProbes(screenData: Phylo5ScreenData,x:String,y:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;
            var al,auxtext:String;
            WorkspaceApplication.getApplication().debug("access db");
            al='chemicalDiv';
            auxtext='';
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{target : screenData.target}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var div = js.Browser.document.createElement('div');        // Create DIV element
                    div.id = "box";

                    var ii:Int;
                    var ttext:String;
                    ttext="";

                    ii=0;
                    for(ii in 0...results.length){
                        ttext=ttext+'<div class="inhibitorsRes"><img src="http://apps.thesgc.org/resources/phylogenetic_trees/ligands_images/ligand'+results[ii].pkey+'.png"><br>
                        '+results[ii].name+'<br>';
                        if(results[ii].ic50!=null)ttext=ttext+'IC50/Kd/Ki: '+results[ii].ic50+'&microM<br>';
                        if((results[ii].pmid!=null)||(results[ii].pmid!='')) ttext=ttext+'Pubmed ID: <a href="http://www.ncbi.nlm.nih.gov/pubmed/'+results[ii].pmid+'" target="_blank">'+results[ii].pmid+'</a>';
                        if((results[ii].ref!=null)||(results[ii].ref!='')) ttext=ttext+results[ii].ref+'<br>';
                        ttext=ttext+'</div>';
                    }

                    var l:Int;
                    l=(ii+1)*310;
                    var t = '
                    <style type="text/css">
                    .inhibitorsContent {width:'+l+'px; background-color:#ffffff; border:1px solid #cccccc;}
                    .inhibitorsTitle{background-color:#eee; padding:5px 15px; }
                    .inhibitorsInfo{font-size:10px}
                    .inhibitorsResult{padding:3px 10px ;}
                    </style>
                    <div class="inhibitorsContent">
                    <div class="inhibitorsTitle">
                    <h3>'+screenData.target+'</h3>
                    <span class="inhibitorsInfo">Activity indicated is that reported by authors, but does not necessarily indicate an examination of the mechanism of action of the compound</span>
                    <div class="inhibitorsResult">
                    '+ttext+'
                    </div>
                    </div>
                    </div>';

// here we'll create whatever we need for each annotation

                    div.innerHTML=t;
                    div.id='divAnnotTable';
                    div.style.cssText = 'position:fixed;width:50px;left:'+x+';top:'+y+';-moz-border-radius:100px;border:1px  solid #ddd;-moz-box-shadow: 0px 0px 8px  #fff;';

                    callBack(div);
                }
                else {
                    WorkspaceApplication.getApplication().debug(error);
                }
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }

    static function divLigands(screenData: Phylo5ScreenData,x:String,y:String, callBack : Dynamic->Void){


        if(screenData.divAccessed==false){
            screenData.divAccessed=true;
            var al,auxtext:String;
            WorkspaceApplication.getApplication().debug("access db");
            al='';
            switch(screenData.suboption){
                case 1:al='ligands95Div';
                case 2:al='ligands95BestDiv';
                case 3:al='ligands40Div';
            }
            auxtext='';
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{pkey : screenData.annotation.text}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var div = js.Browser.document.createElement('div');        // Create DIV element
                    div.id = "box";

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
                        ttext=ttext+'<div class="ligandRes"><img src="http://apps.thesgc.org/resources/phylogenetic_trees/pdb_ligand_images/'+myArray[a].id+'.gif" width="250px"><br>
                        '+myArray[a].id+'<br>structures:';

                        for(pdbi in 0...myArray[a].pdbs.length){
                            var pdbb=myArray[a].pdb.get(myArray[a].pdbs[pdbi]);
                            var tit=pdbb.title;
                            var cent=pdbb.percent;

                            ttext=ttext+'<a href="http://www.rcsb.org/pdb/explore/explore.do?structureId='+myArray[a].pdbs[pdbi]+'" alt="'+tit+'" target="_blank">'+myArray[a].pdbs[pdbi]+'</a>('+cent+'%) - ';
                        }

                        ttext=ttext+'</div><br>';
                    }

                    var t = '
                    <style type="text/css">
                    .inhibitorsContent {width:400px; background-color:#ffffff; border:1px solid #cccccc;}
                    .inhibitorsTitle{background-color:#eee; padding:5px 15px; }
                    .inhibitorsInfo{font-size:10px}
                    .inhibitorsResult{padding:3px 10px ;}
                    </style>
                    <div class="inhibitorsContent">
                    <div class="inhibitorsTitle">
                    <h3>'+screenData.target+'</h3>
                    <div class="inhibitorsResult">
                    '+ttext+'
                    </div>
                    </div>
                    </div>';

// here we'll create whatever we need for each annotation

                    div.innerHTML=t;
                    div.id='divAnnotTable';
                    div.style.cssText = 'position:fixed;width:50px;left:'+x+';top:'+y+';-moz-border-radius:100px;border:1px  solid #ddd;-moz-box-shadow: 0px 0px 8px  #fff;';

                    callBack(div);
                }
                else {
                    WorkspaceApplication.getApplication().debug(error);
                }
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }

    static function divInhibitors(screenData: Phylo5ScreenData,x:String,y:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;
            var al,auxtext:String;
            WorkspaceApplication.getApplication().debug("access db");
            al='';
            switch(screenData.suboption){
                case 0:al='inhibitorsAllDiv';
                case 1:al='inhibitors5nDiv';
                case 2:al='inhibitors2nDiv';
                case 3:al='inhibitors05nDiv';
            }
            auxtext='';
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{target : screenData.target}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var div = js.Browser.document.createElement('div');        // Create DIV element
                    div.id = "box";

                    var ii:Int;
                    var ttext:String;
                    ttext="";

                    ii=0;
                    for(ii in 0...results.length){
                        ttext=ttext+'<div class="inhibitorsRes"><img src="http://apps.thesgc.org/resources/phylogenetic_trees/ligands_images/ligand'+results[ii].pkey+'.png"><br>
                        '+results[ii].name+'<br>';
                        if(results[ii].ic50!=null)ttext=ttext+'IC50/Kd/Ki: '+results[ii].ic50+'&microM<br>';
                        if((results[ii].pmid!=null)||(results[ii].pmid!='')) ttext=ttext+'Pubmed ID: <a href="http://www.ncbi.nlm.nih.gov/pubmed/'+results[ii].pmid+'" target="_blank">'+results[ii].pmid+'</a>';
                        if((results[ii].ref!=null)||(results[ii].ref!='')) ttext=ttext+results[ii].ref+'<br>';
                        ttext=ttext+'</div>';
                    }

                    var l:Int;
                    l=(ii+1)*310;
                    var t = '
                    <style type="text/css">
                    .inhibitorsContent {width:'+l+'px; background-color:#ffffff; border:1px solid #cccccc;}
                    .inhibitorsTitle{background-color:#eee; padding:5px 15px; }
                    .inhibitorsInfo{font-size:10px}
                    .inhibitorsResult{padding:3px 10px ;}
                    </style>
                    <div class="inhibitorsContent">
                    <div class="inhibitorsTitle">
                    <h3>'+screenData.target+'</h3>
                    <span class="inhibitorsInfo">Activity indicated is that reported by authors, but does not necessarily indicate an examination of the mechanism of action of the compound</span>
                    <div class="inhibitorsResult">
                    '+ttext+'
                    </div>
                    </div>
                    </div>';

// here we'll create whatever we need for each annotation

                    div.innerHTML=t;
                    div.id='divAnnotTable';
                    div.style.cssText = 'position:fixed;width:50px;left:'+x+';top:'+y+';-moz-border-radius:100px;border:1px  solid #ddd;-moz-box-shadow: 0px 0px 8px  #fff;';

                    callBack(div);
                }
                else {
                    WorkspaceApplication.getApplication().debug(error);
                }
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }

    static function divSubstrate(screenData: Phylo5ScreenData,x:String,y:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;
            var al,auxtext:String;
            WorkspaceApplication.getApplication().debug("access db");
            al='substrateDiv';auxtext='';
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{target : screenData.target, subb: screenData.annotation.text}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var div = js.Browser.document.createElement('div');        // Create DIV element
                    div.id = "box";

                    var ii:Int;
                    var ttext:String;
                    var subs:String;
                    ttext="Pubmed Ids: <br>";subs="";

                    for(ii in 0...results.length){
                        ttext=ttext+'<a href="http://www.ncbi.nlm.nih.gov/pubmed/'+results[ii].pmid_list+'" target="_blank">'+results[ii].pmid_list+'</a><br><br>';
                        subs=results[ii].sub;
                        break;
                    }


                    var t = '<style type="text/css">
                    .substrateContent {width:300px; background-color:#ffffff; border:1px solid #cccccc;}
                    .substrateTitle{background-color:#eee; padding:5px 15px; }
                    .substrateResult{padding:3px 10px ;}
                    </style>
                    <div class="substrateContent">
                    <div class="substrateTitle">
                    <h3>'+screenData.target+' ('+subs+')</h3>
                    </div><br><br>
                    <div class="substrateResult">
                    '+ttext+'
                    </div>
                    </div>';       // here we'll create whatever we need for each annotation

                    div.innerHTML=t;
                    div.id='divAnnotTable';
                    div.style.cssText = 'position:fixed;width:50px;left:'+x+';top:'+y+';-moz-border-radius:100px;border:1px  solid #ddd;-moz-box-shadow: 0px 0px 8px  #fff;';

                    callBack(div);
                }
                else {
                    WorkspaceApplication.getApplication().debug(error);
                }
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }

    static function divSubcellular(screenData: Phylo5ScreenData,x:String,y:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;
            var al,auxtext:String;
            WorkspaceApplication.getApplication().debug("access db");
            al='subcellularDiv';auxtext='';
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{target : screenData.target}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var div = js.Browser.document.createElement('div');        // Create DIV element
                    div.id = "box";

                    var ii:Int;
                    var ttext:String;
                    var subs:String;
                    ttext=results[0].location+'<br>';



                    var t = '<style type="text/css">
                    .subcellularContent {width:300px; background-color:#ffffff; border:1px solid #cccccc;}
                    .subcellularTitle{background-color:#eee; padding:5px 15px; }
                    .subcellularInfo{font-size:10px}
                    .subcellularResult{padding:3px 10px ;}
                    </style>
                    <div class="subcellularContent">
                    <div class="subcellularTitle">
                    <h3><a href="http://www.uniprot.org/uniprot/'+results[0].uniprot+'" target="_blank">'+screenData.target+'</a></h3>
                    <span class="subcellularInfo">Click title for Uniprot reference page</span>
                    </div><br><br>
                    <div class="subcellularResult">
                    '+ttext+'
                    </div>
                    </div>';       // here we'll create whatever we need for each annotation

                    div.innerHTML=t;
                    div.id='divAnnotTable';
                    div.style.cssText = 'position:fixed;width:50px;left:'+x+';top:'+y+';-moz-border-radius:100px;border:1px  solid #ddd;-moz-box-shadow: 0px 0px 8px  #fff;';

                    callBack(div);
                }
                else {
                    WorkspaceApplication.getApplication().debug(error);
                }
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }

    static function divInteractome(screenData: Phylo5ScreenData,x:String,y:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;
            var al,auxtext:String;
            WorkspaceApplication.getApplication().debug("access db");
            al='interactomeDiv';auxtext='';
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{target : screenData.target}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var div = js.Browser.document.createElement('div');        // Create DIV element
                    div.id = "box";

                    var ii:Int;
                    var ttext:String;
                    var subs:String;
                    ttext="";

                    for(ii in 0...results.length){
                        ttext=ttext+'<a href="http://www.ncbi.nlm.nih.gov/gene/?term='+results[ii].geneid_b+'" target="_blank">'+results[ii].target_id_b+'</a><br>';
                    }


                    var t = '<style type="text/css">
                    .interactomeContent {width:300px; background-color:#ffffff; border:1px solid #cccccc;}
                    .interactomeTitle{background-color:#eee; padding:5px 15px; }
                    .interactomeResult{padding:3px 10px ;}
                    </style>
                    <div class="interactomeContent">
                    <div class="interactomeTitle">
                    <h3>Protein Interactome ('+screenData.target+')</h3>
                    </div><br><br>
                    <div class="interactomeResult">
                    '+ttext+'
                    </div>
                    </div>';

                    div.innerHTML=t;
                    div.id='divAnnotTable';
                    div.style.cssText = 'position:fixed;width:50px;left:'+x+';top:'+y+';-moz-border-radius:100px;border:1px  solid #ddd;-moz-box-shadow: 0px 0px 8px  #fff;';

                    callBack(div);
                }
                else {
                    WorkspaceApplication.getApplication().debug(error);
                }
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }

    static function divOrphanet(screenData: Phylo5ScreenData,x:String,y:String, callBack : Dynamic->Void){

        if(screenData.divAccessed==false){
            screenData.divAccessed=true;
            var al,auxtext:String;
            WorkspaceApplication.getApplication().debug("access db");
            al='orphanetDiv';auxtext='';
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery(al,{target : screenData.target}, null, true, function(results: Dynamic, error){
                if(error == null) {
                    var div = js.Browser.document.createElement('div');        // Create DIV element
                    div.id = "box";

                    var ii:Int;
                    var ttext:String;
                    var geneid:String;
                    ttext="";geneid="";

                    for(ii in 0...results.length){
                        ttext=ttext+results[ii].disorder_gene_assoc_type+' '+results[ii].disorder_name+' ('+results[ii].disorder_gene_assoc_status+')<br><br>';
                        geneid=results[ii].geneid;
                    }

                    var t = '<style type="text/css">
                    .orphanetContent {width:300px; background-color:#ffffff; border:1px solid #cccccc;}
                    .orphanetTitle{background-color:#eee; padding:5px 15px; }
                    .orphanetInfo{font-size:10px}
                    .orphanetResult{padding:3px 10px ;}
                    </style>
                    <div class="orphanetContent">
                    <div class="orphanetTitle">
                    <h3><a href="http://www.orpha.net/consor/cgi-bin/Disease_Genes.php?lng=EN&data_id='+geneid+'" target="_blank">'+screenData.target+'</a></h3>
                    <span class="orphanetInfo">Click title for Orphanet reference page</span>
                    </div><br><br>
                    <div class="orphanetResult">
                    '+ttext+'
                    </div>
                    </div>';       // here we'll create whatever we need for each annotation

                    div.innerHTML=t;
                    div.id='divAnnotTable';
                    div.style.cssText = 'position:fixed;width:50px;left:'+x+';top:'+y+';-moz-border-radius:100px;border:1px  solid #ddd;-moz-box-shadow: 0px 0px 8px  #fff;';

                    callBack(div);
                }
                else {
                    WorkspaceApplication.getApplication().debug(error);
                }
            });
        }
        else
            WorkspaceApplication.getApplication().debug("NOT access db");
    }

/***** methods that will create the content of central panel when the annotation is family tree based ******************/
    static function familyDomain(targetFamily: String,callBack : Dynamic->Void){
        var component = Ext.create('Ext.Img', {
            src: "http://apps.thesgc.org/resources/phylogenetic_trees/static_images/"+targetFamily+"_tree.png",
            renderTo: Ext.getBody()
        });
        callBack(component);
    }

}

