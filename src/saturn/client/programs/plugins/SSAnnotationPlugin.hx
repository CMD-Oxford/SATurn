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
import saturn.client.programs.sequenceeditor.AnnotationEditorBlockDiv;
import bindings.Ext;
import saturn.core.domain.SgcDomain;
import saturn.client.workspace.ProteinWorkspaceObject;
import saturn.client.programs.sequenceeditor.AnnotationEditorBlock;
import saturn.client.ProgramPlugin.BaseProgramPlugin;

import saturn.client.programs.sequenceeditor.SequenceEditor;

import haxe.crypto.Md5;

class SSAnnotationPlugin extends BaseProgramPlugin<SequenceEditor> implements SequenceChangeListener{
    static var reg_predLines : EReg =~/Pred:\s+([A-Z]+)/;

    var annotationPos : Int;

    var firstChangeEvent = true;

    var lastCrc : String;
    var lastSSStr : String;

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

        annotationPos = program.addAnnotation('SS');

        program.setAnnotationClass('SS',AnnotationEditorBlockDiv);
    }

    public function paintFromString(ssStr : String){
        lastSSStr = ssStr;

        var program : SequenceEditor = getProgram();

        var blocks : Array<AnnotationEditorBlock> = program.getAnnotationBlocks('SS');

        var pos = 0;
        var blockSize = program.blockSize;

        for(block in blocks){
            var dBlock = cast(block,AnnotationEditorBlockDiv);

            if(ssStr == null || ssStr == ''){
                dBlock.setHtml('');
                continue;
            }

            var ss = ssStr.substr(pos,blockSize);
            pos += blockSize;

            var replacements = [
                {p1:'E',p2:'C',c:'red'},
                {p1:'E',p2:'H',c:'green'},
                {p1:'H',p2:'C',c:'red'},
                {p1:'H',p2:'E',c:'blue'},
                {p1:'C',p2:'E',c:'blue'},
                {p1:'C',p2:'H',c:'green'}
            ];

            var bNum = block.getBlockNumber();

            var strBuf = new StringBuf();
            var lChar = '-';
            var bCount = 0;
            for(i in 0...ss.length){
                bCount++;

                var cChar = ss.charAt(i);
                if(cChar == lChar){
                    strBuf.add(cChar);
                }else{
                    var c = 'red';
                    if(cChar == 'C'){
                        c='red';
                    }else if(cChar == 'H'){
                        c='green';
                    }if(cChar == 'E'){
                        c='blue';
                    }

                    if(i!=0){
                        strBuf.add('</pre></font>');
                    }

                    strBuf.add('<font color="'+c+'""><pre block_part_start ='+(bCount-1)+' blockNumber ='+bNum+' style="display:inline-block" class="molbio-sequenceeditor-block-part">'+cChar);
                }
            }


            dBlock.setHtml(strBuf.toString());
        }

        program.setAnnotationSequence(annotationPos, ssStr);

        program.getApplication().getMiddleSouthPanel().body.update('<b>Secondary structure prediction performed using PSIPred - <a target="_blank" href="http://bioinfadmin.cs.ucl.ac.uk/downloads/psipred/LICENSE">license</a></b>');
    }

    public function sequenceChanged(sequence:String):Void {
        var program : SequenceEditor = getProgram();

        if(!program.isAnnotationOn(annotationPos)){
            return;
        }

        if(!program.liveUpdateEnabled()){
            return;
        }

        var crc = Md5.encode(sequence);

        if(crc == lastCrc && sequence != null && sequence != ''){
            paintFromString(lastSSStr);
            return;
        }else{
            lastCrc = crc;
        }

        var wo :ProteinWorkspaceObject = program.getActiveObject(ProteinWorkspaceObject);
        var name = wo.getName();

        BioinformaticsServicesClient.getClient().sendPsiPredReportRequest(sequence, name, function(response,error){
            if(error == null){
                var rawHoriReport = response.json.rawHoriReport;

                var location : js.html.Location = js.Browser.window.location;

                var dstURL = location.protocol+'//'+location.hostname+':'+location.port+'/'+rawHoriReport;

                Ext.Ajax.request({
                    url: dstURL,
                    success: function(response, opts) {
                        var obj :String = response.responseText;

                        /*
                        var replacements = [
                            {p1:'E',p2:'C',c:'red'},
                            {p1:'E',p2:'H',c:'green'},
                            {p1:'H',p2:'C',c:'red'},
                            {p1:'H',p2:'E',c:'blue'},
                            {p1:'C',p2:'E',c:'blue'},
                            {p1:'C',p2:'H',c:'green'}
                        ];

                        for(rep in replacements){
                            obj = StringTools.replace(obj,rep.p1+rep.p2,rep.p1+'</pre></font><font color='+rep.c+'>'+rep.p2);
                        }*/


                        paintFromPsiPredString(obj);
                    },
                    failure: function(response, opts) {
                        program.getApplication().showMessage('PSIPred Error', 'PSIPred error');
                    }
                });
            }else{
                program.getApplication().showMessage('PSIPred Error', error);
            }
        });
    }

    public function paintFromPsiPredString(psiPredStr : String){
        var ssStr = new StringBuf();

        var lines = psiPredStr.split('\n');
        for(line in lines){
            if(reg_predLines.match(line)){
                var ss = reg_predLines.matched(1);
                ssStr.add(ss);
            }
        }

        paintFromString(ssStr.toString());
    }
}
