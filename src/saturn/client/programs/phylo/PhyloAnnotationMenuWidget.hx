package saturn.client.programs.phylo;
import saturn.db.Provider;
import saturn.client.core.CommonCore;
class PhyloAnnotationMenuWidget {
    var canvas : PhyloCanvasRenderer;
    var container : Dynamic;
    var activeAnnotations : Map<String, String>;

    var items : Array<Dynamic>;

    public function new(canvas : PhyloCanvasRenderer, activeAnnotations : Map<String,String> = null) {
        this.canvas = canvas;
        this.activeAnnotations = activeAnnotations;

        build();
    }

    public function build(){
        addContainer();
        addAnnotationButtons();
    }

    public function getContainer() : Dynamic {
        return container;
    }

    public function update(activeAnnotations : Map<String, String>){
        this.activeAnnotations = activeAnnotations;

        addAnnotationButtons();
    }

    public function clearAnnotationItems(){
        if(items != null){
            for(item in items){
                container.removeChild(item);
            }
        }
    }

    public function addContainer(){
        container = js.Browser.document.createElement('div');

        container.style.display = 'inline-block';
        container.style.minWidth = '160px';
        container.style.position = 'relative';
        container.style.verticalAlign = 'top';
        container.style.height = '100%';
        container.style.backgroundColor = '#f7f8fb';

        container.innerHTML = '<h1 style="margin-left:5px;margin-right:5px">Annotations</h1>';
    }

    public function addAnnotationButtons(){
        var btnGroups :Array<Dynamic>= canvas.getAnnotationManager().jsonFile.btnGroup;

        clearAnnotationItems();

        items = new Array<Dynamic>();

        for(i in  0...btnGroups.length){
            var btnGroupDef = btnGroups[i];

            var btnDefs : Array<Dynamic> = btnGroupDef.buttons;
            for(btnDef in btnDefs){
                var row = js.Browser.document.createElement('div');
                row.style.display = 'flex';

                var tooltipBtn = js.Browser.document.createElement('button');
                tooltipBtn.innerText = '?';
                tooltipBtn.style.backgroundColor = 'rgb(247, 248, 251)';
                tooltipBtn.style.border = 'none';
                tooltipBtn.style.font = 'normal 11px/16px tahoma, arial, verdana, sans-serif';
                tooltipBtn.style.cursor = 'pointer';

                var enabledBtn = js.Browser.document.createElement('button');
                enabledBtn.innerHTML = ' &#9744;';
                enabledBtn.style.backgroundColor = 'rgb(247, 248, 251)';
                enabledBtn.style.border = 'none';
                enabledBtn.style.font = 'normal 16px/20px tahoma, arial, verdana, sans-serif';
                enabledBtn.style.cursor = 'pointer';

                var btn = js.Browser.document.createElement('button');
                btn.innerText = btnDef.label;
                btn.style.backgroundColor = 'rgb(247, 248, 251)';
                btn.style.border = 'none';
                btn.style.font = 'normal 11px/16px tahoma, arial, verdana, sans-serif';
                btn.style.cursor = 'pointer';
                btn.style.textAlign = 'left';
                btn.style.flexGrow = '1';
                btn.setAttribute('title', btnDef.helpText);

                btn.addEventListener('mouseover', function(){
                    btn.style.backgroundColor = '#dddee1';
                });

                btn.addEventListener('mouseout', function(){
                    btn.style.backgroundColor = 'rgb(247, 248, 251)';
                });

                btn.addEventListener('click', function(){
                    if(canvas.getAnnotationManager().isAnnotationActive(btnDef.annotCode)){
                        enabledBtn.innerHTML = '&#9744;';
                    }else{
                        enabledBtn.innerHTML = '&#9745;';
                    }

                    canvas.getAnnotationManager().toggleAnnotation(btnDef.annotCode);
                });

                row.appendChild(tooltipBtn);
                row.appendChild(enabledBtn);
                row.appendChild(btn);

                items.push(row);

                container.appendChild(row);

                if(activeAnnotations != null && activeAnnotations.exists(btnDef.label)){
                    canvas.getAnnotationManager().toggleAnnotation(btnDef.annotCode);

                    enabledBtn.innerHTML = '&#9745;';
                }
            }
        }
    }
}
