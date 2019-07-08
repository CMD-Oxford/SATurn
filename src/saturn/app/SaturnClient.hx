/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.app;

import saturn.client.programs.ComplexHelper;
import saturn.client.core.ClientCore;
import saturn.client.programs.PurificationHelper;
import saturn.client.programs.SHRNADesigner;
import saturn.client.WorkspaceApplication;
import saturn.client.WorkspaceApplication;
import saturn.core.EUtils;
import saturn.core.annotations.PfamSupplier;
import saturn.db.query_lang.SQLVisitor;
import saturn.core.domain.Compound;
import saturn.core.Table;
import saturn.core.MSA;
import saturn.core.ClustalOmegaParser;
import saturn.core.WONKASession;
import saturn.client.workspace.WONKAWO;
import saturn.core.domain.StructureModel;
import saturn.db.Model;
import saturn.client.programs.plugins.ThreeDMolViewer;
import saturn.client.workspace.ScarabELNWO;
import saturn.util.HaxeException;
import saturn.client.programs.blocks.TargetSummary;
import saturn.client.workspace.GridVarWO;
import saturn.core.GridVar;
import saturn.client.programs.plugins.AlignmentGVPlugin;
import saturn.client.programs.plugins.IViewPlugin;
import saturn.client.programs.plugins.ActiveICMPlugin;
import saturn.client.programs.plugins.GLmolViewerPlugin;
import saturn.client.workspace.StructureModelWO;
import saturn.client.programs.plugins.FASTAGridVarPlugin;
import saturn.client.programs.ConsoleViewer;
import saturn.core.PDBParser;
import saturn.client.core.CommonCore;
import saturn.db.mapping.SQLiteMapping;
import saturn.core.FastaEntity;
import saturn.client.workspace.AlignmentWorkspaceObject;
import saturn.core.domain.Alignment;
import js.Browser;
import saturn.core.domain.TiddlyWiki;
import saturn.client.workspace.TableHelperWO;
import saturn.client.programs.TableHelper;
import saturn.client.programs.ABITraceViewer;
import saturn.core.TableHelperData;
import saturn.client.workspace.WebPageWorkspaceObject;
import saturn.client.workspace.WebPage;
import saturn.db.mapping.SGC;
import saturn.db.Provider;
import saturn.db.NodeProvider;
import saturn.client.programs.plugins.DisoPredAnnotationPlugin;
import saturn.client.workspace.MultiConstructHelperWO;
import saturn.core.MultiConstructHelperData;
import saturn.core.domain.SgcConstructPlate;
import saturn.core.MultiAlleleHelperData;
import saturn.client.workspace.MultiAlleleHelperWO;
import saturn.core.domain.SgcAllelePlate;
import saturn.client.programs.MultiAlleleHelper;
import saturn.client.programs.plugins.TMHMMAnnotationPlugin;
import saturn.client.programs.plugins.SVGDomainAnnotationPlugin;
import saturn.client.programs.plugins.SSAnnotationPlugin;
import saturn.client.programs.plugins.DomainAnnotationPlugin;
import bindings.Ext;
import saturn.core.domain.SgcAllele;
import saturn.core.domain.SgcSeqData;
import saturn.core.domain.SgcTarget;
import saturn.core.domain.SgcEntryClone;
import saturn.core.domain.SgcReversePrimer;
import saturn.core.domain.SgcForwardPrimer;
import saturn.core.domain.SgcConstruct;
import saturn.core.scarab.LabPage;
import saturn.client.programs.MultiConstructHelper;
import js.Lib;
import saturn.client.WorkspaceApplication;
import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.client.programs.WebPageViewer;
import saturn.client.SearchBarListener;
import saturn.client.EXTApplication;
import saturn.core.DNA;
import saturn.core.Primer;
import saturn.core.PrimerRegistry;
import saturn.core.Protein;
import saturn.client.programs.AlleleViewer;
import saturn.client.programs.DigestViewer;
import saturn.client.programs.DNASequenceEditor;
import saturn.client.programs.plugins.AnnotationPlugin;
import saturn.client.programs.AlignmentViewer;
import saturn.client.programs.CrystalHelper;
import saturn.client.programs.PCRProductViewer;
import saturn.client.programs.Phylo5Viewer;
import saturn.client.programs.ProteinSequenceEditor;
import saturn.client.programs.LigationViewer;
import saturn.client.workspace.DNAWorkspaceObject;
import saturn.client.workspace.PrimerWorkspaceObject;
import saturn.client.workspace.ProteinWorkspaceObject;
import saturn.client.workspace.DigestWO;
import saturn.client.ICMClient;
import saturn.core.domain.SgcConstruct;
import saturn.client.programs.TiddlyWikiViewer;

import saturn.client.BioinformaticsServicesClient;

import saturn.client.programs.GridVarViewer;
import saturn.client.programs.PDBViewer;
import saturn.client.programs.HomePage;
import saturn.client.programs.TextEditor;
import saturn.client.programs.ScarabELNViewer;
import saturn.client.programs.GlycanBuilder;
import saturn.client.programs.CompoundViewer;
import saturn.client.programs.WONKA;

import saturn.db.Model.SearchDef;
import saturn.client.programs.BasicTableViewer;
import saturn.client.programs.EmptyViewer;

import saturn.client.programs.ConstructDesigner;
//<IMPORTS>

class SaturnClient extends EXTApplication implements SearchBarListener{
    static var reg_edit  : EReg = ~/edit\s+/;
    static var reg_wiki  : EReg = ~/wiki-\s+/;

    public static function main() {
        var inScarab = false;

        var client : SaturnClient = new SaturnClient('SATurn Framework','Workspace', 'Notifications', 'Outline', 'Editor', 'Type to search (targets/constructs/alleles/entry clones/primers/compounds)', false);

        WorkspaceApplication.setApplication(client);
    }

    override public function initApplication(){
        super.initApplication();

        haxe.Serializer.USE_CACHE = true;

        CommonCore.getAnnotationManager().registerAnnotationSupplier(new PfamSupplier(), 'PFAM');

        var dwin : Dynamic = js.Browser.window;
        dwin.app = this;
        dwin.WK = this.getWorkspace();
        dwin.wk = this.getWorkspace();

        dwin.ASYNC = function(objs, error){dwin.result=objs;dwin.error = error;};
        dwin.EntryClone = saturn.core.domain.SgcEntryClone;
        dwin.Allele = saturn.core.domain.SgcAllele;
        dwin.Construct = saturn.core.domain.SgcConstruct;
        dwin.Vector = saturn.core.domain.SgcVector;
        dwin.DNA = saturn.core.DNA;
        dwin.Protein = saturn.core.Protein;
        dwin.Frame = saturn.core.Frame;
        dwin.StandardCode = saturn.core.DNA.GeneticCodes.STANDARD;
        dwin.DNAWO = saturn.client.workspace.DNAWorkspaceObject;
        dwin.ProteinWO = saturn.client.workspace.ProteinWorkspaceObject;
        dwin.PCR = saturn.core.PCRProduct;
        dwin.Primer = saturn.core.Primer;
        dwin.print = this.addToPrintBuffer;
        dwin.flush = this.flushBufferToPanel;
        dwin.LabPage = saturn.core.scarab.LabPage;

        debug('Saturn loaded');


    }

