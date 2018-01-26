/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;
import saturn.core.BasePrimer;
import saturn.util.StringUtils;

class PrimerRegistry {
	private static var defaultInstance = new PrimerRegistry();
	
	private var primers : Map<String, Primer>;
	
	public static function getDefaultInstance() : PrimerRegistry {
		return defaultInstance;
	}
	
	public function new() {
		primers =  new Map<String, Primer>();
		registerDefaultPrimers();
	}
	
	public function registerDefaultPrimers() {
		//var primer : Primer = new Primer('');
		
		//primer.set5PrimeExtension('TTAAGAAGGAGATATACTATG');
		//primer.setValidate5PrimeExtensionInFrame(true);
		
		//addPrimer(Std.string(BasePrimer.LIC_FORWARD), primer);
		
		//var primer2 : Primer = new Primer('');
		
		//primer2.set5PrimeExtension('GATTGGAAGTAGAGGTTCTCTGC');
		//primer2.setValidate5PrimeExtensionInFrame(true);
		
		//addPrimer(Std.string(BasePrimer.LIC_REVERSE), primer2);
		
		var attB1 : Primer = new Primer('');
		attB1.set5PrimeExtension('GGGGACAAGTTTGTACAAAAAAGCAGGCT');
		attB1.setValidate5PrimeExtensionInFrame(false);
		
		addPrimer(Std.string(BasePrimer.ATT_B1), attB1);
		
		var attB2 : Primer = new Primer('');
		attB2.set5PrimeExtension('GGGGACCACTTTGTACAAGAAAGCTGGGT');
		attB2.setValidate5PrimeExtensionInFrame(false);
		
		addPrimer(Std.string(BasePrimer.ATT_B2), attB2);
	}
	
	public function getPrimerTypes() {
		var primerTypes : Array<String> = new Array<String>();
		
		for (primerType in primers.keys()) {
			primerTypes.push(primerType);
		}
		return primerTypes;
	}
	
	public function autoConfigurePrimer(primer :Primer) {
		for (primerType in getPrimerTypes()) {
			var basePrimer : Primer = getPrimer(primerType);
			
			var primer5Ext : String = basePrimer.get5PrimeExtensionSequence();
			
			if (primer.getSequence().indexOf(primer5Ext) != -1) {
				primer.set5PrimeExtensionLength(primer5Ext.length);
				primer.setType(primerType);
			}
		}
	}
	
	public function addPrimer(name : String, primer : Primer) {
		primers.set(name, primer);
	}
	
	public function removePrimer(name : String) {
		primers.remove(name);
	}
	
	public function getPrimer(name : String) {
		if (primers.exists(name)) {
			return primers.get(name).clonePrimer();
		}else{
			return null;
		}
	}
	
	public function getBasePrimer(primer : BasePrimer) {
		return getPrimer(Std.string(primer));
	}
}