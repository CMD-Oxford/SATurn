/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.workspace;

import saturn.client.workspace.Workspace.WorkspaceObjectBase;
import saturn.core.TableHelperData;

class TableWO extends WorkspaceObjectBase<TableHelperData>{
    public function new(incoming : Dynamic, name : String){
        var data : TableHelperData = incoming;

        if(incoming == null){
            data = new TableHelperData();
        }else if(!Std.is(incoming, TableHelperData)){
            data = new TableHelperData();

            if(Std.is(incoming, Array)){
                data.setRawModels(incoming);
            }else{
                data.setRawModels([incoming]);
            }
        }

        if(name == null){
            name = "Table";
        }

        super(data, name);
    }
}
