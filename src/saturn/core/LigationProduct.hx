/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

class LigationProduct extends DNA{
	var theAcceptor : DoubleDigest;
	var theDonor : DoubleDigest;
	
	public function new( acceptor : DoubleDigest, donor :  DoubleDigest) {
		theAcceptor = acceptor;
		theDonor = donor;
		
		super('');
		
		calculateProduct();
	}
	
	public function calculateProduct() {
		setSequence(
			theAcceptor.getLeftProduct().getSequence() + 
			theDonor.getCenterProduct().getSequence() + 
			theAcceptor.getRightProduct().getSequence());
	}
}