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
import saturn.client.workspace.Workspace.WorkspaceObjectBase;
import saturn.core.Protein;
import saturn.app.SaturnClient;

class ProteinWorkspaceObject extends WorkspaceObjectBase<Protein> {
	public static var FILE_IMPORT_FORMATS : Array<String> = ['fasta'];
	
    public function new(object : Dynamic, name : String){
        if(object == null){
            object = new Protein("");
        }
        
        if(name == null){
            name="Protein Sequence";
        }

        iconPath = '/static/js/images/structure_16.png';
         
        super(object, name);
    }
    
    public static function getNewMenuText() : String {
        return "Protein Sequence";
    }

    public static function getDefaultFolderName() : String{
        return "Protein";
    }

    override public function setName(name : String){
        super.setName(name);

        if(object != null){
            object.setMoleculeName(name);
        }
    }

    override public function setObject(obj : Dynamic){
        super.setObject(obj);

        obj.setMoleculeName(name);
    }

	/*override
	public function serialise() : Dynamic {
		var serialisedObject : Dynamic = super.serialise();
		
		serialisedObject.DATA={ 'SEQ': object.getSequence() };
		
		return serialisedObject;
	}

	override
	public function deserialise(object : Dynamic) : Void{
		super.deserialise(object);
		
		var obj : Protein = new Protein(object.DATA.SEQ);
		
	    setObject(obj);
	}*/
}
