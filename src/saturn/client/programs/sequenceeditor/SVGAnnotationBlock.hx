/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.sequenceeditor;

import jQuery.JQuery;
import js.html.CanvasElement;
import saturn.client.programs.sequenceeditor.AnnotationEditorBlock;

import js.html.CanvasRenderingContext2D;

import js.html.svg.Rect;
import js.html.svg.SVGElement;

class SVGAnnotationBlock extends AnnotationEditorBlock{
    var theCanvas : js.html.Element;

    override private function createElement(){
        //theCanvas = new js.html.svg.SVGElement();
        theCanvas = js.Browser.document.createElementNS("http://www.w3.org/2000/svg","svg");
        //theCanvas.height = 17;
        new JQuery(theCanvas).addClass('molbio-sequenceeditor-block');
        theCanvas.setAttribute('style', theCanvas.style + ';margin-top:2px;margin-left:2px;margin-right:2px');
        ////theCanvas.className = theCanvas.className + " molbio-sequenceeditor-block";
        elem = theCanvas;
    }

    override private function initialise(blockNumber : Int) {
        super.initialise(blockNumber);

        theCanvas.setAttribute('width',theCanvas.style.width);
        theCanvas.setAttribute('height','30');
        //theCanvas.setAttribute('viewBox','0 0 ' + theCanvas.style.width + ' 17');
    }

    public function getCanvas() : js.html.Element{
        return theCanvas;
    }

    /**
    * clear method removes all SVG content and paints a white rectangle across
    * the SVG to prevent ghosting of deleted elements with older versions of
    * WebKit.
    **/
    public function clear(fillStyle){
        var canvas = getCanvas();

        if(canvas.children != null){
            var foo = canvas;

            while (foo.firstChild != null){
                foo.removeChild(foo.firstChild);
            }
        }

        /**
        * Scarab's WebKit has a bug which causes ghosting of deleted SVG
        * elements.  By painting a white box across the whole image the
        * ghosting disappears
        **/
        var rect = js.Browser.document.createElementNS("http://www.w3.org/2000/svg", 'rect');
        rect.setAttribute('width', canvas.getAttribute('width'));
        rect.setAttribute('height', canvas.getAttribute('height'));
        rect.setAttribute('style', 'fill:'+fillStyle);

        canvas.appendChild(rect);
    }

    public function setHeight(height: String){
        theCanvas.style.height = height;
        theCanvas.parentElement.style.height = height;
    }
}
