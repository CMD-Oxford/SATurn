package saturn.core.domain;
class SgcXtalModel {
    public var id : Int;
    public var xtalModelId : String;
    public var modelType : String;
    public var compound1Id : Int;
    public var compound2Id : Int;
    public var xtalDataSetId : Int;
    public var status : String;
    public var pathToCrystallographicPDB : String;
    public var pathToChemistsPDB : String;
    public var pathToXDSLog : String;
    public var pathToMTZ : String;
    public var estimatedEffort : String;
    public var proofingEffort : String;
    public var spaceGroup : String;

    public var xtalDataDataSet : SgcXtalDataSet;

    public function new() {

    }

    public function setup(){

    }
}
