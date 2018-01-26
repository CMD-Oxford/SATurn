/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.plugins;

import saturn.client.ProgramPlugin;
import js.html.CanvasRenderingContext2D;
import saturn.client.programs.sequenceeditor.AnnotationEditorBlock;
import saturn.client.programs.sequenceeditor.CanvasAnnotationBlock;
import saturn.client.ProgramPlugin.BaseProgramPlugin;

import saturn.client.programs.sequenceeditor.SequenceEditor;

class AnnotationPlugin extends BaseProgramPlugin<SequenceEditor> implements SequenceChangeListener{
    override public function onFocus() : Void {
		super.onFocus();
		
		var program : SequenceEditor = getProgram();
        program.addAnnotation('Test Annotation');
        program.setAnnotationClass('Test Annotation',CanvasAnnotationBlock);
	}

    override public function setProgram(program : SequenceEditor) : Void {
        super.setProgram(program);
        program.addSequenceChangeListener(this);
    }

    public function sequenceChanged(sequence:String):Void {
        var program : SequenceEditor = getProgram();

        var blocks : Array<AnnotationEditorBlock> = program.getAnnotationBlocks('Test Annotation');

        var aC = 'rgb(0,255,0)';
        var tC = 'rgb(255,0,0)';
        var gC = 'rgb(0,0,255)';
        var cC = 'rgb(125,125,125)';

        var pos = 0;

        for(block in blocks){
            var canvasBlock = cast(block,CanvasAnnotationBlock);
            var canvas = canvasBlock.getCanvas();

            var ctx : CanvasRenderingContext2D=canvas.getContext("2d");

            ctx.clearRect(0,0,canvas.width,canvas.height);

            var width = canvas.width;

            var charWidth = program.getDefaultCharWidth();//+0.045;

            var xPos = 0.;
            var yPos = Math.round(canvas.height)+0.5;

            var charsDone = 0;
            while(charsDone < program.blockSize){
                charsDone++;
                var char = sequence.charAt(pos++);

                var c;

                switch( char ) {
                    case 'A':
                        c = aC;
                    case 'T':
                        c = tC;
                    case 'C':
                        c = cC;
                    case 'G':
                        c = gC;
                    default:
                        c=aC;
                }

                ctx.beginPath();
                //xPos = Math.round(xPos + charWidth);
                xPos = xPos + charWidth;
                ctx.lineWidth=1;
                ctx.moveTo(xPos+0.5,0);
                ctx.lineTo(xPos+0.5,yPos);
                ctx.strokeStyle = c;
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
    }
}
