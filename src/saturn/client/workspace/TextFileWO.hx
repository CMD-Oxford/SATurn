/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.workspace;

import saturn.core.TextFile;
import saturn.client.workspace.Workspace;

class TextFileWO extends WorkspaceObjectBase<TextFile>{
    public static var FILE_IMPORT_FORMATS : Array<String> = [];

    public function new(object : Dynamic, name : String){
        if(object == null){
            object = new TextFile();
        }

        if(name == null){
            name="TextFile";
        }

        super(object, name);
    }

    public static function getNewMenuText() : String {
        return "TextFile";
    }

    public static function getDefaultFolderName() : String{
        return "TextFiles";
    }
}
