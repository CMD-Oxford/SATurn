package saturn.client;
import saturn.client.programs.chromohub.ChromoHubAnnotationManager;
import phylo.PhyloAnnotationManager;
import saturn.client.programs.chromohub.ChromoHubViewer;
import phylo.PhyloScreenData;
import saturn.client.WorkspaceApplication.ScreenMode;
import phylo.PhyloTreeNode;
import phylo.PhyloAnnotation;
import bindings.Ext;
import saturn.core.Util;

class SingleAppContainer {
    var hbox : Dynamic;
    var centralPanel : Dynamic;
    var centralTargetPanel : Dynamic;
    var controlToolBar : Dynamic;
    var modeToolBar : Dynamic;
    public var legendPanel : Dynamic;
    var geneListBar : Dynamic;
    public var optionsToolBar : Dynamic;
    public var editToolBar : Dynamic;
    public var hideHelp:Bool;
    var subMenuToolBar : Dynamic;
    var helpingDiv: Dynamic;
    var exportSubMenu : Dynamic;
    var popUpWindow : Dynamic;
    var ultraDDWindow : Dynamic;
    var highlightWindow : Dynamic;
    public var annotWindow : Map<Int,Dynamic>;
    var messageWindow : Dynamic;
    var messageDomainWindow : Dynamic;
    var tipWindow : Dynamic;
    var demoWindow: Dynamic;
    var progressBar : Dynamic;

    var deflayout : String;
    var program : Program;


    public function new(?layout = 'border') {
        hbox = Ext.create('Ext.panel.Panel', {
            layout: 'border',
            width: '100%',
            height: '100%',
            region: 'north',
            border: false,
            flex: 1
        });

        deflayout=layout;
        createComponents();
        annotWindow=new Map();
    }

    public function createComponents(){
        createModeToolBar();
        createControlToolBar();

        createCentralPanel();
    }


/********************* Central Panel *********************/
    public function createCentralPanel(){
        centralPanel = Ext.create('Ext.panel.Panel', {
            layout: 'border',
            width: '100%',
            height: '100%',
            region: 'center',
            cls: 'x-centralPanel-single',
            border: false,
            scrollable: true,
            flex: 1,
            id:'id-centralPanel',
            listener:{
                focus: function(e){
                    getApplication().getSingleAppContainer().hideSubMenuToolBar();
                }
            }
        });

        hbox.add(centralPanel);
    }
    public function clearCentralPanel(){
        //centralPanel.removeAll(false);

        var itemslist = centralPanel.items;

// remove the items
        itemslist.each(function(item,index,length){
            if(item.id=='panel-domain-architecture'){
                var itemslist2 = item.items;
                itemslist2.each(function(it,ind,leng){
                    item.remove(it, true);
                });
                centralPanel.remove(item, true);
            }else{
                if(item.id=='chromo-legend'){
                    centralPanel.remove(item, true);
                }
                else{
                    centralPanel.remove(item, false);
                }
            }
        });

        centralPanel.doLayout();
    }

    public function setCentralComponent(component : Dynamic){
        clearCentralPanel();
        centralPanel.add(component);
        centralPanel.doLayout();
    }

    public function addComponentToCentralPanel(component:Dynamic){
        centralPanel.add(component);
        centralPanel.doLayout();
    }
    public function getCentralPanel(){
        return centralPanel;
    }


/***************** Legend Panel *****************************/
    public function createLegendPanel(){
        legendPanel = Ext.create('Ext.panel.Panel', {
            width: '100%',
            height: '20px',
            border: true,
            cls: 'x-tree-legend',
            region:'south',
            split:true,
            id: 'chromo-legend',
            vertical: true,
            collapsible: true,
            collapsed: true,
            title: 'Legend'
        });
        addComponentToCentralPanel(legendPanel);
    }
    public function hideLegendPanel(){
        legendPanel.hide();
    }
    public function showLegendPanel(){
        legendPanel.doLayout();
        legendPanel.show();
        legendPanel.doLayout();
    }
    public function addImageToLegend(image:Dynamic, id:Int){
        var changingImage = Ext.create('Ext.Img', {
            src: image,
            id:id,
            padding: '5 0 15 0',
            //renderTo: Ext.getBody()
        });

        legendPanel.insert(2,changingImage);
        legendPanel.doLayout();
        hbox.doLayout();

    }
    public function removeComponentFromLegend(component:Dynamic){
        var comp=legendPanel.getComponent(component);
        legendPanel.remove(comp);
    }
    public function expandLegend(){
        //  legendPanel.expand();
    }
    public function emptyLegend(){
        var itemslist = legendPanel.items;

        // remove the items
        var items : Array<Dynamic> = new Array<Dynamic>();
        itemslist.each(function(item,index,length){
            legendPanel.remove(item, true);
        });

        legendPanel.doLayout();
    }
    public function getLegendPanel(){
        return legendPanel;
    }

/*********************Mode Tools Bar (main tool bar)*********************/

