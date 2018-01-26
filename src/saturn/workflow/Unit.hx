/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.workflow;

import saturn.core.Util.*;

class Unit<T : saturn.workflow.Object, C : saturn.workflow.Object> {
    var response : T;
    var config : C;
    var cb : T->Void;

    public function new(config : C, cb : T->Void) {
        this.cb = cb;
        this.config = config;
    }

    public function done(){
        debug('Workflow item finished');

        cb(response);
    }

   function setup(cb : Dynamic->Void){
        if(config != null){
            config.setup(cb);
        }else{
            cb(null);
        }
    }

    public function run(){
        setup(function(err : Dynamic){
            if(err != null){
                response.setError(err);

                done();
            }else{
                _run();
            }
        });
    }

    public function _run(){

    }
}
