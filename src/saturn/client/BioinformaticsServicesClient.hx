/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client;

import saturn.core.MSA;
import saturn.client.workspace.Workspace;
import saturn.client.ConversationHelper;
import bindings.Ext.NodeSocketIO;
import bindings.Ext.NodeSocket;
import saturn.core.ClustalOmegaParser;
import saturn.client.core.CommonCore;

import saturn.client.core.ClientCore;

class BioinformaticsServicesClient {
    var theSocket :NodeSocket;

    var cbsAwaitingIds : Array<String->String->Void>;
    var cbsAwaitingResponse : Map<String, Dynamic->String->Void>;

    static var theClient : BioinformaticsServicesClient;

    var blastList : Dynamic;

    var helper : ConversationHelper;

    public static function getClient(?socket, ?helper : ConversationHelper) : BioinformaticsServicesClient{
        if(theClient == null){
            theClient = new BioinformaticsServicesClient(socket, helper);
        }

        return theClient;
    }

    public function new(socket, helper : ConversationHelper){
        this.helper = helper;

        cbsAwaitingIds = new Array<String->String->Void>();
        cbsAwaitingResponse = new Map<String, String->String->Void>();

        /*if(socket == null){
            theSocket = new NodeSocket(NodeSocketIO.connect('http://'+js.Browser.window.location.hostname+':'+js.Browser.window.location.port));
        }else{
            theSocket = socket;
        }*/



        ClientCore.getClientCore().getNodeSocket().on('__response__', function(data : Dynamic){
            var cb = getCb(data);
            if(cb != null){
                if(data == null){
                    cb(null, 'Invalid, empty response from server');
                }else{
                    cb(data.json, data.error);
                }
            }
        });

        initialise();
    }

    public function getCb(data) : Dynamic->String->Void{
        var jobId = data.bioinfJobId;
        if(cbsAwaitingResponse.exists(jobId)){
            var cb = cbsAwaitingResponse.get(jobId);

            cbsAwaitingResponse.remove(jobId);

            return cb;
        }else{
            return null;
        }
    }

    public function sendBlastReportRequest(sequence :String, name : String, database :String, cb:Dynamic->String->Void){
        helper.sendRequest('_blast_', {blastDatabase:database, fasta:'>'+name+'\n'+sequence}, cb);
    }

    public function sendPsiPredReportRequest(sequence :String, name : String, cb:Dynamic->String->Void){
        helper.sendRequest('_psipred_', {fasta:'>'+name+'\n'+sequence}, cb);
    }

    public function sendDisoPredReportRequest(sequence :String, name : String, cb:Dynamic->String->Void){
        helper.sendRequest('_disopred_', {fasta:'>'+name+'\n'+sequence}, cb);
    }

    public function sendTMHMMReportRequest(sequence :String, name : String, cb:Dynamic->String->Void){
        helper.sendRequest('_thmm_', {fasta:'>'+name+'\n'+sequence}, cb);
    }

    public function sendClustalReportRequest(fasta : String, cb:Dynamic->String->Void){
        helper.sendRequest('_clustal_', {fasta: fasta}, cb);
    }

    public function sendPhyloReportRequest(fasta : String, cb:Dynamic->String->Void){
        helper.sendRequest('_phylo_', {fasta: fasta}, cb);
    }

    public function sendBlastDatabaseListRequest(cb:Dynamic->String->Void){
        helper.sendRequest('_blast_.database_list', {}, cb);
    }

    public function sendABIReportRequest(abiContents : String, cb:Dynamic->String->Void){
        helper.sendRequest('_abi_', {abiFile: abiContents}, cb);
    }

    public function sendBLASTDBUpdateRequest(databaseName : String, cb:Dynamic->String->Void){
        helper.sendRequest('_blast_updater_', {database: databaseName}, cb);
    }

    public function upload(icbContents : String, extension : String ,cb:Dynamic->String->Void){
        helper.sendRequest('_uploader_.upload', {fileContents: icbContents, extension: extension}, cb);
    }

    public function sendPDBRequest(pdbId : String, cb:Dynamic->String->Void){
        helper.sendRequest('_pdb_', {pdbId: pdbId}, cb);
    }

    public function sendTestEmail(){
        helper.sendRequest('_email_.test', {}, function(data, err){
            if(err != null){
                WorkspaceApplication.getApplication().showMessage('Error', err);
            }
        });
    }

    public function initialise(){
        sendBlastDatabaseListRequest(function(data,err){
            if(err != null){
                WorkspaceApplication.getApplication().showMessage('Request failure', 'Failed to get list of BLAST DBs');
            }else{
                this.blastList = data.json.dbList;
            }
        });
    }

    public function getBlastList() : Dynamic{
        return this.blastList;
    }

    public function getAlignment(fasta, cb : String->MSA->Void){
        BioinformaticsServicesClient.getClient().sendClustalReportRequest(fasta, function(response, err){
            if(err == null){
                var clustalReport = response.json.clustalReport;

                var location : js.html.Location = js.Browser.window.location;

                var url = location.protocol+'//'+location.hostname+':'+location.port+'/'+clustalReport;

                CommonCore.getContent(url, function(content){
                    var msa = ClustalOmegaParser.read(content);

                    cb(null, msa);
                }, function(err){
                    cb(err, null);
                });
            }else{
                cb(err, null);
            }
        });
    }
}
