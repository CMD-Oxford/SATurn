package saturn.client.programs.phylo;
class PhyloHighlightWidget extends PhyloGlassPaneWidget {
    public var highlightInputs : Array<Dynamic>;
    public var canvas : PhyloCanvasRenderer;

    public function new(parent : Dynamic, canvas : PhyloCanvasRenderer) {
        this.canvas = canvas;

        super(parent,'Select genes to highlight in tree', true);
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
        var formContainer = js.Browser.document.createElement('div');
        formContainer.style.margin = 'auto';

        highlightInputs = new Array<Dynamic>();

        var targets = canvas.getRootNode().targets;

        targets.sort(function(a, b) {
            var targetA = a.toUpperCase();
            var targetB = b.toUpperCase();
            return (targetA < targetB) ? -1 : (targetA > targetB) ? 1 : 0;
        });

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
            inputLabel.style.width = '60px';
            inputLabel.style.marginBottom = '5px';
            inputLabel.style.display = 'inline-block';

            var inputElement = js.Browser.document.createElement('input');
            inputElement.setAttribute('type', 'checkbox');
            inputElement.setAttribute('value', target);
            inputElement.setAttribute('name', name);
            inputElement.style.width = '15px';
            inputElement.style.height = '15px';
            inputElement.style.display = 'inline-block';
            inputElement.style.marginRight = '15px';

            highlightInputs.push(inputElement);

            formContainer.appendChild(inputLabel);
            formContainer.appendChild(inputElement);

            if(i % 7 == 0){
                formContainer.appendChild(js.Browser.document.createElement('br'));
            }
        }

        content.appendChild(formContainer);
    }
}
