/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.blocks;

import saturn.client.programs.blocks.BaseScrollableCanvas.BaseCanvasEvent;
class GridVarCanvasRenderer extends BaseScrollableCanvas {
    var cellHeight : Float = 50;
    var cellWidth : Float = 50;
    var columnOrder : Array<String>;
    var data : Array<Dynamic>;

    var columnToLabel : Dynamic;
    var rowOrder : Array<String>;

    var xLabels : Array<String>;

    var valueToStyle : Map<String, Array<Style>>;

    var padding : Bool;

    var groupToStyles : Map<String, Map<String, Style>>;

    public function new(container){
        super(container);
    }

    public function setPadding(padding){
        this.padding = padding;
    }


    public function setStyles(styles : Map<String, Array<Style>>){
        valueToStyle = styles;
    }

    override public function renderData(){
        var ctx = getGraphCanvasContext();

        var labels = getXAxisLabels();

        var paddingCost = padding && theXUnitSize >1 ? 1 : 0;

        var height = theYUnitSize -1;

        for(j in 0...rowOrder.length){
            var row = rowOrder[j];

            var y = theGraphHeight + theTopMargin - (theYUnitSize * (j+1)) + 1;

            var startingX = null;
            var endX = null;
            var lastValue = '</NULL>';

            for(i in lastPosition...labels.length){
                var column = labels[i];

                var x = theLeftMargin + (theXUnitSize * (i - lastPosition)) + paddingCost;

                var lastPaint = false;

                if(x + theXUnitSize > theGraphWidth + theLeftMargin){
                    if(padding){
                        break;
                    }else{
                        lastPaint = true;
                    }
                }

                var value = data[i][j];

                var width;

                if(!padding){
                    if(lastValue == '</NULL>' && !lastPaint){
                        lastValue = value;
                        startingX = x;

                        continue;
                    }else{
                        if(lastValue == value && !lastPaint){
                            endX = x;

                            if(i != labels.length-1){
                                continue;
                            }
                        }

                        if(endX != null){
                            width = endX - startingX + theXUnitSize;
                        }else{
                            width = theXUnitSize;
                        }

                        var t = startingX;
                        var tv = lastValue;

                        lastValue = value;

                        startingX = x;
                        endX = null;

                        x = t;
                        value = tv;
                    }
                }else{
                    width = theXUnitSize - paddingCost;
                }

                if(valueToStyle.exists(value)){
                    for(style in valueToStyle.get(value)){
                        var match = false;
                        for(column in style.columns){
                            if(column == '*' || row == column){
                                match = true;
                                break;
                            }
                        }

                        if(!match){
                            continue;
                        }

                        if(style.type == 'rec'){
                            ctx.save();
                            ctx.beginPath();
                            //ctx.fillStyle = j % 2 == 0 ? 'orange': 'black';
                            ctx.strokeStyle = '';
                            ctx.fillStyle = style.colour;
                            ctx.fillRect(x, y - 1, width , height);
                            ctx.stroke();
                            ctx.restore();
                        }else if(style.type == 'line'){
                            ctx.save();
                            ctx.beginPath();
                            //ctx.fillStyle = j % 2 == 0 ? 'orange': 'black';
                            ctx.strokeStyle = style.colour;

                            var y = y + (theYUnitSize / 2) -1.5;

                            ctx.moveTo(x, y);
                            ctx.lineTo(x + width, y);

                            ctx.stroke();
                            ctx.restore();
                        }
                    }
                }

                if(lastPaint){
                    break;
                }
            }
        }
    }

    public function setCellHeight(height : Float){
        cellHeight = height;

        theYUnitSize = cellHeight;
    }

    public function setCellWidth(width : Float){
        cellWidth = width;

        theXUnitSize = width;
    }

    public function setColumnOrder(columnOrder){
        this.columnOrder = columnOrder;

        xLabels = null;
    }

    public function setData(data : Dynamic){
        this.data = data;
    }

    override public function getXAxisLabels() : Array<String>{
        if(xLabels == null){
            xLabels = [];
            for(column in columnOrder){
                xLabels.push(Reflect.field(columnToLabel, column));
            }
        }

        return xLabels;
    }

    override public function getYAxisLabels() : Array<String>{
        return rowOrder;
    }

