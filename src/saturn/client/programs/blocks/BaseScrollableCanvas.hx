/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.blocks;

import saturn.client.workspace.Workspace;
import saturn.client.WorkspaceApplication;
import bindings.Ext;

class BaseScrollableCanvas {
    var graphCanvas : js.html.CanvasElement = null;
    var scrollCanvas : js.html.CanvasElement = null;
    var overlayCanvas : js.html.CanvasElement = null;
    var annotationCanvas : js.html.CanvasElement = null;
    var xaxisCanvas : js.html.CanvasElement = null;
    var headerCanvas : js.html.CanvasElement = null;
    var keyCanvas : js.html.CanvasElement = null;

    var container : Dynamic;

    var defaultReadingSeparation = 2; //Pixel separation between readings on the x axis
    var defaultDrawingHeight = 300; //default drawing height of a canvas element
    var maximumCanvasWidth = 30000; //default drawing width of a canvas element

    var drawingHeight = -1;
    var drawingWidth = -1;

    var lastPosition = 0;

    //Margins
    var theMaxIntensity = -1;

    var theLeftMargin : Float;
    var theRightMargin : Float;
    var theTopMargin : Float;
    var theBottomMargin : Float;

    //Unit sizes
    var theXUnitSize : Float;
    var theYUnitSize : Float;

    //Dimensions
    var theGraphWidth : Float;
    var theGraphHeight : Float;
    var theTotalWidth : Float;

    //y axis interval divisions
    var theYIntervalDivisions : Float;

    //number of readings / x units
    var theReadingsCount : Int;

    var theLastScrollBarXPos : Float;
    var theLastScrollBarYPos : Float;

    var theScrollBarBoxHeight : Float;
    var theScrollBarBoxWidth : Float;

    var theStartingXPosition : Float;

    var theViewPortXUnits : Int = 0;
    var theLastXPosition : Int = 0;

    var theLongestYLabel : String;

    var showXAxisLabels : Bool;
    var showXTicks : Bool;

    var renderSVG : Bool = false;
    var svgGraphCanvas : js.html.CanvasRenderingContext2D;

    var fitToArea : Bool = false;

    var theXInternalDivisions : Int;

    var keyCanvasRequiredHeight : Int;

    public var lines : Array<Line>;

    public function new(container){
        this.container = container;

        lines = new Array<Line>();
    }

    public function getXUnitSize(){
        return theXUnitSize;
    }

    public function setFitToArea(fitToArea : Bool){
        this.fitToArea = fitToArea;
    }

    public function render(){
        renderScrollBar();

        installScrollBarListeners();

        updateGraphArea();
    }

    public function updateGraphArea(){
        renderGraph();

        renderXAxis();

        renderXLabels();

        renderYAxis();

        renderYAxisLabels();

        renderKey();
    }

    public function renderKey(){
        getKeyCanvasContext().clearRect(0, 0, keyCanvas.width, keyCanvas.height);
    }

    public function renderGraph(){
        if(lastPosition > theLastXPosition){
            lastPosition = theLastXPosition;
        }

        //fetch dimensions
        var width = graphCanvas.width;
        var height = graphCanvas.height;

        //fetch canvas context
        var ctx = graphCanvas.getContext2d();

        ctx.clearRect(0,0, width, height);

        renderData();

        var lastIPosition = 0;

        var lineX1 :Float = -1;
        var lineY1 :Float = -1;

        var lineX2 :Float  = -1;
        var lineY2 :Float = -1;

        var overlayCtx = overlayCanvas.getContext2d();
        overlayCtx.clearRect(0,0, overlayCanvas.width, overlayCanvas.height);

        var annotationCtx : Dynamic = getAnnotationContext();
        annotationCtx.clearRect(0,0, annotationCanvas.width, annotationCanvas.height);

        paintLines();
    }

    public function renderData(){

    }

    public function renderXAxis(){
        //fetch canvas context
        var ctx = getXGraphCanvasContext();

        //render x axis
        ctx.save();
        ctx.beginPath();
        ctx.lineWidth = 1;
        //theTopMargin + theGraphHeight + 2
        ctx.moveTo(theLeftMargin -1, 0); //-1 to remove overhang caused by y being 2px wide
        //theTopMargin + theGraphHeight + 2
        ctx.lineTo(theLeftMargin + theGraphWidth -1, 0);
        ctx.stroke();
        ctx.restore();
    }

