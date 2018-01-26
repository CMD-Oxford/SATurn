/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.util;

import StringTools;

class StringUtils extends StringTools{
    public static function getRepeat(txt : String, count : Int) {
		var stringBuf : StringBuf = new StringBuf();
		for (i in 0...count) {
			stringBuf.add(txt);
		}
		return stringBuf.toString();
	}

    public static function reverse(txt : String){
        var cols :Array<String> = txt.split('');
        cols.reverse();
        return cols.join('');
    }
}
