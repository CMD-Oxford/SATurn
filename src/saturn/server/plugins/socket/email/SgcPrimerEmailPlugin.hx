/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.socket.email;

import saturn.core.User;
import bindings.Ext.NodeSocket;
class SgcPrimerEmailPlugin extends BaseEmailPlugin {

    public function new(emailer : EmailPlugin, config : Dynamic){
        super(emailer, config);
    }

    override private function registerListeners(){
        emailer.registerListener('sgc_primer_email', function(data : Dynamic, socket : NodeSocket){
            var user : User= emailer.getSocketUserNoAuthCheck(socket);

            var email = user.email;
            var fileName = data.fileName;
            var content = data.content;
            var description = data.description;

            var ccList : Array<String> = config.cc;

            var match = false;
            for(cc in ccList){
                if(cc == email){
                    match = true;
                }
            }

            if(!match){
                ccList.push(email);
            }

            emailer.getTransporter().sendMail({
                "sender": emailer.getConfig().from,
                "from": emailer.getConfig().from,
                "replyTo": email,
                "to": config.to,
                "cc": ccList,
                "subject": "Primer Request",
                "text": "See attached for primer request from " + user.firstname + ' ' + user.lastname + " for " + description,
                "attachments": [
                    {
                        "filename": fileName,
                        "content": content
                    }
                ]
            }, function(err){
                if(err == null){
                    emailer.sendJson(data, {error: null}, null);
                }else{
                    emailer.handleError(data, 'Unable to send email');
                }
            });
        });
    }
}