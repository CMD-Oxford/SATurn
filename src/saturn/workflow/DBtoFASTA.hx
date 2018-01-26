/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.workflow;

import saturn.db.Provider;

import saturn.core.Util.*;

using saturn.core.Util;

import saturn.client.core.CommonCore;

class DBtoFASTA {
    var config : DBtoFASTAConfig;
    var cb : DBtoFASTAResponse->Void;
    var response : DBtoFASTAResponse;

    public function new(config : DBtoFASTAConfig, cb : DBtoFASTAResponse->Void) {
        this.config = config;
        this.cb = cb;

        this.response = new DBtoFASTAResponse(null);
    }

    public function run(){
        var p : Provider = CommonCore.getDefaultProvider();

        debug('Fetching sequences for ' + config.getDatabaseName());

        p.getByNamedQuery('FETCH_PROTEINS',[config.getDatabaseName()], saturn.core.domain.Molecule, false, function(objs : Array<saturn.core.domain.Molecule>, error : String){
            ('Objects fetched ' + objs.length).debug();

            if(error != null){
                response.setError(error);

                done();
            }else{
                opentemp('sequences_', function(error : String, fd : saturn.core.Util.Stream, path : String){
                    if(error != null){
                        response.setError(error);

                        done();
                    }else{
                        path.debug();

                        var added = 10;
                        var limit = config.getLimit();

                        for(obj in objs){
                            if(obj.sequence != null){
                                fd.write('>' + obj.name + '\n' + obj.sequence + '\n');

                                if(limit != -1 && limit == added){
                                    debug('Breaking');
                                    break;
                                }else{
                                    added++;
                                }
                            }
                        }

                        fd.end(function(error : String){
                            if(error != null){
                                response.setError(error);

                                done();
                            }else{
                                response.setFastaFilePath(path);

                                done();
                            }
                        });
                    }
                });
            }
        });
    }

    public function done(){
        debug('Workflow item finished');
        cb(response);
    }

    public static function query(config : DBtoFASTAConfig, cb : DBtoFASTAResponse->Void){
        var runner = new DBtoFASTA(config, cb);

        runner.run();
    }
}

class DBtoFASTAConfig extends saturn.workflow.Object {
    var databaseName : String;
    var type : SequenceType;
    var limit : Int;

    public function new(databaseName : String, type : SequenceType){
        super();

        this.databaseName = databaseName;
        this.type = type;
        this.limit = -1;
    }

    public function setLimit(limit : Int){
        this.limit = limit;
    }

    public function getLimit() : Int {
        return limit;
    }

    public function getDatabaseName() : String {
        return this.databaseName;
    }
}

enum SequenceType {
    PROTEIN;
    DNA;
}

class DBtoFASTAResponse extends saturn.workflow.Object {
    var fastaFilePath : String;

    public function new(fastaFilePath : String){
        super();

        this.fastaFilePath = fastaFilePath;
    }

    public function setFastaFilePath(path : String){
        this.fastaFilePath = path;
    }

    public function getFastaFilePath() : String {
        return this.fastaFilePath;
    }
}
