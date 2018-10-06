package saturn.client.programs.phylo;
import saturn.client.WorkspaceApplication;
import saturn.client.programs.chromohub.ChromoHubViewer;
import saturn.client.programs.phylo.PhyloAnnotation.HasAnnotationType;
import saturn.core.Util;

class PhyloAnnotationManager {
    public var annotations: Array<PhyloAnnotation>;
    public var rootNode : PhyloTreeNode;
    public var canvas : PhyloCanvasRenderer;
    public var treeName : String;
    public var subtreeName : String;
    public var treeType : String;
    public var numTotalAnnot: Int;
    public var legacyViewer : ChromoHubViewer;
    public var searchedGenes :Array<String>;

    /**
    *
    *
    **/

    var nameAnnot: Array<String>;
    public var jsonFile : Dynamic;
    public var viewOptions : Array <Dynamic>;
    public var activeAnnotation:Array<Bool>;
    public var alreadyGotAnnotation:Map<String,Bool>;
    public var selectedAnnotationOptions = [];
    public var onSubmenu:Bool=false;
    public var menuScroll=0;

    public function new(legacyViewer : ChromoHubViewer) {
        this.legacyViewer = legacyViewer;
        annotations = new Array<PhyloAnnotation>();
        activeAnnotation=new Array();
        alreadyGotAnnotation=new Map<String, Bool>();
        selectedAnnotationOptions = new Array();
        searchedGenes=new Array();
    }

    /**
    *  Sefa legacy below
    **/
    public function showScreenData(active:Bool, data: PhyloScreenData, mx: Int, my:Int){
        if(this.canvas == null){
            return;
        }

        if(active==false){
            var mxx:String;
            mxx=mx+'px';
            var myy:String;
            myy=my+'px';
            if(data.created==false){
                var container = WorkspaceApplication.getApplication().getSingleAppContainer();
                container.hideExportSubMenu();
                container.hideHelpingDiv();
                container.hideSubMenuToolBar();
                data.divAccessed=false;
                if((annotations[data.annotation.type].hasClass!=null)&&(annotations[data.annotation.type].divMethod!=null)){
                    var hook:Dynamic;
                    var clazz,method:String;

                    data.suboption=annotations[data.annotation.type].optionSelected[0];
                    data.title=annotations[data.annotation.type].label;
                    data.family = treeName;
                    clazz=annotations[data.annotation.type].hasClass;
                    method=annotations[data.annotation.type].divMethod;

                    hook = Reflect.field(Type.resolveClass(clazz), method);
                    hook(data,mxx, myy,treeType, function(div){
                        data.created=true;
                        data.div=div;
                        var nn='';
                        if(data.target!=data.targetClean){
                            if(data.target.indexOf('(')!=-1 || data.target.indexOf('-')!=-1){
                                var auxArray=data.target.split('');
                                var j:Int;
                                for(j in 0...auxArray.length){
                                    if (auxArray[j]=='(' || auxArray[j]=='-') {
                                        nn=auxArray[j+1];
                                        break;
                                    }
                                }
                            }
                        }
                        if(data.annotation.type==4){
                            if(data.annotation.text.indexOf('.')!=-1){
                                var auxArray=data.annotation.text.split('');
                                var j:Int;
                                var naux='';
                                for(j in 0...auxArray.length){
                                    if(auxArray[j]!='.') naux+=auxArray[j];
                                }
                                nn=nn+naux;
                            }else if(data.annotation.text.indexOf('/')!=-1){
                                var auxArray=data.annotation.text.split('');
                                var j:Int;
                                var naux='';
                                for(j in 0...auxArray.length){
                                    if(auxArray[j]!='/') naux+=auxArray[j];
                                }
                                nn=nn+naux;
                            }else nn=nn+data.annotation.text;
                        }

                        var nom='';
                        if(data.targetClean.indexOf('/')!=-1){
                            var auxArray=data.targetClean.split('');
                            var j:Int;
                            for(j in 0...auxArray.length){
                                if(auxArray[j]!='/') nom+=auxArray[j];
                            }
                        }else nom=data.targetClean;
                        var id=data.annotation.type+'-'+nom+nn;
                        container.showAnnotWindow(div, mx, my,data.title,id,data);
                    });
                }
            }else{

            }
        }else{
            //we need to remove the div
            if(this.rootNode.divactive!=99999){
                if(this.rootNode.screen[this.rootNode.divactive]!=null) this.rootNode.screen[this.rootNode.divactive].created=false;
                this.rootNode.divactive=99999;

            }
        }
    }




    public function fillAnnotationwithJSonData(){

        var i=0; var j=0; var z=0;
        nameAnnot=new Array();

        var b=0;
        while(i< jsonFile.btnGroup.length){
            j=0;
            while(j<jsonFile.btnGroup[i].buttons.length){

                //check if it's a subtitle
                if(jsonFile.btnGroup[i].buttons[j].isTitle==false){
                    var a:Int;
                    a=jsonFile.btnGroup[i].buttons[j].annotCode;
                    annotations[a]= new PhyloAnnotation();

                    selectedAnnotationOptions[a] = null;

                    if (jsonFile.btnGroup[i].buttons[j].shape == "image") {
                        annotations[a].uploadImg(jsonFile.btnGroup[i].buttons[j].annotImg); //summary
                    }
//this.activeAnnotation.set(jsonFile.btnGroup[i].buttons[j].annotCode]=false;
                    this.alreadyGotAnnotation[jsonFile.btnGroup[i].buttons[j].annotCode]=false;
                    annotations[a].shape=jsonFile.btnGroup[i].buttons[j].shape;
                    annotations[a].label=jsonFile.btnGroup[i].buttons[j].label;
                    annotations[a].color=jsonFile.btnGroup[i].buttons[j].color;
// annotations[a].type=jsonFile.btnGroup[i].buttons[j].annotCode;
                    annotations[a].hookName=jsonFile.btnGroup[i].buttons[j].hookName;
                    annotations[a].splitresults=jsonFile.btnGroup[i].buttons[j].splitresults;
                    annotations[a].popup=jsonFile.btnGroup[i].buttons[j].popUpWindows;

                    if(jsonFile.btnGroup[i].buttons[j].hasClass!=null) annotations[a].hasClass=jsonFile.btnGroup[i].buttons[j].hasClass;

                    if(jsonFile.btnGroup[i].buttons[j].hasMethod!=null) annotations[a].hasMethod=jsonFile.btnGroup[i].buttons[j].hasMethod;
                    if(jsonFile.btnGroup[i].buttons[j].divMethod!=null) annotations[a].divMethod=jsonFile.btnGroup[i].buttons[j].divMethod;
                    if(jsonFile.btnGroup[i].buttons[j].familyMethod!=null) annotations[a].familyMethod=jsonFile.btnGroup[i].buttons[j].familyMethod;
                    if(jsonFile.btnGroup[i].buttons[j].popUpWindows!=null && jsonFile.btnGroup[i].buttons[j].popUpWindows==true){
                        annotations[a].popMethod=jsonFile.btnGroup[i].buttons[j].windowsData[0].popMethod;
                    }

                    annotations[a].options=new Array();
                    if(jsonFile.btnGroup[i].buttons[j].legend!=null){
                        annotations[a].legend=jsonFile.btnGroup[i].buttons[j].legend.image;

                        if(jsonFile.btnGroup[i].buttons[j].legend.clazz != null) {
                            annotations[a].legendClazz = jsonFile.btnGroup[i].buttons[j].legend.clazz;
                            annotations[a].legendMethod = jsonFile.btnGroup[i].buttons[j].legend.method;
                        }
                    }

                    if(jsonFile.btnGroup[i].buttons[j].hidden != null){
                        annotations[a].hidden = jsonFile.btnGroup[i].buttons[j].hidden;
                    }

                    if(jsonFile.btnGroup[i].buttons[j].submenu==true){
                        var zz:Int;
                        for (zz in 0 ...jsonFile.btnGroup[i].buttons[j].options.length){
                            annotations[a].options[zz]=jsonFile.btnGroup[i].buttons[j].options[zz].hookName;
                            if(jsonFile.btnGroup[i].buttons[j].options[zz].defaultImg!=null)
                                annotations[a].defaultImg=jsonFile.btnGroup[i].buttons[j].options[zz].defaultImg;
                        }
                        annotations[a].optionSelected[0] = jsonFile.btnGroup[i].buttons[j].optionSelected[0];
                    }
                    nameAnnot[b]=jsonFile.btnGroup[i].buttons[j].label;
                    b++;
                }
                j++;
            }
            numTotalAnnot=numTotalAnnot+j;
            i++;
        }
    }