    public function createModeToolBar(){
        modeToolBar = Ext.create('Ext.toolbar.Toolbar', {
            width: '20px',
            id:'modeToolBarId',
            height: '100%',
            border: false,
            region: 'west',
            cls: 'x-modetoolbar-single',
            vertical: true
        });

        hbox.add(modeToolBar);
    }
    public function hideModeToolBar(){
        modeToolBar.hide();
    }
    public function showModeToolBar(){
        modeToolBar.doLayout();
        modeToolBar.show();
        modeToolBar.doLayout();
    }
    public function getModeToolBar(){
        return modeToolBar;
    }
    public function clearModeToolBar(){
        // the items of the toolbar
        var itemslist = modeToolBar.items;

        // remove the items
        itemslist.each(function(item,index,length){
            modeToolBar.remove(item, false);
        });

        modeToolBar.doLayout();
    }
    public function addElemToModeToolBar(elem:Dynamic){
        modeToolBar.add(elem);
        modeToolBar.doLayout();
    }

/*********************Control Tools Bar (2nd tool bar)*********************/

    public function createControlToolBar(?attachPosition = 1){
        controlToolBar = Ext.create('Ext.toolbar.Toolbar', {
            width: '35px',
// top:'10px',
// left:'100px',
            height: '100px',
            border: false,
            vertical: true,
            region:'east',
            cls: 'x-toolbar-2nd'
        });
        hbox.insert(attachPosition, controlToolBar);
    }
    public function getControlToolBar(){
        return controlToolBar;
    }
    public function hideControlToolBar(){
        controlToolBar.hide();
    }
    public function showControlToolBar(){
        controlToolBar.doLayout();
        controlToolBar.show();
        controlToolBar.doLayout();
    }
    public function clearControlToolBar(){
        var attachPosition = hbox.items.findIndex('id', controlToolBar.id);

        hbox.remove(controlToolBar);

        createControlToolBar(attachPosition);
    }
    public function addElemToControlToolBar(elem:Dynamic){
        controlToolBar.add(elem);
        controlToolBar.doLayout();
    }
    public function refreshControlToolBar(){
        controlToolBar.doLayout();

    }
/*********************Edit Tools Bar *********************/

    public function createEditToolBar(?attachPosition = 2){
        editToolBar = Ext.create('Ext.toolbar.Toolbar', {
            width: '35px',
// top:'10px',
// left:'100px',
            height: '100px',
            border: false,
            vertical: true,
            region:'east',
            cls: 'x-toolbar-2nd'
        });
        hbox.insert(attachPosition, editToolBar);
    }
    public function getEditToolBar(){
        return editToolBar;
    }
    public function hideEditToolBar(){
        editToolBar.hide();
    }
    public function showEditToolBar(){
        editToolBar.doLayout();
        editToolBar.show();
        editToolBar.doLayout();
    }
    public function clearEditToolBar(){
        var attachPosition = hbox.items.findIndex('id', editToolBar.id);

        hbox.remove(editToolBar);

        createEditToolBar(attachPosition);
    }
    public function addElemToEditToolBar(elem:Dynamic){
        editToolBar.add(elem);
        editToolBar.doLayout();
    }
    public function refreshEditToolBar(){
        controlToolBar.doLayout();

    }

    public function removeComponentFromEditToolBar(component:Dynamic){
        editToolBar.remove(component);
        editToolBar.doLayout();
    }

/*********************Gene List Bar *********************/

    public function createGeneListToolBar(?attachPosition = 1){
        geneListBar = Ext.create('Ext.toolbar.Toolbar', {
            top:'0px',
            left:'30px',
            width: '470px',
            height: '100%',
            border: false,
            vertical: true,
            cls: 'x-viewoptionsbar',
            alwaysOnTop:true,
//collapsible: true,
            region: 'west',
            title: 'Options Tool Bar',
            autoScroll:true
        });
        geneListBar.add({
            xtype: 'label',
            text: 'Gene List',
            cls:'targetclass-title'
        });
        hbox.insert(attachPosition,geneListBar);
    }
    public function getGeneListBar(){
        return geneListBar;
    }
    public function hideGeneListBar(){
        geneListBar.hide();
    }
    public function showGeneListBar(){
        geneListBar.show();
    }
    public function clearGeneListBar(){
        geneListBar.removeAll(true);
    }
    public function addGeneToGeneListBar(gene:String){
        geneListBar.add({
            xtype : 'button',
            iconCls: 'x-btn-gene-searched',
            text: gene,
            handler: function(e){
                getApplication().debug(e.text);

            },
            tooltip: {dismissDelay: 10000, text: gene}
        });
    }
    public function removeGeneFromGeneListBar(elem:Dynamic){
        geneListBar.add(elem);
        geneListBar.doLayout();
    }

/*********************Options Tools Bar *********************/

