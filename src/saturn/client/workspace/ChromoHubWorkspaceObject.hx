/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Copyright (C) 2015  Structural Genomics Consortium
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package saturn.client.workspace;

import saturn.core.domain.Alignment;
import saturn.client.workspace.Workspace;

class ChromoHubWorkspaceObject extends WorkspaceObjectBase<Alignment>{
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
