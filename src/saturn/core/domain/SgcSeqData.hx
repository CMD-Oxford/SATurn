/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.domain;

class SgcSeqData {
    public var id : Int;
    public var type : String;
    public var sequence : String;
    public var version : Int;
    public var targetId : String;
    public var target : String;
    public var crc : String;

    public function new(){

    }

    public function setup(){
        if(sequence != null){
            crc = haxe.crypto.Md5.encode(sequence);
        }else{
            crc = '';
        }
    }
}

