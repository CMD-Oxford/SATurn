package saturn.client.programs.phylo;
import saturn.client.programs.phylo.PhyloCanvasRenderer;
class PhyloContextMenu {
    var contextContainer : Dynamic;
    var parent : Dynamic;
    var node : PhyloTreeNode;
    var data : PhyloScreenData;
    var e : Dynamic;
    var canvas : PhyloCanvasRenderer;

    public function new(parent : Dynamic, canvas : PhyloCanvasRenderer, node : PhyloTreeNode, data : PhyloScreenData, e : Dynamic) {
        this.parent = parent;
        this.node = node;
        this.data = data;
        this.e = e;
        this.canvas = canvas;

        build();
    }

    public function build(){
        addContainer();

        if(canvas.getConfig().drawingMode == PhyloDrawingMode.CIRCULAR){
            addWedgeOptions();
        }

        addColourOption();

        if(canvas.getConfig().drawingMode == PhyloDrawingMode.STRAIGHT){
            addRotateNode();
        }

        parent.appendChild(contextContainer);
    }

    public function addContainer(){
        contextContainer = js.Browser.document.createElement('div');
        contextContainer.style.position = 'absolute';
        contextContainer.style.left = e.offsetX;
        contextContainer.style.top = e.offsetY;
        contextContainer.style.background = '#f7f8fb';
        contextContainer.style.color = 'black';
        contextContainer.style.padding = '4px';
    }

    public function destroyContainer(){
        parent.removeChild(contextContainer);

        parent = null;
        node = null;
        data = null;
        e = null;
        canvas = null;
    }

    public function close(){
        destroyContainer();
    }

    public function addColourOption(){
        var rowContainer = js.Browser.document.createElement('div');

        var lineColourInputLabel :Dynamic = js.Browser.document.createElement('label');
        var lineColourRemoveButton :Dynamic = js.Browser.document.createElement('button');

        lineColourInputLabel.setAttribute('for','line_colour_input');
        lineColourInputLabel.innerText = 'Pick line colour';
        //lineColourInputLabel.style.marginRight = '5px';
        lineColourInputLabel.style.width = '100px';
        lineColourInputLabel.style.display = 'inline-block';

        var lineInputColour :Dynamic = js.Browser.document.createElement('input');
        lineInputColour.setAttribute('type', 'color');
        lineInputColour.setAttribute('name', 'line_colour_input');
        lineInputColour.style.width = '100px';
        lineInputColour.addEventListener('change', function(){
            node.colour = lineInputColour.value;

            lineColourRemoveButton.style.display = 'inline-block';

            canvas.redraw();
        });

        rowContainer.appendChild(lineColourInputLabel);
        rowContainer.appendChild(lineInputColour);

        lineColourRemoveButton.setAttribute('for','wedge_colour_input');
        lineColourRemoveButton.innerText = 'Remove';
        lineColourRemoveButton.style.marginLeft = '5px';
        lineColourRemoveButton.style.display = 'none';
        lineColourRemoveButton.style.width = '100px';

        lineColourRemoveButton.addEventListener('click', function(){
            node.colour = null;

            lineColourRemoveButton.style.display = 'none';

            canvas.redraw();
        });

        rowContainer.appendChild(lineColourRemoveButton);

        if(node.colour != null){
            lineColourRemoveButton.style.display = 'inline-block';
        }

        contextContainer.appendChild(rowContainer);
    }

    public function addWedgeOptions(){
        var rowContainer = js.Browser.document.createElement('div');

        var wedgeInputLabel :Dynamic = js.Browser.document.createElement('label');
        var wedgeButtonLabel :Dynamic = js.Browser.document.createElement('button');

        wedgeInputLabel.setAttribute('for','wedge_colour_input');
        wedgeInputLabel.setAttribute('for','wedge_colour_input');
        wedgeInputLabel.innerText = 'Pick wedge colour';
        //wedgeInputLabel.style.marginRight = '5px';
        wedgeInputLabel.style.width = '100px';
        wedgeInputLabel.style.display = 'inline-block';

        var wedgeInputColour :Dynamic = js.Browser.document.createElement('input');
        wedgeInputColour.setAttribute('type', 'color');
        wedgeInputColour.setAttribute('name', 'wedge_colour_input');
        wedgeInputColour.style.width = '100px';

        wedgeInputColour.addEventListener('change', function(){
            node.wedgeColour = wedgeInputColour.value;

            wedgeButtonLabel.style.display = 'inline-block';

            canvas.redraw();
        });

        rowContainer.appendChild(wedgeInputLabel);
        rowContainer.appendChild(wedgeInputColour);

        wedgeButtonLabel.setAttribute('for','wedge_colour_input');
        wedgeButtonLabel.setAttribute('for','wedge_colour_input');
        wedgeButtonLabel.innerText = 'Remove';
        wedgeButtonLabel.style.marginLeft = '5px';
        wedgeButtonLabel.style.width = '100px';
        wedgeButtonLabel.style.display = 'none';

        wedgeButtonLabel.addEventListener('click', function(){
            node.wedgeColour = null;

            wedgeButtonLabel.style.display = 'none';

            canvas.redraw();
        });

        rowContainer.appendChild(wedgeButtonLabel);

        if(node.wedgeColour != null){
            wedgeButtonLabel.style.display = 'inline-block';
        }

        contextContainer.appendChild(rowContainer);
    }
    
    public function addRotateNode(){
        var rowContainer = js.Browser.document.createElement('div');

        var label = js.Browser.document.createElement('label');
        label.innerText = 'Rotate branch';
        label.style.display = 'inline-block';
        label.style.width = '100px';

        rowContainer.appendChild(label);

        var rotateNodeClockwiseButton :Dynamic = js.Browser.document.createElement('button');
        rotateNodeClockwiseButton.innerText = 'Clockwise';
        rotateNodeClockwiseButton.style.marginRight = '5px';
        rotateNodeClockwiseButton.style.width = '100px';
        rotateNodeClockwiseButton.style.display = 'inline-block';

        rotateNodeClockwiseButton.addEventListener('click', function(e){
            canvas.rotateNode(node, true);
        });

        rowContainer.appendChild(rotateNodeClockwiseButton);

        var rotateNodeAnticlockwiseButton :Dynamic = js.Browser.document.createElement('button');
        rotateNodeAnticlockwiseButton.innerText = 'Anticlockwise';
        rotateNodeAnticlockwiseButton.style.marginRight = '5px';
        rotateNodeAnticlockwiseButton.style.width = '100px';
        rotateNodeAnticlockwiseButton.style.display = 'inline-block';

        rotateNodeAnticlockwiseButton.addEventListener('click', function(e){
            canvas.rotateNode(node, false);
        });

        rowContainer.appendChild(rotateNodeAnticlockwiseButton);

        contextContainer.appendChild(rowContainer);
    }
}
