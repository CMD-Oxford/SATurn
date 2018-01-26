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
import saturn.core.DoubleDigest;
import saturn.core.RestrictionSite;

import saturn.util.StringUtils;

import saturn.client.WorkspaceApplication;

class DigestWO<T:DoubleDigest> extends DNAWorkspaceObject<T>{
    public static var FILE_IMPORT_FORMATS : Array<String> = [];
	
	var templateObjId : String;
	var res1ObjId : String;
	var res2ObjId : String;

	var theActiveDNA : DNA;
	
    public function new(object : Dynamic, name : String) {
		theActiveDNA = new DNA('');
		
        if(object == null){
            object = new DoubleDigest(null,null,null);
        }
        
        if(name == null){
            name="Double Digest";
        }
         
        super(object, name);
    }
	
	override public function getDNAObject() : DNA {
		return theActiveDNA;
	}
	
	public function digest() {
		if ( templateObjId == null || res1ObjId == null || res2ObjId == null) {
			return ;
		}
		
		var workspace : Workspace = WorkspaceApplication.getApplication().getWorkspace();
		
		var template : DNA = workspace.getObjectSafely(templateObjId, DNAWorkspaceObject).getObject();
		var res1 : RestrictionSite =  cast(workspace.getObjectSafely(res1ObjId,DNAWorkspaceObject).getObject(), RestrictionSite);
		var res2 : RestrictionSite = cast(workspace.getObjectSafely(res2ObjId,DNAWorkspaceObject).getObject(),RestrictionSite);
		
		object.setTemplate(template);
		object.setRestrictionSite1(res1);
		object.setRestrictionSite2(res2);
		
		object.digest();
		
		theActiveDNA = object.getCenterProduct();
	}
	
	public function getDigest() : DoubleDigest{
		return cast(object, DoubleDigest);
	}
	
	public function setTemplate(template : DNAWorkspaceObject<DNA>) {
		if (template == null) {
			templateObjId = null;
		}else{
			templateObjId = template.getUUID();
		}
	}
	
	public function setRestrictionSite1(res1 : DNAWorkspaceObject<DNA>) {
		if (res1 == null) {
			res1ObjId = null;
		}else{
			res1ObjId = res1.getUUID();
		}
	}
	
	public function setRestrictionSite2(res2 : DNAWorkspaceObject<DNA>) {
		if (res2 == null) {
			res2ObjId = null;
		}else{
			res2ObjId = res2.getUUID();
		}
	}
	
	public function getTemplateId() : String {
		return templateObjId;
	}
	
	public function getRes1Id() : String {
		return res1ObjId;
	}
	
	public function getRes2Id() : String {
		return res2ObjId;
	}
	
    public static function getNewMenuText() : String {
        return "Double Digest";
    }
	
	/*override
	public function serialise() : Dynamic {
		var serialisedObject : Dynamic = super.serialise();
		
		serialisedObject.TEMPLATE_ID = templateObjId;
		serialisedObject.RES1_ID = res1ObjId;
		serialisedObject.RES2_ID = res2ObjId;
		
		
		return serialisedObject;
	}

	override
	public function deserialise(object : Dynamic) : Void{
		super.deserialise(object);
		
		templateObjId = object.TEMPLATE_ID;
		res1ObjId = object.RES1_ID;
		res2ObjId = object.RES2_ID;
		
		theActiveDNA = new DNA(object.DATA.SEQ);
		
        var digest : DoubleDigest = new DoubleDigest(null, null, null);

	    setObject(digest);
	}*/
	
	override public function setDNAObject(dnaObject : DNA) {
		theActiveDNA = dnaObject;
	}
	
	public function setLeftActive() {
		setDNAObject(object.getLeftProduct());
	}
	
	public function setRightActive() {
		setDNAObject(object.getRightProduct());
	}
	
	public function setMiddleActive() {
		setDNAObject(object.getCenterProduct());
	}
}