    public function createOptionsToolBar(?attachPosition = 1){
        optionsToolBar = Ext.create('Ext.toolbar.Toolbar', {
            top:'0px',
            left:'30px',
            id:'optionToolBarId',
            width: '700px',
            height: '100%',
            border: false,
            vertical: true,
            cls: 'x-viewoptionsbar',
            alwaysOnTop:true,
//collapsible: true,
            region: 'west',
            title: 'Options Tool Bar',
            autoScroll:true
        });
        hbox.insert(attachPosition,optionsToolBar);
    }

    public function viewClose(active:Bool){
        /*var closebtn = centralPanel.getComponent('closeAnnotmenu');
        var attachPosition = centralPanel.items.findIndex('itemId', 'closeAnnotmenu');
        centralPanel.remove('closeAnnotmenu', false);
        centralPanel.doLayout();
        if(active==true){
            closebtn.show();
        }
        else{
            closebtn.hide();
        }

        centralPanel.add(closebtn);
        centralPanel.doLayout();*/
    }

    public function updateOptionsToolBar(active:Bool){
        /*var closebtn = centralPanel.getComponent('closeAnnotmenu');
        var attachPosition = centralPanel.items.findIndex('itemId', 'closeAnnotmenu');
        centralPanel.remove('closeAnnotmenu', false);
        centralPanel.doLayout();
        if(active==true){
            closebtn.removeCls('x-btn-open-options');
            closebtn.addCls('x-btn-close-options');
        }
        else{
            closebtn.removeCls('x-btn-close-options');
            closebtn.addCls('x-btn-open-options');
        }

        centralPanel.add(closebtn);
        centralPanel.doLayout();*/
    }

    public function getOptionsToolBar(){
        if(optionsToolBar==null) return null;
        else return optionsToolBar;
    }
    public function hideOptionsToolBar(){
        optionsToolBar.hide();
    }
    public function showOptionsToolBar(){
        optionsToolBar.show();
    }
    public function clearOptionsToolBar(){

        var itemslist = optionsToolBar.items;

        // remove the items
        itemslist.each(function(item,index,length){
            optionsToolBar.remove(item, false);
        });

        optionsToolBar.doLayout();
    }

    public function addElemToOptionsToolBar(elem:Dynamic){
        optionsToolBar.add(elem);
        optionsToolBar.doLayout();
    }

/********************* Export SubMenu Tools Bar *********************/

    public function createExportSubMenu(viewer:ChromoHubViewer,?attachPosition = 10000){
        exportSubMenu = Ext.create('Ext.toolbar.Toolbar', {
            top:'0px',
            width: '120px',
            height: '50px',
            border: false,
            vertical: true,
            cls: 'x-exsubmenu-toolsbar',
            modal:false,
            floating:true,
            alwaysOnTop:true,
            listeners:{
                'mouseleave': function( menu, e, eOpts){
                    menu.hide();
                }
            }
        });
        exportSubMenu.add({
            iconCls :'x-btn-exportpng-single',
            handler : function(){
                viewer.exportPNG();
            },
            tooltip : {dismissDelay: 10000, text: 'Export Tree as PNG file'}
        });
        exportSubMenu.add({
            iconCls :'x-btn-exportsvg-single',
            handler : function(){
                viewer.exportSVG();
            },
            tooltip : {dismissDelay: 10000, text: 'Export Tree as SVG file'}
        });
        hbox.insert(attachPosition,exportSubMenu);
    }

    public function hideExportSubMenu(){
        exportSubMenu.hide();
    }
    public function showExportSubMenu(x:Int){
        exportSubMenu.setPosition(x);
        exportSubMenu.show();
    }

    public function getExportSubMenu(){
        return exportSubMenu;
    }

/*********************SubMenu Tools Bar *********************/

    public function createSubMenuToolBar(?attachPosition = 10000){
        subMenuToolBar = Ext.create('Ext.toolbar.Toolbar', {
            top:'0px',
            left:'150px',
            width: '1px',
            height: '100px',
            border: false,
            vertical: true,
            cls: 'x-submenu-toolsbar',
            modal:false,
            floating:true,
            alwaysOnTop:true,
            title: 'SubMenu Tool Bar'
        });
        hbox.insert(attachPosition,subMenuToolBar);
    }
    public function clearSubMenuToolBar(){
        var attachPosition = hbox.items.findIndex('id', subMenuToolBar.id);

        hbox.remove(subMenuToolBar);
        setTopSubMenuToolBar(0);
        createSubMenuToolBar(attachPosition);
    }
    public function hideSubMenuToolBar(){
        subMenuToolBar.hide();
    }
    public function showSubMenuToolBar(){
        subMenuToolBar.show();
    }
    public function getSubMenuToolBar(){
        return subMenuToolBar;
    }
    public function addElemToSubMenuToolBar(elem:Dynamic){
        subMenuToolBar.add(elem);
    }
    public function setTopSubMenuToolBar(top:Dynamic){
        subMenuToolBar.setPosition(435,top);
    }
    public function setHeightSubMenuToolBar(height:Dynamic){
        subMenuToolBar.setHeight(height);
    }


/*********************Helping Div *********************/

