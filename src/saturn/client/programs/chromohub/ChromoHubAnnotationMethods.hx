package saturn.client.programs.chromohub;
/**
 * Authors Dr David R. Damerell (david.damerell@sgc.ox.ac.uk) (University of Oxford)
 *         Sefa Garsot (sefa.garsot@sgc.ox.ac.uk) (University of Oxford)
 *         Xi Ting (Seacy) Zhen (University of Toronto) (original PHP version)
 *         
 * Group Leaders: 
 *         Dr Brian Marsden (brian.marsden@sgc.ox.ac.uk) (University of Oxford)
 *         Dr Matthieu Schapira (matthieu.schapira@utoronto.ca) (University of Toronto)
 *         
 */

import Date;
import haxe.ds.ArraySort;
import saturn.client.programs.phylo.PhyloAnnotation.HasAnnotationType;

import saturn.core.Util;
import saturn.client.programs.phylo.PhyloAnnotation;
import bindings.Ext;

import saturn.client.core.CommonCore;

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

class ChromoHubAnnotationMethods {
    public function new(){

    }

    public function getCurrentView():Dynamic{
        var prog = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);

        return prog.currentView;
    }

    static public function getFamilyTree():String{
        var prog = cast(WorkspaceApplication.getApplication().getActiveProgram(), ChromoHubViewer);

        return prog.treeName;
    }
}

