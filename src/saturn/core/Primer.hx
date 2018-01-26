/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

import saturn.core.DNA;
import saturn.util.StringUtils;

/**
 * Class Primer
 * 
 * Use class to represent primers, note that all methods/attributes of the DNA class are
 * available on this class.
 * 
 * Synopsis [ Primer Basics ]
 * 
 * var primer : Primer = new Primer('GCC')
 * print primer.getPrimerSequence(false)
 *  > GCC
 * 
 * Synopsis [ Primer Extensions ]
 * 
 * Method 1: Setting primer extension via Primer.setPrimerExtensionLength
 * 
 * var primer : Primer = new Primer('ATTGCC')
 * 
 * primer.setPrimerExtensionLength(3)
 * print primer.getPrimerSequence(false)
 *  >GCC
 * print primer.getPrimerSequence(true)
 *  >ATTGCC
 * 
 * Method 2: Setting primer extension via Primer.setPrimerExtensionSequence()
 * 
 * var primer : Primer = new Primer('GCC')
 * 
 * primer.setPrimerExtensionSequence('ATT')
 * print primer.getPrimerSequence(false)
 *  >GCC
 * print primer.getPrimerSequence(true)
 *  >ATTGCC 
 */

class Primer extends DNA {
	var extLength : Int = -1;
	
	var val_extInFrame : Bool = false;
	
	var theType : String;
	
	/**
	 * Create a new primer object with the specified nucleotide sequence
	 * @param	nucSeq
	 */
	public function new(nucSeq : String) {
		super(nucSeq);
		
		setSequence(nucSeq);
	}
	
	/**
	 * Set the number of 5' nucleotides considered to be a 5' extension.
	 * (e.g. a LIC site)
	 * 
	 * @param	length
	 */
	public function set5PrimeExtensionLength(length : Int) {
		extLength = length;
	}
	
	/**
	 * Get the number of 5' nucleotides considered to be part of a 5' extension
	 * 
	 * @return
	 */
	public function get5PrimeExtensionLength() : Int {
		return extLength;
	}
	
	/**
	 * Set a 5' nucleotide extension sequence by concating extNucSeq with getSequence()
	 * 
	 * @param	extNucSeq
	 */
	public function set5PrimeExtension( extNucSeq : String ) {
		var rawPrimer : String = getSequence();
		
		if (rawPrimer == null) {
			rawPrimer = '';
		}
		
		setSequence(extNucSeq +  rawPrimer);
		
		set5PrimeExtensionLength(extNucSeq.length);
	}
	
	/**
	 * Returns true if a 5' nucleotide extension has been set.
	 * 
	 * @return
	 */
	public function has5PrimeExtension() : Bool {
		return extLength > 0 ? true : false;
	}
	
	/**
	 * Returns the 5' nucleotide extension sequence if one has been set.
	 * 
	 * Otherwise returns an empty string.
	 */
	public function get5PrimeExtensionSequence() {
		if (extLength > -1) {
			return getSequence().substr(0, extLength);
		}else {
			return '';
		}
	}
	
	/**
	 * Append nucleotides to the 3' end of the current primer.
	 * 
	 * @param	postSeq
	 */
	public function extend3Prime(postSeq : String) {
		var primerExtensionSeq : String = get5PrimeExtensionSequence();
		
		setSequence(postSeq);
		set5PrimeExtension(primerExtensionSeq);
	}
	
	/**
	 * Return true if the primer has a 5' extension which has been further extended
	 * (e.g. a LIC base-primer has been extended).  Returns false otherwise.
	 * 
	 * @return
	 */
	public function is3PrimeExtended() : Bool {
		if (has5PrimeExtension()) {
			if (get5PrimeExtensionLength() < getLength()) {
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Returns the 3' extension sequence if one has been set otherwise returns an empty string.
	 * @return
	 */
	public function get3PrimeExtendedSequence() : String {
		if (has5PrimeExtension()) {
			if (get5PrimeExtensionLength() < getLength()) {
				return sequence.substring(get5PrimeExtensionLength(), getLength());
			}
		}
		
		return '';
	}
	
	/**
	 * Returns the primer nucleotide sequence either with or without the 5' 
	 * extension sequence if one has been set.
	 * 
	 * @param	includeExtensionRegion
	 */
	public function getPrimerSequence(includeExtensionRegion : Bool) {
		var rawPrimer : String = getSequence();
		if (extLength == -1 || includeExtensionRegion) {
			return rawPrimer;
		}else {
			return rawPrimer.substring(extLength, rawPrimer.length);
		}
	}
	
	/**
	 * Sets whether or not the 5' nucleotide extension sequence should be in
	 * frame.  Assumes the first ATG encountered after the 5' extension is
	 * the start codon.
	 * 
	 * @param	validate
	 */
	public function setValidate5PrimeExtensionInFrame(validate : Bool) {
		val_extInFrame = validate;
	}
	
	/**
	 * Returns true if the primer is valid and false otherwise.
	 * 
	 * What exactly constitutes a valid primer depends on the primer class
	 * implementation and any calls that have been made to methods like 
	 * setValidate5PrimeExtensionInFrame.
	 * 
	 * @throws HaxeException
	 * @return
	 */
	public function isValid() : Bool {
		if (has5PrimeExtension()) {
			if (val_extInFrame) {
				if (is3PrimeExtended()) {
					var postSequence : String = get3PrimeExtendedSequence();
					if (postSequence.length < 3) {
						return false;
					}else {
						var frameCheck : DNA = new DNA(postSequence);

						var pos : Int = frameCheck.getFirstStartCodonPositionByFrame(GeneticCodes.STANDARD, Frame.ONE);

						if (pos == -1) {
							return false;
						}else {
							return true;
						}
					}	
				}else {
					return false;
				}
			}
		}
		
		return true;
	}
	
	/**
	 * Returns a clone of the current primer object
	 * @return
	 */
	public function clonePrimer() :Primer {
		var newPrimer : Primer = new Primer(getPrimerSequence(true));
		newPrimer.set5PrimeExtensionLength(get5PrimeExtensionLength());
		newPrimer.val_extInFrame = this.val_extInFrame;
		
		return newPrimer;
	}
	
	public function setType(type :String) {
		theType = type;
	}
	
	public function getType() {
		return theType;
	}
}