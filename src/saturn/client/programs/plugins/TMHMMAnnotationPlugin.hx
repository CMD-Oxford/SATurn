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
import haxe.crypto.Md5;
import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.client.programs.sequenceeditor.SVGAnnotationBlock;
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
import bindings.Ext;

class TMHMMAnnotationPlugin extends BaseProgramPlugin<SequenceEditor> implements SequenceChangeListener{
    static var reg_tmhmm_domain : EReg =~/(outside|inside|TMhelix)\s+([0-9]+)\s+([0-9]+)/;

    var seqObserved = false;

    var annotationId : Int;

    var domains : Array<SgcDomain>;
    var lastCrc : String;

    var bgStyle : String;

    override public function onFocus() : Void {
		super.onFocus();
	}

    override public function destroy(){
        var seqProg : SequenceEditor = cast theProgram;
        seqProg.removeSequenceChangeListener(this);

        super.destroy();
    }

    override public function setProgram(program : SequenceEditor) : Void {
        super.setProgram(program);
        program.addSequenceChangeListener(this);

        annotationId = program.addAnnotation('TM');
        program.setAnnotationClass('TM',SVGAnnotationBlock);

        program.setAnnotationPosition(annotationId, AnnotationPosition.TOP);
    }

    public function paintDomains(domains: Array<SgcDomain>, sequence:String){
        bgStyle = 'rgb(255,255,255)';

        var program : SequenceEditor = getProgram();

        var blocks : Array<AnnotationEditorBlock> = program.getAnnotationBlocks('TM');

        var pos = 0;

        var yUnit = 5;

        for(block in blocks){
            var canvasBlock = cast(block, SVGAnnotationBlock);
            var canvas = canvasBlock.getCanvas();

            canvasBlock.clear(bgStyle);

            if(domains == null || domains.length == 0){
                continue;
            }

            //var width = canvas.width;

            var charWidth = program.getDefaultCharWidth();//+0.045;

            var xPos = 0.;

            var domainColours = ['inside'=>'green','outside'=>'blue','TMhelix'=>'red'];

            var charsDone = 0;
            while(charsDone < program.blockSize){
                charsDone++;

                var cPos = ++pos;

                for(domain in domains){
                    if(cPos >= domain.start && cPos <= domain.stop){
                        var l = 15;

                        var c = domainColours.get(domain.accession);

                        var path = js.Browser.document.createElementNS("http://www.w3.org/2000/svg", 'path');
                        path.setAttribute('d','M ' + (xPos+1) + ' ' + l + ' L ' + (xPos+charWidth+1) + ' ' + l + ' ');
                        path.setAttribute('charWidth',Std.string(charWidth));
                        path.setAttribute('stroke',c);

                        canvas.appendChild(path);

                        /*
                        var rec = js.Browser.document.createElementNS("http://www.w3.org/2000/svg", 'rect');
                        rec.setAttribute('x','0');
                        rec.setAttribute('y','0');
                        rec.setAttribute('width','100');
                        rec.setAttribute('height','10');
                        canvas.appendChild(rec);*/

                        /*
                        ctx.lineWidth = 1;
                        ctx.save();
                        ctx.beginPath();
                        ctx.moveTo(xPos,l);
                        ctx.lineTo(xPos+charWidth,l);
                        ctx.strokeStyle = '#00ff00';
                        ctx.closePath();
                        ctx.stroke();
                        ctx.restore();*/


                        if(cPos == domain.start){
                            /*var path = js.Browser.document.createElementNS("http://www.w3.org/2000/svg", 'path');
                            path.setAttribute('d','M ' + (xPos+2) + ' ' + (l-3) + ' L ' + (xPos+2) + ' ' + (l+3) + ' ');
                            path.setAttribute('charWidth',Std.string(charWidth));
                            path.setAttribute('stroke','red');
                            canvas.appendChild(path);*/

                            /*
                            ctx.save();
                            ctx.beginPath();
                            ctx.moveTo(xPos,l-1);
                            ctx.lineTo(xPos,l+1);
                            ctx.strokeStyle = '#0000ff';

                            ctx.closePath();
                            ctx.stroke();
                            ctx.restore();*/

                            var text :Dynamic = js.Browser.document.createElementNS("http://www.w3.org/2000/svg", 'text');
                            text.textContent=domain.accession;

                            text.setAttribute('x',-1000);
                            text.setAttribute('y',-1000);
                            text.setAttribute('font-size','10');
                            text.setAttribute('fill',c);

                            var contextMenu = function(event : Dynamic){
                                var contextMenu : Dynamic = Ext.create('Ext.menu.Menu',{
                                    focusOnToFront : false,
                                    items: [
                                        {
                                            text: 'New Protein',
                                            handler: function(){
                                                var name = getProgram().getActiveObject(WorkspaceObject).getName();
                                                var seq = sequence.substring(domain.start-1,domain.stop);
                                                var protSeq = new Protein(seq);

                                                var wo = new ProteinWorkspaceObject(protSeq,name + '('+domain.accession+' '+domain.start+'-'+domain.stop+')');

                                                getProgram().getWorkspace().addObject(wo,true);
                                            }
                                        }
                                    ],
                                    listeners: {
                                        'close' : function(){
                                            program.redraw();
                                        }
                                    }
                                });

                                contextMenu.showAt(event.clientX, event.clientY);

                                event.preventDefault();

                                return true;
                            };

                            text.onclick = function(event : Dynamic) {
                                contextMenu(event);
                            }

                            canvas.appendChild(text);

                            var bb_w = Std.parseInt(canvas.style.width);
                            var c_pos = xPos;

                            var t_w = text.getComputedTextLength();
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

                            text.setAttribute('x',Std.string(t_pos));
                            text.setAttribute('y',Std.string(l-4));




                            //ctx.fillText(domain.accession,Std.int(t_pos),l-2);
                        }else if(cPos == domain.stop){
                            /*var path = js.Browser.document.createElementNS("http://www.w3.org/2000/svg", 'path');
                            path.setAttribute('d','M ' + (xPos+charWidth) + ' ' + (l-3) + ' L ' + (xPos+charWidth) + ' ' + (l+3) + ' ');
                            path.setAttribute('charWidth',Std.string(charWidth));
                            path.setAttribute('stroke','red');
                            canvas.appendChild(path);*/
                            /*
                            ctx.save();
                            ctx.beginPath();
                            ctx.moveTo(xPos+charWidth,l-1);
                            ctx.lineTo(xPos+charWidth,l+1);
                            ctx.strokeStyle = '#ff0000';
                            ctx.closePath();
                            ctx.stroke();
                            ctx.restore();*/
                        }
                    }
                }

                xPos = xPos + charWidth;
            }
        }
    }