    public function createHelpingDiv(?attachPosition = 10000){
        helpingDiv = Ext.create('Ext.Container', {
            top:'0px',
            left:'5px',
            width: '1px',
           // height: '100px',
            vertical: true,
            cls: 'x-helpingDiv',
            floating:true,
            alwaysOnTop:true,
            id:'helpingDiv',
            title: 'Helping Div',
            listeners:{
                mouseout:
                    function(e){
                        //hide the flying help div
                        helpingDiv.hide();

                    },
                mouseover:
                    //show a flying help div
                    function(e){
                        hideHelp=false;
                    }
            }
        });
        hbox.insert(attachPosition,helpingDiv);
    }
    public function clearHelpingDiv(){
        var attachPosition = hbox.items.findIndex('id', helpingDiv.id);

        hbox.remove(helpingDiv);
        setTopHelpingDiv(0);
        createHelpingDiv(attachPosition);
    }
    public function hideHelpingDiv(){
        helpingDiv.hide();
    }
    public function showHelpingDiv(){
        //sefa
        hideSubMenuToolBar();
        helpingDiv.show();
    }
    public function getHelpingDiv(){
        return helpingDiv;
    }
    public function addHtmlTextHelpingDiv(text:String){
        helpingDiv.html=text;
    }
    public function setTopHelpingDiv(top:Dynamic){
        helpingDiv.setPosition(135,top);
    }
    public function setHeightHelpingDiv(height:Dynamic){
        helpingDiv.setHeight(height);
    }
/*********************Annot Window *********************/

    public function showAnnotWindow(text:String,px:Dynamic, py:Dynamic, title:String,ident:String,data: PhyloScreenData){

        if(alreadyOpen(ident)==false){

            var r= Math.random() * (300-1) + 1;
            var id=Std.int(r);
           //hile(annotWindow.exists(id)){
           //   r=Math.random();
           //   id=Std.int(r);

           //

            var myWindow = Ext.create('Ext.window.Window', {
                x:px,
                y:py,
                maxHeight:500,
               // width: '500px',
               // height: '200px',
                cls: 'x-annot-window',
                id: 'annotWin-'+ident,
                modal:false,
                autoscroll: true,
                overflowY:'auto',
                layout:'fit',
                shadow:true,
                resizable:true,
                title: title,
                html: text,
                listeners:{
                    close:function(win){
                        annotWindow.remove(id);
                        data.created = false;
                    },
                    hide:function(win){
                        annotWindow.remove(id);
                        data.created = false;
                    }
                }
            });
            myWindow.show();
            annotWindow.set(id,myWindow);
            annotWindowDoLayout();
        }
    }
    public function alreadyOpen(ident:String):Bool{
        var key:Dynamic;
        for(key in annotWindow.keys()){
            var elem=annotWindow.get(key);
            if(elem.id=='annotWin-'+ident) return true;
        }
        return false;
    }
    public function removeAnnotWindows(){
        var key:Int;
        for(key in annotWindow.keys()){
            var elem=annotWindow.get(key);
            elem.close();
            annotWindow.remove(key);
        }
    }
    public function annotWindowDoLayout(){
        var key:Int;
        for(key in annotWindow.keys()){
            var elem=annotWindow.get(key);
            elem.doLayout();
        }
    }


    /**** Annot Window for Annot Table ****/

    public function showAnnotWindowTable(text:String,px:Dynamic, py:Dynamic){
        var  annotWindowT = Ext.create('Ext.window.Window', {
            x:px,
            y:py,
            // width: '500px',
            // height: '200px',
            cls: 'x-annot-window',
            modal:false,
            autoscroll: true,
            overflowY:'auto',
            layout:'fit',
            shadow:true,
            resizable:true,
            html: text
        });
        annotWindowT.show();
    }
/**** UltraDD Gene list Window  ****/

