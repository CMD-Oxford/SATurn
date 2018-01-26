/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client;

import saturn.client.Program;

interface ProgramPlugin<T : Program> {
	function emptyInit() : Void;
	function onFocus() : Void;
	function onBlur() : Void;
	function close() : Void;
	
	function getProgram() : T;
	function setProgram(program : T) : Void;
	function destroy() : Void;
    function openFile(file : Dynamic, next : Dynamic) : Void;
	// Below might be implemented in the future
    //function mouseup(event : Dynamic) : Void;
    //function mousedown(event: Dynamic) : Void;
	//function openFile(file : Dynamic, asNew : Bool) : Void;
	//function saveAll() : Void;
	//function serialise() : Dynamic;
	//function deserialise(object : Dynamic) : Void;
	//function postRestore() : Void;
	//function addWorkspaceObject(objectId : String) : Void;
	//function closeWorkspaceObject(objectId : String ) : Void;
}

class BaseProgramPlugin<T : Program> implements ProgramPlugin<T> {
	var theProgram : T;

    public function new(){

    }

    public function openFile(file : Dynamic, next : Dynamic) : Void{

    }

	public function emptyInit() : Void {
		
	}

	public function onFocus() : Void {
		
	}
	
	public function onBlur() : Void {
		
	}
	
	public function close() : Void {
		
	}
	
	public function getProgram() : T {
		return theProgram;
	}
	
	public function setProgram(program : T) : Void {
		theProgram = program;
	}

    public function destroy(){
        theProgram = null;
    }
}
