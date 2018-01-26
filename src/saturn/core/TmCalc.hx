/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

class TmCalc {
    private var deltaHTable : Map<String, Int>;
	private var deltaSTable : Map<String, Float>;
	private var endHTable : Map<String, Float>;
	private var endSTable : Map<String, Float>;
	
	public function new(){
		this.deltaHTable = new Map<String, Int>();
		this.deltaSTable = new Map<String, Float>();
		this.endHTable = new Map<String, Float>();
		this.endSTable = new Map<String, Float>();
		populateDeltaHTable();
		populateDeltaSTable();
		populateEndHTable();
		populateEndSTable();
	}
	
	private function populateDeltaHTable() {
		deltaHTable.set("AA", -7900);
		deltaHTable.set("TT", -7900);
		deltaHTable.set("AT", -7200);
		deltaHTable.set("TA", -7200);
		deltaHTable.set("CA", -8500);
		deltaHTable.set("TG", -8500);
		deltaHTable.set("GT", -8400);
		deltaHTable.set("AC", -8400);
		deltaHTable.set("CT", -7800);
		deltaHTable.set("AG", -7800);
		deltaHTable.set("GA", -8200);
		deltaHTable.set("TC", -8200);
		deltaHTable.set("CG", -10600);
		deltaHTable.set("GC", -9800);
		deltaHTable.set("GG", -8000);
		deltaHTable.set("CC", -8000);
	}
	
	private function populateDeltaSTable() {
		deltaSTable.set("AA", -22.2);
		deltaSTable.set("TT", -22.2);
		deltaSTable.set("AT", -20.4);
		deltaSTable.set("TA", -21.3);
		deltaSTable.set("CA", -22.7);
		deltaSTable.set("TG", -22.7);
		deltaSTable.set("GT", -22.4);
		deltaSTable.set("AC", -22.4);
		deltaSTable.set("CT", -21.0);
		deltaSTable.set("AG", -21.0);
		deltaSTable.set("GA", -22.2);
		deltaSTable.set("TC", -22.2);
		deltaSTable.set("CG", -27.2);
		deltaSTable.set("GC", -24.4);
		deltaSTable.set("GG", -19.9);
		deltaSTable.set("CC", -19.9);
	}
	
	private function populateEndHTable() {
		endHTable.set("A", 2300);
		endHTable.set("T", 2300);
		endHTable.set("G", 100);
		endHTable.set("C", 100);
	}
	
	private function populateEndSTable() {
		endSTable.set("A", 4.1);
		endSTable.set("T", 4.1);
		endSTable.set("G", -2.8);
		endSTable.set("C", -2.8);
	}
	
	public function getDeltaH(primerSeq : DNA){
		var dnaSeq : String = primerSeq.getSequence();
		var seqLen = dnaSeq.length;
		var startNuc = dnaSeq.charAt(0);
		var endNuc = dnaSeq.charAt(seqLen-1);
		var startH = endHTable.get(startNuc);
		var endH = endHTable.get(endNuc);
		var deltaH : Float = startH + endH;
		
		for (i in 1...seqLen) {
			var currNuc : String = dnaSeq.charAt(i);
			var currH = deltaHTable.get(startNuc + currNuc);
			startNuc = currNuc;
			deltaH = deltaH + currH;
		}
		
		return deltaH;
	}
	
	public function getDeltaS(primerSeq : DNA){
		var dnaSeq : String = primerSeq.getSequence();
		var seqLen = dnaSeq.length;
		var startNuc = dnaSeq.charAt(0);
		var endNuc = dnaSeq.charAt(seqLen-1);
		var startS = endSTable.get(startNuc);
		var endS = endSTable.get(endNuc);
		var deltaS : Float = startS + endS;
		
		for (i in 1...seqLen) {
			var currNuc : String = dnaSeq.charAt(i);
			var currS = deltaSTable.get(startNuc + currNuc);
			startNuc = currNuc;
			deltaS = deltaS + currS;
		}
		
		return deltaS;
	}
	
	public function saltCorrection(primerSeq : DNA, saltConc : Float) {
		var saltPenalty = 0.368;
		var dnaSeq : String = primerSeq.getSequence();
		var seqLen = dnaSeq.length;
		
		saltConc = saltConc / 1000.0;
		
		var lnSalt : Float = Math.log(saltConc);
		
		var deltaS = getDeltaS(primerSeq);
		var saltCorrDeltaS = deltaS + (saltPenalty * (seqLen - 1) * lnSalt);
	
		return saltCorrDeltaS;
	}
	
	/*
	 *  tmCalculation returns the Tm of the given primer seq at the specified saltConc (mM) and primerConc (nM)
	 * */
	public function tmCalculation(primerSeq : DNA, saltConc : Float, primerConc : Float) : Float {
		var deltaH = getDeltaH(primerSeq);
		var saltCorrDeltaS = saltCorrection(primerSeq, saltConc);
		var gasConst : Float = 1.987;
		var lnPrimerConc = Math.log((primerConc / 1000000000) / 2);
		var tmKelvin = deltaH / (saltCorrDeltaS + gasConst * lnPrimerConc);
		var tmCelcius = tmKelvin - 273.15;
		
		if (tmCelcius > 75) {
			return 75;
		} else {
			return tmCelcius;
		}
	}
}