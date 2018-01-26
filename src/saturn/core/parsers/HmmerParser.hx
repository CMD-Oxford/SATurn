/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.parsers;

import saturn.core.domain.Entity;
import saturn.core.domain.MoleculeAnnotation;

import saturn.core.Util.*;

using saturn.core.Util;

class HmmerParser extends BaseParser<MoleculeAnnotation>{
    var colSep = ~/\s+/g;

    override function parseLine(line : String) : Dynamic{
        if(line.indexOf('#') == 0 || line == ''){
            return null;
        }else{
            var cols = colSep.split(line);

            var queryName = cols[0];
            var domainDescr = cols[3];
            var domainName = cols[4];
            var start = cols[19];
            var stop = cols[20];
            var evalue = Std.parseFloat(cols[6]);
            var cdevalue = Std.parseFloat(cols[11]);

            var entity = new Entity(); entity.entityId = queryName;
            var referent = new Entity(); referent.entityId = domainName; referent.altName = domainDescr;

            var annotation = new MoleculeAnnotation();
            annotation.entity = entity;
            annotation.referent = referent;
            annotation.start = Std.parseInt(start);
            annotation.stop = Std.parseInt(stop);
            annotation.evalue = cdevalue;
            annotation.altevalue =  evalue;

            return annotation;
        }
    }
}
