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
import haxe.Json;
#end

class SaturnSession {
    public var id : Int;
    public var userName : String;
    public var isPublic : String;
    public var sessionContent : String;
    public var sessionName : String;
    public var user : User;

    public function new() {

    }

    public function load(cb : Dynamic-> Void){
        #if CLIENT_SIDE
        var rawSession = Json.parse(this.sessionContent);

        WorkspaceApplication.getApplication().getWorkspace()._openWorkspace(rawSession);
        #end
    }

    public function getShortDescription() : String {
        if(user != null){
            return user.fullname + ' - ' + sessionName.split('-')[1];
        }else{
            return sessionName;
        }

    }
}
