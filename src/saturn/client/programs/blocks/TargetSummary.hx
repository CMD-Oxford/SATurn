/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.blocks;

import saturn.core.domain.SgcEntryClone;
import saturn.core.domain.SgcConstructStatus;
import saturn.db.Provider;
import saturn.client.workspace.GridVarWO;
import saturn.core.GridVar;
import saturn.client.WorkspaceApplication;
import saturn.core.domain.SgcSeqData;
import saturn.client.core.CommonCore;
import saturn.core.domain.SgcConstruct;
import saturn.client.programs.plugins.AlignmentGVPlugin;
import saturn.core.domain.SgcTarget;

class TargetSummary {
    var targetId : String;
    var constructs : Array<SgcConstruct>;
    var targetSeq : SgcTarget;
    var aln : String;
    var fasta : String;
    var gridVar  : GridVar;
    var parentFolder = null;

    var constructNameToConstruct : Map<String, SgcConstruct>;

    public function new(targetId : String){
        this.targetId = targetId;

        constructNameToConstruct = new Map<String, SgcConstruct>();
    }

    public function setParentFolder(folderNode : Dynamic){
        this.parentFolder = folderNode;
    }

    public function setSequences(constructs: Array<SgcConstruct>){
        this.constructs = constructs;

        for(construct in this.constructs){
            constructNameToConstruct.set(construct.constructId, construct);
        }
    }

    public function generateSummary(){
        getConstructs();
    }

    public function getConstructs(){
        CommonCore.getDefaultProvider().getByNamedQuery('TARGET_TO_CONSTRUCTS',[targetId], SgcConstruct, false, function(constructs: Array<SgcConstruct>,exception){
            if(exception == null && constructs != null){
                this.constructs = constructs;

                for(construct in constructs){
                    constructNameToConstruct.set(construct.constructId, construct);
                }

                getConstructStatus();
            }else{
                lookupException(exception.message);
            }
        });
    }

    public function getTargetSequence(){
        //TODO: M1, abstract issue
        CommonCore.getDefaultProvider().getById(targetId, SgcTarget,function(targetSeq:SgcTarget, ex){
            if(ex == null && targetSeq != null){
                this.targetSeq = targetSeq;
                generateAlignment();
            }else{
                lookupException(ex.message);
            }
        });
    }

    public function getConstructStatus(){
        var values = new Array<String>();

        var constructPkeyToConstruct = new Map<String, SgcConstruct>();

        for(construct in constructs){
            values.push(Std.string(construct.id));

            constructPkeyToConstruct.set(Std.string(construct.id), construct);
        }

        var provider :Provider = CommonCore.getDefaultProvider();
        provider.getByValues(values, SgcConstructStatus, 'constructPkey', function(objs : Array<SgcConstructStatus>, err){
            if(err == null){
                for(obj in objs){
                    constructPkeyToConstruct.get(Std.string(obj.constructPkey)).status = obj.status;
                }

                getTargetSequence();
            }else{
                lookupException(err);
            }
        });
    }

    private function generateFASTA(){
        var objs = new Array<String>();

        var fastaBuf = new StringBuf();

        fastaBuf.add('>'+targetId+'\n'+targetSeq.proteinSeq+'\n');

        for(construct in constructs){
            if(construct.proteinSeqNoTag != null){
                fastaBuf.add('>'+construct.constructId+'\n'+construct.proteinSeqNoTag+'\n');
            }
        }

        fasta = fastaBuf.toString();
    }

    public function generateAlignment(){
        generateFASTA();

        BioinformaticsServicesClient.getClient().sendClustalReportRequest(fasta, function(response, error){
            if(error == null){
                var clustalReport = response.json.clustalReport;
                var location : js.html.Location = js.Browser.window.location;

                var dstURL = location.protocol+'//'+location.hostname+':'+location.port+'/'+clustalReport;

                CommonCore.getContent(dstURL, function(content){
                    aln = content;

                    finish();
                });
            }else{
                WorkspaceApplication.getApplication().showMessage('Clustal Error', error);
            }
        });
    }

    public function finish(){
        gridVar = new GridVar();
        gridVar.dataTableDefinition = AlignmentGVPlugin.getTableDefinitionFromAlignment(aln);
        gridVar.fit = true;
        gridVar.padding = false;
        gridVar.showXLabels = false;
        gridVar.configCollapse = true;

        colourConstructs();

        var wo = new GridVarWO(gridVar, targetId + ' (Construct summary - no tag)');

        WorkspaceApplication.getApplication().getWorkspace().addObject(wo, true, parentFolder);
    }

    public function colourConstructs(){
        var styles = {
            'No progress': {val: 6, colour: 'grey'},
            'Cloned': {val: 2, colour: 'green'},
            'Purified': {val: 7, colour: 'orange'},
            'In xtal trials': {val: 5, colour: 'blue'},
            'Diffraction criteria met': {val: 4, colour: 'red'},
            'Deposited': {val: 3, colour: 'purple'},
            'Unknown':{val: 1, colour:'grey'}
        };

        for(i in 1...gridVar.dataTableDefinition.columnDefs.length){
            var def = gridVar.dataTableDefinition.columnDefs[i];

            var constructName = def.dataIndex;

            var construct = constructNameToConstruct.get(constructName);
            var status = construct.status;

            var num = 1;

            if(Reflect.hasField(styles, status)){
                num = Reflect.field(styles, status).val;
            }

            for(j in 0...gridVar.dataTableDefinition.data.length){
                if(Reflect.field(gridVar.dataTableDefinition.data[j], constructName) == 1){
                    Reflect.setField(gridVar.dataTableDefinition.data[j], constructName, num);
                }
            }
        }

        gridVar.styleTableDefinition.data = [];

        for(style in Reflect.fields(styles)){
            var num = Reflect.field(styles, style).val;

            gridVar.styleTableDefinition.data.push({
                'data_type': 'Construct Status',
                "mapping": num,
                style: 'rec',
                "color":Reflect.field(styles, style).colour,
                "label" : style, 'columns': '*'
            });
        }
    }

    private function lookupException(msg){
        WorkspaceApplication.getApplication().showMessage('Lookup exception',msg);
    }
}
