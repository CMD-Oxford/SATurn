/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.annotations;
import saturn.core.molecule.Molecule;
import saturn.core.domain.MoleculeAnnotation;

class AnnotationManager {
    var annotationSuppliers : Map<String, AnnotationSupplier> = new Map<String, AnnotationSupplier>();

    public function new() {

    }

    public function annotateSequence(sequence : String, name : String, annotationName : String, config : Dynamic, cb: Dynamic->Array<MoleculeAnnotation>->Void){
        if(annotationSuppliers.exists(annotationName)){
            annotationSuppliers.get(annotationName).annotate(sequence, name, annotationName, config, cb);
        }
    }

    public function annotateMolecule(molecule : Molecule, annotationName : String, config : Dynamic, cb: Dynamic->Array<MoleculeAnnotation>->Void){
        if(annotationSuppliers.exists(annotationName)){
            annotationSuppliers.get(annotationName).annotateMolecule(molecule, annotationName, config, cb);
        }
    }

    public function registerAnnotationSupplier(as: AnnotationSupplier, annotationName : String){
        annotationSuppliers.set(annotationName, as);
    }
}
