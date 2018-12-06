package saturn.app;
import saturn.client.programs.chromohub.annotations.SomaticMutationAnnotation;
import saturn.client.workspace.ChromoHubWorkspaceObject;
import saturn.client.programs.chromohub.ChromoHubViewer;
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

        SomaticMutationAnnotation.updateSomaticDiseaseList(function(error){

        });
    }

    override public function textChanged( app : WorkspaceApplication, queryStr : String, it : Dynamic ) : Void {
        //check if the gene is in any of the families
        var prog = cast(getActiveProgram(), ChromoHubViewer);
        if(prog!=null){
            if(queryStr.length>2){
                prog.showSearchedGenes(queryStr);

                var storeList : Array<Dynamic> = new Array<Dynamic>();


                WorkspaceApplication.getApplication().getProvider().getByNamedQuery("getTargetSynonym",{gene: '%'+queryStr+'%'}, null, true, function(db_results:Array<Dynamic>, error){

                    if(error == null) {

                        if(db_results.length!=0){

                            var model = Type.resolveClass('saturn.core.domain.chromohub.Target');

                            for(i in 0 ... db_results.length){
                                var target = db_results[i].target_id;
                                var synonym = db_results[i].synonyms;
                                var targetSynonym;
                                if(synonym == null) {
                                    targetSynonym = target;
                                } else {
                                    targetSynonym = target + ' - ' + synonym;
                                }


                                var item = { field: 'targetId', group : 'Genes', icon: '', id : i, title : targetSynonym, targetId: target, type : model};

                                storeList.push(item);

                            }
                            autocomplete_update(storeList);
                            it.next();
                        }

                    } else {
                        WorkspaceApplication.getApplication().debug(error);
                    }


                });





            }
        }



    }

    override public function objectSelected( app : WorkspaceApplication, records : Dynamic, it : Dynamic ) : Void {
        var targetId : String = records[0].data.targetId;

        #if UBIHUB

        #else
        //var prog : saturn.client.programs.ChromoHubViewer = getActiveProgram();
        var prog = cast(getActiveProgram(), ChromoHubViewer);
       // prog.searchedGenes[prog.searchedGenes.length]=targetId;
        prog.showAddedGenes(targetId );
        #end
    }
}
