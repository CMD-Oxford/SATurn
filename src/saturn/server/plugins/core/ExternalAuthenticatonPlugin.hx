/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.core;

import saturn.db.provider.hooks.ExternalJsonHook;
import saturn.core.User;
import saturn.core.Util;

import js.Node;

class ExternalAuthenticationPlugin implements AuthenticationManager{
    var config : Dynamic;

    public function new(config){
        this.config = config;
    }

    public function authenticate(username : String, password : String, onSuccess : User->Void, onFailure : String->Void, src :Dynamic) : Void{
        var hookConfig :Dynamic = config.external_hook;

        var authObj = [{
            'username': username,
            'password': password,
            'mode': 'authenticate',
            'src': src
        }];

        ExternalJsonHook.run('Authenticate', authObj, null, function(objs, error){
            if(error != null){
                Util.debug(error);
                onFailure('Internal server error');
            }else{
                Util.debug('Authentication manager returned');
                var authResponse = objs[0];
                if(authResponse.outcome == 'success'){
                    var user = new User();

                    user.firstname = authResponse.firstName;
                    user.lastname = authResponse.lastName;
                    user.email = authResponse.email;
                    user.projects = authResponse.projects;

                    Util.debug('Returning success');
                    onSuccess(user);
                }else{
                    Util.debug('Returning error');
                    onFailure('Unable to authenticate');
                }
            }
        }, hookConfig);
    }
}