    public function renderYAxis(){
        //fetch canvas context
        var ctx = getGraphCanvasContext();

        //render x axis
        ctx.save();
        ctx.beginPath();
        ctx.lineWidth = 1;
        //theTopMargin + theGraphHeight + 2
        ctx.moveTo(theLeftMargin -0.5, theTopMargin); //-1 to remove overhang caused by y being 2px wide
        //theTopMargin + theGraphHeight + 2
        ctx.lineTo(theLeftMargin -0.5, theGraphHeight + theTopMargin);
        ctx.stroke();
        ctx.restore();
    }

    public function renderYAxisLabels(){
        //Fetch canvas context
        var ctx = getGraphCanvasContext();

        //Fetch labels
        var labels = getYAxisLabels();

        //Fetch font metrics for "M" (used to center text)
        var mMetrics = ctx.measureText('M');

        //Iterate labels
        for(i in 0...labels.length){
            //Fetch label
            var label = labels[i];

            //Calculate bottom y of box
            var y_pos = theYUnitSize * i;

            /* Vertically center label */
            //Center of box = y_pos + (theYUnitSize / 2)
            //Center of text = mMetrics.width/2 (based on M being the same width and height)
            y_pos = y_pos + (theYUnitSize / 2) - (mMetrics.width/2);

            var yLabelMetrics = ctx.measureText(Std.string(label));

            //x -2 to account for shift in y axis by -2px across
            //y -2 to account for shift in y axis by -2 px down
            //y -2 as theLeftMargin has an extra 2 px to push trace zero point next to y line and not on it
            ctx.fillText(label, theLeftMargin - yLabelMetrics.width -2 -2, theGraphHeight + theTopMargin - y_pos -1);
        }
    }

    public function setRenderXLabels(render){
        this.showXAxisLabels = render;
    }

    public function renderXLabels(){
        //fetch canvas context
        var ctx = getXGraphCanvasContext();

        ctx.clearRect(0, 3, xaxisCanvas.width,20); // 10

        showXTicks = true;

        if(showXTicks){
            var j = lastPosition;

            var tickDivisions = 10;

            var magnitude = Math.pow(tickDivisions, Math.floor(Math.log(theGraphWidth / theXUnitSize) / Math.log(tickDivisions)));

            var x = theLeftMargin + (theXUnitSize/2);

            for(i in lastPosition...theReadingsCount){
                var pos = i + 1;
                if(x > theGraphWidth + theLeftMargin){
                    break;
                }else if(pos == 1 || pos % magnitude == 0){
                    var posStr = Std.string(pos);

                    var metrics = ctx.measureText(posStr);

                    ctx.fillText(posStr, x - (metrics.width/2), 10);
                }

                x += theXUnitSize;
            }
        }

        if(showXAxisLabels){
            var labels = getXAxisLabels();
            for(i in lastPosition...labels.length){
                var correctedI = i - lastPosition;

                var label = labels[i];

                var metrics = ctx.measureText(label);

                var x_pixel_pos = cast((theXUnitSize * correctedI)  + theLeftMargin, Float);

                if(x_pixel_pos + theXUnitSize > theGraphWidth + theLeftMargin){
                    break;
                }

                x_pixel_pos = x_pixel_pos + (theXUnitSize / 2) - (metrics.width / 2);

                ctx.fillText(labels[i], x_pixel_pos, 20);//10
            }
        }
    }

    public function getXAxisLabels() : Array<String>{
        return [];
    }

    public function getXAxisCanvasHeight(){
        return 25;
    }

    public function getScrollCanvasHeight(){
        return getScrollBoxHeight();
    }

    public function getScrollBoxHeight(){
        return 35;
    }

    public function getBottomPanelHeight(){
        return getScrollCanvasHeight() + getXAxisCanvasHeight();
    }

    public function configureXReadingCounts(){
        //set reading count
        theReadingsCount = 1000;
    }

    public function getYAxisLabels() : Array<String>{
        return [];
    }

