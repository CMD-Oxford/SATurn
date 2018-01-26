/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.util;

import Math;
import StdTypes;
import Std;

class MathUtils {
    public static function logX(num : Float, x : Int) : Float {
        return Math.log(num)/Math.log(x);
    }

    public static function sigFigs( num : Float, figs : Int) : Float {        
        var places : Int =Std.int(Math.pow(10,figs));
        
        var forRound : Float = num * places;
        
        var afterRound : Float = Math.round(forRound);
        
        return afterRound/places;
    }
}