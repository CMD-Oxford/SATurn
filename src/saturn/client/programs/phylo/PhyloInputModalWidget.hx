package saturn.client.programs.phylo;
class PhyloInputModalWidget extends PhyloGlassPaneWidget{
    public var message  : String;
    public var initialValue : String;
    public var textArea : Dynamic;

    public function new(parent : Dynamic, message : String, title : String, initialValue : String) {
        this.message = message;
        this.initialValue = initialValue;

        super(parent, title);
    }

    override public function addContent(){
        super.addContent();

        addMessage();

        addInputField();
    }

    public function addMessage(){
        var p = js.Browser.document.createElement('p');
        p.innerText = message;

        content.appendChild(p);
    }

    public function addInputField(){
        textArea = js.Browser.document.createElement('textarea');
        textArea.value = initialValue;
        textArea.style.width = '100%';
        textArea.setAttribute('rows','10');

        content.appendChild(textArea);
    }

    public function getText() : String{
        return textArea.value;
    }
}
