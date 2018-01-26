/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

class DoubleDigest extends DNA{
	var theTemplate : DNA;
	var theRes1 : RestrictionSite;
	var theRes2 : RestrictionSite;
	
	var leftProduct : DNA;
	var centerProduct : DNA;
	var rightProduct : DNA;
	
	public function new(template : DNA, res1 : RestrictionSite, res2: RestrictionSite) {
		theTemplate = template;
		
		theRes1 = res1;
		theRes2 = res2;
		
		if(template !=null){
			digest();
		}
		
		super('');
	}
	
	public function setTemplate(template : DNA) {
		theTemplate = template;
	}
	
	public function setRestrictionSite1(res1 : RestrictionSite) {
		theRes1 = res1;
	}
	
	public function setRestrictionSite2(res2 : RestrictionSite) {
		theRes2 = res2;
	}
	
	public function digest() : Void {
		var cutSeq : String = theRes1.getAfterCutSequence(theTemplate);
		cutSeq = theRes2.getLastBeforeCutSequence(new DNA(cutSeq));
		
		centerProduct = new DNA(cutSeq);
		
		leftProduct = new DNA(theRes1.getBeforeCutSequence(theTemplate));
		rightProduct = new DNA(theRes2.getLastAfterCutSequence(theTemplate));
	}
	
	public function getLeftProduct() : DNA {
		return leftProduct;
	}
	
	public function getCenterProduct() : DNA {
		return centerProduct;
	}
	
	public function getRightProduct() : DNA {
		return rightProduct;
	}
}