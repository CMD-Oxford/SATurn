/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.scarab;

/*
 * Corresponding table in database icmdb_labpage.LABPAGE_EXCEL
 *
 *  createdBy - Useful in scenarios when a new section is added by those to whom the page is
 *   shared with. This would differentiate the section from the author and helpful for the PIs
 *   when reviewing the ELN page.
 *
 *   editedBy - Useful when the ELN page is edited ferquently by other people with whom
 *   the page is shared. The reason for list is to keep track of everyone who has edited the
 *   section.
 */

class LabPageExcel extends LabPageItem {
    public var excel: Dynamic;
    public var filename: String;
    public var html: Dynamic;
    public var htmlFolder: Dynamic;

    public function new() {
        super();
    }
}
