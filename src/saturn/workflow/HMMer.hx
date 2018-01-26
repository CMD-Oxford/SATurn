/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.workflow;


import saturn.client.core.CommonCore;
#if NODE
import saturn.app.SaturnServer;
import saturn.core.Generator;
import saturn.core.parsers.HmmerParser;
import saturn.core.domain.MoleculeAnnotation;
import saturn.core.parsers.BaseParser;
import saturn.core.domain.MoleculeAnnotation.Uploader;
#end
import saturn.core.Util.Stream;
using saturn.core.Util;

import saturn.core.Util.*;

class HMMer extends Unit<HMMerResponse, HMMerConfig>{
    var hmmPath = 'bin/hmmer';
    var hmmSearchPath : String;

    public function new(config : HMMerConfig, cb : HMMerResponse->Void) {
        super(config,cb);

        this.response = new HMMerResponse();

        hmmSearchPath = hmmPath + '/hmmsearch';
    }

    public function getHMMPath() : String{
        return hmmPath;
    }

    public function getHMMSearchPath() : String{
        return hmmSearchPath;
    }

    override public function _run(){
        if(config.getProgram() == HMMerProgram.HMMSEARCH){
            runHMMSearch();
        }else if(config.getProgram() == HMMerProgram.HMMUPLOAD){
            runUpload();
        }else{
            debug('Unknown program: ' + config.getProgram());
        }
    }

    public function runHMMSearch(){
        debug('Running HMMSearch');

        var fastaFile = config.getParameter('fastaFilePath');

        if(fastaFile != null){
            var data : Dynamic = config.getData();

            opentemp('hmm_table_', function(error : String, stream : Stream, path_table : String){
                if(error != null){
                    response.setError(error);
                }else{
                    opentemp('hmm_raw_', function(error : String, stream : Stream, path_raw : String){
                        if(error != null){
                            response.setError(error);
                        }else{
                            var args = ['--domtblout', path_table, '--noali', '-o', path_raw, config.getParameter('hmmFilePath'), config.getParameter('fastaFilePath')];

                            debug(args.join(','));

                            exec(this.hmmSearchPath, args, function(code : Int){
                                if(code != 0){
                                    response.setError('An error has occurred running HMMSearch');

                                    done();
                                }else{
                                    if(config.isRemote()){
                                        #if NODE
                                        SaturnServer.makeStaticAvailable(path_table, function(err : String, path: String){
                                            if(err == null){
                                                response.setTableOutputPath(path);
                                            }else{
                                                response.setError(err);
                                            }

                                            done();
                                        });
                                        #else
                                            done();
                                        #end

                                    }else{
                                        response.setTableOutputPath(path_table);
                                        response.setRawOutputPath(path_raw);

                                        done();
                                    }
                                }


                            });
                        }
                    });
                }
            });
        }else{
            response.setError('fastaFilePath missing!');
            done();
        }
    }

    public function runUpload(){
        #if NODE
        var uploader = new Uploader('PFAM', 0.0000001);

        var p = getProvider();
        p.setAutoCommit(false, function(err : String){
            var parser = new HmmerParser(config.getParameter('tableOutputPath'), uploader.next, function(err :String){
                if(err == null){
                    p.commit(function(err: String){
                        if(err != null){
                            response.setError(err);
                        }else{
                            debug('Commit called');
                        }

                        done();
                    });
                }else{
                    response.setError(err);
                    done();
                }
            });
        });

        #end
    }

    public static function query(config : HMMerConfig, cb : HMMerResponse->Void){
        debug('HMMer query started');

        var runner = new HMMer(config, cb);

        runner.run();
    }
}

class HMMerConfig extends Object {
    var hmmFilePath : String;
    var fastaFilePath : String;
    var tableOutputPath : String;
    var fastaContent : String;

    var program : HMMerProgram;

    public function new(program : HMMerProgram){
        super();

        this.program = program;
    }

    public function getProgram() : HMMerProgram{
        return program;
    }

    public function setProgram(program : HMMerProgram) {
        this.program = program;
    }

    public function setHMMPath(hmmFilePath : String){
        this.hmmFilePath = hmmFilePath;
    }

    public function setFastaFilePath(fastaFilePath : String){
        this.fastaFilePath = fastaFilePath;
    }

    public function setFastaContent(fastaContent : String){
        this.fastaContent = fastaContent;
    }

    override public function setup(cb : Dynamic->Void){
        if(fastaFilePath == null && fastaContent != null){
            opentemp('fasta_file_', function(error : String, stream : Stream, path : String){
                if(error == null){
                    stream.write(fastaContent);
                }

                fastaFilePath = path;

                cb(error);
            });
        }
    }
}

enum HMMerProgram {
    HMMSEARCH;
    HMMUPLOAD;
}

class HMMerResponse extends Object {
    var tableOutputPath : String;
    var rawOutputPath : String;

    public function new(){
        super();

        tableOutputPath = 'Test';
    }

    public function setTableOutputPath(path :String){
        tableOutputPath = path;
    }

    public function getTableOutputPath() : String{
        return tableOutputPath;
    }

    public function setRawOutputPath(path : String){
        rawOutputPath = path;
    }

    public function getRawOutputPath() : String{
        return rawOutputPath;
    }
}
