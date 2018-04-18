/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client;

import saturn.db.Provider;
import haxe.ds.ObjectMap;
import saturn.util.HaxeException;
import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.client.workspace.Workspace;

import js.Lib;

class ProgramRegistry {
    var programList : Array<Class<Program>>;
    var clazzNameToPrograms : ObjectMap<Dynamic, List<Class<Program>>>;
    var clazzNameToDefaultProgram : ObjectMap<Dynamic, Dynamic>;
	
	var fileExtensionToDefaultProgram : Map < String, Class<Program> > ;
	
	var programToPlugins : ObjectMap<Dynamic, List<Class<ProgramPlugin<Dynamic>>>>;
    
    public function new(){
        programList = new Array<Class<Program>>();
        
        clazzNameToDefaultProgram = new ObjectMap<Dynamic,Dynamic>();
        clazzNameToPrograms = new ObjectMap<Dynamic, List<Class<Program>>>();
		
		fileExtensionToDefaultProgram = new Map < String, Class<Program> > ();
		
		programToPlugins = new ObjectMap<Dynamic, List<Class<ProgramPlugin<Dynamic>>>>();
    }
	
	public function registerPlugin(progClazz : Class<Program>, pluginClazz : Class<ProgramPlugin<Dynamic>>) {
		if (! programToPlugins.exists(progClazz)) {
			programToPlugins.set(progClazz, new List<Class<ProgramPlugin<Dynamic>>>());
		}
		
		programToPlugins.get(progClazz).push(pluginClazz);

        if(Reflect.hasField(pluginClazz, 'loadResources')){
            Reflect.callMethod(pluginClazz, Reflect.field(pluginClazz, 'loadResources'), []);
        }
	}
	
	public function installPlugins(program : Program) {
        if(!program.arePluginsInstalled()){
            var progClazz = Type.getClass(program);

            if(programToPlugins.exists(progClazz)){
                for (pluginClazz in programToPlugins.get(progClazz)) {
                    var plugin = Type.createInstance(pluginClazz, []);

                    program.addPlugin(plugin);
                }
            }

            program.setPluginsInstalled();
        }
	}
    
    public function getRegisteredWorkspaceObjectShortNames() : Map<String, String>{
        var shortNames : Map<String, String> = new Map<String, String>();
        
        for (clazz in clazzNameToPrograms.keys()) {
			var clazzName : String = Type.getClassName(clazz);
            var parts : Array<String> = clazzName.split('.');
            
            shortNames.set(parts.pop(), clazzName);
        }
        
        return shortNames;
    }

    public function getQuickLaunchItems() : Array<Dynamic>{
        var items = new Array<Dynamic>();

        for (clazz in programList) {
            var clazzName : String = Type.getClassName(clazz);

            if(Reflect.hasField(clazz, 'getQuickLaunchItems')){
                var func = Reflect.field(clazz, 'getQuickLaunchItems');
                var clazzItems : Array<Dynamic> = Reflect.callMethod(clazz, func,[]);

                for(item in clazzItems){
                    items.push(item);
                }
            }
        }

        return items;
    }
	
	public function getPrograms() : List<Class<Program>> {
		var newList : List<Class<Program>> = new List<Class<Program>>();
		
		for (programDef in programList) {
			newList.push(programDef);
		}
		
		return newList;
	}
	
	public function registerProgram(type : Class<Program>, defaults: Bool) {
        programList.push(type);

		var classFields: Array<String> = Type.getClassFields(type);
		if (Reflect.hasField(type,'CLASS_SUPPORT')) {
			var supported : Array<Class<WorkspaceObject<Dynamic>>> = Reflect.field(type, 'CLASS_SUPPORT');
			for (clazz in supported) {
				var clazzName = Type.getClassName(type);
				
				if(!clazzNameToPrograms.exists(clazz)){
					clazzNameToPrograms.set(clazz, new List<Class<Program>>());
				}
            
				clazzNameToPrograms.get(clazz).add(type);
            
				if(defaults){
					clazzNameToDefaultProgram.set(clazz, type);
				
					var fileFormats : Array<String>= cast Reflect.field(clazz, "FILE_IMPORT_FORMATS");
				
					for (fileFormat in fileFormats) {
						fileExtensionToDefaultProgram.set(fileFormat, type);
					}
				}
			}  
		}
	}

    public function openWith(progClazz : Class<Program>, defaults : Bool, typeClazz : String){
        var clazzName = Type.getClassName(progClazz);

        if(!clazzNameToPrograms.exists(typeClazz)){
            clazzNameToPrograms.set(typeClazz, new List<Class<Program>>());
        }

        clazzNameToPrograms.get(typeClazz).add(progClazz);

        if(defaults){
            clazzNameToDefaultProgram.set(typeClazz, progClazz);

            if(Reflect.hasField(typeClazz, "FILE_IMPORT_FORMATS")){
                var fileFormats : Array<String>= cast Reflect.field(typeClazz, "FILE_IMPORT_FORMATS");

                for (fileFormat in fileFormats) {
                    fileExtensionToDefaultProgram.set(fileFormat, progClazz);
                }
            }
        }
    }
	
	public function getDefaultProgramByFileExtension( fileExtension : String) {
		if (fileExtensionToDefaultProgram.exists(fileExtension.toLowerCase())) {
			return fileExtensionToDefaultProgram.get(fileExtension.toLowerCase());
		}else {
			return null;
		}
	}
    
    public function removeProgram(program : Class<Program>){
        if(!programList.remove(program)){
            throw new ProgramNotFoundException("Program "+Type.getClassName(program));
        }

        for(clazz in clazzNameToPrograms.keys()){
            clazzNameToPrograms.get(clazz).remove(program);
            
            if(clazzNameToDefaultProgram.exists(clazz) && clazzNameToDefaultProgram.get(clazz)==program){
                clazzNameToDefaultProgram.remove(clazz);
            }
        }
    }
    
    public function getDefaultProgram(clazz : Class<WorkspaceObject<Dynamic>>) : Class<Program>{
        if(clazzNameToDefaultProgram.exists(clazz)) {
            var d :Dynamic = clazzNameToDefaultProgram.get(clazz);
			return d;
        }
        return null;
    }

    public function getClassesForProgram(progClazz : Class<Dynamic>){
        var clazzList = new Array<Class<Dynamic>>();

        for(clazz in clazzNameToPrograms.keys()){
            for(programClazz in clazzNameToPrograms.get(clazz)){
                if(progClazz == programClazz){
                    clazzList.push(clazz);
                }
            }
        }

        return clazzList;
    }

    public function getProgramList() : Array<Class<Dynamic>>{
        return programList;
    }
}





class ProgramNotFoundException extends HaxeException {
    public function new(message : String){
        super(message);
    }
}