    public function showUltraDDWindow(item:Array<Dynamic>,px:Dynamic, py:Dynamic,title:Int,viewer:ChromoHubViewer){
        cleanALlWindows();
         ultraDDWindow = Ext.create('Ext.window.Window', {
            x:px,
            //y:py,
            width: '800px',
            maxHeight: 600,
            cls: 'x-ultradd-window',
            modal:true,
            autoScroll: true,
            overflowY:'auto',
            //layout:'fit',
            shadow:true,
            resizable:true,
            maximizable:true,
            title:'UltraDD Genes'

        });
        ultraDDWindow.add(
            {
            xtype : 'form',
            iconCls: 'x-popup-form',
           // height: '100%',
            defaultType: 'checkboxfield',
            id:'wform',
            items: item,
            title:'Select the genes you want to add into annotations table.Total number of genes: '+title,
            buttons: [{
                    iconCls: 'x-btn-accept',
                    text: 'Accept',
                    handler: function() {
                        var form:Dynamic;
                        form = this.ultraDDWindow.getComponent('wform');
                        viewer.geneMap=new Map<String, PhyloTreeNode>();

                        if (form.isValid()) {

                            var i=0;var j=0;
                            var mylist:Array<String>;
                            mylist=new Array();
                            for(i in 0...form.items.items.length){
                                if(form.items.items[i].checked==true){
                                    mylist.push(form.items.items[i].inputValue);
                                    viewer.treeName='';
                                    viewer.treeType='gene';
                                    viewer.newickStr='';
                                    viewer.annotationManager.searchedGenes=new Array();
                                    viewer.annotationManager.searchedGenes=mylist;
                                    //we need to create a TreeNode and add it into our geneMap structure
                                    var geneNode=new PhyloTreeNode(null, form.items.items[i].inputValue, true, 0);

                                    geneNode.l =1;
                                    geneNode.annotations= new Array();
                                    geneNode.activeAnnotation= new Array();

                                    viewer.geneMap.set(form.items.items[i].inputValue,geneNode);
                                }

                            }
                           if(mylist.length>0){
                               WorkspaceApplication.getApplication().showMessage('Alert','This process might take some time. Please wait.');
                               viewer.renderTable();
                           }
                            ultraDDWindow.hide();
                        }
                    }
                },
                {
                    iconCls: 'x-btn-accept',
                    text: 'Cancel',
                    handler: function() {
                        ultraDDWindow.hide();
                    }
                }
            ]});
        ultraDDWindow.show();
    }

    function cleanALlWindows(){
        if(highlightWindow!=null){
            /*var itemslist = highlightWindow.items;

            itemslist.each(function(item,index,length){
                highlightWindow.remove(item, true);
            });*/
            highlightWindow.removeAll(true);
            highlightWindow.doLayout();
            //highlightWindow=null;
        }
        if(ultraDDWindow!=null){
            var itemslist = ultraDDWindow.items;

            itemslist.each(function(item,index,length){
                ultraDDWindow.remove(item, true);
            });
            ultraDDWindow.removeAll(true);
            ultraDDWindow.doLayout();
            //ultraDDWindow=null;
        }
        if(popUpWindow!=null){
            var itemslist = popUpWindow.items;

            itemslist.each(function(item,index,length){
                popUpWindow.remove(item, true);
            });
            popUpWindow.removeAll(true);
            popUpWindow.doLayout();
           // popUpWindow=null;
        }

        if(tipWindow!=null){
            var itemslist = tipWindow.items;

            itemslist.each(function(item,index,length){
                tipWindow.remove(item, true);
            });
            tipWindow.removeAll(true);
            tipWindow.doLayout();
            // popUpWindow=null;
        }
    }
/**** Highlight Gene list Window  ****/

    public function showHighlightWindow(item:Array<Dynamic>,px:Dynamic, py:Dynamic,title:Int,viewer:ChromoHubViewer){
        cleanALlWindows();

        function compare(a, b) {
            var geneNameA = a.boxLabel.toUpperCase();
            var geneNameB = b.boxLabel.toUpperCase();

            var comparison = 0;
            if (geneNameA > geneNameB){
                comparison = 1;
            } else if (geneNameA < geneNameB){
                comparison = -1;
            }
            return comparison;
        }

        item.sort(compare);

        highlightWindow = Ext.create('Ext.window.Window', {
            x:px,
            //y:py,
            width: '800px',
            maxHeight: 600,
            cls: 'x-highlight-window',
            modal:true,
            autoScroll: true,
            overflowY:'auto',
            //layout:'fit',
            shadow:true,
            resizable:true,
            maximizable:true,
            title:'Highlight Genes'

        });
        highlightWindow.add(
            {
                xtype : 'form',
                iconCls: 'x-popup-form',
                // height: '100%',
                defaultType: 'checkboxfield',
                id:'wform',
                items: item,
                title:'Select the genes you want to highlight in tree.Total number of genes: '+title,
                buttons: [{
                    iconCls: 'x-btn-accept',
                    text: 'Accept',
                    handler: function() {
                        var form:Dynamic;
                        form = this.highlightWindow.getComponent('wform');
                        viewer.config.highlightedGenes=new Map<String, Bool>();
                        if (form.isValid()) {

                            var i=0;var j=0;
                            for(i in 0...form.items.items.length){
                                if(form.items.items[i].checked==true){
                                    if(viewer.config.highlightedGenes.exists(viewer.rootNode.targets[i])==false){
                                        viewer.config.highlightedGenes.set(form.items.items[i].inputValue,true);
                                    }
                                }
                            }
                            viewer.newposition(0,0);
                            highlightWindow.hide();
                        }
                    }
                    },
                    {
                        iconCls: 'x-btn-accept',
                        text: 'Remove highlights',
                        handler: function() {
                            viewer.config.highlightedGenes=new Map<String, Bool>();
                            viewer.newposition(0,0);
                            highlightWindow.hide();
                        }
                    },
                    {
                        iconCls: 'x-btn-accept',
                        text: 'Cancel',
                        handler: function() {
                            highlightWindow.hide();
                        }
                    }
                ]});
        highlightWindow.doLayout();
        highlightWindow.show();
    }


/*********************User message Domain based doesn't exist *********************/