    override function createMenuBar(){
        super.createMenuBar();

        getResourcesMenu().add({
            text : 'Clear compound image cache',
            handler: function(){
                clearCompoundImageCache();
            }
        });

        var exportMenu = getWorkspaceExportMenu();

        exportMenu.add({
            text : 'Protein -> FASTA',
            handler: function() {
                var workspace = getWorkspace();

                var strBuf = new StringBuf();

                var woProteins : Array<Protein> = workspace.getAllObjects(Protein);
                for(protein in woProteins){

                    var name = protein.getName();
                    name = StringTools.replace(name, ' (Protein)', '');

                    strBuf.add(FastaEntity.formatFastaFile(name, protein.getSequence()));
                }

                saveTextFile(strBuf.toString(),'Workspace_Proteins.fasta');
            }
        });

        exportMenu.add({
            text : 'DNA -> FASTA',
            handler: function() {
                var workspace = getWorkspace();

                var strBuf = new StringBuf();

                var objs : Array<DNA> = workspace.getAllObjects(saturn.core.DNA);
                for(dna in objs){
                    var name = dna.getName();
                    name = StringTools.replace(name, ' (DNA)', '');

                    strBuf.add(FastaEntity.formatFastaFile(name, dna.getSequence()));
                }

                saveTextFile(strBuf.toString(),'Workspace_DNA.fasta');
            }
        });

        var databases = [
            'construct_protein'=>'Update Construct Protein BLASTDB',
            'construct_protein_no_tag'=>'Update Construct Protein (No Tag) BLASTDB',
            'construct_nucleotide'=>'Update Construct Nucleotide BLASTDB',
            'allele_nucleotide'=>'Update PCR Products Nucleotide BLASTDB',
            'allele_protein'=>'Update PCR Products Protein BLASTDB',
            'entryclone_nucleotide'=>'Update Entry Clone Nucleotide BLASTDB',
            'entryclone_protein'=>'Update Entry Clone Protein BLASTDB',
            'target_nucleotide'=>'Update Target Nucleotide BLASTDB',
            'target_protein'=>'Update Target Protein BLASTDB',
            'vector_nucleotide'=>'Update Vector Nucleotide BLASTDB'
        ];



        getUpdateMenu().add({
            text: 'All Local BLASTDBs',
            handler: function(){
                var databaseNames = [];
                for(databaseName in databases.keys()){
                    databaseNames.push(databaseName);
                }

                var next = null;

                next = function(){
                    var databaseName = databaseNames.pop();

                    BioinformaticsServicesClient.getClient().sendBLASTDBUpdateRequest(databaseName, function(response, error){
                        if(error != null){
                            showMessage('BLASTDB update failed on ' + databaseName, error);
                        }

                        if(databaseNames.length == 0){
                            showMessage('BLAST Updates','BLASTDB updates completed');
                        }else{
                            next();
                        }
                    });
                };

                next();
            }
        });

        for(databaseName in databases.keys()){
            getUpdateMenu().add({
                text: databases.get(databaseName),
                handler: function(){
                    BioinformaticsServicesClient.getClient().sendBLASTDBUpdateRequest(databaseName, function(response, error){
                        if(error != null){
                            showMessage('BLASTDB update failed', error);
                        }else{
                            showMessage('BLASTDB updated', 'BLASTDB updated');
                        }
                    });
                }
            });
        }
    }

    /**
    * registerPrograms registers are default plugins and programs
    **/
    override public function registerPrograms(){
        super.registerPrograms();

        /**
        * Register default sequence editor plugins
        **/
        this.getProgramRegistry().registerPlugin(ProteinSequenceEditor,SVGDomainAnnotationPlugin);
        this.getProgramRegistry().registerPlugin(ProteinSequenceEditor,SSAnnotationPlugin);
        this.getProgramRegistry().registerPlugin(ProteinSequenceEditor,TMHMMAnnotationPlugin);
        //this.getProgramRegistry().registerPlugin(ProteinSequenceEditor,DisoPredAnnotationPlugin);
        this.getProgramRegistry().registerPlugin(GridVarViewer, FASTAGridVarPlugin);

        this.getProgramRegistry().registerPlugin(PDBViewer, ThreeDMolViewer);
        //this.getProgramRegistry().registerPlugin(PDBViewer, IViewPlugin);
        //this.getProgramRegistry().registerPlugin(PDBViewer, ActiveICMPlugin);
        this.getProgramRegistry().registerPlugin(PDBViewer, GLmolViewerPlugin);


        this.getProgramRegistry().registerPlugin(GridVarViewer, AlignmentGVPlugin);

        /**
        * Register default programs
        **/

        this.getProgramRegistry().registerProgram(WebPageViewer, true);
        this.getProgramRegistry().registerProgram(ProteinSequenceEditor, true);
        this.getProgramRegistry().registerProgram(DNASequenceEditor, true);
        this.getProgramRegistry().registerProgram(AlignmentViewer, true);
        this.getProgramRegistry().registerProgram(ABITraceViewer, true);
        //this.getProgramRegistry().registerProgram(PurificationHelper, true);

        this.getProgramRegistry().registerProgram(ConstructDesigner, true);
        this.getProgramRegistry().registerProgram(MultiAlleleHelper,true);
        this.getProgramRegistry().registerProgram(MultiConstructHelper,true);

        this.getProgramRegistry().registerProgram(Phylo5Viewer, true);
        //this.getProgramRegistry().registerProgram(ChromoHubViewer, true);
        //this.getProgramRegistry().registerProgram(SHRNADesigner, true);
        this.getProgramRegistry().registerProgram(TableHelper, true);

        this.getProgramRegistry().registerProgram(GridVarViewer, true);
        this.getProgramRegistry().registerProgram(PDBViewer, true);
        //this.getProgramRegistry().registerProgram(WONKA, true);
        //this.getProgramRegistry().registerProgram(CompoundViewer, true);

        this.getProgramRegistry().registerProgram(TextEditor, true);
	#if ELN
        //this.getProgramRegistry().registerProgram(ScarabELNViewer, true);
        this.getProgramRegistry().registerProgram(TiddlyWikiViewer, true);
	#end


        this.getProgramRegistry().registerProgram(BasicTableViewer, true);

        this.getProgramRegistry().registerProgram(CompoundViewer, true);
	#if GLYCANBUILDER
        this.getProgramRegistry().registerProgram(GlycanBuilder, true);
        #end

        this.getProgramRegistry().registerProgram(HomePage, true);

        this.getProgramRegistry().registerProgram(ComplexHelper, true);

		//<LOAD_PROGRAMS>

        /**
        * Register search bar listener
        **/
        addSearchBarListener(this);
    }