    public function setColumnKeyToLabels(mapping : Dynamic){
        this.columnToLabel = mapping;

        xLabels = null;
    }

    public function setRowOrder(rowOrder : Array<String>){
        this.rowOrder = rowOrder;
    }

    override public function configureXReadingCounts(){
        theReadingsCount = Reflect.fields(columnToLabel).length;
    }

    override public function configureLongestYLabel(){
        theLongestYLabel = '';
        for(label in rowOrder){
            if(theLongestYLabel.length < label.length){
                theLongestYLabel = label;
            }
        }
    }

    override public function getGraphHeight() : Int{
        return Std.int(cellHeight * rowOrder.length);
    }

    override public function overlayEvent(event : BaseCanvasEvent){
        super.overlayEvent(event);

        var column = event.column;
        var ctx = headerCanvas.getContext2d();

        //var y  = theTopMargin;
        var y = 20;
        //var y  = event.offsetY;
        var x = event.offsetX;

        //column += lastPosition;

        if(columnOrder.length-1 < column){
            return ;
        }

        var overlayCtx = overlayCanvas.getContext2d();
        var overlayY = theTopMargin;

        overlayCtx.beginPath();
        overlayCtx.strokeStyle = 'black';
        overlayCtx.moveTo(event.offsetX, overlayY); //theTopMargin
        overlayCtx.lineTo(event.offsetX, overlayCanvas.height);
        overlayCtx.stroke();
        overlayCtx.closePath();

        ctx.clearRect(0,0, headerCanvas.width, headerCanvas.height);

        ctx.save();

        var centerLabel : CanvasLabel = {width: 0, x: 0, y: 0, font : '', label: ''};
        var leftLabel : CanvasLabel = {width: 0, x: 0, y: 0, font : '', label: ''};
        var leftPosLabel : CanvasLabel = {width: 0, x: 0, y: 0, font : '', label: ''};
        var rightLabel : CanvasLabel = {width: 0, x: 0, y: 0, font : '', label: ''};
        var rightPosLabel : CanvasLabel = {width: 0, x: 0, y: 0, font : '', label: ''};

        var labels = [centerLabel, leftLabel, leftPosLabel, rightLabel, rightPosLabel];

        //center label
        centerLabel.font = '18px Arial';
        ctx.font = centerLabel.font;
        centerLabel.label = Reflect.field(columnToLabel, Std.string(columnOrder[column]));
        centerLabel.width = ctx.measureText(centerLabel.label).width;
        centerLabel.x = x - (centerLabel.width/2);
        centerLabel.y = y -2;

        if(column-1 > -1){
            //leftLabel
            leftLabel.label = Reflect.field(columnToLabel, Std.string(columnOrder[column-1]));
            leftLabel.font = '10px Arial';
            ctx.font = leftLabel.font;
            leftLabel.width = ctx.measureText(leftLabel.label).width;
            leftLabel.x = centerLabel.x - leftLabel.width - 2;
            leftLabel.y = y -2;

            //leftLabelPos
            leftPosLabel.label = Std.string(Std.parseInt(columnOrder[column-1]) + 1);
            leftPosLabel.font = '8px Arial';
            ctx.font = leftPosLabel.font;
            leftPosLabel.width = ctx.measureText(leftPosLabel.label).width;
            leftPosLabel.x = leftLabel.x - leftPosLabel.width;
            leftPosLabel.y = leftLabel.y - 10;
        }

        if(column+1 < columnOrder.length){
            //rightLabel
            rightLabel.label = Reflect.field(columnToLabel, Std.string(columnOrder[column+1]));
            rightLabel.font = '10px Arial';
            ctx.font = rightLabel.font;
            rightLabel.width = ctx.measureText(rightLabel.label).width;
            rightLabel.x = centerLabel.x + centerLabel.width + 2;
            rightLabel.y = y -2;


            //rightLabelPos
            rightPosLabel.label = Std.string(Std.parseInt(columnOrder[column+1]) + 1);
            rightPosLabel.font = '8px Arial';
            ctx.font = rightPosLabel.font;
            rightPosLabel.width = ctx.measureText(rightPosLabel.label).width;
            rightPosLabel.x = rightLabel.x + rightLabel.width;
            rightPosLabel.y = rightLabel.y -  10;
        }

        var bStart = leftPosLabel.x;
        var bEnd = x + centerLabel.width + rightLabel.width + rightPosLabel.width;

        ctx.save();
        ctx.fillStyle = 'rgba(255,255,255,0.8)';
        //ctx.setFillColor(255,255,255, 0.8);
        ctx.fillRect(bStart, y - 20, bEnd - bStart, 20);
        ctx.restore();

        ctx.fillStyle = 'black';

        for(label in labels){
            if(label.width > 0){
                ctx.font = label.font;
                ctx.fillText(label.label, label.x, label.y);
            }
        }

        ctx.restore();
    }

