package saturn.client.programs.phylo;
class PhyloInfoWidget extends PhyloGlassPaneWidget{
    public var message  : String;

    public function new(parent : Dynamic, message : String, title : String) {
        this.message = message;

        super(parent, title);
    }

    override public function addContent(){
        super.addContent();

        var p = js.Browser.document.createElement('p');
        p.innerText = message;

        content.appendChild(p);
    }
}
