/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.annotations;

import saturn.client.WorkspaceApplication;
import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.core.molecule.Molecule;
import saturn.core.domain.MoleculeAnnotation;
import saturn.core.parsers.HmmerParser;
import saturn.client.core.CommonCore;
import saturn.core.Util.*;
import saturn.workflow.HMMer.HMMerConfig;
import saturn.workflow.HMMer.HMMerResponse;
import saturn.workflow.HMMer.HMMerProgram;
import saturn.workflow.Chain;

class PfamSupplier extends AnnotationSupplier{
    public function new() {
        super();
    }

    override public function annotateMolecule(molecule : Molecule,  annotationName : String, annotationConfig : Dynamic, cb : Dynamic->Array<MoleculeAnnotation>->Void){
        molecule.setAnnotations(null, annotationName);
        molecule.setRawAnnotationData(null, annotationName);

        var chain = new Chain();

        var config = new HMMerConfig(HMMerProgram.HMMSEARCH);

        config.setFastaContent('>' + molecule.getMoleculeName() + '\n' + molecule.getSequence());

        config.setHMMPath('databases/Pfam-A.hmm');

        chain.add('saturn.workflow.HMMer.query', config);

        chain.start(function(error : Dynamic){
            if(error != null){
                WorkspaceApplication.getApplication().showMessage('Error', error);
                return;
            }

            var outputFile = '../' + cast(config.getResponse(), HMMerResponse).getTableOutputPath();
            CommonCore.getContent( outputFile, function(content){
                var annotations = new Array<MoleculeAnnotation>();

                var p = new HmmerParser(null, function(objs:Array<MoleculeAnnotation>, iter :Generator<MoleculeAnnotation>){
                    for(obj in objs){
                        if(obj.evalue <= 0.001 && obj.altevalue <= 0.001){
                            obj.referent.entityId = obj.referent.entityId.split('.')[0];
                            annotations.push(obj);
                        }
                    }

                    iter.next();
                }, function(err : String){
                    if(annotationConfig.removeOverlaps){
                        var kept = new Array<MoleculeAnnotation>();
                        var removed = new Array<MoleculeAnnotation>();

                        for(obj1 in annotations){
                            var keep = true;
                            for(obj2 in annotations){
                                if(Math.max(obj1.start,obj2.start) <= Math.min(obj1.stop,obj2.stop)){
                                    if(obj1.evalue > obj2.evalue){
                                        keep = false;
                                        break;
                                    }else if(obj1.evalue == obj2.evalue){
                                        if(obj1.stop - obj1.start < obj2.stop - obj2.start){
                                            keep = false;
                                            break;
                                        }
                                    }
                                }
                            }

                            if(keep){
                                kept.push(obj1);
                            }else{
                                debug('Removing ' + obj1.referent.entityId);
                            }
                        }

                        annotations = kept;
                    }

                    molecule.setAnnotations(annotations, annotationName);
                    molecule.setRawAnnotationData(outputFile, annotationName);

                    cb(err, annotations);
                });

                p.setContent(content);
            });
        });
    }
}
