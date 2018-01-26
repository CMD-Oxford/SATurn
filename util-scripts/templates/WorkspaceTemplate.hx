package saturn.client.workspace;

import saturn.core.<OBJECT_TEMPLATE>;
import saturn.client.workspace.Workspace;

class <WORKSPACE_TEMPLATE> extends WorkspaceObjectBase<<OBJECT_TEMPLATE>>{
    public static var FILE_IMPORT_FORMATS : Array<String> = [];

    public function new(object : Dynamic, name : String){
        if(object == null){
            object = new <OBJECT_TEMPLATE>();
        }

        if(name == null){
            name="<OBJECT_TEMPLATE>";
        }

        super(object, name);
    }

    public static function getNewMenuText() : String {
        return "<OBJECT_TEMPLATE>";
    }

    public static function getDefaultFolderName() : String{
        return "<OBJECT_TEMPLATE>";
    }
}