    public function createViewOptions(){
        viewOptions = new Array<Dynamic>();

        if(jsonFile == null){
            return;
        }

        var i=0;var j=0;
        while(i< jsonFile.btnGroup.length){

            //we generate the annotations menu from json file
            viewOptions[j]=
            {
                text : jsonFile.btnGroup[i].title,
                margin: '0 10 5 0',
                xtype : 'label',
                cls : 'x-title-viewoptions'
            };
            var z=0;
            j++;
            while(z<jsonFile.btnGroup[i].buttons.length){
                var b=jsonFile.btnGroup[i].buttons[z];

                if(!b.enabled){
                    z++;
                    continue;
                }

                // Hard coded to hide annotations for some of the trees
                if(b.annotCode == 26 && treeName == 'E1' || b.annotCode == 26 && treeName == 'E2' || b.annotCode == 26 && treeName == 'USP'){
                    z++;
                    continue;
                }

                if(b.hidden == true){
                    z++;
                    continue;
                }

                if(b.isTitle==true){
                    viewOptions[j]=
                    {
                        text : b.label,
                        margin: '0 0 5 0',
                        xtype : 'label',
                        cls : 'x-title-viewsuboptions'
                    };
                }else{
                    var auxtext:String;
                    if(b.submenu){
                        var k=b.optionSelected[0];
                        auxtext = b.label+' ('+b.options[k].label+')';
                    }
                    else auxtext = b.label;
                    var tit=b.label+' Options';
                    //we need to create the help button

                    var _viewOptions_Items :Array<Dynamic>= [
                        {
                            text:'',
                            margin: '0',
                            xtype : 'button',
                            cls : 'x-button-helpicon',
                            icon : '/static/js/images/helpicon.png',
                            handler: function(){},
                            listeners:{
                                mouseout:
                                function(e){
                                    closeHelpingDiv();

                                },
                                mouseover:
                                    //show a flying help div
                                function(e){
                                    prepareHelpingDiv(e,b.helpText);
                                }
                            }
                        },

                        {
                            text:'',
                            margin: '0',
                            xtype : if(this.activeAnnotation[b.annotCode]==true) 'button' else 'container',
                            width: 19,
                            cls : if(this.activeAnnotation[b.annotCode]==true) 'x-button-uncheck-icon' else 'x-button-hidden',
                            icon : '/static/js/images/checkicon.png',
                            handler: function(){

                                var elem=js.Browser.document.getElementById('optionToolBarId');
                                menuScroll=elem.scrollTop;
                                var container=WorkspaceApplication.getApplication().getSingleAppContainer();

                                closeAnnotWindows();

                                showAnnotation(b.annotCode,false);

                                // Hard coded to close hidden annotations
                                if (b.annotCode == 25){
                                    showAnnotation(30,false);
                                }
                                if (b.annotCode == 28){
                                    showAnnotation(29,false);
                                }

                                container.clearOptionsToolBar();
                                createViewOptions();
                                container.addElemToOptionsToolBar(viewOptions);

                                var elem=js.Browser.document.getElementById('optionToolBarId');
                                elem.scrollTop=menuScroll;
                            },
                            listeners:{
                                mouseout:
                                function(e){
                                    //hide the flying help div
                                    // closeHelpingDiv();

                                },
                                mouseover:
                                    //show a flying help div
                                function(e){
                                    closeHelpingDiv();
                                }
                            }
                        },
                        {
                            html: '<span>' + auxtext + '</span>',
                            margin: '0 10 5 0',
                            xtype : 'button',

                            cls :
                            if(b.submenu) {
                                if(this.activeAnnotation != null && this.activeAnnotation.length > 0 && this.activeAnnotation[b.annotCode]==true) 'x-btn-viewoptions-suboptions-checked';
                                else  'x-btn-viewoptions-suboptions';
                            }
                            else if(b.popUpWindows) {
                                if(this.activeAnnotation != null && this.activeAnnotation.length > 0 && this.activeAnnotation[b.annotCode]==true) 'x-btn-viewoptions-popup-checked';
                                else  'x-btn-viewoptions-popup';
                            }
                            else{
                                if(this.activeAnnotation != null && this.activeAnnotation.length > 0 && this.activeAnnotation[b.annotCode]==true) 'x-btn-viewoptions-checked';
                                else
                                    'x-btn-viewoptions';
                            },
                            icon : '',
                            handler:
                            if(b.popUpWindows==true){
                                var ia=i; var za=z;
                                function(){
                                    var elem=js.Browser.document.getElementById('optionToolBarId');
                                    menuScroll=elem.scrollTop;
                                    var container=WorkspaceApplication.getApplication().getSingleAppContainer();

                                    closeAnnotWindows();

                                    container.clearPopUpWindow();
                                    container.setPosPopUpWindow(300,150);
                                    container.setPopUpWindowTitle(tit);

                                    var optt=jsonFile.btnGroup[ia].buttons[za].windowsData[0];
                                    container.addFormItemToPopUpWindow(optt.form.items,b.annotCode,optt.hasClass,optt.popMethod, this.treeType, this.treeName, null, this );
                                    container.showPopUpWindow();

                                    // Load annotation.js
                                    var fileref = js.Browser.document.createElement('script');
                                    fileref.setAttribute("type","text/javascript");
                                    fileref.setAttribute("src", '/static/js/annotation.js');
                                    js.Browser.document.head.appendChild(fileref);
                                };
                            }else {
                                function(){
                                    var elem=js.Browser.document.getElementById('optionToolBarId');
                                    menuScroll=elem.scrollTop;
                                    var act=this.activeAnnotation[b.annotCode];
                                    if(this.activeAnnotation[b.annotCode]==null || this.activeAnnotation[b.annotCode]==false){
                                        var container=WorkspaceApplication.getApplication().getSingleAppContainer();

                                        closeAnnotWindows();

                                        container.hideSubMenuToolBar();
                                        showAnnotation(b.annotCode,true);

                                        var cert=!this.activeAnnotation[b.annotCode];
                                        // if (tableActive==false){
                                        //it's the tree
                                        legacyViewer.updateLegend(b,cert);
                                        //}
                                        container.clearOptionsToolBar();
                                        createViewOptions();
                                        container.addElemToOptionsToolBar(viewOptions);
                                        var elem=js.Browser.document.getElementById('optionToolBarId');
                                        elem.scrollTop=menuScroll;
                                        if(legacyViewer.tableActive==true){
                                            legacyViewer.baseTable.reconfigure(legacyViewer.tableAnnot.tableDefinition);
                                        }
                                        if(cert==false){
                                            container.legendPanel.expand();
                                        }
                                    }
                                    else{


                                        var elem=js.Browser.document.getElementById('optionToolBarId');
                                        menuScroll=elem.scrollTop;
                                        var container=WorkspaceApplication.getApplication().getSingleAppContainer();

                                        closeAnnotWindows();

                                        showAnnotation(b.annotCode,false);

                                        container.clearOptionsToolBar();
                                        createViewOptions();
                                        container.addElemToOptionsToolBar(viewOptions);

                                        var elem=js.Browser.document.getElementById('optionToolBarId');
                                        elem.scrollTop=menuScroll;
                                    }

                                    //if (controlToolsActive == true) getApplication().getSingleAppContainer().showControlToolBar();
                                }
                            },
                            listeners:{
                                mouseout:
                                function(e){
                                    var container = WorkspaceApplication.getApplication().getSingleAppContainer();
                                    container.hideHelpingDiv();
                                    if (onSubmenu==false){
                                        container.hideSubMenuToolBar();
                                    }

                                },
                                mouseover:
                                if(b.submenu){
                                    var a=j;
                                    var subm:Array<Dynamic>;
                                    var t=0;
                                    var t1,i1,z1:Int;
                                    subm=new Array();
                                    t1=0;
                                    var nuopt=b.options.length;
                                    while (t<b.options.length){
                                        i1=i; z1=z; t1=t;
                                        subm[t]={
                                            text:b.options[t].label,
                                            //margin: '0 10 5 0',
                                            xtype : if((b.options[t].isTitle==false)&&(b.options[t].isLabelTitle==false)) 'button';
                                            else 'label',
                                            cls :
                                            if((b.options[t].isTitle==true)||(b.options[t].isLabelTitle==true)) {
                                                if(b.options[t].isTitle==true) 'x-btn-viewoptions-title';
                                                else 'x-btn-viewoptions-label';
                                            }
                                            else{
                                                if (b.optionSelected[0]==t)'x-btn-viewoptions-default';
                                                else 'x-btn-viewoptions';
                                            },

                                            handler:
                                            if((b.options[t].isTitle==false)&&(b.options[t].isLabelTitle==false)){
                                                var t2=t;
                                                function(){

                                                    var container=WorkspaceApplication.getApplication().getSingleAppContainer();

                                                    closeAnnotWindows();

                                                    var check:Bool;
                                                    check=changeDefaultOption(t2,i1,z1);
                                                    showAnnotation(b.annotCode,check);
                                                    container.hideExportSubMenu();
                                                    container.hideHelpingDiv();
                                                    container.hideSubMenuToolBar();
                                                    onSubmenu=false;
                                                    container.clearOptionsToolBar();
                                                    createViewOptions();
                                                    container.addElemToOptionsToolBar(viewOptions);
                                                }
                                            }
                                            else{
                                                function(){
                                                    //
                                                }
                                            },
                                            tooltip: { text: b.options[t].helpText}
                                        };
                                        t++;
                                    }
                                    function(e){
                                        var h = e.ownerCt.y - e.ownerCt.ownerCt.el.dom.scrollTop;
                                        var n=t;
                                        var container=WorkspaceApplication.getApplication().getSingleAppContainer();

                                        //closeAnnotWindows();

                                        container.hideHelpingDiv();
                                        container.clearSubMenuToolBar();
                                        container.addElemToSubMenuToolBar(subm);

                                        container.setTopSubMenuToolBar(h);
                                        container.setHeightSubMenuToolBar(n*25);

                                        container.showSubMenuToolBar();
                                        onSubmenu=true;
                                    }
                                }
                                else{
                                    function(e){
                                        var container = WorkspaceApplication.getApplication().getSingleAppContainer();
                                        container.hideHelpingDiv;

                                        // closeAnnotWindows();

                                        container.hideSubMenuToolBar();
                                        onSubmenu=false;
                                    }
                                }

                            }
                        }
                    ];

                    var _viewOptions = {
                        xtype: "container",
                        cls: "x-group2btns",
                        layout: "hbox",
                        items: _viewOptions_Items
                    };

                    viewOptions[j]=_viewOptions;

                }
                j++;z++;
            }

            i++;
        }
        var l=this.activeAnnotation.length;
        var i=1;
        var num=0;
        var showhide=false;
        while(i < l && num<2){
            if(this.activeAnnotation[i]==true){
                num++;
            }
            i++;
        }
        if(num==2) showhide=true;
        if(showhide==true){
            viewOptions[j]={
                text:'Hide all',
                margin: '20 10 5 0',
                xtype : 'button',
                cls : 'x-btn-viewoptions x-btn-viewoptions-hide',
                handler: function(){
                    onSubmenu=false;
                    var l=this.activeAnnotation.length;
                    var i=1;
                    while(i < l){
                        this.activeAnnotation[i]=false;
                        i++;
                    }

                    var container = WorkspaceApplication.getApplication().getSingleAppContainer();
                    container.hideExportSubMenu();
                    container.hideHelpingDiv();

                    closeAnnotWindows();

                    container.hideSubMenuToolBar();
                    container.clearOptionsToolBar();
                    createViewOptions();
                    container.emptyLegend();
                    container.addElemToOptionsToolBar(viewOptions);
                },
                listeners:{
                    mouseover:
                    function(e){
                        onSubmenu=false;
                        var container = WorkspaceApplication.getApplication().getSingleAppContainer();
                        container.hideExportSubMenu();
                        container.hideHelpingDiv();

                        // closeAnnotWindows();

                        container.hideSubMenuToolBar();
                    }
                },
                tooltip: {dismissDelay: 10000, text: 'Remove all Annotations'}
            };
        }
    }

