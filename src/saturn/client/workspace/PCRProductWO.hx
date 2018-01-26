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
import saturn.core.PCRProduct;
import saturn.util.StringUtils;

import saturn.client.WorkspaceApplication;

class PCRProductWO<T:PCRProduct> extends DNAWorkspaceObject<T>{
    public static var FILE_IMPORT_FORMATS : Array<String> = [];
	
	var forwardPrimerObjId : String;
	var reversePrimerObjId : String;
	var templateObjId : String;

    public function new(object : Dynamic, name : String){
        if(object == null){
            object = new PCRProduct(null, null, null);
        }
        
        if(name == null){
            name="PCR Product";
        }
         
        super(object, name);
    }
	
	public function updateProduct() {
		if ( forwardPrimerObjId == null || reversePrimerObjId == null || templateObjId == null) {
			return ;
		}
		
		var workspace : Workspace = WorkspaceApplication.getApplication().getWorkspace();
		
		var fDNA : DNA = workspace.getObjectSafely(forwardPrimerObjId, DNAWorkspaceObject).getObject();
		
		var fPrimer : Primer;
		
		if (Std.is(fDNA, Primer)) {
			fPrimer = cast(fDNA, Primer);
		}else {
			fPrimer = new Primer(fDNA.getSequence());
		}
		
		object.setForwardPrimer(fPrimer);
		
		var rDNA : DNA = workspace.getObjectSafely(reversePrimerObjId, DNAWorkspaceObject).getObject();
		
		var rPrimer : Primer;
		
		if (Std.is(rDNA, Primer)) {
			rPrimer = cast(rDNA, Primer);
		}else {
			rPrimer = new Primer(rDNA.getSequence());
		}
		
		object.setReversePrimer(rPrimer);
		
		object.setTemplate(workspace.getObjectSafely(templateObjId, DNAWorkspaceObject).getObject());
		
		object.calculateProduct();
	}
	
	public function setForwardPrimer(obj : DNAWorkspaceObject<DNA>) {
		if (obj == null) {
			forwardPrimerObjId = null;
		}else{
			forwardPrimerObjId = obj.getUUID();
		}
	}
	
	public function getForwardPrimerId() {
		return forwardPrimerObjId;
	}
	
	public function setReversePrimer(obj : DNAWorkspaceObject<DNA>) {
		if (obj == null) {
			reversePrimerObjId = null;
		}else{
			reversePrimerObjId = obj.getUUID();
		}
	}
	
	public function getReversePrimerId() {
		return reversePrimerObjId;
	}
	
	public function getTemplateId() {
		return templateObjId;
	}
	
	public function setTemplate(obj : DNAWorkspaceObject<DNA>) {
		if (obj == null) {
			templateObjId = null;
		}else{
			templateObjId = obj.getUUID();
		}
	}

    public static function getNewMenuText() : String {
        return "PCR Product";
    }
	
	/*override
	public function serialise() : Dynamic {
		var serialisedObject : Dynamic = super.serialise();
		
		serialisedObject.FORWARD_ID = forwardPrimerObjId;
		serialisedObject.REVERSE_ID = reversePrimerObjId;
		serialisedObject.TEMPLATE_ID = templateObjId;
		
		//serialisedObject.DATA={ 'OBJECT_IDS': object.getAlignmentObjectIds().join(','), 'ALN_URL' : this.getObject().getAlignmentURL() };
		
		return serialisedObject;
	}

	override
	public function deserialise(object : Dynamic) : Void{
		super.deserialise(object);
		
		forwardPrimerObjId = object.FORWARD_ID;
		reversePrimerObjId = object.REVERSE_ID;
		templateObjId = object.TEMPLATE_ID;
		
        var pcrProduct : PCRProduct = new PCRProduct(null, null, null);

	    setObject(pcrProduct);
	}*/
}
