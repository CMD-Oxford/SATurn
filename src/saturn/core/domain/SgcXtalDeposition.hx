package saturn.core.domain;
class SgcXtalDeposition {
    public var id : Int;
    public var pdbId : String;
    public var xtalModelId : Int;
    public var counted : String;
    public var site : String;
    public var followUp : String;
    public var dateDeposited : Date;

    public var xtalModel : SgcXtalModel;
    public var depType: String;

    public function new() {

    }

    public function setup(){

    }
}