    public function createMessageDomainWindow(viewer:ChromoHubViewer){
        messageDomainWindow = Ext.create('Ext.window.Window', {
            width: '500px',
// height: '200px',
            cls: 'x-popup-window',
            modal:true,
            title: 'Message'
        });
        messageDomainWindow.add({
            xtype : 'form',
            iconCls: 'x-popup-form',
            height: '200px',
            id:'w1form',
            defaultType: 'checkboxfield',
            items: [{
                xtype: "label",
                text: "There is no domain-based alignment for this family. This phylogenetic tree is based on full-length alignment.",
                cls: 'x-label-message',
                boxLabel:'',
                id:''

            },
            {
                xtype: "checkboxfield",
                text: "Don\'t show this message again",
                boxLabel: "Don\'t show this message again",
                cls: 'x-checkbox-message',
                id: "click_message_finish"
            }],
            buttons: [{
                iconCls: 'x-btn-accept',
                text: 'Accept',
                handler: function() {
                    var form = this.messageDomainWindow.getComponent('w1form');
                    if (form.isValid()) {
                        if(form.items.items[1].lastValue==true){
                            viewer.adviseDomainUser(false);
                        }
                        //viewer.
                        hideMessageDomainWindow();
                    }
                }
            }]
        });
    }

    public function showMessageDomainWindow(){
        messageDomainWindow.show();
    }

    public function hideMessageDomainWindow(){
        messageDomainWindow.hide();
    }

 /************** Progress Bar *****************/
    public function showProgressBar(){
        cleanALlWindows();
        progressBar = Ext.create('Ext.window.Window', {
            width:  230,
            height: 210,
            //y:    5,
            //x:   6,
            cls:    'x-progressbar',
            modal:  true,
            resizable: false,
            closable: false,
            title:  'Please wait ...',
            items: [{
                xtype: "container",
                cls: 'x-progress-bar',
                width:  200,
                height: 130,
                html:'<img src="/static/js/images/giphy.gif">',
                boxLabel:'',
                id:'id-tip-html'
            }]
        });
        progressBar.show();
    }