    /**
    * objectSelected is called when a search term is selected
    *
    * app: The application which triggered the search
    * records: Matching records
    * it: SearchBarListener iterator, call it.next() to notify the next listener
    **/
    public function objectSelected( app : WorkspaceApplication, records : Dynamic, it : Dynamic ) : Void {
        var targetId : String = records[0].data.targetId;
        var seqType : String = records[0].data.type;

        var item = records[0].data;

        var self = this;

        if(autocomplete_retrieveModel(item)){

        }else if(targetId.indexOf('PAGE') != -1){
            autocomplete_retrievePage(targetId);
        }else {
            autocomplete_retrieveTargetSequence(targetId, seqType, item);
        }
    }

    /**
    * textChanged is called when the search term is changed
    *
    * app: Application which triggered the event
    * queryStr: Term entered by the user
    * it: SearchBarListener iterator, call it.next() to notify the next listener
    **/
    public function textChanged( app : WorkspaceApplication, queryStr : String, it : Dynamic ) : Void {
        // Note that at the start of the SATurn project most of the search was hard-coded for each entity
        // SATurn now has a fully configurable search system for entities but some of the old code remains below

        var sequenceEntered = false;

        if(queryStr.length > 30){
            // Assume long sequences are DNA or Protein
            // TODO support InChI and SMILES
            if(queryStr.indexOf('>') == -1){
                var regex =~/\s/g;
                var regex2 =~/\n/g;

                var convertedString = regex.replace(queryStr,'');
                var convertedString = regex2.replace(convertedString,'');

                if(saturn.core.DNA.isDNA(convertedString) || saturn.core.Protein.isProtein(convertedString)){
                    queryStr = '>Sequence\n' + convertedString + '\n';

                    sequenceEntered = true;
                }
            }else{
                sequenceEntered = true;
            }

            if(sequenceEntered){
                // Type automatically determined
                DNASequenceEditor.parseFastaString(queryStr, true);

                return;
            }
        }

        var modifier = null;
        if(queryStr.indexOf('edit ') > -1){
            // TODO: check if we can remove this
            modifier = 'edit';

            queryStr = reg_edit.replace(queryStr,'');

            if(queryStr.length == 0){
                autocomplete_update([]);
                return;
            }
        }

        if(queryStr == 'me'){
            // Search for my own entities
            // TODO: Check if this still works
            if(ClientCore.getClientCore().getUser() != null){
                queryStr = ClientCore.getClientCore().getUser().fullname;
            }
        }

        // Each unit represents a different type of search
        var units = new Array<Dynamic>();



        // Legacy SGC units below
        var provider = getProvider();
        if(provider != null){
            var model = provider.getModel(saturn.app.SaturnClient);

            if(model != null){
                if(model.hasFlag('SGC')){
                    units.push({indexof: null, func: autocomplete_targets, minlen: null, name: 'Targets', limit : 10});
                    units.push({indexof: 'pdb-', func: retrieve_pdb, minlen: null, name: 'PDB', limit : 10});
                    units.push({indexof: 'PAGE', func: autocomplete_eln, minlen: null, name: 'ELN', limit : 10});
                }
            }
        }

        // Most entities should be configured to be searchable via this unit
        units.push({indexof: null, func: autocomplete_fts_models, minlen: null, name: 'FTS', limit : 10});

        // List of entities or pseudo entities (action + entity is a unique item)
        var foundItems = new Array<Dynamic>();

        // Gives each unit a unique ID
        var i = 0;

        // Units completed
        var completed = 0;
        // Units to complete
        var toComplete  = 0;

        // Function is called after each unit completes
        var onComplete = function(items : Array<Dynamic>){
            // Increment unit complete counter
            completed += 1;

            // Add items found to global list
            if(items != null){
                for(item in items){
                    item.id = i++;
                    foundItems.push(item);
                }
            }

            if(completed == toComplete){
                // Search functions now return in an unpredictable order as they are all run in parellel.
                // So we have to sort after all functions have completed by the unit order
                foundItems.sort(function(a, b){
                    var aUnitSortPosition : Int = Reflect.field(a, 'unitSortPosition');
                    var bUnitSortPosition : Int = Reflect.field(b, 'unitSortPosition');

                    var aInternalSortPosition : Int = Reflect.field(a, 'internalSortPosition');
                    var bInternalSortPosition : Int = Reflect.field(b, 'internalSortPosition');


                    if (aUnitSortPosition < bUnitSortPosition) return -1;
                    if (aUnitSortPosition > bUnitSortPosition) return 1;

                    if (aInternalSortPosition > bInternalSortPosition) return 1;
                    if (aInternalSortPosition < bInternalSortPosition) return -1;

                    return 0;
                });

                // We get here when all units have completed and we then update the search options shown to the user
                autocomplete_update(foundItems);

                // Pass control back to ExtJS
                it.next();
            }
        }

        // Test each unit against the user search string to see if it's going to be run so we can set toComplete to the correct value
        for(unit in units){
            var indexof = unit.indexof;
            var minlen = unit.minlen;

            if(!(indexof != null && queryStr.indexOf(indexof) == -1)){
                if(!(minlen != null && queryStr.length < minlen)){
                    toComplete += 1;
                }
            }
        }

        // Run each unit in parallel (take advantage of async nature of NodeJS)

        var unitSortPosition = 0;

        for(unit in units){
            var indexof = unit.indexof;
            var minlen = unit.minlen;
            var func :Dynamic = unit.func;
            var name = unit.name;
            var limit = unit.limit;

            if(!(indexof != null && queryStr.indexOf(indexof) == -1)){
                if(!(minlen != null && queryStr.length < minlen)){
                    // Unit is called here

                    unitSortPosition += 1;

                    func(queryStr, onComplete, limit, unitSortPosition);
                }
            }
        }

    }

