/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.domain;

class Alignment {
    var objectIds : Map<String, Bool>;

    var alignmentURL : String;

    var content : String;

    var name : String;
    var id : Int;

    public function new(){
        emptyInit();
    }

    public function emptyInit(){
        objectIds = new Map<String, Bool>();
    }

    public function addObject(objectId : String){
        objectIds.set(objectId, true);
    }

    public function removeObject(objectId : String){
        objectIds.remove(objectId);
    }

    public function getAlignmentObjectIds() : Array<String>{
        var newObjectIds : Array<String> = new Array<String>();

        for(objectId in objectIds.keys()){
            newObjectIds.push(objectId);
        }

        return newObjectIds;
    }

    public function setAlignmentObjectIds(newObjectIds : Array<String>) : Void{
        objectIds = new Map<String, Bool>();

        for(objectId in newObjectIds){
            objectIds.set(objectId, true);
        }
    }

    public function objectExists(objectId : String) : Bool{
        return objectIds.exists(objectId);
    }

    public function setAlignmentURL(alignmentURL : String){
        this.alignmentURL = alignmentURL;

        this.content = null;
    }

    public function getAlignmentURL() : String{
        return this.alignmentURL;
    }

    public function setAlignmentContent(content : String){
        this.content = content;
    }

    public function getAlignmentContent() : String{
        return this.content;
    }

    public function setName(name : String){
        this.name = name;
    }
}
