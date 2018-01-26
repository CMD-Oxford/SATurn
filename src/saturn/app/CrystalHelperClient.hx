/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.app;

import saturn.client.WorkspaceApplication;
import saturn.client.EXTApplication;
import saturn.client.programs.CrystalHelper;

import saturn.client.workspace.CrystalHelperDataWO;
import saturn.client.ICMClient;
import saturn.client.BuildingBlock;

import bindings.Ext;
import js.Lib;

class CrystalHelperClient extends EXTApplication { 
    public static function main() {
		ICMClient.setup(false, false);
		
	    var client : CrystalHelperClient = new CrystalHelperClient('CrystalHelper','Workspace', 'Information', 'Outline', 'Editor', 'Search', true);
	    
	    WorkspaceApplication.setApplication(client);
    }
    
    override public function initApplication(){
        super.initApplication();
		
		WorkspaceApplication.getApplication().getWorkspace().addObject(new CrystalHelperDataWO(null, 'Crystal Helper'), true);
    }
    
    override public function registerPrograms(){
        super.registerPrograms();
		
		this.getProgramRegistry().registerProgram(CrystalHelper, true);
    }
}
