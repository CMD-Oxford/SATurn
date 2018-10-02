package saturn.client.programs.phylo;

class PhyloToolBar {
    public var canvas : PhyloCanvasRenderer;
    public var parent : Dynamic;
    public var container : Dynamic;

    public var positionTop : Bool = false;
    public var titleElement : Dynamic;
    public var toolbarContainer : Dynamic;
    public var lineTypeButton : Dynamic;

    public function new(canvas : PhyloCanvasRenderer, parent : Dynamic = null) {
        this.canvas = canvas;

        build();
    }

    public function build(){
        if(parent == null){
            parent = canvas.getContainer();

            positionTop = true;
        }

        createContainer();

        parent.appendChild(container);
    }

    public function createContainer(){
        container = js.Browser.document.createElement('div');

        if(positionTop){
            container.style.position = 'absolute';
            container.style.top = '15px';
            container.style.left = '35px';
        }

        createTitleElement();

        createToolBar();
    }

    public function createTitleElement(){
        titleElement = js.Browser.document.createElement('label');
        titleElement.style.color = '#1c66e0';
        titleElement.style.fontSize = '19px';
        titleElement.style.margin = '10px 0px 0px 0px';
        titleElement.style.left = '35px';

        setTitle(canvas.getConfig().title);

        container.appendChild(titleElement);
    }

    public function createToolBar(){
        toolbarContainer = js.Browser.document.createElement('div');

        toolbarContainer.style.marginTop = '10px';

        addCenterButton();
        addZoomInButton();
        addZoomOutButton();
        addExportPNGButton();
        addExportSVGButton();
        addHighlightButton();
        addSetLineWidthButton();
        addTreeTypeButton();
        addTreeLineTypeButton();
        addShadowTypeButton();

        container.appendChild(toolbarContainer);
    }

    public function addCenterButton(){
        var button = js.Browser.document.createElement('button');
        button.style.backgroundImage = 'url(/static/js/images/center-single.png)';
        button.style.backgroundRepeat = 'no-repeat';
        button.style.backgroundPosition = 'center center';

        button.style.height='25px';
        button.style.width='25px';
        button.style.backgroundColor='initial';
        button.style.border='none';
        button.style.cursor='pointer';
        button.style.marginRight = '20px';

        button.addEventListener('click', function(){
            canvas.center();
        });

        toolbarContainer.appendChild(button);
    }

    public function addZoomInButton(){
        var button = js.Browser.document.createElement('button');
        button.style.backgroundImage = 'url(/static/js/images/mag_plus-single.png)';
        button.style.backgroundRepeat = 'no-repeat';
        button.style.backgroundPosition = 'center center';

        button.style.height='25px';
        button.style.width='25px';
        button.style.backgroundColor='initial';
        button.style.border='none';
        button.style.cursor='pointer';
        button.style.marginRight = '20px';

        button.addEventListener('click', function(){
           canvas.zoomIn();
        });

        toolbarContainer.appendChild(button);
    }

    public function addZoomOutButton(){
        var button = js.Browser.document.createElement('button');
        button.style.backgroundImage = 'url(/static/js/images/mag_minus-single.png)';
        button.style.backgroundRepeat = 'no-repeat';
        button.style.backgroundPosition = 'center center';
        button.style.height='25px';
        button.style.width='25px';
        button.style.backgroundColor='initial';
        button.style.border='none';
        button.style.cursor='pointer';
        button.style.marginRight = '20px';

        button.addEventListener('click', function(){
            canvas.zoomOut();
        });

        toolbarContainer.appendChild(button);
    }

    public function addExportPNGButton(){
        var button = js.Browser.document.createElement('button');
        button.style.backgroundImage = 'url(/static/js/images/png-single.png)';
        button.style.backgroundRepeat = 'no-repeat';
        button.style.backgroundPosition = 'center center';
        button.style.height='25px';
        button.style.width='25px';
        button.style.backgroundColor='initial';
        button.style.border='none';
        button.style.cursor='pointer';
        button.style.marginRight = '20px';

        button.addEventListener('click', function(){
            canvas.exportPNGToFile();
        });

        toolbarContainer.appendChild(button);
    }

