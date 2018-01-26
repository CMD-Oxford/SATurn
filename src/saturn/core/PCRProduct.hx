/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;
import saturn.core.exceptions.LocusPrimerMissingException;
import saturn.core.exceptions.MultiLocusPrimerException;
import saturn.util.StringUtils;

class PCRProduct extends DNA {	
	var theSequenceMinusExtensions : String;
	
	var theForwardPrimer : Primer;
	var theReversePrimer : Primer;
	
	var theSrcDNA : DNA;
	
	public function new(srcDNA : DNA, fPrimer : Primer, rPrimer : Primer) {
		super("");
		
		
		theSrcDNA = srcDNA;
		theReversePrimer = rPrimer;
		theForwardPrimer = fPrimer;
		
		if (srcDNA != null) {
			calculateProduct();
		}
	}
	
	public function setForwardPrimer(fPrimer : Primer) {
		theForwardPrimer = fPrimer;
	}
	
	public function setReversePrimer(rPrimer : Primer) {
		theReversePrimer = rPrimer;
	}
	
	public function setTemplate(template : DNA) {
		theSrcDNA = template;
	}
	
	public function calculateProduct() {
		/**
		 * Forward Primer: Validation
		 */
		var fPrimerSequence : String = theForwardPrimer.getPrimerSequence( false );
		
		var fLocusCount : Int = theSrcDNA.getLocusCount( fPrimerSequence );
		if ( fLocusCount > 1 ) {
			throw new MultiLocusPrimerException('The forward primer sequence ' + fPrimerSequence + ' is present '
													+ fLocusCount + ' in the source DNA sequence', theForwardPrimer );
		}
		
		var startPosition : Int = theSrcDNA.getFirstPosition( theForwardPrimer.getPrimerSequence(false) );
		if ( startPosition == -1 ) {
			throw new LocusPrimerMissingException( 'The forward primer sequence ' 
								+ fPrimerSequence + ' is not present in the source DNA sequence', theForwardPrimer );
		}
		
		var icSrcDNA : DNA = new DNA(theSrcDNA.getInverseComplement());
		
		/**
		 * Reverse Primer: Validation
		 */
		var rPrimerSequence : String = theReversePrimer.getPrimerSequence( false );
		
		var rLocusCount : Int = icSrcDNA.getLocusCount( rPrimerSequence );
		if ( rLocusCount > 1 ) {
			throw new MultiLocusPrimerException('The reverse primer sequence ' + rPrimerSequence + ' is present '
													+ rLocusCount + ' in the source DNA sequence', theReversePrimer );
		}
		
		var endPosition : Int = icSrcDNA.getFirstPosition( theReversePrimer.getPrimerSequence(false) );
		
		if ( endPosition > -1 ) {
			endPosition = theSrcDNA.getLength() - endPosition; //reposition on srcDNA strand
		}else {
			throw new LocusPrimerMissingException( 'The reverse primer sequence ' 
								+ rPrimerSequence + ' is not present in the source DNA sequence', theReversePrimer );
		}
		
		var fExtension : String = theForwardPrimer.get5PrimeExtensionSequence();
		var rExtension : String = new DNA(theReversePrimer.get5PrimeExtensionSequence()).getInverseComplement();
	
		theSequenceMinusExtensions = theSrcDNA.getSequence().substring(startPosition, endPosition);
		
		setSequence(fExtension + theSequenceMinusExtensions + rExtension);
	}
	
	public function getPCRProduct( includePrimerExtensions : Bool ) : String {
		if (includePrimerExtensions) {
			return getSequence();
		}else {
			return theSequenceMinusExtensions;
		}
	}
	
	public function getForwardPrimer() : Primer {
		return theForwardPrimer;
	}
	
	public function getReversePrimer() : Primer {
		return theReversePrimer;
	}
}