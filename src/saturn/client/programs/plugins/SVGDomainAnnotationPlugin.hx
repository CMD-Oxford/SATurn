/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.plugins;

import saturn.core.ConstructDesignTable;
import saturn.client.workspace.WebPageWorkspaceObject;
import saturn.client.workspace.WebPage;
import saturn.core.molecule.Molecule;
import saturn.core.domain.Entity;
import saturn.core.domain.MoleculeAnnotation;
import saturn.core.Util.*;
import saturn.workflow.HMMer.HMMerConfig;
import saturn.workflow.HMMer.HMMerProgram;
import saturn.workflow.Chain;
import saturn.client.ProgramPlugin;
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
import saturn.client.core.CommonCore;

class SVGDomainAnnotationPlugin extends BaseProgramPlugin<SequenceEditor> implements SequenceChangeListener{
    static var reg_pfam : EReg =~/pfam([0-9]+)/;

    var firstChangeEvent = true;

    var annotationId : Int;

    var bgStyle : String;

    override public function onFocus() : Void {
		super.onFocus();

        getProgram().getApplication().getViewMenu().add({
            text: 'HMMer report',
            handler: function(){
                displayRawAnnotationData('PFAM');
            }
        });
	}

    override public function destroy(){
        var seqProg : SequenceEditor = cast theProgram;
        seqProg.removeSequenceChangeListener(this);

        super.destroy();
    }

    override public function setProgram(program : SequenceEditor) : Void {
        super.setProgram(program);
        program.addSequenceChangeListener(this);

        annotationId = program.addAnnotation('Pfam');
        program.setAnnotationClass('Pfam',SVGAnnotationBlock);

        program.setAnnotationPosition(annotationId, AnnotationPosition.TOP);
    }