    public function autocomplete_models(queryStr, nextSearch, limit : Int) {
        var match = false;

        for(model in getProvider().getModelClasses()){
            var searchMap = model.getSearchMap();
            if(searchMap == null){
                continue;
            }

            for(field in searchMap.keys()){
                var regex = searchMap.get(field);

                if(regex.match(queryStr)){
                    match = true;

                    if(model.stripPrefixes()){
                        queryStr = regex.replace(queryStr, '');
                    }

                    var idField = model.getFirstKey();
                    var icon = model.getIcon();

                    getProvider().getByIdStartsWith(queryStr, field, model.getClass(),limit, function(objs : Array<Dynamic>,exception){
                        if(exception == null){
                            if(objs == null || objs.length == 0){
                                nextSearch(null);
                            }else{
                                var storeList : Array<Dynamic> = new Array<Dynamic>();

                                var objIds = new Array<String>();
                                for(obj in objs){
                                    var id = Reflect.field(obj, field);

                                    objIds.push(id);
                                }

                                objIds.sort(function(a,b)
                                return Reflect.compare(Std.string(a).toLowerCase(),Std.string(b).toLowerCase())
                                );

                                var i = 0 ;
                                for (objId in objIds) {
                                    storeList.push( { icon: icon, title : objId, id : i++, targetId: objId, type : model, field: field} );
                                }

                                nextSearch(storeList);
                            }
                        }else {
                            lookupException(exception);
                        }
                    });
                }
            }
        }

        if(!match){
            nextSearch(null);
        }
    }

    /**
    * autocomplete_fts_models will search queryStr against all configured entity search columns
    **/
    public function autocomplete_fts_models(queryStr : String, nextSearch : Dynamic, limit : Int, unitSortPosition: Int) : Void{
        var match = false;

        var model : Model = null;
        var models = new Array<Model>();
        var ftsMap = new Map<String, SearchDef>();

        var ftsColumns = new Array<String>();

        var next :Dynamic = null;

        var foundItems = new Array<Dynamic>();

        var queryItems :Array<String> = null;

        if(queryStr.indexOf(' ') > -1){
            // We get here for query strings which include spaces and split to get a list of query items
            var reg =~/\s+/g;
            queryItems = reg.split(queryStr);

            if(queryItems.length > 1){
                // Only process as a list request if more than one item is found
                for(model in getProvider().getModelClasses()){
                    var ftsColumn = model.getFirstKey();

                    // We get here when the user wants to retrieve items rather than search for them

                    var cleanedItems = queryItems;

                    if(model.stripPrefixes()){
                        cleanedItems = new Array<String>();

                        for(i in 0...queryItems.length){
                            cleanedItems[i] = model.getIdRegEx().replace(queryItems[i], '');
                        }
                    }

                    // Get items by value
                    getProvider().getByValues(cleanedItems, model.getClass(), ftsColumn, function(objs : Array<Dynamic>,err){
                        if(err == null){
                            if(objs != null){
                                for(obj in objs){
                                    getWorkspace().addObject(obj, true);
                                }
                            }
                        }
                    });
                }

                return;
            }
        }

        // Build up a list of entities to search
        for(model in getProvider().getModelClasses()){
            models.push(model);
        }

        // Number of columns which need to be searched
        var toComplete = 0;

        // Iterate models and FTS columns to work out how many need to be searched (required so we know when searches have been performed
        for(model in models){
            var ftsMap = model.getFTSColumns();

            if(ftsMap != null){
                for(column in ftsMap.keys()){
                    toComplete += 1;
                }
            }
        }

        // Stores the number of searches which have been performed.  When completed == toComplete we are done
        var completed = 0;

        // Complete list of matching entities / entities + actions
        var storeList : Array<Dynamic> = new Array<Dynamic>();

        var internalSortPosition = 0;

        // Iterate models - note that all searches are performed in parellel
        for(model in models){
            ftsMap = model.getFTSColumns();

            if(ftsMap == null){
                // Skip models with no search columns configured
                continue;
            }

            // Iterate configured search columns
            for(ftsColumn in ftsMap.keys()){
                // Get the search column definition
                var searchDef = ftsMap.get(ftsColumn);

                internalSortPosition += 1;

                // REGEX query string must match against to perform search
                var regex = searchDef.regex;

                if(regex != null){
                    // We get here when a REGEX has been set which must match the query string for a search to be run
                    if(!regex.match(queryStr)){
                        // We get here for search strings which don't match the FTS REGEX and so skip it

                        completed +=1;

                        continue;
                    }else{
                        // We get here when the search string matches the given REGEX
                        if(searchDef.replaceWith != null){
                            // We get here when a replaceWith has been set for this column and replace the matching part with replaceWith
                            queryStr = searchDef.regex.replace(queryStr, searchDef.replaceWith);
                        }
                    }
                }

                // Model for icon if there is one
                var icon = model.getIcon();

                // List of actions for model
                var actions : Map<String, ModelAction> = model.getActions('search_bar');

                var _internalSortPosition = internalSortPosition;

                // Handler called when this search is finished
                var handler = function(objs : Array<Dynamic>,exception){
                    // Increment the number of searches completed by one
                    completed += 1;

                    if(exception == null){
                        // We get here when no exceptions have occurred performing the search
                        if(!(objs == null || objs.length == 0)){
                            // Sort entities
                            objs.sort(function(a, b){
                                return Reflect.compare(Reflect.field(a, ftsColumn), Reflect.field(b, ftsColumn));
                            });

                            var i = 0 ;

                            // Get the user visible primary key column name
                            var idField = model.getFirstKey();

                            // Iterate entities
                            for (obj in objs) {
                                // Get the user visible primary key
                                var idValue = Reflect.field(obj, idField);

                                // Allow for attribte retrieval from depth
                                var title = Model.extractField(obj, ftsColumn);

                                // If the search column doesn't match the user visible primary key column append the entity ID to the match
                                if(idField != ftsColumn){
                                    title += ' - ' + idValue;
                                }

                                // If a short description field is present append this to the match
                                if(Reflect.field(obj,'getShortDescription') != null){
                                    title = obj.getShortDescription();
                                }

                                if(actions.exists('DEFAULT')){
                                    // If a default action is present append this to the list of options the user can select from
                                    var action : ModelAction = actions.get('DEFAULT');

                                    storeList.push( { internalSortPosition: _internalSortPosition, unitSortPosition: unitSortPosition, action: action, icon: icon, title : title, id : i++, targetId: idValue, type : model, field: idField, group: model.getAlias()} );
                                }else{
                                    // Add this matching entity to the list which will be shown to the user
                                    storeList.push( { internalSortPosition: _internalSortPosition, unitSortPosition: unitSortPosition, icon: icon, title : title, id : i++, targetId: idValue, type : model, field: idField, group: model.getAlias()} );
                                }

                                // Iterate custom actions (i.e. each action givens you an additional item in the drop-down for the user)
                                for(actionName in actions.keys()){
                                    // Skip the default action as this will already have been dealt with
                                    if(actionName == 'DEFAULT'){
                                        continue;
                                    }

                                    // Get action definition and append to list shown to the user
                                    var action : ModelAction = actions.get(actionName);

                                    var actionIcon = icon;
                                    if(action.icon != null){
                                        actionIcon = action.icon;
                                    }

                                    storeList.push( { internalSortPosition: _internalSortPosition, unitSortPosition: unitSortPosition, action: action, icon: actionIcon, title : title + ' (' + action.userSuffix + ')' , id : i++, targetId: idValue, type : model, field: idField, group: model.getAlias()} );
                                }
                            }
                        }
                    }else{
                        // We get here when an exception has occurred.  At the moment we consume these
                        if(CommonCore.getStringError(exception) == 'You must be logged in to use this provider'){

                        }else{

                        }
                    }

                    // Test if this was the last search waiting to complete
                    if(completed == toComplete){
                        // We get here if this was the last search waiting to complete
                        nextSearch(storeList);
                    }
                };

                // If the search column includes a period then it means we actually want to search an FK'd property
                if(ftsColumn.indexOf('.') > -1){
                    getProvider().queryPath(model.getClass(), ftsColumn, queryStr,'getByValues',function(err, objs){
                        handler(objs, err);
                    });
                }else{
                    // All other search columns end up here

                    if(queryItems == null){
                        // We get here when we need to perform a single search

                        // Strip prefixes if this model requires it
                        if(model.stripPrefixes()){
                            queryStr = model.getIdRegEx().replace(queryStr, '');
                        }

                        // Look for matches by ID starts with
                        getProvider().getByIdStartsWith(queryStr, ftsColumn, model.getClass(), limit,handler);
                    }
                }
            }
        }

    }

