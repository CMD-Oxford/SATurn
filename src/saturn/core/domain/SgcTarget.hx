/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.domain;

#if CLIENT_SIDE
import saturn.client.WorkspaceApplication;
import saturn.client.workspace.WONKAWO;
#end


class SgcTarget extends DNA{
    public var targetId : String;
    public var id : Int;
    public var gi : String;
    public var dnaSeq : String;
    public var proteinSeq : String;
    public var geneId : String;
    public var activeStatus : String;
    public var pi : String;
    public var comments : String;
    public var proteinSequenceObj : Protein;
    public var complexComments : String;
    public var eln : String;
    public var complex : String;
    public var complexOverride : String;

    public function new(){
        super(null);

        setup();
    }

    public function setup(){
        setSequence(dnaSeq);

        setName(targetId);

        sequenceField = 'dnaSeq';

        if(proteinSequenceObj == null){
            proteinSequenceObj = new Protein(null);
        }

        addProtein('Translation', proteinSequenceObj);
    }

    override public function proteinSequenceUpdated(sequence : String){
        proteinSeq = sequence;
    }

    override public function setSequence(sequence : String){
        super.setSequence(sequence);

        dnaSeq = sequence;
    }

    public function loadWonka(){
        #if CLIENT_SIDE
        var so = new WONKASession();
        so.src = '/WONKA/' + targetId + '/Summarise';
        var wo = new WONKAWO(so, 'WONKA ' + targetId);

        WorkspaceApplication.getApplication().getWorkspace().addObject(wo, true);
        #end
    }
}