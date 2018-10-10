package saturn.client.programs.phylo;

class PhyloWindowWidget {
    public var container : Dynamic;
    public var content : Dynamic;
    public var parent : Dynamic;
    public var header : Dynamic;
    public var title : String;
    public var modal : Bool;
    public var onCloseFunc : Dynamic;

    public function new(parent : Dynamic, title : String = null, modal = false) {
        this.parent = parent;
        this.title = title;
        this.modal = modal;

        build();
    }

    public function setOnCloseEvent(func : Dynamic){
        onCloseFunc = func;
    }

    public function build(){
        addContainer();

        addWindowHeader();

        addContent();

        container.appendChild(content);
    }

    public function getContainer() : Dynamic{
        return container;
    }

    public function getContent() : Dynamic {
        return content;
    }

    public function addContainer(){
        container = js.Browser.document.createElement('div');
        container.style.position = 'fixed';
        container.style.zIndex = 1;
        container.style.paddingTop = '20px';
        container.style.left = 0;
        container.style.top = 0;
        container.style.minWidth = '200px';
        container.style.minHeight = '100px';
        container.style.backgroundColor = 'rgb(247, 248, 251)';

        if(!isModal()){
            installMoveListeners();
        }

        parent.appendChild(container);
    }

    public function isModal() : Bool{
        return modal;
    }

    public function addWindowHeader(){
        header = js.Browser.document.createElement('div');
        header.style.position = 'absolute';
        header.style.top = '0px';
        header.style.backgroundColor = 'rgb(125, 117, 117)';
        header.style.height = '20px';
        header.style.width = '100%';

        addTitle();
        addCloseButton();

        container.appendChild(header);
    }

    public function addTitle(){
        var titleSpan = js.Browser.document.createElement('span');
        titleSpan.innerText = this.title;

        titleSpan.style.color = 'white';
        titleSpan.style.fontSize = '16px';
        titleSpan.style.fontWeight = 'bold';

        header.appendChild(titleSpan);
    }

    public function addCloseButton(){
        var closeButton = js.Browser.document.createElement('span');
        closeButton.style.color = 'white';
        closeButton.style.float = 'right';
        closeButton.style.fontSize = '16px';
        closeButton.style.fontWeight = 'bold';
        closeButton.innerHTML = '&times;';
        closeButton.style.cursor = 'pointer';

        closeButton.addEventListener('click', function(e){
            close();
        });

        header.appendChild(closeButton);
    }

    public function addContent(){
        content = js.Browser.document.createElement('div');
        content.style.backgroundColor = '#fefefe';
        content.style.width = '100%';
    }

    public function close(){
        onClose();

        parent.removeChild(container);
    }

    public function onClose(){
        if(onCloseFunc != null){
            onCloseFunc(this);
        }
    }

    public function installMoveListeners(){
        var isDown = false;
        var offsetX = 0.;
        var offsetY = 0.;

        var moveListener = function(event) {
            event.preventDefault();

            if (isDown) {
                container.style.left = (event.clientX + offsetX) + 'px';
                container.style.top  = (event.clientY + offsetY) + 'px';
            }
        };

        container.addEventListener('mousedown', function(e) {
            isDown = true;

            offsetX = container.offsetLeft - e.clientX;
            offsetY = container.offsetTop - e.clientY;

            js.Browser.document.body.addEventListener('mousemove', moveListener);

        });

        container.addEventListener('mouseup', function() {
            isDown = false;
            js.Browser.document.body.removeEventListener('mousemove', moveListener);

        });
    }
}
