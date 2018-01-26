/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.plugins;

import saturn.core.FastaEntity;
import saturn.client.ProgramPlugin.BaseProgramPlugin;
import saturn.client.core.CommonCore;

class FASTAGridVarPlugin extends BaseProgramPlugin<GridVarViewer> {
    override public function openFile(file : Dynamic, next : Dynamic) : Void{
        var ext = CommonCore.getFileExtension(file.name);

        if(ext == 'fasta'){
            CommonCore.getFileAsText(file, function(content){
                var entities : Array<FastaEntity> = FastaEntity.parseFasta(content);

                if(entities.length > 0){
                    content = entities[0].getSequence().split('').join('\n');

                    var prog : GridVarViewer = getProgram();
                    prog.getDataTable().performPaste(content, [0, 0]);
                }
            });
        }else{
            next();
        }
    }
}
