package saturn.client.programs.phylo;
class PhyloWindowWidget {
    public var container : Dynamic;
    public var content : Dynamic;
    public var parent : Dynamic;

    public function new(parent : Dynamic) {
        this.parent = parent;

        build();
    }

    public function build(){
        addContainer();

        addContent();

        container.appendChild(content);
    }

    public function addContainer(){
        container = js.Browser.document.createElement('div');
        container.style.position = 'fixed';
        container.style.zIndex = 1;
        container.style.paddingTop = '100px';
        container.style.left = 0;
        container.style.top = 0;
        container.style.width = '100%';
        container.style.height = '100%';
        container.style.backgroundColor = 'rgba(0,0,0,0.4)';

        parent.appendChild(container);
    }

    public function addContent(){
        content = js.Browser.document.createElement('div');
        content.style.backgroundColor = '#fefefe';
        content.style.margin = 'auto';
        content.style.padding = '20px';
        content.style.width = '50%';

        addCloseButton();

    }

    public function addCloseButton(){
        var closeButton = js.Browser.document.createElement('span');
        closeButton.style.color = '#aaaaaa';
        closeButton.style.float = 'right';
        closeButton.style.fontSize = '28px';
        closeButton.style.fontWeight = 'bold';
        closeButton.innerHTML = '&times;';
        closeButton.style.cursor = 'pointer';

        closeButton.addEventListener('click', function(e){
            close();
        });

        content.appendChild(closeButton);
    }

    public function close(){
        onClose();

        parent.removeChild(container);
    }

    public function onClose(){

    }
}