    public function addExportSVGButton(){
        var button = js.Browser.document.createElement('button');
        button.style.backgroundImage = 'url(/static/js/images/svg-single.png)';
        button.style.backgroundRepeat = 'no-repeat';
        button.style.backgroundPosition = 'center center';
        button.style.height='25px';
        button.style.width='25px';
        button.style.backgroundColor='initial';
        button.style.border='none';
        button.style.cursor='pointer';
        button.style.marginRight = '20px';

        button.addEventListener('click', function(){
            canvas.exportSVGToFile();
        });

        toolbarContainer.appendChild(button);
    }

    public function addHighlightButton(){
        var button = js.Browser.document.createElement('button');
        button.style.backgroundImage = 'url(/static/js/images/hightlight-single.png)';
        button.style.backgroundRepeat = 'no-repeat';
        button.style.backgroundPosition = 'center center';
        button.style.height='25px';
        button.style.width='25px';
        button.style.backgroundColor='initial';
        button.style.border='none';
        button.style.cursor='pointer';
        button.style.marginRight = '20px';

        button.addEventListener('click', function(){
            canvas.showHighlightDialog();
        });

        toolbarContainer.appendChild(button);
    }

    public function setTitle(title : String){
        titleElement.innerText = title;
    }

    public function addSetLineWidthButton(){
        var inputLabel = js.Browser.document.createElement('label');
        inputLabel.setAttribute('for', 'tree_line_width');
        inputLabel.innerText = 'Pen width';
        inputLabel.style.display = 'inline-block';

        var inputElement :Dynamic = js.Browser.document.createElement('input');
        inputElement.setAttribute('type', 'text');
        inputElement.style.width = '30px';
        inputElement.setAttribute('value', '1');
        inputElement.style.display = 'inline-block';
        inputElement.style.marginLeft = '5px';

        inputElement.addEventListener('input', function(e){
            canvas.setLineWidth(Std.parseFloat(inputElement.value));
        });

        toolbarContainer.appendChild(inputLabel);
        toolbarContainer.appendChild(inputElement);
    }

    public function addTreeTypeButton(){
        var button = js.Browser.document.createElement('button');
        button.innerText = 'Toggle Type';
        button.style.border='none';
        button.style.cursor='pointer';
        button.style.marginLeft = '20px';

        button.addEventListener('click', function(){
            canvas.toggleType();
        });

        toolbarContainer.appendChild(button);
    }

    public function addTreeLineTypeButton(){
        var button = js.Browser.document.createElement('button');
        button.innerText = 'Toggle Line Type';
        button.style.border='none';
        button.style.cursor='pointer';
        button.style.marginLeft = '20px';

        button.addEventListener('click', function(){
            canvas.toggleLineMode();
        });

        toolbarContainer.appendChild(button);

        lineTypeButton = button;
    }

    public function setLineTypeButtonVisible(visible){
        if(visible){
            lineTypeButton.style.display = 'inline-block';
        }else{
            lineTypeButton.style.display = 'none';
        }
    }

    public function addShadowTypeButton(){
        var shadowInputColourLabel :Dynamic = js.Browser.document.createElement('label');
        shadowInputColourLabel.innerText = 'Shadow colour';
        shadowInputColourLabel.style.marginLeft = '20px';

        toolbarContainer.appendChild(shadowInputColourLabel);

        var shadowInputColour :Dynamic = js.Browser.document.createElement('input');
        shadowInputColour.style.marginLeft = '5px';
        shadowInputColour.setAttribute('type', 'color');
        shadowInputColour.setAttribute('name', 'shadow_colour_input');
        shadowInputColour.style.width = '50px';
        shadowInputColour.addEventListener('change', function(){
            canvas.setShadowColour(shadowInputColour.value);
        });

        toolbarContainer.appendChild(shadowInputColour);
    }
}