    public function configure(){
        //initialise margins
        theTopMargin = 0;

        recreateCanvasElements();

        //fetch dimensions
        var width = graphCanvas.width;
        var height = graphCanvas.height;

        configureXReadingCounts();
        configureLongestYLabel();


        //fetch canvas context
        var ctx = graphCanvas.getContext2d();

        //fetch text metrics for largetest y axis label
        var yTextMetrics = ctx.measureText(Std.string(theLongestYLabel));


        theBottomMargin = 0;

        //initialise left margin and allow for y axis label
        theLeftMargin = 5 + yTextMetrics.width + 2;
        theRightMargin = 20;

        //initialise graphing area height
        theGraphHeight = height - theTopMargin - theBottomMargin;

        //initialise graphing area weidth
        theGraphWidth = width - theLeftMargin - theRightMargin;

        //determine pixels per y unit
        //theYUnitSize = theGraphHeight / cast(maximumYValue, Float);

        if(showXAxisLabels){
            var metrics = ctx.measureText('M');

            if(fitToArea || theXUnitSize < metrics.width){
                theXUnitSize = metrics.width;
            }
        }else if(fitToArea){
            theXUnitSize = theGraphWidth / theReadingsCount;
        }

        theTotalWidth = theXUnitSize * theReadingsCount;

        theViewPortXUnits = Std.int(theGraphWidth / theXUnitSize);
        theLastXPosition = Std.int(theReadingsCount - theViewPortXUnits);

        if(theLastXPosition < 0){
            theLastXPosition = 0;
        }

        lastPosition = 0;

        theXInternalDivisions = Std.int(theViewPortXUnits / 10);
    }

    public function configureLongestYLabel(){
        theLongestYLabel = 'Hello World';
    }

    public function recreateCanvasElements(){
        removeCanvasElements();
        createCanvasElements();
    }

    public function removeCanvasElements(){
        var container : js.html.Element = getDomElement();

        if(getGraphCanvas() != null){
            container.removeChild(getGraphCanvas());
        }

        if(getScrollCanvas() != null){
            container.removeChild(getScrollCanvas());
        }

        if(getOverlayCanvas() != null){
            container.removeChild(getOverlayCanvas());
        }

        if(getAnnotationCanvas() != null){
            container.removeChild(getAnnotationCanvas());
        }
    }

    public function getDomElement() : js.html.Element{
        return container;
    }

    public function getGraphCanvas() : js.html.CanvasElement{
         return graphCanvas;
    }

    public function getAnnotationCanvas() : js.html.CanvasElement {
        return annotationCanvas;
    }

    public function getGraphCanvasContext() : js.html.CanvasRenderingContext2D {
        if(renderSVG){
            return svgGraphCanvas;
        }else{
            return graphCanvas.getContext2d();
        }
    }

    public function getKeyCanvasContext(): js.html.CanvasRenderingContext2D {
        if(renderSVG){
            return svgGraphCanvas;
        }else{
            return keyCanvas.getContext2d();
        }
    }

    public function getXGraphCanvasContext() : js.html.CanvasRenderingContext2D {
        if(renderSVG){
            return svgGraphCanvas;
        }else{
            return xaxisCanvas.getContext2d();
        }
    }

    public function getScrollCanvas() : js.html.CanvasElement{
        return scrollCanvas;
    }

    public function getOverlayCanvas() : js.html.CanvasElement{
        return overlayCanvas;
    }

    public function getAnnotationContext(): js.html.CanvasRenderingContext2D {
        if(renderSVG){
            return svgGraphCanvas;
        }else{
            return annotationCanvas.getContext2d();
        }
    }

