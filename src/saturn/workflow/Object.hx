/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.workflow;

using saturn.core.Util;


class Object {
    var error : String;

    var data : saturn.workflow.Object;
    var response : saturn.workflow.Object;

    var remote = false;

    public function new() {

    }

    public function setRemote(remote : Bool){
        this.remote = remote;
    }

    public function isRemote() : Bool{
        return this.remote;
    }

    public function getParameter(param : String){
        var data : Dynamic = getData();

        if(data != null && Reflect.hasField(data, param)){
            return Reflect.field(data, param);
        }else if(Reflect.hasField(this, param)){
            return Reflect.field(this, param);
        }else{
            return null;
        }
    }

    public function setError(error  : String){
        error.debug();

        this.error = error;
    }

    public function getError() : String {
        return this.error;
    }

    public function setData(data : saturn.workflow.Object){
        this.data = data;
    }

    public function getData() : saturn.workflow.Object {
        return this.data;
    }

    public function getResponse() : saturn.workflow.Object {
        return this.response;
    }

    public function setResponse(resp : saturn.workflow.Object){
        this.response = resp;
    }

    public function setup(cb : Dynamic->Void){

    }
}
