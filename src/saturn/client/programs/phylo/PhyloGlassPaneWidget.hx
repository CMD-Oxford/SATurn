package saturn.client.programs.phylo;

class PhyloGlassPaneWidget extends PhyloWindowWidget{

    public function new(parent : Dynamic, title : String, modal : Bool = true) {
        super(parent, title, modal);

        container.style.width = '100%';
        container.style.height = '100%';
        container.style.backgroundColor = 'rgba(0,0,0,0.4)';

        header.style.width = '50%';
        header.style.margin = 'auto';
        header.style.position = 'initial';
        header.style.padding = '20px';

        content.style.backgroundColor = '#fefefe';
        content.style.margin = 'auto';
        content.style.padding = '20px';
        content.style.width = '50%';
    }

    override public function addContainer(){
        super.addContainer();
    }
}