    public function hideProgressBar(){
        if(progressBar!=null) progressBar.hide();
    }

/*********** Tip Of the Day Window **********************/
    public function createTipWindow(viewer:ChromoHubViewer, top:Int, left:Int, width:Int, height:Int, text:String){
        var th=Std.int(height*0.85);
        var fh=Std.int(th*0.85);
        var bh=height-fh;
        tipWindow = Ext.create('Ext.window.Window', {
            width:  width,
            height: height,
            maxHeight:600,
            y:    5,
            x:   left,
            cls:    'x-tip-window',
            modal:  true,
            resizable: false,
            closable: true,
            title:  'Tip of the Day'
        });
        tipWindow.add({
            xtype : 'form',
            iconCls: 'x-popup-form',
            width:  width,
            buttonAlign : 'left',
            id:'tipForm',
            items: [{
                xtype: "container",
                cls: 'x-sefa-form',
                width:  width,
                height: height-150,
                html: text,

                boxLabel:'',
                id:'id-tip-html'

            }],
            buttons: [{
                iconCls: 'x-previous-tip-btn',
                text: 'Prev Tip',
                id:'previous-tip-btn',
                handler: function() {
                    var t=viewer.tipActive;
                    if(t==0) t=viewer.tips.length-1;
                    else t--;
                    viewer.tipActive=t;
                    var title =viewer.tips[viewer.tipActive].title;
                    var html =viewer.tips[viewer.tipActive].html;
                    var text="<h2>"+title+"</h2>"+html;
                    changeContentTipWindow(text);
                }
            },{
                iconCls: 'x-next-tip-btn',
                text: 'Next Tip',
                id:'next-tip-btn',
                handler: function() {

                    var t=viewer.tipActive;
                    t++;
                    if(t==viewer.tips.length) t=0;

                    viewer.tipActive=t;
                    var title =viewer.tips[viewer.tipActive].title;
                    var html =viewer.tips[viewer.tipActive].html;
                    var text="<h2>"+title+"</h2>"+html;
                    changeContentTipWindow(text);
                }
            },{
                iconCls: 'x-close-tip-btn',
                text: 'Close',
                id:'close-tip-btn',
                handler: function(){

                    var checkoption = this.tipWindow.getComponent('click_tip_finish');

                    if(checkoption.lastValue==true){
                        viewer.showTips(true);


                    }else{
                        viewer.showTips(false);

                    }
                    hideTipWindow();
                }

            }],
            listeners:{
                close:function(win){
                     var checkoption = this.tipWindow.getComponent('click_tip_finish');

                    if(checkoption.lastValue==true){
                        viewer.showTips(true);


                    }else{
                        viewer.showTips(false);

                    }
                    hideTipWindow();

                },
                hide:function(win){
                    var checkoption = this.tipWindow.getComponent('click_tip_finish');

                    if(checkoption.lastValue==true){
                        viewer.showTips(true);

                    }else{
                        viewer.showTips(false);
                    }
                    hideTipWindow();
                }
            }
        });
        tipWindow.add({
            xtype: "checkboxfield",
            html: '',
            width:  135,
            height: 30,
            checked: true,
            boxLabel: "Show Tips on Startup",
            cls: 'x-checkbox-message',
            id: "click_tip_finish"
        });
        tipWindow.show();
    }

    public function changeContentTipWindow(html:String){

        var item = tipWindow.items.items[0].items.items[0];

        // remove the items
       // itemslist.each(function(item,index,length){
            if(item.id=='id-tip-html') item.html=html;
      //  });
        item.update(html);
        tipWindow.doLayout();

    }

    public function hideTipWindow(){
        tipWindow.hide();
    }

    public function showTipWindow(){
        if(subMenuToolBar!=null) hideSubMenuToolBar();
        if(helpingDiv!=null) hideHelpingDiv();
        tipWindow.show();
    }
    public function getTipWindow():Dynamic{
        return tipWindow;
    }


    /********* Demo Video window *********/
    public function createDemoWindow(viewer:ChromoHubViewer, top:Int, left:Int, width:Int, height:Int, text:String){
        var th=Std.int(height*0.85);
        var fh=Std.int(th*0.85);
        var bh=height-fh;
        demoWindow = Ext.create('Ext.window.Window', {
            width:  width,
            height: height,
            maxHeight:600,
            y:    5,
            x:   left,
            cls:    'x-tip-window',
            modal:  true,
            resizable: false,
            closable: true,
            title:  'Demo'
        });
        demoWindow.add({
            xtype : 'form',
            iconCls: 'x-popup-form',
            width:  width,
            buttonAlign : 'left',
            id:'demoForm',
            items: [{
                xtype: "container",
                cls: 'x-leo-form',
                width:  width,
                height: height-150,
                html: text,
                boxLabel:'',
                id:'id-demo-html'
            }],
            buttons: [{
                iconCls: 'x-close-demo-btn',
                text: 'Close',
                id:'close-demo-btn',
                handler: function(){
                    var checkoption = this.demoWindow.getComponent('click_demo_finish');
                    hideDemoWindow();
                }

            }],
            listeners:{
                close:function(win){
                    var checkoption = this.demoWindow.getComponent('click_demo_finish');
                    hideDemoWindow();

                }
            }
        });
        demoWindow.show();
    }

    public function hideDemoWindow(){
        demoWindow.hide();
    }

    public function showDemoWindow(){
        if(subMenuToolBar!=null) hideSubMenuToolBar();
        if(helpingDiv!=null) hideHelpingDiv();
        demoWindow.show();
    }

    public function getDemoWindow():Dynamic{
        return demoWindow;
    }


/*********************User message *********************/

    public function createMessageWindow(viewer:ChromoHubViewer){
        messageWindow = Ext.create('Ext.window.Window', {

            width: '500px',
// height: '200px',
            cls: 'x-popup-window',
            modal:true,
            title: 'Message'
        });
        messageWindow.add({
            xtype : 'form',
            iconCls: 'x-popup-form',
            height: '200px',
            id:'w2form',
            defaultType: 'checkboxfield',
            items: [{
                xtype: "label",
                text: "Click on the annotation icon for more details.",
                cls: 'x-label-message',
                boxLabel:'',
                id:''

            },
            {
                xtype: "checkboxfield",
                text: "Don\'t show this message again",
                boxLabel: "Don\'t show this message again",
                cls: 'x-checkbox-message',
                id: "click_moremessage_finish"
            }],
            buttons: [{
                iconCls: 'x-btn-accept',
                text: 'Accept',
                handler: function() {
                    var form = this.messageWindow.getComponent('w2form');
                    if (form.isValid()) {
                        if(form.items.items[1].lastValue==true){
                            viewer.adviseUser(false);
                        }
                        //viewer.
                        hideMessageWindow();
                    }
                }
            }]
        });
    }

