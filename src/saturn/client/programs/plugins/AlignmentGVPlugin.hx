/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.plugins;

import saturn.core.Protein;
import saturn.client.programs.blocks.BaseTable.TableDefinition;
import saturn.client.programs.blocks.BaseTable.ColumnDefinition;
import saturn.core.MSA;
import saturn.client.workspace.ProteinWorkspaceObject;
import saturn.core.DNA;
import saturn.client.workspace.DNAWorkspaceObject;
import saturn.core.ClustalOmegaParser;
import saturn.client.workspace.Alignment;
import saturn.client.workspace.AlignmentWorkspaceObject;
import saturn.client.ProgramPlugin.BaseProgramPlugin;
import saturn.client.core.CommonCore;

class AlignmentGVPlugin implements GridVarPlugin extends BaseProgramPlugin<GridVarViewer> {

    public function outlineAdd(objectId : String) : Void{
        var object :Dynamic = getProgram().getWorkspace().getObject(objectId);

        if(Std.is(object, AlignmentWorkspaceObject)){
            refreshAlignment(object);
        }else if(Std.is(object, DNAWorkspaceObject)){
            refreshDNASequence(object);
        }else if(Std.is(object, ProteinWorkspaceObject)){
            refreshProteinSequence(object);
        }else if(Std.is(object, Protein) || Std.is(object, DNA)){
            refreshSequenceString(rowSequence(object.getSequence()));
        }
    }

    public function refreshDNASequence(object : DNAWorkspaceObject<DNA>){
        refreshSequenceString(rowSequence(object.getDNAObject().getSequence()));
    }

    public function refreshProteinSequence(object : ProteinWorkspaceObject){
        refreshSequenceString(rowSequence(object.getObject().getSequence()));
    }

    public function refreshSequenceString(contents: String){
        var prog : GridVarViewer = getProgram();
        prog.getDataTable().performPaste(contents, [0, 0]);
    }

    public function refreshAlignment(object : AlignmentWorkspaceObject = null){
        if(object != null){
            var aln :Alignment = object.getObject();
            var alnURL = aln.getAlignmentURL();
            if(alnURL != null){
                CommonCore.getContent(alnURL, function(content){
                    var def = getTableDefinitionFromAlignment(content);

                    var prog : GridVarViewer = getProgram();
                    var dataTable = prog.getDataTable();

                    dataTable.reconfigure(def);
                    prog.redrawGridVar();
                });
            }
        }
    }

    public static function getTableDefinitionFromAlignment(alignmentString : String){
        var msa = ClustalOmegaParser.read(alignmentString);

        return getTableDefinition(msa.getFirstName(),msa);
    }

    public static function getTableDefinition(baseItem : String, msa : MSA) : TableDefinition {
        msa.idToAlnStr.remove(' ');
        msa.seqOrder.pop();

        var baseSequence = msa.getAlignment(baseItem);

        var overlaps = new Array<Array<String>>();

        var def : TableDefinition = {title: 'Data', data: [], columnDefs: new Array<ColumnDefinition>(), raw: null};

        def.raw = msa;

        var alns = new Array<String>();
        var columnOrder = new Array<String>();
        for(column in msa.seqOrder){
            if(column != baseItem){
                columnOrder.push(column);
                alns.push(msa.getAlignment(column));

                def.columnDefs.unshift({text: column, dataIndex: column, editor: 'textfield'});
            }
        }

        def.columnDefs.unshift({text: 'Residue', dataIndex: 'residue', editor: 'textfield'});

        for(i in 0...baseSequence.length){
            var char = baseSequence.charAt(i);
            if(char != '-'){
                var row :Dynamic = {'residue': char};

                for(j in 0...columnOrder.length){
                    if(alns[j].charAt(i) != '-'){
                        Reflect.setField(row, columnOrder[j], '1');
                    }
                }

                def.data.push(row);
            }
        }

        return def;
    }

    public function rowSequence(sequence : String){
        var buf = new StringBuf();
        for(i in 0...sequence.length){
            buf.add(sequence.charAt(i) + '\n');
        }

        return buf.toString();
    }
}