    function closeHelpingDiv(){
        var container=WorkspaceApplication.getApplication().getSingleAppContainer();
        var i=0;
        for(i in 0...300000000){

        }
        if(container.hideHelp==true) container.hideHelpingDiv();
    }

    function prepareHelpingDiv(e: Dynamic, text:String){

        var h = e.ownerCt.y - e.ownerCt.ownerCt.el.dom.scrollTop;

        var container=WorkspaceApplication.getApplication().getSingleAppContainer();

        // closeAnnotWindows();

        container.hideHelp=true;
        container.clearHelpingDiv();

        container.addHtmlTextHelpingDiv(text);

        container.setTopHelpingDiv(h);

        container.showHelpingDiv();
    }

    public function setSelectedAnnotationOptions(annotation : Int, selectedOptions : Dynamic){
        selectedAnnotationOptions[annotation] = selectedOptions;
    }

    public function getSelectedAnnotationOptions(annotation : Int) : Dynamic{
        return selectedAnnotationOptions[annotation];
    }

    public function closeAnnotWindows(){
        var app = WorkspaceApplication.getApplication();

        if(app != null){
            var container = app.getSingleAppContainer();
            var annotWindow=container.annotWindow;
            var key:Int;
            var numWindows=0;
            for(key in annotWindow.keys()){
                numWindows++;
            }
            if(numWindows>1){
                WorkspaceApplication.getApplication().userPrompt('Question', 'You have popup windows opened. Do you want to close them?', function(){
                    container.removeAnnotWindows();
                });
            }else{
                if(numWindows==1){
                    container.removeAnnotWindows();
                }

            }
        }
    }

    //Function called when the user select any annotation to be added
    //like any of the checks in the current chromohub
    //depending on if it's already checked or not , active will be true or false
    public function showAnnotation(annotCode:Dynamic, active:Bool){
        //here we should check the scroll position for annotations menu

        var currentAnnot=annotCode;

        //update activeAnnotation array
        activeAnnotation[currentAnnot]=active;

        var container = WorkspaceApplication.getApplication().getSingleAppContainer();

        if(active==true){
            var i:Int;
            var needToExpandLegend=false;

            for (i in 0...activeAnnotation.length){
                if (activeAnnotation[i]==true){
                    if(annotations[i].legend!='' && annotations[i].legendClazz == '') {
                        needToExpandLegend=true;
                        container.addImageToLegend(annotations[i].legend, i);
                    } else if(annotations[i].legend != null && annotations[i].legendClazz != '' && annotations[i].legendMethod != ''){
                        var clazz = Type.resolveClass(annotations[i].legendClazz);
                        var method = Reflect.field(clazz, annotations[i].legendMethod);
                        var legend = method(treeName);

                        container.addImageToLegend(legend, i);
                    }
                }
            }
            if( needToExpandLegend==true){
                container.legendPanel.expand();
            }
            var annot=annotations[currentAnnot];


            if(annot.hookName != null && annot.hookName != ''){
                var myGeneList: Array<String>;
                myGeneList=this.rootNode.targets;

                var currentOption=100;
                var alias:Dynamic;
                var dbAccessed=false;
                var u:Int;
                if(annot.options.length==0){ //there aren't options
                    alias= annot.hookName;
                    annot.defaultImg=0;
                    if(alreadyGotAnnotation.exists(alias)==false){ //it's the first time we access the db
                        alreadyGotAnnotation.set(alias,true);//we need to add it
                        dbAccessed=false;
                    }
                    else {dbAccessed=true;}
                }else{
                    if(annot.optionSelected.length==1){
                        currentOption =annot.optionSelected[0];
                        alias= annot.options[currentOption];
                        if(annot.defaultImg==null) annot.defaultImg=0;
                        else annot.defaultImg=currentOption;
                        dbAccessed=false;
                    }
                    else{
                        dbAccessed=false;
                        alias='';
                    }
                }

                var error:Dynamic;
                dbAccessed=false;
                if(dbAccessed==false){
                    var parameter:Dynamic;
                    //before calling the mysql select, we need to check the tree type (domain or gene)
                    if(treeName!=''){
                        if(this.treeName.indexOf('/')!=-1){
                            var aux=this.treeName.split('/');
                            parameter=aux[1];
                        }
                        else{
                            parameter=this.treeName;
                        }
                        if(this.treeType=='gene'){
                            alias='gene_'+alias;
                        }
                    }else{ //own genes option
                        parameter=this.rootNode.targets;
                    }

                    WorkspaceApplication.getApplication().getProvider().getByNamedQuery(alias,{param : parameter}, null, true, function(db_results, error){
                        if(error == null) {
                            addAnnotData(db_results,currentAnnot,currentOption, function(){
                                legacyViewer.newposition(0,0);
                            });
                        }
                        else {
                            WorkspaceApplication.getApplication().debug(error);
                        }
                    });
                } else{
                    legacyViewer.newposition(0,0);
                }
            }

            if(annot.familyMethod!=''){
                var hook:Dynamic;
                var clazz,method:String;

                #if UBIHUB

                #else
                activeAnnotation[currentAnnot]=false;
                #end

                clazz=annotations[currentAnnot].hasClass;
                method=annotations[currentAnnot].familyMethod+'table';

                var data=new PhyloScreenData();

                data.renderer=legacyViewer.radialR;
                data.target='';
                data.targetClean='';
                data.annot=currentAnnot;
                data.divAccessed=false;
                data.root=this.rootNode;
                data.title= annotations[currentAnnot].label;

                hook = Reflect.field(Type.resolveClass(clazz), method);

                legacyViewer.dom = legacyViewer.theComponent.down('component').getEl().dom;

                var posXDiv  = (legacyViewer.dom.clientWidth/2)-100;
                var posYDiv = legacyViewer.dom.clientHeight/5;
                closeDivInTable();

                hook(data,Math.round(posXDiv), Math.round(posYDiv),treeName, treeType, function(div){
                    data.created=true;
                    data.div=div;

                    var nn='';
                    if(data.target!=data.targetClean){
                        if(data.target.indexOf('(')!=-1 || data.target.indexOf('-')!=-1){
                            var auxArray=data.target.split('');
                            var j:Int;
                            for(j in 0...auxArray.length){
                                if (auxArray[j]=='(' || auxArray[j]=='-') {
                                    nn=auxArray[j+1];
                                    break;
                                }
                            }
                        }
                    }
                    if(currentAnnot==4){
                        if(data.annotation.text.indexOf('.')!=-1){
                            var auxArray=data.annotation.text.split('');
                            var j:Int;
                            var naux='';
                            for(j in 0...auxArray.length){
                                if(auxArray[j]!='.') naux+=auxArray[j];
                            }
                            nn=nn+naux;
                        }else if(data.annotation.text.indexOf('/')!=-1){
                            var auxArray=data.annotation.text.split('');
                            var j:Int;
                            var naux='';
                            for(j in 0...auxArray.length){
                                if(auxArray[j]!='/') naux+=auxArray[j];
                            }
                            nn=nn+naux;
                        }else nn=nn+data.annotation.text;
                    }

                    var nom='';
                    if(data.targetClean.indexOf('/')!=-1){
                        var auxArray=data.targetClean.split('');
                        var j:Int;
                        for(j in 0...auxArray.length){
                            if(auxArray[j]!='/') nom+=auxArray[j];
                        }
                    }else nom=data.targetClean;
                    var id=currentAnnot+'-'+nom+nn;
                    WorkspaceApplication.getApplication().getSingleAppContainer().showAnnotWindow(div, Math.round(posXDiv), Math.round(posYDiv), data.title,id,data);

                });
            }


        }else{
            legacyViewer.newposition(0,0);
            container.emptyLegend();
            var i:Int;
            var needToExpandLegend=false;

            for (i in 0...activeAnnotation.length){
                if (activeAnnotation[i]==true){
                    if(annotations[i].legend!=''){
                        needToExpandLegend=true;
                        container.addImageToLegend(annotations[i].legend, i);
                    }
                }
            }
            if( needToExpandLegend==false){
                container.legendPanel.collapse();
            }

        }
    }

