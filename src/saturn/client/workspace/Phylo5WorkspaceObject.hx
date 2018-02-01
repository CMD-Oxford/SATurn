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
import saturn.core.domain.Alignment;

class Phylo5WorkspaceObject extends WorkspaceObjectBase<Alignment>{
    public static var FILE_IMPORT_FORMATS : Array<String> = [];

    public var newickStr = null;

    public function new(object : Dynamic, name : String){
        if(object == null){
            object = new Alignment();
        }
        
        if(name == null){
            name="Phylogenetic tree";
        }

        iconPath = '/static/js/images/tree_16.png';

        super(object, name);
    }

    public static function getNewMenuText() : String {
        return "Phylogenetic tree";
    }

    public static function getDefaultFolderName() : String{
        return "Trees";
    }
	
	/*override
	public function serialise() : Dynamic {
		var serialisedObject : Dynamic = super.serialise();
		
		serialisedObject.DATA={ 'OBJECT_IDS': object.getAlignmentObjectIds().join(','), 'ALN_URL' : this.getObject().getAlignmentURL() };
		
		return serialisedObject;
	}

	override
	public function deserialise(object : Dynamic) : Void{
		super.deserialise(object);
		
        var alnObject : Alignment = new Alignment();

        var alnObjectIdsStr : String = object.DATA.OBJECT_IDS;

        if(alnObjectIdsStr != null){
            var ids : Array<String> = alnObjectIdsStr.split(',');
            alnObject.setAlignmentObjectIds(ids);
        }

        alnObject.setAlignmentURL(object.DATA.ALN_URL);

	    setObject(alnObject);
	}*/
}