    public function autocomplete_retrieveModel(item : Dynamic) : Bool{
        var model = item.type;
        var id = item.targetId;
        var field = item.field;

        if(Std.is(model, Model)){
            var clazz = model.getClass();
            var wrapperClazz = model.getWorkspaceWrapperClass();
            getProvider().getByValue(id, clazz, field, function(obj : Dynamic,exception){
                if(exception == null && obj != null){
                    var append = function(obj){
                        if(obj != null){
                            var wo;
                            if(wrapperClazz != null){
                                wo = Type.createInstance(wrapperClazz, [obj, id]);
                            }else{
                                wo = obj;
                            }

                            getWorkspace().addObject(wo, true);
                        }
                    }

                    if(item.action != null){
                        item.action.run(obj, append);
                    }else{
                        append(obj);
                    }
                }else if(exception != null){
                    lookupException(exception.message);
                }
            });

            return true;
        }else{
            return false;
        }
    }

    private function autocomplete_eln(query : String, nextSearch : Dynamic, limit : Int) {
        getProvider().getByIdStartsWith(query, null, LabPage, limit, function(pages : Array<LabPage>,exception){
            if(exception == null){
                if(pages == null || pages.length == 0){
                    nextSearch(null); return;
                }
                var storeList : Array<Dynamic> = new Array<Dynamic>();

                var i = 0;
                for(page in pages){
                    storeList.push( { title : page.experimentNo, id : i++, targetId: page.experimentNo, type : 'eln' } );
                }

                nextSearch(storeList);
            }else if(exception != null){
                lookupException(exception.message);

                nextSearch(null);
            }
        });
    }

    private function autocomplete_retrievePage(query : String) {
        getProvider().getById(query, LabPage, function(page : LabPage,exception){
            if(exception == null && page != null){
                getProvider().activate([page], 2, function(error){
                    var wo = new ScarabELNWO(page, query);

                    getWorkspace().addObject(wo, true);
                });
            }else if(exception != null){
                lookupException(exception.message);
            }
        });
    }

    private function lookupException(msg){
        WorkspaceApplication.getApplication().showMessage('Lookup exception',msg);
    }

    /**
    * TARGETS
    **/

    private function autocomplete_targets(query : String, nextSearch : Dynamic, limit : Int, unitSortPosition : Int) {
        var modifierStr = '';
        var modifier = '';

        getProvider().getByIdStartsWith(query, null,SgcTarget, limit, function(targets : Array<SgcTarget>,exception){
            if(exception == null){
                var internalSortPosition = 0;

                if(targets == null || targets.length == 0){
                    nextSearch(null);
                    return;
                }
                var storeList : Array<Dynamic> = new Array<Dynamic>();

                var uniqueMap : Map<String,String> = new Map<String,String>();

                for(target in targets){
                    var targetId = target.targetId.substr(0,target.targetId.length-1);
                    uniqueMap.set(targetId,'');
                }

                var baseCount = 0;
                for(key in uniqueMap.keys()){
                    baseCount++;
                }

                var lastBaseName = null;
                var i = 0 ;
                for (target in targets) {
                    var baseName =  target.targetId.substr(0,target.targetId.length-1);

                    var group = 'Targets';

                    if(target.targetId.toUpperCase() == query.toUpperCase() || (baseCount <=2 && (lastBaseName == null || baseName != lastBaseName))){
                        lastBaseName = baseName;

                        group = target.targetId;

                        storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'gridvar_16.png', title : target.targetId + ' (Target Summary)', id : i++, targetId: target.targetId, type : 'Constructs Protein - No Tag Summary', group: group } );

                        internalSortPosition += 1;


                        storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'structure_16.png', title : modifierStr + baseName + ' (All Isoforms - Protein)', id : i++, targetId: target.targetId, type : 'All Isoforms - Protein', modifier: modifier, group: group } );

                        internalSortPosition += 1;

                        storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'dna_16.png', title : modifierStr + baseName + ' (All Isoforms - Nucleotide)', id : i++, targetId: target.targetId, type : 'All Isoforms - Nucleotide', modifier: modifier, group: group } );