    public function paintDomains(domains: Array<MoleculeAnnotation>, sequence:String){
        bgStyle = 'rgb(255,255,255)';
        var program : SequenceEditor = getProgram();

        var blocks : Array<AnnotationEditorBlock> = program.getAnnotationBlocks('Pfam');

        if(domains == null){
            for(block in blocks){
                var canvasBlock = cast(block, SVGAnnotationBlock);
                var canvas = canvasBlock.getCanvas();

                canvasBlock.clear(bgStyle);
            }

            return;
        }

        var orderedDomains :Array<MoleculeAnnotation> = new Array<MoleculeAnnotation>();

        var domainToLevel = new Map<MoleculeAnnotation, Int>();

        var maxLevel = -1;
        for(domain in domains){
            var level = 1;
            for(oDomain in orderedDomains){
                if(oDomain == domain){
                    continue;

                }

                if(Math.max(domain.start,oDomain.start) <= Math.min(domain.stop,oDomain.stop)){
                    level = domainToLevel.get(oDomain) + 1;

                    debug('Overlap ' + domain.referent.entityId + ' with ' + oDomain.referent.entityId);

                    break;
                }
            }

            if(level > maxLevel){
                maxLevel = level;
            }

            domainToLevel.set(domain,level);

            orderedDomains.unshift(domain);
        }

        var pos = 0;

        //var yUnit = 30 / (maxLevel*2);

        debug('Max level ' + maxLevel);

        var height = (maxLevel * 20 + 4);

        var color = 'green';

        var levelToColor = new Map<Int, String>();
        for(i in 1...maxLevel+1){
            levelToColor.set(i, 'green');
        }

        for(block in blocks){
            var canvasBlock = cast(block, SVGAnnotationBlock);
            var canvas = canvasBlock.getCanvas();

            canvasBlock.clear(bgStyle);
            canvasBlock.setHeight(height + 'px');
            //var width = canvas.width;

            var charWidth = program.getDefaultCharWidth();//+0.045;

            var xPos = 0.;

            var charsDone = 0;
            while(charsDone < program.blockSize){
                charsDone++;

                var cPos = ++pos;

                for(domain in orderedDomains){
                    if(domain.start != 1 && cPos >= domain.start && cPos <= domain.stop){
                        var l = domainToLevel.get(domain) * 20;

                        var color = levelToColor.get(domainToLevel.get(domain));

                        if(cPos == domain.start){

                            var text :Dynamic = js.Browser.document.createElementNS("http://www.w3.org/2000/svg", 'text');
                            text.textContent=domain.referent.entityId + ':' + domain.referent.altName;

                            if(color == 'green'){
                                color = 'orange';
                            }else if(color =='orange'){
                                color = 'green';
                            }

                            levelToColor.set(domainToLevel.get(domain), color);

                            text.setAttribute('x',-1000);
                            text.setAttribute('y',-1000);
                            text.setAttribute('font-size','10');
                            text.setAttribute('fill',color);

                            var protEditor = cast(getProgram(), ProteinSequenceEditor);
                            var addPlateMenu : Dynamic = protEditor.getAddToPlateContextMenu(null,domain.start, domain.stop);

                            var items : Array<Dynamic> = [];

                            items.push({
                                text: 'New Protein',
                                handler: function(){
                                    var name = getProgram().getActiveObject(WorkspaceObject).getName();
                                    var seq = sequence.substring(domain.start,domain.stop);
                                    var protSeq = new Protein(seq);

                                    var wo = new ProteinWorkspaceObject(protSeq,name + '('+domain.referent.entityId+' '+domain.start+'-'+domain.stop+')');

                                    getProgram().getWorkspace().addObject(wo,true);
                                }
                            });

                            items.push({
                                text: 'Goto Pfam',
                                handler: function(){
                                    var ac = domain.referent.entityId;

                                    var id = '';
                                    if(reg_pfam.match(ac)){
                                        id = 'PF' + reg_pfam.matched(1);
                                    }else{
                                        id = ac;
                                    }

                                    getProgram().getApplication().openUrl('http://pfam.xfam.org/family/'+id);
                                }
                            });

                            items.push({
                                text: 'Add to plate',
                                menu: addPlateMenu
                            });

                            var contextMenu = function(event : Dynamic){
                                var contextMenu : Dynamic = Ext.create('Ext.menu.Menu',{
                                    focusOnToFront : false,
                                    items: items
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
                        }

                        var path = js.Browser.document.createElementNS("http://www.w3.org/2000/svg", 'path');
                        path.setAttribute('d','M ' + (xPos+1) + ' ' + l + ' L ' + (xPos+charWidth+1) + ' ' + l + ' ');
                        path.setAttribute('charWidth',Std.string(charWidth));
                        path.setAttribute('stroke',color);

                        canvas.appendChild(path);
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

        var wo :ProteinWorkspaceObject = program.getActiveObject(ProteinWorkspaceObject);

        if(wo != null){

            if(Reflect.isFunction(wo.getDomainObj) && wo.getDomainObj() != null && Std.is(wo.getDomainObj(),SgcSeqData)){
                var domainObj = wo.getDomainObj();
                var targetId = domainObj.targetId;
                if(targetId != null){
                    var crc = domainObj.crc;
                    var cCrc = haxe.crypto.Md5.encode(sequence);

                    if(crc == cCrc){
                        if(Reflect.hasField(domainObj, 'domains')){
                            paintDomains(getProgram().getEntity().getAnnotations('PFAM'), sequence);
                        }else{
                            program.getProvider().getByNamedQuery('TARGET_PKEY_TO_DOMAIN',[domainObj.targetId], SgcDomain, false, function(domains: Array<SgcDomain>,err){
                                if(err == null){
                                    var objs = new Array<MoleculeAnnotation>();
                                    for(domain in domains){
                                        var obj = new MoleculeAnnotation();
                                        obj.start = domain.start;
                                        obj.stop = domain.stop;
                                        obj.referent = new Entity();
                                        obj.referent.entityId = domain.accession;

                                        if(domain.accession == 'userdefined:Full_Length'){
                                            continue;
                                        }

                                        objs.push(obj);
                                    }
                                    //domainObj.domains = domains;
                                    getProgram().getEntity().setAnnotations(objs, 'PFAM');
                                    paintDomains(objs, sequence);
                                }
                            });
                        }
                    }else{
                        getProgram().getEntity().setAnnotations(null, 'PFAM');
                        domainObj.domains = null;
                    }
                }
            }else{
                updateAnnotation('PFAM', function(err : String, objs: Array<MoleculeAnnotation>){
                    if(err == null){
                        var editor : SequenceEditor = getProgram();
                        paintDomains(objs, editor.getSequence());
                    }
                });
            }
        }
    }

    public function updateAnnotation(annotationName : String, cb : String->Array<MoleculeAnnotation>->Void){
        var m = cast(getProgram().getWorkspaceObject(), Molecule);

        var editor : SequenceEditor = getProgram();

        m.setSequence(editor.getSequence());

        m.updateAnnotations(annotationName, {'removeOverlaps': true},CommonCore.getAnnotationManager(), cb);
    }

    public function displayRawAnnotationData(annotationName){
        var m = cast(getProgram().getWorkspaceObject(), Molecule);

        updateAnnotation(annotationName, function(err : String, objs : Array<MoleculeAnnotation>){
            if(err == null){
                var m = cast(getProgram().getEntity(), Molecule);
                var dstURL = m.getRawAnnotationData(annotationName);

                var webPage : WebPage = new WebPage();
                webPage.setURL(dstURL);

                var w0 : WebPageWorkspaceObject = new WebPageWorkspaceObject(webPage, m.getMoleculeName() + '(' + annotationName + ')');

                getProgram().getApplication().getWorkspace().addObject(w0,true);
            }
        });
    }
}