    public function sequenceChanged(sequence:String):Void {
        var program : SequenceEditor = getProgram();

        if(!program.isAnnotationOn(annotationId)){
            return;
        }

        if(!program.liveUpdateEnabled()){
            return;
        }

        var crc = Md5.encode(sequence);

        if(crc == lastCrc && domains != null){
            paintDomains(domains, sequence);
            return;
        }else{
            lastCrc = crc;
        }

        var wo :ProteinWorkspaceObject = program.getActiveObject(ProteinWorkspaceObject);
        var name = wo.getName();
        if(wo != null){
            BioinformaticsServicesClient.getClient().sendTMHMMReportRequest(sequence, name, function(response,error){
                if(error == null){
                    var report = response.json.rawReport;
                    var location : js.html.Location = js.Browser.window.location;

                    var dstURL = location.protocol+'//'+location.hostname+':'+location.port+'/'+report;

                    Ext.Ajax.request({
                        url: dstURL,
                        success: function(response, opts) {
                            var content :String = response.responseText;
                            var lines = content.split('\n');
                            domains = new Array<SgcDomain>();

                            for(line in lines){
                                if(!StringTools.startsWith(line, '#')){
                                    if(reg_tmhmm_domain.match(line)){
                                        var domain = new SgcDomain();
                                        domain.start = Std.parseInt(reg_tmhmm_domain.matched(2));
                                        domain.stop = Std.parseInt(reg_tmhmm_domain.matched(3));
                                        domain.accession = reg_tmhmm_domain.matched(1);

                                        domains.push(domain);
                                    }
                                }
                            }

                            paintDomains(domains,sequence);
                        },
                        failure: function(response, opts) {
                            program.getApplication().showMessage('TMHMM Error', 'TMHMM error');
                        }
                    });

                }else{
                    program.getApplication().showMessage('TMHMM Error', error);
                }
            });
        }
    }
}
