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

import haxe.Serializer;
import haxe.Unserializer;

class ABITraceWO extends WorkspaceObjectBase<ABITrace>{
    public static var FILE_IMPORT_FORMATS : Array<String> = ['ab1'];

    public var previousTraces : Array<Dynamic> = new Array<Dynamic>();

    public var blastResultMap = new Map<String, String>();
    public var blastDBtoHitName = new Map<String, Array<String>>();

    public function new(object : Dynamic, name : String){
        if(object == null){
            object = new ABITrace();
        }
        
        if(name == null){
            name="ABI Trace";
        }

        iconPath = '/static/js/images/trace_16.png';
         
        super(object, name);
    }

    public static function getDefaultFolderName() : String{
        return "Traces";
    }

    /**
    * trim returns the trace data between start and stop and sets the main trace object to the trimmed trace.
    *
    * Previous traces are stored in previousTraces.
    *
    * Trim operations can be reversed by calling untrim()
    **/
    public function trim(start, stop) : ABITrace{
        previousTraces.push(object);

        object = object.trim(start, stop);

        return object;
    }

    /**
    * untrim sets the active trace to the one before the last trim operation.
    *
    * @returns - the parent of the last trimmed trace or null if no previous traces remain
    **/
    public function untrim(): ABITrace {
        if(previousTraces.length > 0){
            object = previousTraces.pop();

            return object;
        }else{
            return null;
        }
    }

    /**
    * getLastTrace returns the trace before the last trim operation was returned
    **/
    public function getLastTrace(){
        return previousTraces[previousTraces.length -1];
    }

    public function align(aln : Dynamic, isForwards : Bool) : saturn.core.Alignment{
        previousTraces.push(object);

        object = object.align(aln, isForwards);

        return object;
    }

    public static function getNewMenuText() : String {
        return "ABI Trace";
    }

	/*override
	public function serialise() : Dynamic {
		var serialisedObject : Dynamic = super.serialise();
		
		serialisedObject.DATA = { 'TRACE_DATA': Serializer.run(object) };
		
		return serialisedObject;
	}*/

	override
	public function deserialise(object : Dynamic) : Void{
		super.deserialise(object);

        setObject(Unserializer.run(object.DATA.TRACE_DATA));

        /*var trace = new ABITrace();

        var fields = Reflect.fields(object.DATA);

        for(field in fields){
            if(Reflect.hasField(trace, field)){
                Reflect.setField(trace, field, Reflect.field(object.DATA, field));
            }
        }*/

        //setObject(trace);
		
        /*var webPageObject : WebPage = new WebPage();
        webPageObject.setURL(object.DATA.URL);
		
	    setObject(webPageObject);*/
	}
}
