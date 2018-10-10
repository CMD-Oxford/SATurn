package saturn.client.programs.phylo;
class PhyloLegendWidget {
    var canvas : PhyloCanvasRenderer;
    var container : Dynamic;
    var legendContainer : Dynamic;

    public function new(canvas : PhyloCanvasRenderer) {
        this.canvas = canvas;

        build();
    }

    public function build(){
        addContainer();
    }

    public function getCanvas() : PhyloCanvasRenderer{
        return canvas;
    }

    public function getContainer() : Dynamic {
        return container;
    }

    public function addContainer(){
        container = js.Browser.document.createElement('div');

        container.style.display = 'inline-block';
        container.style.minWidth = '160px';
        container.style.position = 'relative';
        container.style.verticalAlign = 'top';
        container.style.height = '100%';
        container.style.backgroundColor = '#f7f8fb';

        container.innerHTML = '<h1 style="margin-left:5px;margin-right:5px">Legend</h1>';

        legendContainer = js.Browser.document.createElement('div');

        container.appendChild(legendContainer);

        redraw();
    }

    public function clearLegendContainer(){
        while(legendContainer.firstChild){
            legendContainer.removeChild(legendContainer.firstChild);
        }
    }

    public function getLegendContainer(){
        return legendContainer;
    }

    public function redraw(){
        clearLegendContainer();

        var annotationManager = canvas.getAnnotationManager();

        var activeAnnotations = annotationManager.getActiveAnnotations();

        for(annotationDef in activeAnnotations){
            var config = canvas.getAnnotationManager().getAnnotationConfigByName(annotationDef.label);

            if(config.legendFunction != null){
                var func = config.legendFunction;

                func(this, config);
            }
        }
    }
}