    function changeDefaultOption(newDef:Int, groupBtn:Int, btn:Int):Bool{

        jsonFile.btnGroup[groupBtn].buttons[btn].optionSelected[0]=newDef;

//when we select another suboption we need to be sure that the already got annotation is false, otherwise we don't get the data from the database if the user selects again the previous selected otpions
        var currentAnnot=jsonFile.btnGroup[groupBtn].buttons[btn].annotCode;
        var u =annotations[currentAnnot].optionSelected[0];
        if(u!=newDef){
            var alias= annotations[currentAnnot].options[u];
            if(alreadyGotAnnotation.exists(alias)==true){
                alreadyGotAnnotation.remove(alias);
            }
        }
        annotations[jsonFile.btnGroup[groupBtn].buttons[btn].annotCode].optionSelected[0]=newDef;

        return true;
    }

    public function  fillInDataInAnnotTable(type:String,callback : Dynamic->String->Void){
        var annotlist : Array<Dynamic> = annotations;

        var leaves : Array<Dynamic> ;
        var myGeneList: Array<String>;

        if(type=='family'){
            myGeneList=this.rootNode.targets;
            leaves= rootNode.targets;
        }else{
            myGeneList=searchedGenes;
            leaves=searchedGenes;
        }

        var total=numTotalAnnot;

        var completedAnnotations = 0;

        var onDone = function(error, annotation){
            if(completedAnnotations == total){
                Util.debug('All results fetch');

                var d=dataforTable(annotlist, leaves);//only when it's the last one
                callback(d,null);

                return;
            }
        }

        // total+1 as min...max excludes max - i.e. min to max-1
        for(currentAnnot in 1...total+1){
            // What is annotation 11?
            if(currentAnnot==11){
                completedAnnotations += 1;
                onDone(null, currentAnnot);
                continue;
            }

            var alias = annotlist[currentAnnot].hookName;
            if(alias==''){
                completedAnnotations += 1;
                onDone(null, currentAnnot);
                continue;
            }

            var parameter:Dynamic;

            //before calling the mysql select, we need to check the tree type (domain or gene)
            if(treeName != ''){
                if(treeType=='gene'){
                    alias='gene_'+alias;
                }

                parameter=this.treeName;

                if(annotlist[currentAnnot].popup==false){
                    var u =annotlist[currentAnnot].optionSelected[0];

                    WorkspaceApplication.getApplication().getProvider().getByNamedQuery(alias,{param : parameter}, null, true, function(db_results, error){

                        if(error == null) {
                            addAnnotData(db_results,currentAnnot,u,function(){
                                completedAnnotations += 1;
                                onDone(null,currentAnnot);
                            });
                        }else {
                            Util.debug(error);

                            completedAnnotations += 1;
                            onDone(error,currentAnnot);
                        }
                    });
                }else{
                    var l=currentAnnot;
                    var popMethod=annotlist[currentAnnot].popMethod;
                    var hasClass=annotlist[currentAnnot].hasClass;
                    var hook = Reflect.field(Type.resolveClass(hasClass), popMethod);

                    hook(currentAnnot,null,this.treeType,treeName,null,this, function(results, error){
                        completedAnnotations += 1;

                        //TODO: Why doesn't this method do anything!!!!!!!

                        if(error == null){
                            onDone(null, currentAnnot);
                        }else{
                            Util.debug(error);

                            onDone(error, currentAnnot);
                        }
                    });
                }
            }else{
                if(annotlist[currentAnnot].popup==false){
                    alias='list_'+alias;
                    var parameter=searchedGenes;

                    if(this.treeType=='gene'){
                        alias='gene_'+alias;
                    }

                    WorkspaceApplication.getApplication().getProvider().getByNamedQuery(alias,{param : parameter}, null, true, function(db_results, error){
                        if(error == null) {
                            addAnnotDataGenes(db_results,currentAnnot,function(){
                                completedAnnotations += 1;

                                onDone(null, currentAnnot);
                            });
                        }else {
                            WorkspaceApplication.getApplication().showMessage('Unknown',error);
                            completedAnnotations += 1;
                            onDone(error, currentAnnot);
                        }
                    });
                }else{
                    var l=currentAnnot;
                    var popMethod=annotlist[currentAnnot].popMethod;
                    var hasClass=annotlist[currentAnnot].hasClass;
                    var hook = Reflect.field(Type.resolveClass(hasClass), popMethod);

                    hook(currentAnnot,null,this.treeType,treeName,searchedGenes,this, function(results, error){
                        completedAnnotations += 1;
                        onDone(null,currentAnnot);
                    });
                }
            }
        }
    }