    public function showMessageWindow(){
        messageWindow.show();
    }

    public function hideMessageWindow(){
        messageWindow.hide();
    }


/*********************POP UP Window *********************/

    public function createPopUpWindow(){

        cleanALlWindows();
        popUpWindow = Ext.create('Ext.window.Window', {
            x:'300px',
            y:'30px',
            width: '500px',
// height: '200px',
            cls: 'x-popup-window',
            modal:true,
            title: 'Windows POP UP'
        });
        popUpWindow.doLayout();
    }
    public function clearPopUpWindow(){
        var attachPosition = hbox.items.findIndex('id', popUpWindow.id);

        hbox.remove(popUpWindow);
        popUpWindow.removeAll();
        setPosPopUpWindow(0,0);
        createPopUpWindow();
    }
    public function hidePopUpWindow(){
        popUpWindow.hide();
    }
    public function showPopUpWindow(){
        popUpWindow.show();
    }
    public function getPopUpWindow(){
        return popUpWindow;
    }
    public function addElemToPopUpWindow(elem:Dynamic){
        popUpWindow.add(elem);
    }
    public function addFormItemToPopUpWindow(item:Dynamic, annot, hasClass, popMethod, tree_type:String, family:String, searchGenes:Array<Dynamic>,annotationManager:ChromoHubAnnotationManager){

        popUpWindow.add({
            xtype : 'form',
            iconCls: 'x-popup-form',
            height: '200px',
            defaultType: 'checkboxfield',
            id:'wform',
            items: item,
            buttons: [
               /* {sefa
                iconCls: 'x-btn-accept',
                text: 'Hide Annotation',
                handler: function() {
                    viewer.showAnnotation(annot, false);
                    removeComponentFromLegend(annot);
                    hidePopUpWindow();
                }
            },*/
            {
                iconCls: 'x-btn-accept',
                text: 'Accept',
                handler: function() {
                    var form = this.popUpWindow.getComponent('wform');
                    if (form.isValid()) {

                       annotationManager.cleanAnnotResults(annot);

                       var hook = Reflect.field(Type.resolveClass(hasClass), popMethod);
                        hook(annot,form,tree_type,family,searchGenes,annotationManager, function(){

                        }
                        );
                       // if(viewer.userMessage==true){
                         //   showMessageWindow();
                        //}

                        if (annotationManager.skipAnnotation[annot] != true){
                            if (annotationManager.skipCurrentLegend[annot] != true){
                                addImageToLegend(annotationManager.annotations[annot].legend, annot);
                            }
                            legendPanel.expand();
                            hidePopUpWindow();

                            if (annotationManager.skipCurrentLegend[annot] != true){
                                annotationManager.activeAnnotation[annot]=true;
                            }
                            annotationManager.activeAnnotation[annot]=true;
                            clearOptionsToolBar();
                            annotationManager.createViewOptions();
                            addElemToOptionsToolBar(annotationManager.viewOptions);
                            var elem=js.Browser.document.getElementById('optionToolBarId');
                            elem.scrollTop=annotationManager.menuScroll;
                        } else {

                            hidePopUpWindow();
                            clearOptionsToolBar();
                            annotationManager.createViewOptions();
                            addElemToOptionsToolBar(annotationManager.viewOptions);
                        }
                    }
                }
            },
                {
                    iconCls: 'x-btn-accept',
                    text: 'Cancel',
                    handler: function() {
                    hidePopUpWindow();
                }
            }]
        });
    }
    public function setPosPopUpWindow(left:Dynamic,top:Dynamic){
        popUpWindow.setPosition(left,top);
    }
    public function setPopUpWindowTitle(title:String){
        popUpWindow.title=title;
    }

/********************/

    public function getComponent(){
        return hbox;
    }

    public function setProgram(program : Program){
        this.program = program;

        var progComponent = this.program.getRawComponent();

        centralPanel.add(progComponent);
        centralPanel.doLayout();

        progComponent.doLayout();
        progComponent.show();

        centralPanel.doLayout();

        program.focusProgram();
    }

    public function getApplication() : WorkspaceApplication{
        return WorkspaceApplication.getApplication();
    }

    public function getCentralContainer() : Dynamic {
        return centralPanel;
    }


}
