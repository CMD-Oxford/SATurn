package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.chromohub.ChromoHubAnnotation.HasAnnotationType;

class ProteinSubFamilyAnnotation {
    public function new() {

    }

    static function hasSubFamily(target: String, data: Dynamic, selected:Int,annotList:Array<ChromoHubAnnotation>, item:String, cb : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'red',used:true},defImage:0};

        // data.family_id
        // data.subfamily

        cb(r);
    }
}
