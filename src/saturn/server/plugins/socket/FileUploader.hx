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
import js.Node.NodePath;
import js.Node;
import bindings.NodeTemp;
import bindings.NodeFSExtra;
import bindings.Ext.NodeSocket;

import saturn.server.plugins.socket.core.BaseServerSocketPlugin;

import com.dongxiguo.continuation.Continuation;
@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":cps"))
class FileUploader  extends BaseServerSocketPlugin{
    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);

        registerListener('upload', function(data : Dynamic, socket : NodeSocket){upload(data, socket, function(){});});
    }

    @:cps public function upload(data : Dynamic, socket: NodeSocket) : Void{
        var binaryData = new NodeBuffer(data.fileContents, 'base64');
        var extension = data.extension;

        var err, binary_info = @await NodeTemp.open('abi_conversion_');
        if(err != null){
            handleError(data, err); return;
        }

        var err = @await Node.fs.writeFile(binary_info.path, binaryData);
        if(err != null){
            handleError(data, err); return;
        }

        var outputFileName = binary_info.path;

        var serveFileName : String = saturn.getRelativePublicOuputFolder() + '/' + this.saturn.pathLib.basename(outputFileName) + '.' + extension;
        var returnPath : String = saturn.getRelativePublicOuputURL() + '/' + this.saturn.pathLib.basename(outputFileName) + '.' + extension;
        var err = @await NodeFSExtra.copy(outputFileName, serveFileName);

        sendJson(data, {url: returnPath}, null);
    }
}