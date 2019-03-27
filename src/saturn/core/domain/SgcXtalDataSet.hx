package saturn.core.domain;
class SgcXtalDataSet {
    public var id : Int;
    public var xtalDataSetId : String;
    public var xtalMountId : Int;
    public var estimatedResolution : Float;
    public var scaledResolution : Float;

    public var xtalMount : SgcXtalMount;
    public var beamline : String;
    public var outcome : String;
    public var dsType : String;
    public var visit : String;
    public var spaceGroup : String;
    public var dateRecordCreated : Date;

    public function new() {

    }

    public function setup(){

    }
}
