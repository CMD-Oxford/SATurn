package saturn.core.domain;

class SgcXtalPhasing {
    public var id : Int;
    public var phasingId : String;
    public var xtalDataSetId : Int;
    public var phasingMethod : String;
    public var phasingConfidence : String;
    public var spaceGroup : String;

    public var xtalDataSet : SgcXtalDataSet;

    public function new() {

    }

    public function setup(){

    }
}
