package saturn.client.programs.phylo;
class PhyloHighlightWidget extends PhyloWindowWidget {
    public var highlightInputs : Array<Dynamic>;
    public var canvas : PhyloCanvasRenderer;

    public function new(parent : Dynamic, canvas : PhyloCanvasRenderer) {
        this.canvas = canvas;

        super(parent);
    }

    override public function onClose(){
        canvas.getConfig().highlightedGenes=new Map<String, Bool>();

        for(inputElement in highlightInputs){
            if(inputElement.checked){
                canvas.getConfig().highlightedGenes.set(inputElement.getAttribute('value'), true);
            }
        }

        canvas.redraw();
    }

    override public function addContent(){
        super.addContent();

        addHighlightList();
    }

    public function addHighlightList(){
        highlightInputs = new Array<Dynamic>();

        var heading = js.Browser.document.createElement('label');
        heading.style.color = 'rgb(28, 102, 224)';
        heading.style.marginBottom = '5px';
        heading.style.fontSize = '15px';
        heading.style.left = '35px';
        heading.innerText = 'Select genes to highlight in tree';
        heading.style.display = 'block';

        content.appendChild(heading);

        var targets = canvas.getRootNode().targets;

        var i = 0;
        for(target in targets){
            if(target == null || target == ''){
                continue;
            }

            i += 1;

            var name = 'target_highlight_' + i;

            var inputLabel = js.Browser.document.createElement('label');
            inputLabel.setAttribute('for', name);
            inputLabel.innerText = target;
            inputLabel.style.width = '50px';
            inputLabel.style.display = 'inline-block';

            var inputElement = js.Browser.document.createElement('input');
            inputElement.setAttribute('type', 'checkbox');
            inputElement.setAttribute('value', target);
            inputElement.setAttribute('name', name);
            inputElement.style.width = '10px';
            inputElement.style.display = 'inline-block';
            inputElement.style.marginRight = '10px';

            highlightInputs.push(inputElement);

            content.appendChild(inputLabel);
            content.appendChild(inputElement);

            if(i % 10 == 0){
                content.appendChild(js.Browser.document.createElement('br'));
            }
        }
    }
}
