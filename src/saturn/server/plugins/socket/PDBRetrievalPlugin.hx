/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.socket;

import saturn.app.SaturnServer;
import js.Node;
import bindings.Ext.NodeSocket;

class PDBRetrievalPlugin extends QueuePlugin{
    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);
    }

    override public function processRequest(job, done, cb){
        Node.console.info('Fetching PDB');
        fetch_pdb(job, done);
    }

    @:cps public function fetch_pdb(job : Dynamic, done) : Void{
        var pdb_id = job.data.pdbId;

        Node.require('needle').get('http://www.rcsb.org/pdb/files/' + pdb_id.toUpperCase() + '.pdb', function(error,response) {
            if(error == null && response.statusCode == 200){
                Node.console.info('Sending response');

                var d :Dynamic = {};
                d.pdb = response.body;

                sendJson(job, d, done);
            }else{
                sendError(job, 'Unable to fetch PDB', done);
            }
        });
    }
}