    public function createCanvasElements(){
        configureKeyCanvasDimensions();

        keyCanvas = cast js.Browser.document.createElement('canvas');
        keyCanvas.width = getContainerWidth();
        keyCanvas.height = getKeyCanvasHeight();

        headerCanvas = cast js.Browser.document.createElement('canvas');
        headerCanvas.width = getContainerWidth();
        headerCanvas.height = 20;

        container.appendChild(keyCanvas);
        container.appendChild(headerCanvas);

        var canvasContainer = js.Browser.document.createElement('div');
        canvasContainer.style.overflowY = 'auto';

        var availableHeight = container.clientHeight - getBottomPanelHeight() - getTopCanvasHeight() - getKeyCanvasHeight();

        var requiredHeight = getGraphHeight() + theTopMargin;

        canvasContainer.style.height = Std.string(Math.min(availableHeight, requiredHeight) + 'px'); //Std.string(container.clientHeight - getBottomPanelHeight()) + 'px';

        container.appendChild(canvasContainer);

        var scrollContainer = js.Browser.document.createElement('div');
        //scrollContainer.style.height = '10%';

        container.appendChild(scrollContainer);

        graphCanvas = cast js.Browser.document.createElement('canvas');

        var width = container.style.width;

        graphCanvas.width = getContainerWidth();
        graphCanvas.height = Std.int(getGraphHeight() + theTopMargin);

        overlayCanvas = cast js.Browser.document.createElement('canvas');
        overlayCanvas.width = getContainerWidth();
        overlayCanvas.height = Std.int(getGraphHeight() + theTopMargin);
        overlayCanvas.style.position = 'relative';
        overlayCanvas.style.background = 'transparent';

        var offset = Std.int(getGraphHeight() + theTopMargin);

        overlayCanvas.style.marginTop = '-' + offset + 'px';

        annotationCanvas = cast js.Browser.document.createElement('canvas');
        annotationCanvas.width = getContainerWidth();
        annotationCanvas.height = Std.int(getGraphHeight() + theTopMargin);
        annotationCanvas.style.position = 'relative';

        annotationCanvas.style.marginTop = '-' + offset + 'px';
        annotationCanvas.style.background = 'transparent';

        scrollCanvas = cast js.Browser.document.createElement('canvas');

        scrollCanvas.width = getContainerWidth();
        scrollCanvas.height = getScrollCanvasHeight();
        scrollCanvas.style.display = 'block';

        canvasContainer.appendChild(graphCanvas);
        canvasContainer.appendChild(annotationCanvas);
        canvasContainer.appendChild(overlayCanvas);


        //X Axis container
        xaxisCanvas = cast js.Browser.document.createElement('canvas');
        xaxisCanvas.width = getContainerWidth();
        xaxisCanvas.height = getXAxisCanvasHeight();
        xaxisCanvas.style.display = 'block';

        scrollContainer.appendChild(xaxisCanvas);

        scrollContainer.appendChild(scrollCanvas);

        installOverlayListeners();

        //Possible performance issue below


    }

    public function getTopCanvasHeight(){
        return 20;
    }

    public function getKeyCanvasHeight() {
        return keyCanvasRequiredHeight;
    }

    public function installOverlayListeners(){
        var fireOverlayEvent = function(e, clicked : Bool = false){
            var ne : BaseCanvasEvent = convertToBaseCanvasEvent(e);
            ne.clicked = clicked;

            var ctx = overlayCanvas.getContext2d();

            ctx.clearRect(0,0, overlayCanvas.width, overlayCanvas.height);

            if(ne.offsetX < theLeftMargin || ne.offsetX > theGraphWidth + theLeftMargin){
                return;
            }

            overlayEvent(ne);
        };

        overlayCanvas.onmousemove = function(e){fireOverlayEvent(e, false);};
        overlayCanvas.onmouseup = function(e){fireOverlayEvent(e, true);};
    }

    /**
    * getColumnFromEvent - returns the column "event" occurred in
    *
    * event : Dynamic - Event instance
    **/
    private function getColumnFromEvent(event : Dynamic) : Int{
        var column = Std.int((event.offsetX - theLeftMargin) / theXUnitSize);

        column += lastPosition;

        return column;
    }

    /**
    * getRowFromEvent - returns the row "event" occurred in
    *
    * event : Dynamic = Event instance
    **/
    private function getRowFromEvent(event : Dynamic) : Int{
        var row = Std.int((event.offsetY - theTopMargin) / theYUnitSize);

        return row;
    }

    /**
    * markEvent - Place a line where the "event" occurred
    **/
    public function markEvent(event : BaseCanvasEvent, colour : String = 'red'){
        mark(event.column, event.row, colour);

        var annotationCtx : Dynamic = getAnnotationContext();

        annotationCtx.clearRect(0,0, getAnnotationCanvas().width, getAnnotationCanvas().height);

        paintLines();
    }

    /**
    * mark - Place a vertical line at the specified column and row
    *
    * column : Int = Column to mark
    * row : Int = Row to mark
    * colour : String = Colour to mark line (default red)
    **/
    public function mark(column : Int, row : Int = null, colour : String = 'red'){
        var removed = false;
        for(line in lines){
            if(line.column == column && line.row == row){
                var l = lines.length;
                lines.remove(line);

                removed = true;

                break;
            }
        }

        if(!removed){
            lines.push({colour : colour, column : column, row: row});
        }

        WorkspaceApplication.getApplication().debug('Lines: ' + lines.length);
    }

