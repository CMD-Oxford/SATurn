package saturn.client.programs.phylo;
import saturn.client.WorkspaceApplication;
import saturn.client.WorkspaceApplication;
import saturn.client.WorkspaceApplication;
import saturn.client.programs.chromohub.ChromoHubViewer;

class PhyloAnnotationManager {
    public var annotations: Array<PhyloAnnotation>;
    public var rootNode : PhyloTreeNode;
    public var canvas : PhyloCanvasRenderer;
    public var treeName : String;
    public var subtreeName : String;
    public var treeType : String;
    public var numTotalAnnot: Int;
    public var legacyViewer : ChromoHubViewer;

    public function new(legacyViewer : ChromoHubViewer) {
        this.legacyViewer = legacyViewer;
        annotations = new Array<PhyloAnnotation>();
        activeAnnotation=new Array();
        alreadyGotAnnotation=new Map<String, Bool>();
        selectedAnnotationOptions = new Array();
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
                                    container.addFormItemToPopUpWindow(optt.form.items,b.annotCode,optt.hasClass,optt.popMethod, this.treeType, this.treeName, null, legacyViewer );
                                    container.showPopUpWindow();
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
        var container = WorkspaceApplication.getApplication().getSingleAppContainer();
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
                            legacyViewer.addAnnotData(db_results,currentAnnot,currentOption, function(){
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
                legacyViewer.closeDivInTable();

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
}

