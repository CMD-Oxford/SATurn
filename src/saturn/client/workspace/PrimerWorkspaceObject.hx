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
import saturn.core.Primer;
import saturn.core.PrimerRegistry;
import saturn.app.SaturnClient;

class PrimerWorkspaceObject<T:Primer> extends DNAWorkspaceObject<T> {
	public static var FILE_IMPORT_FORMATS : Array<String> = [];
	
    public function new(object : Dynamic, name : String){
        if(object == null){
            object = new Primer("");
        }
        
        if(name == null){
            name="Primer Sequence";
        }
         
        super(object, name);
    }
    
    public static function getNewMenuText() : String {
        return "Primer";
    }

	/*override
	public function deserialise(object : Dynamic) : Void{
		super.deserialise(object);
		
		var primerObj :Primer = new Primer(object.DATA.SEQ);
		
		primerObj.set5PrimeExtensionLength(object.DATA.PRIME5LEN);
		
	    setObject(primerObj);
	}
	
	override public function serialise() :Dynamic {
		var serialisedObject : Dynamic = super.serialise();
		
		serialisedObject.DATA.PRIME5LEN= getPrimer().get5PrimeExtensionLength();
		
		return serialisedObject;
	}*/
	
	public function getPrimer() :Primer {
		return cast(getDNAObject(),Primer);
	}
}