    private function paintLines(){
        var annotationCtx : Dynamic = getAnnotationContext();

        for(line in lines){

            if(line.column < lastPosition){
                continue;
            }

            var x = theLeftMargin + ((line.column - lastPosition) * theXUnitSize) + (theXUnitSize / 2);
            var y1 = theTopMargin + (theYUnitSize * (line.row+1)) -1;
            var y2 = theTopMargin + (theYUnitSize * line.row);

            annotationCtx.beginPath();
            annotationCtx.strokeStyle = line.colour;
            annotationCtx.moveTo(x, y1); //theTopMargin
            annotationCtx.lineTo(x, y2);
            annotationCtx.stroke();
            annotationCtx.closePath();
        }
    }

    public function overlayEvent(event : BaseCanvasEvent){
        if(event.clicked && event.button == 0){
            markEvent(event);
        }
    }

    public function getContainerHeight() : Int {
        var height = container.style.clientHeight;

        if(height == null){
            return container.parentElement.style.clientHeight;
        }else{
            return height;
        }
    }

    public function getGraphHeight() : Int{
        return 300;
    }

    public function getContainerWidth(){
        return Std.int(container.clientWidth - 40);
    }

    public function onFocus() : Void{

    }

    public function onBlur() : Void{

    }

    public function renderScrollBar(?moveX : Float, ?forwards : Bool){
        //fetch dimensions
        var width = scrollCanvas.width;
        var height = scrollCanvas.height;

        var ctx = scrollCanvas.getContext2d();

        ctx.clearRect(0,0, width, height);

        if(theGraphWidth >= theTotalWidth){
            return;
        }

        var shownRatio = theGraphWidth / theTotalWidth;

        var padding = 5;

        var rectWidth = (theGraphWidth-(padding*2)) * shownRatio;

        ctx.save();
        ctx.beginPath();
        ctx.strokeStyle = 'black';
        ctx.rect(theLeftMargin,0, theGraphWidth, getScrollBoxHeight());
        ctx.stroke();
        ctx.restore();

        theScrollBarBoxWidth = rectWidth;
        theScrollBarBoxHeight = height-(padding*2);

        var leftStop = padding + theLeftMargin;
        var rightStop = width - theRightMargin - theScrollBarBoxWidth - padding;

        if(moveX != null){
            if(forwards){
                theLastScrollBarXPos = theLastScrollBarXPos + moveX;
            }else{
                theLastScrollBarXPos = theLastScrollBarXPos - moveX;
            }

            if(theLastScrollBarXPos < leftStop){
                theLastScrollBarXPos = leftStop;
            }else if(theLastScrollBarXPos > rightStop){
                theLastScrollBarXPos = rightStop;
            }
        }else{
            if(lastPosition > 0){
                var progress = lastPosition / theReadingsCount;

                theLastScrollBarXPos = (theGraphWidth * progress) + theLeftMargin;
                theLastScrollBarYPos = padding;
            }else{
                theLastScrollBarXPos = leftStop;
                theLastScrollBarYPos = padding;
            }

            if(theLastScrollBarXPos < leftStop){
                theLastScrollBarXPos = leftStop;
            }else if(theLastScrollBarXPos > rightStop){
                theLastScrollBarXPos = rightStop;
            }
        }

        ctx.save();
        ctx.beginPath();
        ctx.strokeStyle = 'blue';
        ctx.rect(theLastScrollBarXPos,theLastScrollBarYPos ,theScrollBarBoxWidth, theScrollBarBoxHeight);
        ctx.fill();
        ctx.restore();
    }

