/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.workspace;

import saturn.core.domain.SgcConstructPlate;
import saturn.client.WorkspaceApplication;
import saturn.client.programs.TableHelper;
import saturn.client.workspace.Workspace;
import saturn.client.workspace.Workspace.WorkspaceObjectBase;
import saturn.core.MultiConstructHelperData;

class MultiConstructHelperWO extends WorkspaceObjectBase<MultiConstructHelperData> {
	public static var FILE_IMPORT_FORMATS : Array<String> = [];



	
    public function new(object : Dynamic, name : String){
        if(object == null){
            object = new MultiConstructHelperData();
        }else if(Std.is(object, saturn.core.domain.SgcConstructPlate)){
            var constructPlate : SgcConstructPlate = object;
            object = new MultiConstructHelperData();
            object.setPlateName(constructPlate.plateName);
        }
        
        if(name == null){
            name="Construct Helper";
        }

        iconPath = '/static/js/images/dna_conical_16.png';
         
        super(object, name);
    }
    
    public static function getNewMenuText() : String {
        return "Construct Helper";
    }

    public static function getDefaultFolderName() : String{
        return "Construct Plates";
    }

    override public function serialise() : Dynamic {
        var app = WorkspaceApplication.getApplication();
        var prog : TableHelper = cast(app.getWorkspace().getOpenProgram(getUUID()), TableHelper);

        var models = prog.getModels();

        var dataModels = new Array<Dynamic>();

        for(model in models){
            dataModels.push(model.data);
        }

        object.setRawModels(dataModels);

        return super.serialise();
    }
	
	/*override
	public function serialise() : Dynamic {
		var serialisedObject : Dynamic = super.serialise();
		
		serialisedObject.DATA={ 'DATA': object.getData() };
		
		return serialisedObject;
	}

	override
	public function deserialise(object : Dynamic) : Void{
		super.deserialise(object);
		
		var obj : MultiConstructHelperData = new MultiConstructHelperData();
		
		obj.setData(object.DATA.DATA);
		
	    setObject(obj);
	}*/

    override public function clone() : MultiConstructHelperWO {
        var app = WorkspaceApplication.getApplication();
        var prog : TableHelper = cast(app.getWorkspace().getOpenProgram(getUUID()), TableHelper);

        var models = prog.getModels();

        var data = new MultiConstructHelperData();
        data.setModelsToCopy(models);

        var newwo = new MultiConstructHelperWO(data, getName());

        return newwo;
    }
}