                        internalSortPosition += 1;
                    }



                    storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'structure_16.png', title : modifierStr + target.targetId + ' (Protein)', id : i++, targetId: target.targetId, type : 'Protein', modifier: modifier, group: group } );

                    internalSortPosition += 1;

                    storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'dna_16.png', title : modifierStr + target.targetId + ' (DNA)', id : i++, targetId: target.targetId, type : 'Nucleotide', modifier: modifier, group: group } );

                    internalSortPosition += 1;

                    if(target.targetId.toUpperCase() == query.toUpperCase() || (targets.length <= 3)){
                        group = target.targetId;

                        storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'dna_16.png', title : modifierStr + target.targetId + ' (Entry Clones DNA)', id : i++, targetId: target.targetId, type : 'Entry Clones DNA', modifier: modifier, group: group } );

                        internalSortPosition += 1;

                        storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'structure_16.png', title : modifierStr + target.targetId + ' (Entry Clones - Translation)', id : i++, targetId: target.targetId, type : 'Entry Clones Translation', modifier: modifier, group: group } );

                        internalSortPosition += 1;

                        storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'structure_16.png', title : modifierStr + target.targetId + ' (Alleles Protein)', id : i++, targetId: target.targetId, type : 'Alleles Protein', modifier: modifier, group: group } );

                        internalSortPosition += 1;

                        storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'dna_16.png', title : modifierStr + target.targetId + ' (Alleles DNA)', id : i++, targetId: target.targetId, type : 'Alleles DNA', modifier: modifier, group: group } );

                        internalSortPosition += 1;

                        storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'structure_16.png', title : modifierStr + target.targetId + ' (Constructs Protein)', id : i++, targetId: target.targetId, type : 'Constructs Protein', modifier: modifier, group: group } );

                        internalSortPosition += 1;

                        storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'structure_16.png', title : modifierStr + target.targetId + ' (Constructs Protein - No Tag)', id : i++, targetId: target.targetId, type : 'Constructs Protein - No Tag', modifier: modifier, group: group } );

                        internalSortPosition += 1;

                        storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'dna_16.png', title : modifierStr + target.targetId + ' (Constructs DNA)', id : i++, targetId: target.targetId, type : 'Constructs DNA', modifier: modifier, group: group } );

                        internalSortPosition += 1;

                        storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'aln_16.png', title : 'Align ' + target.targetId + ' (Constructs DNA)', id : i++, targetId: target.targetId, type : 'Constructs DNA Align' , group: group} );

                        internalSortPosition += 1;

                        storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'aln_16.png', title : 'Align ' + target.targetId + ' (Constructs Protein)', id : i++, targetId: target.targetId, type : 'Constructs Protein Align', group: group } );

                        internalSortPosition += 1;

                        storeList.push( { unitSortPosition: unitSortPosition, internalSortPosition : internalSortPosition, icon: 'aln_16.png', title : 'Align ' + target.targetId + ' (Constructs Protein - No Tag)', id : i++, targetId: target.targetId, type : 'Constructs Protein - No Tag Align' , group: group});

                        internalSortPosition += 1;

                    }
                }

                nextSearch(storeList);
            }else if(exception != null){
                lookupException(exception.message);
            }
        });
    }

    private function autocomplete_retrieveTargetSequence(targetId : String, seqType : String, item : Dynamic) {
        if(seqType == 'All Isoforms - Protein' || seqType == 'All Isoforms - Nucleotide'){
            var type = 'Protein';
            var label = 'Protein';

            if(seqType == 'All Isoforms - Nucleotide'){
                label = 'DNA';
                type = 'Nucleotide';
            }

            getProvider().getById(targetId, SgcTarget,function(obj:SgcTarget, ex){
                if(ex != null){
                    lookupException(ex.message);return;
                }

                getProvider().getByValues([obj.geneId], SgcTarget,'geneId', function(objs :Array<SgcTarget>, ex){
                    if(ex != null){
                        lookupException(ex.message);return;
                    }

                    if(objs.length == 0){
                        lookupException('No isoforms found');
                    }
                    var autoOpen = true;
                    getWorkspace().beginUpdate();
                    for(obj in objs){
                        if(type == 'Protein'){
                            getWorkspace().addObject(obj, false);

                            obj.proteinSequenceObj.setName(obj.targetId + ' (Translation)');

                            getWorkspace().addObject(obj.proteinSequenceObj, true);
                        }else if(type == 'Nucleotide'){
                            getWorkspace().addObject(obj, true);
                        }

                        autoOpen = false;
                    }

                    getWorkspace().reloadWorkspace();
                });
            });
        }else if(seqType == 'Protein' || seqType == 'Nucleotide'){
            getProvider().getById(targetId, SgcTarget,function(obj:SgcTarget, ex){
                if(ex != null){
                    lookupException(ex.message);return;
                }

                if(seqType == 'Protein'){
                    getWorkspace().addObject(obj, false);

                    obj.proteinSequenceObj.setName(obj.targetId + ' (Translation)');

                    getWorkspace().addObject(obj.proteinSequenceObj, true);
                }else if(seqType == 'Nucleotide'){
                    getWorkspace().addObject(obj, true);
                }
            });
        }else if(seqType == 'Entry Clones DNA'){
            getProvider().getByNamedQuery('TARGET_TO_ENTRY_CLONES',[targetId], SgcEntryClone, false, function(clones: Array<SgcEntryClone>,exception){
                if(exception == null && clones != null && clones.length != 0){
                    var autoOpen = true;

                    var folderName = targetId + ' (Entry Clone DNA)';

                    var folder = getWorkspace()._addFolder(folderName);

                    getWorkspace().beginUpdate();

                    var added = 0;
                    for(clone in clones){
                        if(clone.dnaSeq != null){
                            getWorkspace()._addObject(clone, autoOpen, false, folder);

                            autoOpen = false;

                            added++;
                        }
                    }

                    if(added > 0){
                        getWorkspace().reloadWorkspace();
                    }else{
                        showMessage('No data','No alleles with a Protein sequence');
                    }
                }else if(exception != null){
                    lookupException(exception.message);
                }else if(clones == null || clones.length == 0){
                    showMessage('No entries','No entries in database');
                }
            });
        }else if(seqType == 'Entry Clones Translation'){
            getProvider().getByNamedQuery('TARGET_TO_ENTRY_CLONES',[targetId], SgcEntryClone, false, function(clones: Array<SgcEntryClone>,exception){
                if(exception == null && clones != null && clones.length != 0){
                    var autoOpen = true;

                    var folderName = targetId + ' (Entry Clone Translation)';

                    var folder = getWorkspace()._addFolder(folderName);

                    getWorkspace().beginUpdate();

                    var added = 0;
                    for(clone in clones){
                        if(clone.dnaSeq != null){
                            try{
                                var tx = clone.getTranslation(GeneticCodes.STANDARD, 0, false);
                                var prot = new Protein(tx);
                                prot.setName(clone.entryCloneId + ' (Protein)');

                                //var protWO = new ProteinWorkspaceObject(prot, clone.entryCloneId + ' (Protein)');

                                getWorkspace()._addObject(prot, autoOpen, false, folder);

                                autoOpen = false;

                                added++;
                            }catch(ex : HaxeException){
//do nothing
                            }
                        }
                    }

                    if(added > 0){
                        getWorkspace().reloadWorkspace();
                    }else{
                        showMessage('No data','No alleles with a Protein sequence');
                    }
                }else if(exception != null){
                    lookupException(exception.message);
                }else if(clones == null || clones.length == 0){
                    showMessage('No entries','No entries in database');
                }
            });
        }else if(seqType == 'Alleles Protein'){
            getProvider().getByNamedQuery('TARGET_TO_ALLELES',[targetId], SgcAllele, false, function(alleles: Array<SgcAllele>,exception){
                if(exception == null && alleles != null && alleles.length != 0){
                    var autoOpen = true;

                    var folderName = targetId + ' (Allele Protein)';

                    var folder = getWorkspace()._addFolder(folderName);

                    getWorkspace().beginUpdate();

                    var added = 0;
                    for(allele in alleles){
                        if(allele.proteinSeq != null){

                            allele.proteinSequenceObj.setName(allele.getName() + ' (Protein)');

                            getWorkspace()._addObject(allele.proteinSequenceObj, autoOpen, false, folder);
                            autoOpen = false;

                            added++;
                        }
                    }

                    if(added > 0){
                        getWorkspace().reloadWorkspace();
                    }else{
                        showMessage('No data','No alleles with a Protein sequence');
                    }
                }else if(exception != null){
                    lookupException(exception.message);
                }else if(alleles == null || alleles.length == 0){
                    showMessage('No entries','No entries in database');
                }
            });
        }else if(seqType == 'Alleles DNA'){
            getProvider().getByNamedQuery('TARGET_TO_ALLELES',[targetId], SgcAllele, false,function(alleles: Array<SgcAllele>,exception){
                if(exception == null && alleles != null && alleles.length != 0){
                    var autoOpen = true;

                    var folderName = targetId + ' (Allele DNA)';

                    var folder = getWorkspace()._addFolder(folderName);

                    getWorkspace().beginUpdate();

                    var added = 0;

                    for(allele in alleles){
                        if(allele.dnaSeq != null){
                            getWorkspace()._addObject(allele, autoOpen, false, folder);

                            added++;

                            autoOpen = false;
                        }
                    }

                    if(added > 0){
                        getWorkspace().reloadWorkspace();
                    }else{
                        showMessage('No data','No alleles with a DNA sequence');
                    }
                }else if(exception != null){
                    lookupException(exception.message);
                }else if(alleles == null || alleles.length == 0){
                    showMessage('No entries','No entries in database');
                }
            });
        }else if(seqType == 'Constructs Protein'){
            getProvider().getByNamedQuery('TARGET_TO_CONSTRUCTS',[targetId], SgcConstruct, false, function(constructs: Array<SgcConstruct>,exception){
                if(exception == null && constructs != null && constructs.length != 0){
                    var autoOpen = true;

                    var folderName = targetId + ' (Constructs Protein)';

                    var folder = getWorkspace()._addFolder(folderName);

                    getWorkspace().beginUpdate();

                    var added = 0;
                    for(construct in constructs){
                        if(construct.proteinSeq != null){
                            var protein = construct.proteinSequenceObj;
                            protein.setName(construct.constructId + ' - Protein');

                            getWorkspace()._addObject(protein, autoOpen, false, folder);
                            autoOpen = false;

                            added++;
                        }
                    }

                    if(added > 0){
                        getWorkspace().reloadWorkspace();
                    }else{
                        showMessage('No data','No constructs with a protein sequence');
                    }
                }else if(exception != null){
                    lookupException(exception.message);
                }else if(constructs == null || constructs.length == 0){
                    showMessage('No entries','No entries in database');
                }
            });
        }else if(seqType == 'Constructs DNA'){
            getProvider().getByNamedQuery('TARGET_TO_CONSTRUCTS',[targetId], SgcConstruct, false, function(constructs: Array<SgcConstruct>,exception){
                if(exception == null && constructs != null && constructs.length != 0){
                    var autoOpen = true;

                    var folderName = targetId + ' (Constructs DNA)';

                    var folder = getWorkspace()._addFolder(folderName);

                    getWorkspace().beginUpdate();

                    var added = 0;

                    for(construct in constructs){
                        if(construct.proteinSeq != null){
                            getWorkspace()._addObject(construct, autoOpen, false, folder);
                            autoOpen = false;

                            added++;
                        }
                    }

                    if(added > 0){
                        getWorkspace().reloadWorkspace();
                    }else{
                        showMessage('No data','No constructs with a DNA sequence');
                    }
                }else if(exception != null){
                    lookupException(exception.message);
                }else if(constructs == null || constructs.length == 0){
                    showMessage('No entries','No entries in database');
                }
            });
        }else if(seqType == 'Constructs Protein - No Tag'){
            getProvider().getByNamedQuery('TARGET_TO_CONSTRUCTS',[targetId], SgcConstruct, false, function(constructs: Array<SgcConstruct>,exception){
                if(exception == null && constructs != null && constructs.length != 0){
                    var autoOpen = true;

                    var folderName = targetId + ' (Constructs Protein - No tag)';

                    var folder = getWorkspace()._addFolder(folderName);

                    getWorkspace().beginUpdate();

                    var added = 0;
                    for(construct in constructs){
                        if(construct.proteinSeq != null){
                            var protein = construct.proteinSequenceNoTagObj;
                            protein.setName(construct.constructId + ' - Protein No Tag');
                            getWorkspace()._addObject(protein, autoOpen, false, folder);
                            autoOpen = false;

                            added++;
                        }
                    }

                    if(added > 0){
                        getWorkspace().reloadWorkspace();
                    }else{
                        showMessage('No data','No constructs with a DNA sequence');
                    }
                }else if(exception != null){
                    lookupException(exception.message);
                }else if(constructs == null || constructs.length == 0){
                    showMessage('No entries','No entries in database');
                }
            });
        }else if(seqType == 'Constructs DNA Align'){
            getProvider().getByNamedQuery('TARGET_TO_CONSTRUCTS',[targetId], SgcConstruct, false, function(constructs: Array<SgcConstruct>,exception){
                if(exception == null && constructs != null){

                    var objs = new Array<String>();

                    var folderName = targetId + ' (Constructs DNA)';

                    var folder = getWorkspace()._addFolder(folderName);

                    getWorkspace().beginUpdate();

                    for(construct in constructs){
                        if(construct.proteinSeq != null){
                            getWorkspace()._addObject(construct, false, false, folder);

                            objs.push(untyped (construct.getUUID()));
                        }
                    }

                    var alignObj = new Alignment();
                    alignObj.setAlignmentObjectIds(objs);

                    var wo = new AlignmentWorkspaceObject(alignObj, targetId + ' Construct DNA Alignment');

                    for(obj in objs){
                        wo.addReference('Sequences', obj);
                    }

                    getWorkspace()._addObject(wo, true, false);

                    getWorkspace().reloadWorkspace();
                }else if(exception != null){
                    lookupException(exception.message);
                }
            });
        }else if(seqType == 'Constructs Protein Align'){
            getProvider().getByNamedQuery('TARGET_TO_CONSTRUCTS',[targetId], SgcConstruct, false, function(constructs: Array<SgcConstruct>,exception){
                if(exception == null && constructs != null){
                    var objs = new Array<String>();

                    var folderName = targetId + ' (Constructs Protein)';

                    var folder = getWorkspace()._addFolder(folderName);

                    getWorkspace().beginUpdate();

                    for(construct in constructs){
                        if(construct.proteinSeq != null){
                            var protObj :Dynamic = construct.proteinSequenceObj;
                            protObj.setName(construct.constructId+ ' (Protein)');

                            getWorkspace()._addObject(protObj, false, false, folder);

                            objs.push(protObj.getUUID());
                        }
                    }

                    var alignObj = new Alignment();

                    var wo = new AlignmentWorkspaceObject(alignObj, targetId + ' Construct Protein Alignment');

                    for(obj in objs){
                        wo.addReference('Sequences', obj);
                    }

                    getWorkspace()._addObject(wo, true, false);

                    getWorkspace().reloadWorkspace();
                }else if(exception != null){
                    lookupException(exception.message);
                }
            });
        }else if(seqType == 'Constructs Protein - No Tag Align'){
            getProvider().getByNamedQuery('TARGET_TO_CONSTRUCTS',[targetId], SgcConstruct, false, function(constructs: Array<SgcConstruct>,exception){
                if(exception == null && constructs != null){
                    var objs = new Array<String>();

                    var folderName = targetId + ' (Constructs Protein - No Tag)';

                    var folder = getWorkspace()._addFolder(folderName);

                    getWorkspace().beginUpdate();

                    for(construct in constructs){
                        if(construct.proteinSeq != null){
                            var protObj :Dynamic = construct.proteinSequenceNoTagObj;
                            protObj.setName(construct.constructId+ ' (Protein - No Tag)');

                            getWorkspace()._addObject(protObj, false, false, folder);

                            objs.push(protObj.getUUID());
                        }
                    }

                    var alignObj = new Alignment();
                    alignObj.setAlignmentObjectIds(objs);

                    var wo = new AlignmentWorkspaceObject(alignObj, targetId + ' Construct Protein - No Tag Alignment');

                    for(obj in objs){
                        wo.addReference('Sequences', obj);
                    }

                    getWorkspace()._addObject(wo, true, false);

                    getWorkspace().reloadWorkspace();
                }else if(exception != null){
                    lookupException(exception.message);
                }
            });
        }else if(seqType == 'Constructs Protein - No Tag Summary'){
            var targetSummary = new TargetSummary(targetId);

            targetSummary.generateSummary();
        }else if(seqType == 'WONKA'){
            var session = new WONKASession();

            session.src = '/WONKA/'+targetId+'/Summarise/';

            var wo = new WONKAWO(session, targetId + ' (WONKA)');

            getWorkspace()._addObject(wo, true, false);

            getWorkspace().reloadWorkspace();
        }else if(seqType == 'Assay Summary'){
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery('target_assay_search', [targetId], null, false, function(json, error){
                var dwin : Dynamic = js.Browser.window;
                dwin.results = json;
                dwin.error = error;

                if(error == null){
                    var table :Dynamic = new Table();
                    table.setFixedRowHeight(50);

                    table.setData(json, {'SDF':{'renderer': function(value){
                        return '<div>' + Compound.getMolImage(value, 'SDF') + '</div>';

                    }}});

                    table.name = targetId + ' (Assay Results)';

                    WorkspaceApplication.getApplication().getWorkspace().addObject(table, true);
                }
            });
        }
    }

    override public function showELN(){
        var wo : WorkspaceObject<Dynamic>= getActiveProgram().getActiveObject(WorkspaceObject);
        if(wo != null){
            ICMClient.getClient().callFunction('sys.showELN', [wo.getDocId()], function(data : Dynamic){}, function(exception:Dynamic){});
        }
    }

    public function retrieve_pdb(query : String){
        var pdb_id = query.substr(4,4);

        var obj = new StructureModel();
        obj.modelId = pdb_id;

        var wo = new StructureModelWO(obj, pdb_id);

        getWorkspace()._addObject(wo, true, true);
    }

    public function getAlignment(fasta, cb : String->MSA->Void){
        BioinformaticsServicesClient.getClient().sendClustalReportRequest(fasta, function(response, err){
            if(err == null){
                var clustalReport = response.json.clustalReport;

                var location : js.html.Location = js.Browser.window.location;

                var url = location.protocol+'//'+location.hostname+':'+location.port+'/'+clustalReport;

                CommonCore.getContent(url, function(content){
                    var msa = ClustalOmegaParser.read(content);

                    cb(null, msa);
                }, function(err){
                    cb(err, null);
                });
            }else{
                cb(err, null);
            }
        });
    }

    public function clearCompoundImageCache(){
        Compound.clearMolCache();
    }

    public static function getSaturn() : SaturnClient{
        return cast(WorkspaceApplication.getApplication(), SaturnClient);
    }


    public static function addProteinsFromNCBIGene(geneIds : Array<String>, editor : ProteinSequenceEditor = null){
        for(geneId in geneIds){
            EUtils.getProteinsForGene(Std.parseInt(geneId), function(err, objs : Array<Protein>){
                if(err == null){
                    if(editor != null){
                        var obj = objs.pop();
                        editor.setSequence(obj.getSequence());
                        editor.getEntity().setDNA(obj.getDNA());

                        editor.getWorkspace().renameWorkspaceObject(editor.getActiveObjectId(), obj.getMoleculeName());

                        editor = null; // if we are fetching for multiple genes
                    }

                    for(obj in objs){
                        WorkspaceApplication.getApplication().getWorkspace().addObject(obj, false);
                    }

                }else{
                    WorkspaceApplication.getApplication().showMessage('Fetch failure', 'Unable to fetch proteins from NCBI ' + err);
                }
            });
        }

    }

    public static function addProteinsFromUniProtKB(accessions : Array<String>, editor : ProteinSequenceEditor = null){
        for(accession in accessions){
            var url = 'http://www.uniprot.org/uniprot/' + accession + '.fasta';
            CommonCore.getContent(url, function(content : String){
                var entities : Array<FastaEntity> = FastaEntity.parseFasta(content);

                    if(editor != null){
                        var entity = entities.pop();
                        editor.setSequence(entity.getSequence());
                        editor.getEntity().setDNA(null);

                        editor.getWorkspace().renameWorkspaceObject(editor.getActiveObjectId(), entity.getName());

                        editor = null; // if we are fetching for multiple genes
                    }

                    for(entity in entities){
                        var prot = new Protein(entity.getSequence());
                        prot.setMoleculeName(entity.getName());
                        WorkspaceApplication.getApplication().getWorkspace().addObject(prot, false);
                    }
            });
        }

    }
}
