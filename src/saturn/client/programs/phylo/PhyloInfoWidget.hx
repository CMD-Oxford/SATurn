package saturn.client.programs.phylo;
class PhyloInfoWidget extends PhyloWindowWidget{
    public var message  : String;

    public function new(parent : Dynamic, message : String) {
        this.message = message;

        super(parent);
    }

    override public function addContent(){
        super.addContent();

        var p = js.Browser.document.createElement('p');
        p.innerText = message;

        content.appendChild(p);
    }
}
