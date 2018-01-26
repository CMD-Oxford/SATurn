/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

import saturn.core.domain.Entity;
class ReactionComponent {
    public var id : Int;
    public var position : Int;

    public var reactionRoleId: Int;
    public var entityId : Int;
    public var reactionId : Int;

    public var reaction : Reaction;
    public var reactionRole : ReactionRole;
    public var entity : Entity;

    public function new() {

    }
}