    public function installScrollBarListeners(){
        var isInHitBox = function(e){
            return e.offsetX >= theLastScrollBarXPos && e.offsetX <= theLastScrollBarXPos + theScrollBarBoxWidth &&
                    e.offsetY >= theLastScrollBarYPos && e.offsetY <= theLastScrollBarYPos + theScrollBarBoxHeight;
        }

        var lastX : Float = theLeftMargin + 10;//theLeftMargin;
        var lastY : Float = 0;

        var onMouseMove = function(e : Dynamic){
            e = convertToBaseCanvasEvent(e);
            //if(isInHitBox(e)){
                var forwards = true;

                var diff = theReadingsCount - lastPosition;

                if(e.offsetX < lastX){
                    forwards = false;
                }else{
                   // if(theXUnitSize * diff <= theGraphWidth){
                   //     return;
                   // }
                }

                var xMove = Math.abs(lastX - e.offsetX);

                var xScrollUnits = (theGraphWidth - 10) / theReadingsCount; //-10

                var numRequested = Math.ceil(xMove/xScrollUnits);

                lastX = e.offsetX;
                lastY = e.offsetY;

                var oldLastPosition = lastPosition;

                if(forwards){
                    lastPosition += numRequested;
                }else{
                    lastPosition -= numRequested;
                }

                if(lastPosition < 0){
                    lastPosition =0;
                }

                renderScrollBar();

                js.Browser.window.console.log('lastX: ' + lastX + '/' + e.offsetX );





                js.Browser.window.console.log('xMove: ' + xMove + '/' + xScrollUnits);

                js.Browser.window.console.log('Moved: ' + numRequested);

                /*else if(lastPosition > a){
                    lastPosition = a;
                }*/

                if(lastPosition != oldLastPosition){
                    updateGraphArea();
                }
            //}
        }

        scrollCanvas.onmousedown = function(evt){
            var e :Dynamic = convertToBaseCanvasEvent(evt);

            if(isInHitBox(e)){
                lastX = e.offsetX;
                lastY = e.offsetY;

                scrollCanvas.onmousemove = onMouseMove;
            }else{
                onMouseMove(evt);
            }
        };

        scrollCanvas.onmouseup = function(e){
            scrollCanvas.onmousemove = null;
        };
    }

    /**
    * getNormalisedEvent returns event x, y positions of the event normalised
    * to account for differences between web-browsers implementations of clientX
    **/
    inline function convertToBaseCanvasEvent(e : Dynamic) : BaseCanvasEvent{
        var ne :BaseCanvasEvent = {offsetX:0., offsetY:0., column: 0, row: 0, source : null, button: -1, clicked: false};

        if(e == null){
            e = new js.html.Event('');
        }

        //http://www.jacklmoore.com/notes/mouse-position/
        var target :Dynamic = e.target ? e.target : e.srcElement;

        var rect = target.getBoundingClientRect();

        ne.offsetX = e.clientX - rect.left;
        ne.offsetY = e.clientY - rect.top;

        ne.column = getColumnFromEvent(ne);
        ne.row = getRowFromEvent(ne);

        ne.source = e;

        ne.button = e.button;

        return ne;
    }

    public function exportSVG(){
        var height = getKeyCanvasHeight() + getXAxisCanvasHeight() + getGraphHeight() + theTopMargin;
        var width = theLeftMargin + (theXUnitSize * theReadingsCount) + theRightMargin;

        svgGraphCanvas = untyped __js__('new C2S(width,height)');
        renderSVG = true;

        var canvasWidth = theGraphWidth;
        var originalLastPosition = lastPosition;

        lastPosition = 0;

        theGraphWidth = theXUnitSize * theReadingsCount;

        renderKey();
        getGraphCanvasContext().save();
        getGraphCanvasContext().translate(0, getKeyCanvasHeight());

        renderYAxis();
        renderYAxisLabels();
        renderData();
        paintLines();
        getGraphCanvasContext().restore();

        getGraphCanvasContext().save();
        getGraphCanvasContext().translate(0, getKeyCanvasHeight() + theGraphHeight + theTopMargin);

        renderXAxis();
        renderXLabels();

        getGraphCanvasContext().restore();

        renderSVG = false;

        var d : Dynamic = cast svgGraphCanvas;

        WorkspaceApplication.getApplication().saveTextFile(d.getSerializedSvg(true), 'Test.svg');

        theGraphWidth = canvasWidth;
        lastPosition = originalLastPosition;
    }

    public function configureKeyCanvasDimensions() {

    }

    public function getKeyCanvas(){
        return keyCanvas;
    }
}

typedef BaseCanvasEvent = {
    var offsetX : Float;
    var offsetY : Float;
    var column : Int;
    var row : Int;
    var source : Dynamic;
    var button : Int;
    var clicked : Bool;
};

typedef Line = {
    var colour : String;
    var column : Int;
    var row : Int;
}
