/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.domain;

#if CLIENT_SIDE
import saturn.client.WorkspaceApplication;
import saturn.app.SaturnClient;

#end

class Compound {
    public var id : Int;
    public var compoundId : String;
    public var supplierId : String;
    public var shortCompoundId : String;
    public var sdf : String;
    public var supplier : String;
    public var description : String;
    public var concentration : Float;
    public var location : String;
    public var solute : String;
    public var comments : String;
    public var mw : Float;
    public var confidential : String;
    public var datestamp : Date;
    public var person : String;
    public var inchi : String;
    public var smiles : String;

    public static var molCache : Map<String, Map<String,String>> = new Map<String, Map<String,String>>();
    public static var r =~/svg:/g;

    public static var rw =~/width='300px'/g;
    public static var rh =~/height='300px'/g;

    public function new(){
        datestamp = new Date(1,2,3,4,5,6);

        compoundId = 'Compound';
    }

    public function setup(){

    }

    public function substructureSearch(cb : Dynamic-> Void){
        #if CLIENT_SIDE
            js.Browser.alert('Hello World!!!!');
        #end
    }

    public function assaySearch(cb : Dynamic-> Void){
        #if CLIENT_SIDE
            WorkspaceApplication.getApplication().getProvider().getByNamedQuery('compound_assay_search', [this.compoundId], null, false, function(json, error){
                var dwin : Dynamic = js.Browser.window;
                dwin.results = json;
                dwin.error = error;

                var r =~/svg:/g;

                var rw =~/width='300px'/g;
                var rh =~/height='300px'/g;

                if(error == null){
                    var table :Dynamic = new Table();

                    table.setFixedRowHeight(50);

                    var d : Array<Dynamic> = json;

                    //Compound.appendMolImage(d, 'SDF', 'SDF', 'SDF');

                    table.setData(json, {'SDF':{'renderer': function(value){
                       /*if(value == '' || value == null){
                            return '<div></div>';
                        }else{
                            var s = SaturnClient.getSaturn().getMolImage(value);

                            SaturnClient.getSaturn().debug(s);

                            return '<div>' + s + '</div>';
                        }*/
                        //return '<div>'+value+'</div>';
                         return '<div>' + Compound.getMolImage(value, 'SDF') + '</div>';
                    }}});



                    table.name = this.compoundId + ' (Assay Results)';

                    WorkspaceApplication.getApplication().getWorkspace().addObject(table, true);
                }else{

                }
            });
        #end
    }

    public function test(cb : Dynamic-> Void){
        #if CLIENT_SIDE
            var protein :Dynamic = new Protein('ATGC');
            protein.name="Test Me";

            WorkspaceApplication.getApplication().getWorkspace().addObject(protein, true);
        #end
    }

    public static function appendMolImage(objs : Array<Dynamic>, structureField : String, outputField: String, format :String){
        for(row in objs){
            var value = Reflect.field(row, structureField);
            if(value == '' || value == null){
                value = '';
            }else{
                var s = Compound.getMolImage(value, format);

                value= s;
            }

            Reflect.setField(row, outputField,value);
        }
    }

    public static function getMolImage(value : String, format: String){
        if(!molCache.exists(format)){
            molCache.set(format, new Map<String, String>());
        }

        if(!molCache.get(format).exists(value)){
            try{
                var rdkit = untyped __js__('RDKit');

                var mol : Dynamic = null;

                if(format == 'SDF'){
                    mol = rdkit.Molecule.MolBlockToMol(value);
                }else{
                    mol = rdkit.Molecule.fromSmiles(value);
                }

                mol.Kekulize();

                var s = mol.Drawing2D();

                s = r.replace(s, '');
                s = rw.replace(s, 'width="100%"');
                s = rh.replace(s, 'height="100%" viewBox="0 0 300 300"');

                molCache.get(format).set(value, s);
            }catch(err : Dynamic){
                molCache.get(format).set(value, null);
            }


        }

        return molCache.get(format).get(value);
    }

    public static function clearMolCache(){
        for(format in molCache.keys()){
            for(key in molCache.get(format).keys()){
                molCache.get(format).remove(key);
            }
        }
    }
}
