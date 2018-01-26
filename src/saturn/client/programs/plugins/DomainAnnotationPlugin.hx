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
import saturn.core.domain.SgcDomain;
import saturn.core.domain.SgcSeqData;
import saturn.core.domain.SgcTarget;
import saturn.core.Protein;
import saturn.client.workspace.ProteinWorkspaceObject;
import js.html.CanvasRenderingContext2D;
import saturn.client.programs.sequenceeditor.AnnotationEditorBlock;
import saturn.client.programs.sequenceeditor.CanvasAnnotationBlock;
import saturn.client.ProgramPlugin.BaseProgramPlugin;

import saturn.client.programs.sequenceeditor.SequenceEditor;

class DomainAnnotationPlugin extends BaseProgramPlugin<SequenceEditor> implements SequenceChangeListener{
    override public function onFocus() : Void {
		super.onFocus();
	}

    override public function setProgram(program : SequenceEditor) : Void {
        super.setProgram(program);
        program.addSequenceChangeListener(this);

        program.addAnnotation('Pfam');
        program.setAnnotationClass('Pfam',CanvasAnnotationBlock);
    }

    override public function destroy(){
        var seqProg : SequenceEditor = cast theProgram;
        seqProg.removeSequenceChangeListener(this);

        super.destroy();
    }

    public function paintDomains(domains: Array<SgcDomain>, sequence:String){
        var program : SequenceEditor = getProgram();

        var orderedDomains :Array<SgcDomain> = new Array<SgcDomain>();

        var domainToLevel = new Map<SgcDomain, Int>();

        var maxLevel = -1;
        for(domain in domains){
            var level = 1;
            for(oDomain in orderedDomains){
                if(domain.start >= oDomain.start && domain.start <= oDomain.stop){
                    level = domainToLevel.get(oDomain) + 1;

                    break;
                }
            }

            if(level > maxLevel){
                maxLevel = level;
            }

            domainToLevel.set(domain,level);

            orderedDomains.unshift(domain);
        }


        var blocks : Array<AnnotationEditorBlock> = program.getAnnotationBlocks('Pfam');

        var pos = 0;

        var yUnit = 17 / (maxLevel*2);

        for(block in blocks){
            var canvasBlock = cast(block,CanvasAnnotationBlock);
            var canvas = canvasBlock.getCanvas();

            var ctx : CanvasRenderingContext2D=canvas.getContext("2d");

            ctx.clearRect(0,0,canvas.width,canvas.height);

            var width = canvas.width;

            var charWidth = program.getDefaultCharWidth();//+0.045;

            var xPos = 0.;

            var charsDone = 0;
            while(charsDone < program.blockSize){
                charsDone++;

                var cPos = ++pos;

                for(domain in orderedDomains){
                    if(domain.start != 1 && cPos >= domain.start && cPos <= domain.stop){
                        var l = domainToLevel.get(domain) * yUnit;

                        ctx.lineWidth = 1;
                        ctx.save();
                        ctx.beginPath();
                        ctx.moveTo(xPos,l);
                        ctx.lineTo(xPos+charWidth,l);
                        ctx.strokeStyle = '#00ff00';
                        ctx.closePath();
                        ctx.stroke();
                        ctx.restore();

                        if(cPos == domain.start){
                            ctx.save();
                            ctx.beginPath();
                            ctx.moveTo(xPos,l-1);
                            ctx.lineTo(xPos,l+1);
                            ctx.strokeStyle = '#0000ff';

                            ctx.closePath();
                            ctx.stroke();
                            ctx.restore();

                            var bb_w = width;
                            var c_pos = xPos;

                            var t_w = ctx.measureText(domain.accession).width;
                            var h_w = t_w/2;

                            var l_w = xPos;
                            var r_w = bb_w - l_w;

                            var t_pos = c_pos - h_w;
                            if(t_w > bb_w){
                                t_pos = 0.;
                            }else{
                                if(h_w > l_w){
                                    var shift_w = h_w - l_w;
                                    t_pos = t_pos + shift_w;
                                }else if(h_w > r_w){
                                    var shift_w = h_w - r_w;
                                    t_pos = t_pos - shift_w;
                                }
                            }

                            ctx.fillText(domain.accession,Std.int(t_pos),l-2);
                        }else if(cPos == domain.stop){
                            ctx.save();
                            ctx.beginPath();
                            ctx.moveTo(xPos+charWidth,l-1);
                            ctx.lineTo(xPos+charWidth,l+1);
                            ctx.strokeStyle = '#ff0000';
                            ctx.closePath();
                            ctx.stroke();
                            ctx.restore();
                        }
                    }
                }

                xPos = xPos + charWidth;
            }
        }
    }

    public function sequenceChanged(sequence:String):Void {
        var program : SequenceEditor = getProgram();

        var wo :ProteinWorkspaceObject = program.getActiveObject(ProteinWorkspaceObject);

        if(wo != null){
            var domainObj = wo.getDomainObj();
            if(domainObj != null && Std.is(domainObj,SgcSeqData)){
                var targetId = domainObj.targetId;
                if(targetId != null){
                    var crc = domainObj.crc;
                    var cCrc = haxe.crypto.Md5.encode(sequence);

                    if(crc == cCrc){
                        if(Reflect.hasField(domainObj, 'domains')){
                            paintDomains(domainObj.domains, sequence);
                        }else{
                            program.getProvider().getByNamedQuery('TARGET_PKEY_TO_DOMAIN',[domainObj.targetId], SgcDomain, false, function(domains: Array<SgcDomain>,err){
                                if(err == null){
                                    domainObj.domains = domains;

                                    paintDomains(domains, sequence);
                                }
                            });
                        }
                    }else{
                        domainObj.domains = null;
                    }
                }
            }
        }
    }
}
