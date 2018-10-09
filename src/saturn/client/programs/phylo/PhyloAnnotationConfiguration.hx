package saturn.client.programs.phylo;

class PhyloAnnotationConfiguration {
    public var name : String;
    public var annotationFunction : Dynamic;
    public var styleFunction : Dynamic;
    public var legendFunction : Dynamic;
    public var infoFunction : Dynamic;
    public var shape : Dynamic;
    public var colour : Dynamic;

    public function new() {

    }

    public function getColourOldFormat() : Dynamic{
        return {color: colour, 'used':'false'};
    }
}
