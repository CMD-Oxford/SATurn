package saturn.app;
import saturn.client.workspace.ChromoHubWorkspaceObject;
import saturn.client.programs.ChromoHubViewer;
import saturn.core.domain.Alignment;
import saturn.client.WorkspaceApplication;

class ChromoHubClient extends SaturnClient{
    public function new(applicationTitle : String, navigationTitle : String, southTitle : String, detailsTitle : String, tabContainerTitle : String, searchBarTitle : String, nakedMode : Bool, mainSearchText : String){
        //REF: mainSearchText
        super(applicationTitle, navigationTitle, southTitle, detailsTitle, tabContainerTitle, searchBarTitle, nakedMode);
    }

    override public function registerPrograms(){
        this.getProgramRegistry().registerProgram(ChromoHubViewer, true);
    }

    override public function initApplication(){
        super.initApplication();

        addSearchBarListener(this);
    }

    //REF: override
    override public function afterLoad(){
        // Creates a ChromoHub object
        var prog = new ChromoHubViewer();

        var obj = new ChromoHubWorkspaceObject(new Alignment(), "Tree");
        obj.standaloneMode = true;

        getWorkspace().registerObjectWith(obj,prog);
    }

    override public function textChanged( app : WorkspaceApplication, queryStr : String, it : Dynamic ) : Void {
        if(queryStr == 'me'){
            if(clientCore.getUser() != null){
                queryStr = clientCore.getUser().fullname;
            }
        }

        //check if the gene is in any of the families
        var prog = cast(getActiveProgram(), ChromoHubViewer);
        if(prog!=null){
            if(queryStr.length>2){
                prog.showSearchedGenes(queryStr );
            }
        }


        var units = new Array<Dynamic>();

        units.push({indexof: null, func: autocomplete_fts_models, minlen: null, name: 'FTS', limit : 40});

        var foundItems = new Array<Dynamic>();

        var i = 0;

        var next = null;
        next = function(items : Array<Dynamic>){
            if(items != null){
                for(item in items){
                    item.id = i++;
                    foundItems.push(item);
                }
            }

            if(units.length == 0){
                js.Browser.window.console.log('Returning');

                var d :Dynamic= js.Browser.window;
                d.items = foundItems;

                var auxMap:Map<String,Dynamic>;
                auxMap=new Map();
                var i=0;
                for(i in 0...foundItems.length){
                    //remove duplicate target in name
                    if(foundItems[i].title.indexOf('-')!=-1){
                        var tit=new Array();
                        tit=foundItems[i].title.split(' - ');
                        if (tit.length==2 && tit[0]==tit[1]){
                            foundItems[i].title=tit[0];
                        }
                    }
                    if(auxMap.exists(foundItems[i].targetId)==false) auxMap.set(foundItems[i].targetId,foundItems[i]);
                }

                var newFoundItems:Array<Dynamic>;
                newFoundItems=new Array();
                var key:Dynamic;
                for (key in auxMap.keys()) {

                    newFoundItems.push(auxMap.get(key));
                }
                autocomplete_update(newFoundItems);

                return;
            }else{
                var unit = units.pop();
                var indexof = unit.indexof;
                var minlen = unit.minlen;
                var func :Dynamic = unit.func;
                var name = unit.name;
                var limit = unit.limit;

                if(indexof != null && queryStr.indexOf(indexof) == -1){
                    next(null);
                }else {
                    if(minlen != null && queryStr.length < minlen){
                        next(null);
                    }else{
                        js.Browser.window.console.log('Running ' + name);
                        func(queryStr, next, limit);
                    }
                }
            }
        }

        next(null);

        it.next();
    }

    override public function objectSelected( app : WorkspaceApplication, records : Dynamic, it : Dynamic ) : Void {
        var targetId : String = records[0].data.targetId;

        //var prog : saturn.client.programs.ChromoHubViewer = getActiveProgram();
        var prog = cast(getActiveProgram(), ChromoHubViewer);
       // prog.searchedGenes[prog.searchedGenes.length]=targetId;
        prog.showAddedGenes(targetId );

    }
}
