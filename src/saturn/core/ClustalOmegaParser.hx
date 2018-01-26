/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

class ClustalOmegaParser {
    public static function read(content : String) : MSA{
        var msaMap = new Map<String, String>();

        var wr = ~/\s+/g;

        if(content != null){
            var lines :Array<String> = content.split('\n');

            var seqOrder = new Array<String>();

            var s = -1;

            for(i in 3...lines.length){
                var line = lines[i];

                line = StringTools.replace(line, '\n','');
                line = StringTools.replace(line, '\r','');

                if(line != ''){
                    var cols = wr.split(line);

                    if(cols.length <= 1){
                        continue;
                    }else if(cols[0] == ''){
                        cols[0] = ' ';
                    }

                    if(s == -1){
                        s = line.length - cols[1].length;
                    }

                    if(!msaMap.exists(cols[0])){
                        msaMap.set(cols[0], line.substr(s, line.length));

                        seqOrder.push(cols[0]);
                    }else{
                        msaMap.set(cols[0], msaMap.get(cols[0]) + line.substr(s, line.length));
                    }
                }
            }

            return new MSA(msaMap, seqOrder);
        }else{
            return new MSA();
        }
    }
}