    public function dataforTable(annotlist:Array<Dynamic>, leaves:Array<Dynamic>):Array<Dynamic>{
        var d=new Array();
        var total=numTotalAnnot;
        if(treeName!=''){

            var results=new Array();
            for (i in 0 ... leaves.length){

                if(rootNode.leafNameToNode.exists(leaves[i])){
                    var leaf=rootNode.leafNameToNode.get(leaves[i]);

                    var j:Int;

                    for(j in 1...total+1){
                        if(annotlist[j]!=null && annotlist[j].familyMethod!=''){
                            results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().showFamilyMethodDivInTable('+j+',\''+annotlist[j].familyMethod+'\')";return false;"><span style="text-align:center;color:">Visualize</span></a> ';
                            Util.debug('Here!');
                        }else{
                            Util.debug('Here2!');
                            if(leaf.annotations[j]!=null){
                                if(leaf.annotations[j]!=null){
                                    if(leaf.annotations[j].hasAnnot==true){
                                        if (leaf.annotations[j].alfaAnnot.length==0){

                                            switch (annotations[j].shape){
                                                case "cercle": results[j]= '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">O</span></a> ';
                                                case "html": results[j]= generateIcon(j, leaf.annotations[j].myleaf.name, leaf.results);
                                                case "square": results[j]= '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><div id="rectangle" style="text-align:center;width:10px; height:10px; background-color:'+leaf.annotations[j].color[0].color+'"/> </div></a> ';
                                                case "text": results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">'+leaf.annotations[j].text+'</span></a> ';
                                                case "image":
                                                    var t=leaf.annotations[j].defaultImg;
                                                    if(t==null) t=0;
                                                    if((annotations[j].annotImg[t]!=null)&&(annotations[j].annotImg[t].currentSrc!=null)){
                                                        if (t!=100){
                                                            if(j==1) results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'" width="20px"/><a> ';
                                                            else results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'"/><a> ';
                                                        }
                                                        else results[j]='';
                                                    }
                                            }
                                        }else{
// var g:Int;
                                            results[j]='';
                                            if(leaf.annotations[j].hasAnnot==true){
                                                switch (annotations[j].shape){
                                                    case "cercle": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">O</span></a> ';
                                                    case "square": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><div id="rectangle" style="text-align:center;width:10px; height:10px; background-color:'+leaf.annotations[j].color[0].color+'"/> </div></a> ';
                                                    case "html": results[j]=results[j]+generateIcon(j, leaf.annotations[j].myleaf.name, leaf.results);
                                                    case "text": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\',\''+leaf.annotations[j].text+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">'+leaf.annotations[j].text+'</span></a> ';
                                                    case "image":
                                                        var t=leaf.annotations[j].defaultImg;
                                                        if(t==null) t=0;
                                                        if((annotations[j].annotImg[t]!=null)&&(annotations[j].annotImg[t].currentSrc!=null)){
                                                            if (t!=100) results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'"/><a> ';

                                                        }
                                                }
                                            }
                                            var b:Int;
                                            for(b in 0...leaf.annotations[j].alfaAnnot.length){
                                                if(leaf.annotations[j].alfaAnnot[b]!=null){

                                                    switch (annotations[j].shape){
                                                        case "cercle": results[j]=results[j]+ '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].alfaAnnot[b].color[0].color+'">O</span></a> ';
                                                        case "square": results[j]=results[j]+ '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><div id="rectangle" style="text-align:center;width:10px; height:10px; background-color:'+leaf.annotations[j].alfaAnnot[b].color[0].color+'"/> </div></a> ';
                                                        case "html": results[j]=results[j]+generateIcon(j, leaf.annotations[j].myleaf.name, leaf.results);
                                                        case "text": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\',\''+leaf.annotations[j].alfaAnnot[b].text+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].alfaAnnot[b].color[0].color+'">'+leaf.annotations[j].alfaAnnot[b].text+'</span></a> ';
                                                        case "image":
                                                            var t=leaf.annotations[j].alfaAnnot[b].defaultImg;
                                                            if(t==null) t=0;
                                                            if((annotations[j].annotImg[t]!=null)&&(annotations[j].annotImg[t].currentSrc!=null)){
                                                                if (t!=100) results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'"/><a> ';
                                                            }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        results[j]='';
                                    }
                                }
                                else{
                                    results[j]='';
                                }
                            }
                            else{
                                results[j]='';
                            }
                        }
                    }

                    d[i] = {};

                    var a=0;
                    Reflect.setField(d[i], 'Target', leaf.name);
                    for(a in 0 ... annotations.length){
                        if(a==12){
                            var iwanttostop=true;
                        }
                        if(results[a+1]!=null){
                            //annotcode=11 doesnt exist
                            if(a!=10)  Reflect.setField(d[i], annotations[a+1].label, results[a+1]);
                            //if(a!=10)  Reflect.setField(d[i], "<a href='www.google.com'>"+annotations[a+1].label+"</a>", results[a+1]);
                        }
                    }
                }
            }
            //d=results;
        }
        else{
            var results=new Array();
            var leaf:PhyloTreeNode;
            for (i in 0 ... searchedGenes.length){
                leaf=legacyViewer.geneMap.get(searchedGenes[i]);

                var j:Int;
                for(j in 1...total+1){
                    if(annotlist[j]!=null && annotlist[j].familyMethod!=''){
                        //results[j]='n/a';
                        if(leaf.targetFamilyGene!=null && leaf.targetFamilyGene.length!=0){
                            var ii=0;
                            var r='';
                            for(ii in 0...leaf.targetFamilyGene.length){
                                r=r+leaf.targetFamilyGene[ii]+' ';
                            }
                            results[j]=r;
                        }
                        else results[j]='';
                    }
                    else{
                        if(leaf.annotations[j]!=null){
                            if(leaf.annotations[j].hasAnnot==true){
                                if (leaf.annotations[j].alfaAnnot.length==0){
                                    switch (annotations[j].shape){
                                        case "cercle": results[j]= '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">O</span></a> ';
                                        case "square": results[j]= '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><div id="rectangle" style="text-align:center;width:10px; height:10px; background-color:'+leaf.annotations[j].color[0].color+'"/> </div></a> ';
                                        case "html": results[j]= generateIcon(j, leaf.annotations[j].myleaf.name, leaf.results);
                                        case "text": results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">'+leaf.annotations[j].text+'</span></a> ';
                                        case "image":
                                            var t=leaf.annotations[j].defaultImg;
                                            if(t==null) t=0;
                                            if((annotations[j].annotImg[t]!=null)&&(annotations[j].annotImg[t].currentSrc!=null)){
                                                if (t!=100) {
                                                    if(j==1) results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'" width="20px"/><a> ';
                                                    else results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'"/><a> ';
                                                }
                                                else results[j]='';
                                            }
                                    }
                                }else{
// var g:Int;
                                    results[j]='';
                                    if(leaf.annotations[j].hasAnnot==true){
                                        switch (annotations[j].shape){
                                            case "cercle": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">O</span></a> ';
                                            case "square": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><div id="rectangle" style="text-align:center;width:10px; height:10px; background-color:'+leaf.annotations[j].color[0].color+'"/> </div></a> ';
                                            case "html": results[j]=results[j]+generateIcon(j, leaf.annotations[j].myleaf.name, leaf.results);
                                            case "text": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\',\''+leaf.annotations[j].text+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].color[0].color+'">'+leaf.annotations[j].text+'</span></a> ';
                                            case "image":
                                                var t=leaf.annotations[j].defaultImg;
                                                if(t==null) t=0;
                                                if((annotations[j].annotImg[t]!=null)&&(annotations[j].annotImg[t].currentSrc!=null)){
                                                    if (t!=100) {
                                                        if(j==1) results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'" width="20px"/><a> ';
                                                        else results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'"/><a> ';
                                                    }
                                                }
                                        }
                                    }
                                    var b:Int;
                                    for(b in 0...leaf.annotations[j].alfaAnnot.length){
                                        if(leaf.annotations[j].alfaAnnot[b]!=null){

                                            switch (annotations[j].shape){
                                                case "cercle": results[j]=results[j]+ '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].alfaAnnot[b].color[0].color+'">O</span></a> ';
                                                case "square": results[j]=results[j]+ '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><div id="rectangle" style="text-align:center;width:10px; height:10px; background-color:'+leaf.annotations[j].alfaAnnot[b].color[0].color+'"/> </div></a> ';
                                                case "html": results[j]=results[j]+ '<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><div id="rectangle" style="text-align:center;width:10px; height:10px; background-color:'+leaf.annotations[j].alfaAnnot[b].color[0].color+'"/> </div></a> ';
                                                case "text": results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\',\''+leaf.annotations[j].alfaAnnot[b].text+'\')";return false;"><span style="text-align:center;color:'+leaf.annotations[j].alfaAnnot[b].color[0].color+'">'+leaf.annotations[j].alfaAnnot[b].text+'</span></a> ';
                                                case "image":
                                                    var t=leaf.annotations[j].alfaAnnot[b].defaultImg;
                                                    if(t==null) t=0;
                                                    if((annotations[j].annotImg[t]!=null)&&(annotations[j].annotImg[t].currentSrc!=null)){
                                                        if (t!=100){
                                                            if(j==1) results[j]='<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'" width="20px"/><a> ';
                                                            else  results[j]=results[j]+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+leaf.annotations[j].myleaf.name+'\')";return false;"><img src="'+annotations[j].annotImg[t].currentSrc+'"/><a> ';
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                }
                            }
                            else{
                                results[j]='';
                            }
                        }
                        else{
                            results[j]='';
                        }
                    }
                }

                d[i] = {};

                var a=0;
                Reflect.setField(d[i], 'Target', leaf.name);
                var tt='';
                for(a in 0 ... annotations.length){
                    if(results[a+1]!=null){

                        //annotcode=11 doesnt exist
                        if(a!=10){
                            if(a+1==5) Reflect.setField(d[i], 'Family Domains', results[a+1]);
                            else Reflect.setField(d[i], annotations[a+1].label, results[a+1]);
                        }
                    }
                }
                //we need to add into the second column, the list of family domains where the target belongs
                /*  WorkspaceApplication.getApplication().getProvider().getByNamedQuery("getFamilies",{gene: leaf.name}, null, true, function(db_results, error){

                        if(error == null) {
                            tt=generateFamilyDomainList(db_results);
                            Reflect.setField(d[i], 'Family Domains', tt);


                            return d;
                        }
                        else {
                            WorkspaceApplication.getApplication().debug(error);
                            return null;
                        }

                    });*/
            }
        }

        return d;
    }

    function generateIcon(j:Int, tarname:String,results:Array<Int>):String{
        var name=tarname;
        if(name.indexOf('(')!=-1 || name.indexOf('/')!=-1){
            var auxArray=name.split('');
            var j:Int;
            var nn='';
            for(j in 0...auxArray.length){
                if (auxArray[j]!='(' && auxArray[j]!=')' && auxArray[j]!='/') {
                    nn=nn+auxArray[j];
                }
            }
            name=nn;
        }
        var r1=23-results[1];
        var r2=23-results[2];
        var r3=23-results[3];
        var r4=23-results[4];
        var r5=23-results[5];
        var r6=23-results[6];
        var r7=23-results[7];
        return "<script type=\"text/javascript\">
        $('.horizontal .progress-fill span').each(function(){
  var percent = $(this).html();
  $(this).parent().css('width', percent);
});


$('.vertical .progress-fill span').each(function(){
  var percent = $(this).html();
  var pTop = 100 - ( percent.slice(0, percent.length - 1) ) + \"%\";
  $(this).parent().css({
    'height' : percent,
    'top' : pTop
  });
});
                </script>"+'
                <style type="text/css" media="all">
                *, *:before, *:after {
  -moz-box-sizing: border-box; -webkit-box-sizing: border-box; box-sizing: border-box;
 }
.container {
  width: 23px;
  height: 23px;
  background: #fff;
  overflow: hidden;
  border-bottom:1px solid #000;
}

.vertical .progress-bar {
  float: left;
  height: 100%;
  width: 3px;
}

.vertical .progress-track {
  position: relative;
  width: 3px;
  height: 100%;
  background: #ffffff;
}

.vertical .progress-track-1 {
   position: relative;
   width: 3px;
   height: 100%;
   background: #2980d6;
}
.vertical .progress-fill-1'+name+' {
  position: relative;
  height: '+r1+'px;
  width: 3px;
  background-color:#ffffff;
}

.vertical .progress-track-2 {
   position: relative;
   width: 3px;
   height: 100%;
   background: #bf0000;
}
.vertical .progress-fill-2'+name+' {
  position: relative;
  height: '+r2+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-track-3 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #63cf1b;
}
.vertical .progress-fill-3'+name+' {
  position: relative;
  height: '+r3+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-track-4 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #ff8000;
}
.vertical .progress-fill-4'+name+' {
  position: relative;
  height: '+r4+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-track-5 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #c05691;
}
.vertical .progress-fill-5'+name+' {
  position: relative;
  height: '+r5+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-fill-6'+name+' {
  position: relative;
  height: '+r6+'px;
  width: 3px;
  background-color:#ffffff;
}
.vertical .progress-track-6 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #ffcc00;
}
.vertical .progress-track-7 {
  position: relative;
   width: 3px;
   height: 100%;
   background: #793ff3;
}
.vertical .progress-fill-7'+name+' {
  position: relative;
  height: '+r7+';
  width: 3px;
  background-color:#ffffff;
}
                </style>
                '+'<a id="myLink" title="Click to visualize annotation details"  href="#" onclick="app.getActiveProgram().annotationManager.showDivInTable('+j+',\''+tarname+'\')";return false;">
                <div class="container vertical flat">
                          <div class="progress-bar">
                            <div class="progress-track-1">
                              <div class="progress-fill-1'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-2">
                              <div class="progress-fill-2'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-3">
                              <div class="progress-fill-3'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-4">
                              <div class="progress-fill-4'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-5">
                              <div class="progress-fill-5'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-6">
                              <div class="progress-fill-6'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>

                          <div class="progress-bar">
                            <div class="progress-track-7">
                              <div class="progress-fill-7'+name+'">
                                <span> </span>
                              </div>
                            </div>
                          </div>
                        </div></a>';
    }

    public function showFamilyMethodDivInTable(annotation:Int){
        if((annotations[annotation].hasClass!=null)&&(annotations[annotation].familyMethod!=null)){
            var hook:Dynamic;
            var clazz,method:String;

            clazz=annotations[annotation].hasClass;
            method=annotations[annotation].familyMethod+'table';

            var data=new PhyloScreenData();

            data.renderer=legacyViewer.radialR;
            data.target='';
            data.targetClean='';
            data.annot=annotation;
            data.divAccessed=false;
            data.root=this.rootNode;
            data.title=annotations[annotation].label;

            hook = Reflect.field(Type.resolveClass(clazz), method);

            legacyViewer.dom = legacyViewer.theComponent.down('component').getEl().dom;

            var posXDiv  = (legacyViewer.dom.clientWidth/2)-100;
            var posYDiv = legacyViewer.dom.clientHeight/5;


            hook(data,Math.round(posXDiv), Math.round(posYDiv),treeName, treeType, function(div){
                data.created=true;
                data.div=div;
                var nn='';
                if(data.target!=data.targetClean){
                    if(data.target.indexOf('(')!=-1 || data.target.indexOf('-')!=-1){
                        var auxArray=data.target.split('');
                        var j:Int;
                        for(j in 0...auxArray.length){
                            if (auxArray[j]=='(' || auxArray[j]=='-') {
                                nn=auxArray[j+1];
                                break;
                            }
                        }
                    }
                }
                var nom='';
                if(data.targetClean.indexOf('/')!=-1){
                    var auxArray=data.targetClean.split('');
                    var j:Int;
                    for(j in 0...auxArray.length){
                        if(auxArray[j]!='/') nom+=auxArray[j];
                    }
                }else nom=data.targetClean;
                var id=annotation+'-'+nom+nn;

                WorkspaceApplication.getApplication().getSingleAppContainer().showAnnotWindow(div, Math.round(posXDiv), Math.round(posYDiv), data.title,id,data);

            });
        }
    }

    public function showDivInTable(annotation:Int,target:String, ?text:String){
        var leaf:Dynamic;
        if(treeName=='') leaf=legacyViewer.geneMap.get(target);
        else leaf=rootNode.leafNameToNode.get(target);

        if((annotations[annotation].hasClass!=null)&&(annotations[annotation].divMethod!=null)){
            var hook:Dynamic;
            var clazz,method:String;

            clazz=annotations[annotation].hasClass;
            method=annotations[annotation].divMethod;

            var data=new PhyloScreenData();

            data.renderer=legacyViewer.radialR;
            data.target=target;
            data.annot=annotation;
            if(text!=null){
                data.annotation.text=text;
            }
            else data.annotation.text=leaf.annotations[annotation].text;
            var name='';
            if(target.indexOf('(')!=-1 || target.indexOf('-')!=-1){
                var auxArray=target.split('');
                var j:Int;
                for(j in 0...auxArray.length){
                    if (auxArray[j]=='(' || auxArray[j]=='-') {

                        // if(auxArray[j]=='(') {index=auxArray[j+1]; variant='1';}
                        // if(auxArray[j]=='-') {index=null; variant=auxArray[j+1];}
                        break;
                    }
                    name+=auxArray[j];
                }
                data.targetClean=name;
            }
            else{
                data.targetClean=target;
            }
            data.annot=annotation;
            data.divAccessed=false;
            data.root=this.rootNode;
            data.title=annotations[annotation].label;

            hook = Reflect.field(Type.resolveClass(clazz), method);

            legacyViewer.dom = legacyViewer.theComponent.down('component').getEl().dom;

            var posXDiv  = (legacyViewer.dom.clientWidth/2)-100;
            var posYDiv = legacyViewer.dom.clientHeight/5;
            // closeDivInTable();

            hook(data,Math.round(posXDiv), Math.round(posYDiv),treeType, function(div){
                data.created=true;
                data.div=div;

                var nn='';
                if(data.target!=data.targetClean){
                    if(data.target.indexOf('(')!=-1 || data.target.indexOf('-')!=-1){
                        var auxArray=data.target.split('');
                        var j:Int;
                        for(j in 0...auxArray.length){
                            if (auxArray[j]=='(' || auxArray[j]=='-') {
                                nn=auxArray[j+1];
                                break;
                            }
                        }
                    }
                }
                if(annotation==4){
                    if(data.annotation.text.indexOf('.')!=-1){
                        var auxArray=data.annotation.text.split('');
                        var j:Int;
                        var naux='';
                        for(j in 0...auxArray.length){
                            if(auxArray[j]!='.') naux+=auxArray[j];
                        }
                        nn=nn+naux;
                    }else if(data.annotation.text.indexOf('/')!=-1){
                        var auxArray=data.annotation.text.split('');
                        var j:Int;
                        var naux='';
                        for(j in 0...auxArray.length){
                            if(auxArray[j]!='/') naux+=auxArray[j];
                        }
                        nn=nn+naux;
                    }else nn=nn+data.annotation.text;
                }

                var nom='';
                if(data.targetClean.indexOf('/')!=-1){
                    var auxArray=data.targetClean.split('');
                    var j:Int;
                    for(j in 0...auxArray.length){
                        if(auxArray[j]!='/') nom+=auxArray[j];
                    }
                }else nom=data.targetClean;

                var id=annotation+'-'+nom+nn;

                WorkspaceApplication.getApplication().getSingleAppContainer().showAnnotWindow(div, Math.round(posXDiv), Math.round(posYDiv), data.title,id,data);

            });
        }
    }

    public function closeDivInTable(){
        var container = WorkspaceApplication.getApplication().getSingleAppContainer();
        // closeAnnotWindows();
    }

    public function addAnnotDataGenes (annotData  : Array<Dynamic>, annotation: Int, callback:Void->Void ){
        var i:Int;

        var mapResults: Map<String, Dynamic>;
        mapResults=new Map();

        var target:String;
        var j=0;

        for(i in 0 ... annotData.length){
            if(annotation==1){
                var aux=annotData[i].pmid_list;
                var aux2=aux.split(';');
                var max = aux2.length;

                var v = annotations[1].fromresults[1];

                if(max>v || annotations[1].fromresults[1]==null){
                    annotations[1].fromresults[1]=max;
                }
            }
            target=annotData[i].target_id+'_'+j;
            while (mapResults.exists(target)){
                j++;
                target=annotData[i].target_id+'_'+j;
            }
            j=0;
            mapResults.set(target, annotData[i]);
        }

        var items=new Array();
        var i=0;
        for (i in 0...searchedGenes.length){
            items[i]=searchedGenes[i];
        }

        processGeneAnnotations(items, mapResults, annotation, callback);
    }

    /**
    * processGeneAnnotations
    **/
    public function processGeneAnnotations(items:Array<String>, mapResults: Map<String, Dynamic>, annotation: Int, cb:Void->Void){
        var toComplete = items.length;

        var onDone = function(){
            if(toComplete == 0){
                cb();
            }
        }

        if(toComplete == 0){
            cb(); return;
        }

        for(name in items){
            var target = name + '_0';

            if (mapResults.exists(target)){
                var res = mapResults.get(target);

                var leafaux: PhyloTreeNode = legacyViewer.geneMap.get(name);

                var index = null;
                var variant = '1';

                // TODO: What is the purpose of this block?
                #if PHYLO5

                #else
                if(annotation == 13 && Reflect.hasField(res, 'family_id')) {
                    leafaux.targetFamily = mapResults.get(target).family_id;
                }
                #end

                if((annotations[annotation].hasClass != null) && (annotations[annotation].hasMethod != null)){
                    var clazz = annotations[annotation].hasClass;
                    var method = annotations[annotation].hasMethod;

                    var hook : Dynamic = Reflect.field(Type.resolveClass(clazz), method);

                    hook(name, res, 0, annotations, name, function(r : HasAnnotationType){
                        if(r.hasAnnot){
                            leafaux.activeAnnotation[annotation] = true;

                            if(leafaux.annotations[annotation] == null){
                                leafaux.annotations[annotation] = new PhyloAnnotation();
                                leafaux.annotations[annotation].myleaf = leafaux;
                                leafaux.annotations[annotation].text = r.text;
                                leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                                leafaux.annotations[annotation].saveAnnotationData(annotation,mapResults.get(target),100,r);
                            }else{
                                if(leafaux.annotations[annotation].splitresults == true){
                                    var z = 0;

                                    while(leafaux.annotations[annotation].alfaAnnot[z] != null){
                                        z++;
                                    }

                                    leafaux.annotations[annotation].alfaAnnot[z] = new PhyloAnnotation();
                                    leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
                                    leafaux.annotations[annotation].alfaAnnot[z].text = '';
                                    leafaux.annotations[annotation].alfaAnnot[z].defaultImg = annotations[annotation].defaultImg;
                                    leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,mapResults.get(target),100,r);
                                }
                            }
                        }

                        toComplete--;
                        onDone();
                    });
                }else{
                    var col = '';

                    if(annotations[annotation].color[0] != null){
                        col = annotations[annotation].color[0].color;
                    }

                    var r : HasAnnotationType = {hasAnnot : true, text : '', color : {color : col, used : true}, defImage : annotations[annotation].defaultImg};

                    var leafaux: PhyloTreeNode = legacyViewer.geneMap.get(name);
                    leafaux.activeAnnotation[annotation] = true;

                    if(leafaux.annotations[annotation] == null){
                        leafaux.annotations[annotation] = new PhyloAnnotation();
                        leafaux.annotations[annotation].myleaf = leafaux;
                        leafaux.annotations[annotation].text = '';
                        leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                        leafaux.annotations[annotation].saveAnnotationData(annotation,mapResults.get(target),100,r);
                    }else{
                        if(leafaux.annotations[annotation].splitresults == true){
                            var z = 0;

                            while(leafaux.annotations[annotation].alfaAnnot[z]!=null){
                                z++;
                            }

                            leafaux.annotations[annotation].alfaAnnot[z] = new PhyloAnnotation();
                            leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
                            leafaux.annotations[annotation].alfaAnnot[z].text = '';
                            leafaux.annotations[annotation].alfaAnnot[z].defaultImg = annotations[annotation].defaultImg;
                            leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,mapResults.get(target),100,r);
                        }
                    }

                    toComplete--;
                    onDone();
                }
            }else{
                //in case of suboptions we have to be sure we remove the previous ones
                var leafaux: PhyloTreeNode = legacyViewer.geneMap.get(name);
                leafaux.activeAnnotation[annotation] = false;
                leafaux.annotations[annotation] = null;

                toComplete--;
                onDone();
            }
        }
    }

    public function addAnnotData(annotData  : Array<Dynamic>, annotation: Int, option:Int, callback:Void->Void ){
        var i:Int;
        var mapResults: Map<String, Dynamic>;
        mapResults=new Map();
        var j=0;
        var target:String;
        for(i in 0 ... annotData.length){
            #if PHYLO5

            #else
            if(annotation==1){
                var aux=annotData[i].pmid_list;
                var aux2=aux.split(';');
                var max = aux2.length;

                var v = annotations[1].fromresults[1];

                if(max>v || annotations[1].fromresults[1]==null) annotations[1].fromresults[1]=max;
            }
            #end
            target=annotData[i].target_id+'_'+j;
            while (mapResults.exists(target)){
                j++;
                target=annotData[i].target_id+'_'+j;
            }
            j=0;
            mapResults.set(target, annotData[i]);
        }

        //creating target list to be processed
        var items=new Array();
        for(i in 0 ... this.rootNode.targets.length){
            items[i]=this.rootNode.targets[i];
        }
        #if PHYLO5
        processAnnotationsSimple(items,mapResults,annotation, option, callback);
        #else
        processFamilyAnnotations(items, mapResults, annotation, option, callback);
        #end
    }

    public function processAnnotationsSimple(items:Array<String>,mapResults: Map<String, Dynamic>,annotation: Int, option:Int, cb:Void->Void){
        var toComplete = 0;
        for(key in mapResults){
            toComplete += 1;
        }

        var onDone = function(){
            if(toComplete  == 0){
                cb();
            }
        };

        if(toComplete == 0){
            cb();return;
        }

        for(item in items){
            var name = item + '_0';
            var res = mapResults.get(name);
            if((annotations[annotation].hasClass != null)&&(annotations[annotation].hasMethod != null)){
                var clazz = annotations[annotation].hasClass;
                var method :Dynamic = annotations[annotation].hasMethod;

                var _processAnnotation = function(r:HasAnnotationType){
                    if(r.hasAnnot){
                        var leafaux: PhyloTreeNode;
                        leafaux = this.rootNode.leafNameToNode.get(item);

                        leafaux.activeAnnotation[annotation] = true;
                        if(leafaux.annotations[annotation] == null){
                            leafaux.annotations[annotation] = new PhyloAnnotation();
                            leafaux.annotations[annotation].myleaf = leafaux;
                            leafaux.annotations[annotation].text = r.text;
                            leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                            leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                        }else{
                            if(annotations[annotation].splitresults == true){
                                leafaux.annotations[annotation].splitresults = true;

                                var z=0;

                                while(leafaux.annotations[annotation].alfaAnnot[z] != null){
                                    z++;
                                }

                                leafaux.annotations[annotation].alfaAnnot[z] = new PhyloAnnotation();
                                leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
                                leafaux.annotations[annotation].alfaAnnot[z].text = '';
                                leafaux.annotations[annotation].alfaAnnot[z].defaultImg = annotations[annotation].defaultImg;
                                leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,res,option,r);
                                if(leafaux.annotations[annotation].alfaAnnot[z].text == leafaux.annotations[annotation].text){
                                    leafaux.annotations[annotation].alfaAnnot[z] = null;
                                }
                            }else{
                                if(leafaux.annotations[annotation].option != annotations[annotation].optionSelected[0]){
                                    leafaux.annotations[annotation] = new PhyloAnnotation();
                                    leafaux.annotations[annotation].myleaf = leafaux;
                                    leafaux.annotations[annotation].text = '';
                                    leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                                    leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                                }
                            }
                        }
                    }

                    toComplete--;
                    onDone();
                };

                if(Reflect.isFunction(method)){
                    method(name,res,option, annotations, item, _processAnnotation);
                }else{
                    var hook : Dynamic = Reflect.field(Type.resolveClass(clazz), method);

                    hook(name,res,option, annotations, item, _processAnnotation);
                }
            }else {
                var col = '';
                if(annotations[annotation].color[0] != null){
                    col=annotations[annotation].color[0].color;
                }

                var r : HasAnnotationType = {hasAnnot : true, text : '',color : {color : col, used : true},defImage : annotations[annotation].defaultImg};

                var leafaux: PhyloTreeNode = this.rootNode.leafNameToNode.get(item);
                leafaux.activeAnnotation[annotation]=true;

                if(leafaux.annotations[annotation] == null){
                    leafaux.annotations[annotation] = new PhyloAnnotation();
                    leafaux.annotations[annotation].myleaf = leafaux;
                    leafaux.annotations[annotation].text = '';
                    leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                    leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                }else{
                    if(leafaux.annotations[annotation].splitresults == true){
                        var z=0;

                        while(leafaux.annotations[annotation].alfaAnnot[z]!=null){
                            z++;
                        }

                        leafaux.annotations[annotation].alfaAnnot[z] = new PhyloAnnotation();
                        leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
                        leafaux.annotations[annotation].alfaAnnot[z].text = '';
                        leafaux.annotations[annotation].alfaAnnot[z].defaultImg = annotations[annotation].defaultImg;
                        leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,res,option,r);

                    }else{
                        if(leafaux.annotations[annotation].option != annotations[annotation].optionSelected[0]){
                            leafaux.annotations[annotation] = new PhyloAnnotation();
                            leafaux.annotations[annotation].myleaf = leafaux;
                            leafaux.annotations[annotation].text = '';
                            leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                            leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                        }
                    }
                }

                toComplete--;
                onDone();
            }
        }
    }


    /**
    * processFamilyAnnotations
    *
    * TODO: Fully document this function especially around Sefa's code to handle variants and indexes as I don't understand this
    **/
    public function processFamilyAnnotations(items:Array<String>,mapResults: Map<String, Dynamic>,annotation: Int, option:Int, cb:Void->Void){
        var toComplete = 0;

        // First we work out how many annotations we need to process
        // We do this so that it's easy for our onDone function to work out when all async callbacks have finished
        // We used to use a timer to wait for all the callbacks to finish but that's not necessary
        for(item in items){
            var name  = '';
            var hookCount = 0;

            var index = null;
            var variant = '1';
            var hasName = false;

            if(item.indexOf('(') != -1 || item.indexOf('-') != -1){
                hasName = true;

                var auxArray = item.split('');

                for(j in 0...auxArray.length){
                    if(auxArray[j] == '(' || auxArray[j] == '-'){
                        if(auxArray[j] == '(') {
                            index  = auxArray[j+1];
                            variant = '1';
                        }else if(auxArray[j] == '-') {
                            index = null;
                            variant = auxArray[j+1];
                        }

                        break;
                    }

                    name += auxArray[j];
                }
            }else{
                name = item;
            }

            var j = 0;
            var finished = false;
            var showAsSgc = false;

            while((mapResults.exists(name+'_'+j)==true)&&(finished==false)){
                var keepgoing=true;
                var res=mapResults.get(name+'_'+j);

                if (mapResults.get(name+'_'+ j).sgc == 1 || showAsSgc == true) {
                    res.sgc = 1;
                    showAsSgc = true;
                }

                if(hasName==true){
                    if(res.target_name_index!=index || res.variant_index!=variant){
                        keepgoing=false;
                    }
                }
                if(keepgoing==false){
                    j++;
                }else{
                    toComplete += 1;
                    if((annotations[annotation].hasClass!=null)&&(annotations[annotation].hasMethod!=null)){
                        j++;
                    }else{
                        finished=true;
                    }
                }
            }
        }


        var onDone = function(){
            if(toComplete  == 0){
                cb();
            }
        };

        if(toComplete == 0){
            cb();return;
        }

        for(item in items){
            var hookCount = 0;

            var index = null;
            var variant = '1';
            var hasName = false;
            var name = '';

            if(item.indexOf('(') != -1 || item.indexOf('-') != -1){
                hasName = true;

                var auxArray = item.split('');

                for(j in 0...auxArray.length){
                    if(auxArray[j] == '(' || auxArray[j] == '-'){
                        if(auxArray[j] == '(') {
                            index  = auxArray[j+1];
                            variant = '1';
                        }else if(auxArray[j] == '-') {
                            index = null;
                            variant = auxArray[j+1];
                        }

                        break;
                    }

                    name += auxArray[j];
                }
            }else{
                name = item;
            }

            var j = 0;
            var finished = false;
            var showAsSgc = false;

            while((mapResults.exists(name+'_'+j) == true) && (finished == false)){
                var keepGoing = true;
                var res = mapResults.get(name+'_'+j);

                if(mapResults.get(name+'_'+ j).sgc == 1 || showAsSgc == true) {
                    res.sgc = 1;
                    showAsSgc = true;
                }

                if(hasName==true){
                    if(res.target_name_index != index || res.variant_index != variant){
                        keepGoing=false;
                    }
                }

                if(keepGoing==false){
                    j++;
                }else{
                    if((annotations[annotation].hasClass != null)&&(annotations[annotation].hasMethod != null)){
                        var clazz = annotations[annotation].hasClass;
                        var method :Dynamic = annotations[annotation].hasMethod;

                        var _processAnnotation = function(r:HasAnnotationType){
                            if(r.hasAnnot){
                                var leafaux: PhyloTreeNode;
                                leafaux = this.rootNode.leafNameToNode.get(item);

                                leafaux.activeAnnotation[annotation] = true;
                                if(leafaux.annotations[annotation] == null){
                                    leafaux.annotations[annotation] = new PhyloAnnotation();
                                    leafaux.annotations[annotation].myleaf = leafaux;
                                    leafaux.annotations[annotation].text = r.text;
                                    leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                                    leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                                }else{
                                    if(annotations[annotation].splitresults == true){
                                        leafaux.annotations[annotation].splitresults = true;

                                        var z=0;

                                        while(leafaux.annotations[annotation].alfaAnnot[z] != null){
                                            z++;
                                        }

                                        leafaux.annotations[annotation].alfaAnnot[z] = new PhyloAnnotation();
                                        leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
                                        leafaux.annotations[annotation].alfaAnnot[z].text = '';
                                        leafaux.annotations[annotation].alfaAnnot[z].defaultImg = annotations[annotation].defaultImg;
                                        leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,res,option,r);
                                        if(leafaux.annotations[annotation].alfaAnnot[z].text == leafaux.annotations[annotation].text){
                                            leafaux.annotations[annotation].alfaAnnot[z] = null;
                                        }
                                    }else{
                                        if(leafaux.annotations[annotation].option != annotations[annotation].optionSelected[0]){
                                            leafaux.annotations[annotation] = new PhyloAnnotation();
                                            leafaux.annotations[annotation].myleaf = leafaux;
                                            leafaux.annotations[annotation].text = '';
                                            leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                                            leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                                        }
                                    }
                                }
                            }

                            toComplete--;
                            onDone();
                        };

                        if(Reflect.isFunction(method)){
                            method(name,res,option, annotations, item, _processAnnotation);
                        }else{
                            var hook : Dynamic = Reflect.field(Type.resolveClass(clazz), method);

                            hook(name,res,option, annotations, item, _processAnnotation);
                        }

                        j++;
                    }else {
                        finished=true;

                        var col = '';
                        if(annotations[annotation].color[0] != null){
                            col=annotations[annotation].color[0].color;
                        }

                        var r : HasAnnotationType = {hasAnnot : true, text : '',color : {color : col, used : true},defImage : annotations[annotation].defaultImg};

                        var leafaux: PhyloTreeNode = this.rootNode.leafNameToNode.get(item);
                        leafaux.activeAnnotation[annotation]=true;

                        if(leafaux.annotations[annotation] == null){
                            leafaux.annotations[annotation] = new PhyloAnnotation();
                            leafaux.annotations[annotation].myleaf = leafaux;
                            leafaux.annotations[annotation].text = '';
                            leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                            leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                        }else{
                            if(leafaux.annotations[annotation].splitresults == true){
                                var z=0;

                                while(leafaux.annotations[annotation].alfaAnnot[z]!=null){
                                    z++;
                                }

                                leafaux.annotations[annotation].alfaAnnot[z] = new PhyloAnnotation();
                                leafaux.annotations[annotation].alfaAnnot[z].myleaf = leafaux;
                                leafaux.annotations[annotation].alfaAnnot[z].text = '';
                                leafaux.annotations[annotation].alfaAnnot[z].defaultImg = annotations[annotation].defaultImg;
                                leafaux.annotations[annotation].alfaAnnot[z].saveAnnotationData(annotation,res,option,r);

                            }else{
                                if(leafaux.annotations[annotation].option != annotations[annotation].optionSelected[0]){
                                    leafaux.annotations[annotation] = new PhyloAnnotation();
                                    leafaux.annotations[annotation].myleaf = leafaux;
                                    leafaux.annotations[annotation].text = '';
                                    leafaux.annotations[annotation].defaultImg = annotations[annotation].defaultImg;
                                    leafaux.annotations[annotation].saveAnnotationData(annotation,res,option,r);
                                }
                            }
                        }

                        toComplete--;
                        onDone();
                    }
                }
            }
        }
    }

    /**Function used to remove the previous results of a PopUp Window Annotations. **/
    public function cleanAnnotResults(annot:Int){

        var items=new Array();
        for(i in 0 ... this.rootNode.targets.length){
            var item=this.rootNode.targets[i];

            var leafaux=this.rootNode.leafNameToNode.get(item);
            if(leafaux.annotations[annot]!=null) leafaux.annotations[annot].hasAnnot=false;
        }

    }

    public function hideAnnotationWindows(){
        var app = WorkspaceApplication.getApplication();

        if(app != null){
            var container = app.getSingleAppContainer();

            if(container != null){
                container.hideExportSubMenu();
                container.hideHelpingDiv();

                if(WorkspaceApplication.getApplication().getScreenMode() != ScreenMode.DEFAULT){
                    container.hideSubMenuToolBar();
                }
            }
        }
    }

}

