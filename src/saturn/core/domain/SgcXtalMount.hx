package saturn.core.domain;
class SgcXtalMount {
    public var id : Int;
    public var xtalMountId : String;
    public var xtbmId : Int;
    public var xtalProjectId : Int;
    public var dropStatus : String;
    public var compoundId : Int;
    public var pinId : Int;
    public var xtalFormId : Int;

    public var xtbm : SgcXtbm;
    public var xtalProject : SgcXtalProject;
    public var compound : Compound;
    public var xtalForm : SgcXtalForm;

    public function new() {

    }

    public function setup(){

    }
}
