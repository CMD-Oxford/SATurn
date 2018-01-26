/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.sequenceeditor;

import js.html.CanvasElement;
import saturn.client.programs.sequenceeditor.AnnotationEditorBlock;

import js.html.CanvasRenderingContext2D;

class CanvasAnnotationBlock extends AnnotationEditorBlock{
    var theCanvas : js.html.CanvasElement;

    override private function createElement(){
        theCanvas = js.Browser.document.createCanvasElement();
        theCanvas.height = 17;
        elem = theCanvas;
    }

    override private function initialise(blockNumber : Int) {
        super.initialise(blockNumber);

        theCanvas.setAttribute('width',theCanvas.style.width);
        theCanvas.setAttribute('height','17px');

        var ctx : CanvasRenderingContext2D=theCanvas.getContext("2d");

        var width = theCanvas.width;

        var charWidth = width / getSequenceEditor().blockSize;

        var xPos = 0.;
        var yPos = Math.round(theCanvas.height)+0.5;

        while(xPos < width){
            ctx.beginPath();
            xPos = Math.round(xPos + charWidth) + 0.5;
            ctx.lineWidth=1;
            ctx.moveTo(xPos,0);
            ctx.lineTo(xPos,yPos);
            ctx.stroke();
            ctx.closePath();
        }

        ctx.beginPath();
        var yCenterPos = yPos/2;
        ctx.moveTo(0,yCenterPos);
        ctx.lineTo(width,yCenterPos);
        ctx.stroke();
        ctx.closePath();
    }

    public function getCanvas() : CanvasElement{
        return theCanvas;
    }
}
