/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.client.ProgramRegistry;
import js.Lib;
import saturn.core.DNA;
import saturn.core.DoubleDigest;
import saturn.client.workspace.DNAWorkspaceObject;
import saturn.client.workspace.LigationWO;
import saturn.core.Ligation;
import saturn.client.workspace.DigestWO;
import saturn.util.StringUtils;
import saturn.util.HaxeException;

import saturn.client.workspace.Workspace;
import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.client.WorkspaceApplication;

import saturn.client.Program;

import bindings.Ext;

class LigationViewer extends DNASequenceEditor {	
	static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ LigationWO ];
	
    public function new(){
        super();
    } 
	
	override public function emptyInit() {
		super.emptyInit();
		
		getWorkspace().addListener(this);
	}
    
    override public function onFocus(){
        super.onFocus();	
    }
	
	override public function workspaceObjectUpdated() {
		try {
			var wo : LigationWO<Ligation>  = getActiveObject(LigationWO);
			
			wo.updateLigation();
			
			var sequence : String = wo.getLigation().getSequence();
			
			if (sequence != null && sequence.length != 0) {	
				blockChanged(null, null, 0, null, sequence);	
			}
		}catch ( ex : HaxeException ) {
			js.Browser.alert(ex.getMessage());
		}
	}

    override public function serialise() : Dynamic {
        var object : Dynamic = super.serialise();

        return object;
	}
	
    override public function deserialise(object : Dynamic) : Void {
        super.deserialise(object);
	}
	
	override function installOutlineTree() {
        super.installOutlineTree();
		
		var wo : LigationWO<Ligation> = getActiveObject(LigationWO);
		
		var acceptor : DigestWO<DoubleDigest> = null;
		var donor : DigestWO<DoubleDigest> = null;
		
		if (wo != null) {
			if (wo.hasAcceptor()) {
				acceptor = wo.getAcceptor();
			}
			
			if (wo.hasDonor()) {
				donor = wo.getDonor();
			}
		}
		
		addWorkspaceDropFolder('Donor', donor, DigestWO, false);
		addWorkspaceDropFolder('Acceptor', acceptor, DigestWO, false);
	}
}
