package saturn.core.domain;
class SgcXtalForm {
    public var id : Int;
    public var formId : String;
    public var phasingId : Int;
    public var a : Float;
    public var b : Float;
    public var c : Float;
    public var alpha : Float;
    public var beta : Float;
    public var gamma : Float;
    public var spaceGroup : String;
    public var latticeSymbol : String;
    public var lattice : String;

    public var xtalPhasing : SgcXtalPhasing;

    public function new() {

    }

    public function setup(){

    }
}
