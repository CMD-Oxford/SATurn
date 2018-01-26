/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.workspace;

import saturn.client.workspace.Workspace;
import saturn.core.DNA;
import saturn.core.RestrictionSite;
import saturn.app.SaturnClient;

class DNAWorkspaceObject<T:DNA> extends WorkspaceObjectBase<T> {
	public static var FILE_IMPORT_FORMATS : Array<String> = ['fasta']; //'ab1'
	
    public function new(object : Dynamic, name : String){
        if(object == null){
            object = new DNA("");
        }
        
        if(name == null){
            name="DNA Sequence";
        }

        iconPath = '/static/js/images/dna_16.png';

        super(object, name);
    }
	
	override public function clone() : DNAWorkspaceObject<T> {
		if (Std.is(object, RestrictionSite)) {
			return new DNAWorkspaceObject(new RestrictionSite(object.getSequence()), getName() + ' (duplicate)');
		}else {
			return new DNAWorkspaceObject(new DNA(object.getSequence()), getName() + ' (duplicate)');
		}
	}
	
	public function getDNAObject() : DNA {
		return cast(object, DNA);
	}
    
	public function setDNAObject(dnaObject : DNA) : Void {
		object = dnaObject;
	}
	
    public static function getNewMenuText() : String {
        return "DNA Sequence";
    }

    public static function getDefaultFolderName() : String{
        return "DNA";
    }
	
	/*override
	public function serialise() : Dynamic {
		var serialisedObject : Dynamic = super.serialise();
		
		if (Std.is(object, RestrictionSite)) {
			serialisedObject.DATA = { 'SEQ': cast(getDNAObject(), RestrictionSite).getStarSequence() };
			serialisedObject.DATA.TYPE = 'R';
		}else {
			serialisedObject.DATA = { 'SEQ': getDNAObject().getSequence() };
			serialisedObject.DATA.TYPE = 'D';
		}
		
		return serialisedObject;
	}

	override
	public function deserialise(object : Dynamic) : Void{
		super.deserialise(object);
		
		var dnaObj :DNA;
		
		if (object.DATA.TYPE == 'R') {
			dnaObj = new RestrictionSite(object.DATA.SEQ);
		}else{
			dnaObj = new DNA(object.DATA.SEQ);
		}
		
	    setObject(dnaObj);
	}*/
}
