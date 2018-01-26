/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.scarab;

class LabPage {
    public var id: Int;
    public var experimentNo: String;
    public var dateStarted: Date;
    public var title: String;
    public var userId: String;
    public var elnDocumentId: Int;
    public var minEditableItem: Int;
    public var lastEdited: Date;
    public var user: Int;
    public var sharingAllowed: Bool;
    public var personalTemplate: Bool;
    public var globalTemplate: Bool;
    public var dateExperimentStarted: Date;
    public var userObj : LabPageUser;


    /*
     * List of element elements that extend LabPageItem and inherit some of the common
     * fields such as id or caption or order of display
     *
     */
    public var items: Array<LabPageItem>;

    /*
     * relatedLabPages could very well be replaced with a model in order to provide a
     * bidirectional relation to-from, I don't see the practicl requirement though.
     */
    public var relatedLabPages: Array<Int>;

    /*
     * List of userse to which this LabPage is shared
     * either referenceing the User model or the user id in which clase below
     * public var sharedTo: List<Int>
     */
    public var sharedTo: Array<User>;

   /*
    * List of tags associated with an ELN page
    */
    public var tags: Array<LabPageTag>;

    public function new() {
    }

    public function getShortDescription() :String{
        return title + ' (' + experimentNo + ')';
    }

    public static function findAll(phrase: String, cb : Array<LabPage>->String->Void){
        // 'custom_search_function' =>  'saturn.core.scarab.LabPage.findAll'
        Util.getProvider().getByNamedQuery('SCARAB_ELN_QUERY',  [phrase, phrase, phrase, phrase], LabPage,false, function(objs : Array<LabPage>, err : String){
            cb(objs, err);
        });
    }
}