    override public function configureKeyCanvasDimensions() {
        keyCanvasRequiredHeight = 60;

        groupToStyles = new Map<String, Map<String, Style>>();

        for(value in valueToStyle.keys()){
            for(style in valueToStyle.get(value)){
                if(!groupToStyles.exists(style.group)){
                    groupToStyles.set(style.group, new Map<String, Style>());
                }

                var key = style.name + '~' + style.type + '~' + style.colour;

                if(!groupToStyles.get(style.group).exists(key)){
                    groupToStyles.get(style.group).set(key, style);
                }
            }
        }

        var canvas : js.html.CanvasElement = cast js.Browser.document.createElement('canvas');
        canvas.style.position = 'absolute';
        canvas.style.left = '-100px';
        canvas.style.top = '-100px';

        canvas.width = 100;
        canvas.height = 100;

        js.Browser.document.body.appendChild(canvas);

        var width = getContainerWidth() - theLeftMargin - theRightMargin;

        var sep = 6;
        var boxSize = 10;

        var yPos = 2;

        var ctx = canvas.getContext2d();

        for(group in groupToStyles.keys()){
            var xPos = theLeftMargin;

            var metrics = ctx.measureText(group);

            yPos += 12;

            for(styleKey in groupToStyles.get(group).keys()){
                var style = groupToStyles.get(group).get(styleKey);

                /*var colStr = style.columns.join(',');

                if(colStr == '*'){
                    colStr = '';
                }*/

                var colStr = '';

                var label = style.name + ' ' + colStr;
                var metrics = ctx.measureText(label);

                var totalWidth = xPos + metrics.width + boxSize + sep;

                if(totalWidth > width){
                    xPos = theLeftMargin;

                    yPos += 12;
                }

                xPos += boxSize + sep;

                xPos += metrics.width + sep;
            }

            yPos += 12;
        }

        js.Browser.document.body.removeChild(canvas);

        keyCanvasRequiredHeight = yPos;
    }

    override public function renderKey(){
        super.renderKey();

        var width = getContainerWidth() - theLeftMargin - theRightMargin;

        var sep = 6;
        var boxSize = 10;

        var yPos = 2;

        var ctx = getKeyCanvasContext();

        for(group in groupToStyles.keys()){
            var xPos = theLeftMargin;

            ctx.save();
            ctx.fillText(group, xPos, yPos + 10);

            var metrics = ctx.measureText(group);

            ctx.moveTo(xPos, yPos);
            ctx.lineTo(xPos + metrics.width, yPos);
            ctx.restore();

            yPos += 12;

            for(styleKey in groupToStyles.get(group).keys()){
                var style = groupToStyles.get(group).get(styleKey);

                /*var colStr = style.columns.join(',');

                if(colStr == '*'){
                    colStr = '';
                }*/

                var colStr = '';

                var label = style.name + ' ' + colStr;

                var metrics = ctx.measureText(label);

                var totalWidth = xPos + metrics.width + boxSize + sep;

                if(totalWidth > width){
                    xPos = theLeftMargin;

                    yPos += 12;
                }

                if(style.type == 'rec'){
                    ctx.save();
                    ctx.fillStyle = style.colour;
                    ctx.fillRect(xPos, yPos, boxSize, boxSize);
                    ctx.restore();
                }

                xPos += boxSize + sep;

                ctx.fillText(label, xPos, yPos + 10);

                xPos += metrics.width + sep;
            }

            yPos += 12;
        }
    }
}

typedef Style = {
    var type : String;
    var colour : String;
    var name : String;
    var columns: Array<String>;
    var value : String;
    var group : String;
}

typedef CanvasLabel = {
    var width : Float;
    var label : String;
    var x : Float;
    var y : Float;
    var font : String;
}
