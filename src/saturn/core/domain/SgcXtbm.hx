package saturn.core.domain;
class SgcXtbm {
    public var id : Int;
    public var xtbmId : String;
    public var plateRow : String;
    public var plateColumn : String;
    public var subwell : String;
    public var xtalPlateId : Int;
    public var barcode : String;

    public var xtalPlate : SgcXtalPlate;

    public var score : String;

    public function new() {

    }

    public function setup(){

    }
}
