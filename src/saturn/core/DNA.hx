/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

import haxe.ds.StringMap;
import haxe.ds.HashMap;
import saturn.core.molecule.Molecule;
import saturn.util.HaxeException;
import saturn.core.molecule.MoleculeConstants;
import Std;


class DNA extends Molecule{
    public var protein : Protein;

    public var proteins : StringMap<Protein> = new StringMap<Protein>();

    public function addProtein(name : String, protein : Protein){
        if(protein != null){
            proteins.set(name, protein);
        }
    }

    public function removeProtein(name : String){
        proteins.remove(name);
    }

    public function getProtein(name : String): Protein{
        return proteins.get(name);
    }

    public function getProteinNames() : Array<String>{
        var names = new Array<String>();
        for(name in proteins.keys()){
            names.push(name);
        }

        return names;
    }

	/**
	 * Method returns the fraction of nucleotides that are GC
	 * @return
	 */
    public function getGCFraction() : Float {
        var dnaComposition : DNAComposition = this.getComposition();
        
        return (dnaComposition.cCount+dnaComposition.gCount)/this.getLength();
    }

    var reg_tReplace =~/T/g;

    public function convertToRNA() : String {
        return reg_tReplace.replace(getSequence(), 'U');
    }
    
	/**
	 * Method returns the number of hydrogen bonds
	 * @return
	 */
    public function getHydrogenBondCount() : Int {
        var dnaComposition : DNAComposition = this.getComposition();
        
        return ((dnaComposition.gCount+dnaComposition.cCount)*3)
                + ((dnaComposition.aCount+dnaComposition.tCount)*2);
    }
    
	/**
	 * Method returns the molecular weight
	 * @param	phosphateAt5Prime
	 * @return
	 */
    public function getMolecularWeight(phosphateAt5Prime : Bool) : Float {
        var dnaComposition : DNAComposition = this.getComposition();
        
        var seqMW : Float = 0.0;
        
        seqMW += dnaComposition.aCount * MoleculeConstants.aChainMW;
        seqMW += dnaComposition.tCount * MoleculeConstants.tChainMW;
        seqMW += dnaComposition.gCount * MoleculeConstants.gChainMW;
        seqMW += dnaComposition.cCount * MoleculeConstants.cChainMW;
        
        if(phosphateAt5Prime==false){
            seqMW -= MoleculeConstants.PO3;
        }
        
        seqMW += MoleculeConstants.OH;
        
        return seqMW;
    }

    override public function setSequence(sequence : String) {
        super.setSequence(sequence);

        if(isChild()){
            var p : Protein = getParent();
            p.dnaSequenceUpdated(this.sequence);
        }
    }

    public function proteinSequenceUpdated(sequence : String){

    }
    
	/**
	 * Method returns the composition as a DNAComposition object
	 * @return
	 */
    public function getComposition() : DNAComposition {
        var aCount : Int = 0;
        var tCount : Int = 0;
        var gCount : Int = 0;
        var cCount : Int = 0;
        
        var seqLen=this.sequence.length;
        
        for(i in 0...seqLen){
            var nuc : String = this.sequence.charAt(i);
            
            switch (nuc) {
                case 'A':
                    aCount++;
                case 'T' :
                    tCount++;
                case 'G' :
                    gCount++;
                case 'C' :
                    cCount++;
                case 'U' :
                    tCount++;
            }
        }
        
        return new DNAComposition(aCount, tCount, gCount, cCount);
    }
    
	/**
	 * Method returns the melting temperature 
	 * @return
	 */
    public function getMeltingTemperature() : Float {
        //var composition : DNAComposition = this.getComposition();
        //return ( 4 * ( composition.cCount + composition.gCount ) ) + ( 2 * (composition.aCount + composition.tCount) );
        //return ((41.0*(this.getNumGC()-16.4))/(this.getLength())+64.9);

        var saltConc = 50;

        var primerConc = 500; //300

        var testTmCalc : TmCalc = new TmCalc();

        return testTmCalc.tmCalculation(this, saltConc, primerConc);
    }

    public function findPrimer(startPos: Int, minLength : Int, maxLength : Int, minMelting : Float, maxMelting : Float, ?extensionSequence : String = null, ?minLengthExtended : Int = -1, ?minMeltingExtended : Float = -1, ?maxMeltingExtentded : Float=-1){
        var cCount, gCount, tCount, aCount = 0;

        var seq = sequence.substr(startPos-1, minLength-1);

        var comp = new DNA(seq).getComposition();

        cCount = comp.cCount;
        gCount = comp.gCount;
        tCount = comp.tCount;
        aCount = comp.aCount;

        var rangeStart = startPos-1+minLength-1;
        var rangeStop = rangeStart + maxLength;

        for(i in rangeStart...rangeStop){
            var char = sequence.charAt(i);

            if(char == 'C'){
                cCount++;
            }else if(char == 'G'){
                gCount++;
            }else if(char == 'A'){
                aCount++;
            }else if(char == 'T'){
                tCount++;
            }

            seq += char;

            var mt = new DNA(seq).getMeltingTemperature();//( 4 * (cCount + gCount ) ) + ( 2 * (aCount + tCount) );

            if(mt > maxMelting){
                throw new HaxeException('Maximum melting temperature exceeded');
            }else if(mt >= minMelting && mt <= maxMelting){
                if(extensionSequence == null){
                    return seq;
                }else{
                    var completeSequence = new DNA(extensionSequence + seq);
                    var completeMT = completeSequence.getMeltingTemperature();

                    if(completeMT >= minMeltingExtended && completeMT <= maxMeltingExtentded && completeSequence.getLength() >= minLengthExtended){
                        return seq;
                    }else if(completeMT < minMeltingExtended){
                        continue;
                    }else if(completeMT > maxMeltingExtentded){
                        throw new HaxeException('Maximum melting temperature for extended primer sequence exceeded');
                    }else if(completeSequence.getLength() < minLengthExtended){
                        continue;
                    }
                }
            }
        }

        throw new HaxeException('Unable to find region with required parameters');
    }

	/**
	 * Method returns the number of GC nucleotides
	 * @return
	 */
    public function getNumGC() : Int {
        var seqLen=this.sequence.length;

        var gcNum : Int=0;

        for(i in 0...seqLen){
            var nuc : String = this.sequence.charAt(i);

            if(nuc=='G' || nuc=='C'){
                gcNum++;
            }
        }

        return gcNum;
    }

	/**
	 * Method returns the inverse string sequence
	 * @return
	 */
    public function getInverse() :String {
        var newSequence : StringBuf=new StringBuf();
        
        var seqLen=this.sequence.length;
        
        for(i in 0...seqLen){
            var j=seqLen-i-1;
            
            var nuc : String = this.sequence.charAt(j);
            
            newSequence.add(nuc);
        }
        
        return newSequence.toString();
    }
    
	/**
	 * Method returns the complement string sequence
	 * @return
	 */
    public function getComplement() :String {
        var newSequence : StringBuf=new StringBuf();
        
        var seqLen=this.sequence.length;
        
        for(i in 0...seqLen){
            var nuc : String = this.sequence.charAt(i);
            
            switch (nuc) {
                case 'A':
                    nuc = 'T';
                case 'T' :
                    nuc = 'A';
                case 'G' :
                    nuc = 'C';
                case 'C' :
                    nuc = 'G';
            }
            
            newSequence.add(nuc);
        }
        
        return newSequence.toString();
    }
    
	/**
	 * Method returns the string inverse complement
	 * @return
	 */
    public function getInverseComplement() :String {
        var newSequence : StringBuf=new StringBuf();
        
        var seqLen=this.sequence.length;
        
        for(i in 0...seqLen){
            var j=seqLen-i-1;
            
            var nuc : String = this.sequence.charAt(j);
            
            switch (nuc) {
                case 'A':
                    nuc = 'T';
                case 'T' :
                    nuc = 'A';
                case 'G' :
                    nuc = 'C';
                case 'C' :
                    nuc = 'G';
            }
            
            newSequence.add(nuc);
        }
        
        return newSequence.toString();
    }


    public function getFirstStartCodonPosition(geneticCode : GeneticCodes){
        var geneticCode : GeneticCode = GeneticCodeRegistry.getRegistry().getGeneticCodeByEnum(geneticCode);
        var codons = geneticCode.getStartCodons();

        var minStartPos = -1;
        for(codon in codons.keys()){
            var index = sequence.indexOf(codon);
            if(index > -1){
                if(minStartPos == -1 || minStartPos > index){
                    minStartPos = index ;
                }
            }
        }

        return minStartPos;
    }

    @:throws('sgc.HaxeException', 'sgc.molbio.DNA.InvalidCodonException') 
	
	/**
	 * Method returns the translation starting at offSetPosition using the supplied genetic code
	 * @param	geneticCode
	 * @param	offSetPosition
	 * @return
	 */
    public function getTranslation(geneticCode : GeneticCodes, offSetPosition : Int = 0, stopAtFirstStop : Bool) : String {
        if(!this.canHaveCodons()) throw new HaxeException("Unable to translate a sequence with less than 3 nucleotides");
        
        var proteinSequenceBuffer : StringBuf = new StringBuf();
        
        var seqLength : Int = this.sequence.length;
        
        var finalCodonPosition = seqLength - ((seqLength-offSetPosition) % 3);
        
        var geneticCode : GeneticCode = GeneticCodeRegistry.getRegistry().getGeneticCodeByEnum(geneticCode);
        
        var startIndex : Int = offSetPosition;

        var stopCodons = geneticCode.getStopCodons();

        while(startIndex < finalCodonPosition){ //should be <= but see below explanation of +2/+3
            var endIndex : Int = startIndex + 3; //+3 rather than +2 as substring goes to endIndex-1 
            
            var codon : String = this.sequence.substring(startIndex, endIndex);
            
            var code : String = geneticCode.lookupCodon(codon);

            if(stopAtFirstStop && code == '!'){
                break;
            }
            
            proteinSequenceBuffer.add(code);
            
            startIndex = endIndex;
        }
        
        return proteinSequenceBuffer.toString();
    }
    
    @:throws('sgc.HaxeException', 'sgc.molbio.DNA.InvalidCodonException') 
	
	/**
	 * Method returns the translation for the supplied frame and genetic code
	 * @param	geneticCode
	 * @param	frame
	 * @return
	 */
    public function getFrameTranslation(geneticCode : GeneticCodes, frame : Frame) : String{
        if(sequence == null){
            return null;
        }

        var offSetPos : Int = 0;
        
        if(frame == Frame.TWO){
            offSetPos = 1;
        }else if(frame == Frame.THREE){
            offSetPos = 2;
        }

        return getTranslation(geneticCode, offSetPos, true);
    }
    
    /**
     * Returns a Hash containing each of the three possible frames3
     *  = Keys =
     *  ONE = First frame
     *  TWO = Second frame
     *  Three = Third frame
     */
    @:throws('sgc.HaxeException', 'sgc.molbio.DNA.InvalidCodonException') 
    public function getThreeFrameTranslation(geneticCode : GeneticCodes) : Map<String, String>{
        var threeFrameTranslations : Map<String, String> = new Map<String, String>();
        
        threeFrameTranslations.set(Std.string(Frame.ONE), getFrameTranslation(geneticCode, Frame.ONE));
        threeFrameTranslations.set(Std.string(Frame.TWO), getFrameTranslation(geneticCode, Frame.TWO));
        threeFrameTranslations.set(Std.string(Frame.THREE), getFrameTranslation(geneticCode, Frame.THREE)); 
        
        return threeFrameTranslations;
    }
    
    /**
     * Returns a Has containing each of the six possible frames (three in each direction)
     * = Keys =
     *  ONE = First frame
     *  TWO = Second frame
     *  Three = Third frame
     *  ONE_IC = First inverse complement frame
     *  TWO_IC = Second inverse complement frame
     *  Three_IC = Third inverse complement frame
     */
    @:throws('sgc.HaxeException', 'sgc.molbio.DNA.InvalidCodonException')
    public function getSixFrameTranslation(geneticCode: GeneticCodes) : Map<String, String>{
        var forwardFrames = getThreeFrameTranslation(geneticCode);
        
        var dnaSeq : String = getInverseComplement();
        
        var inverseComplementDNAObj : DNA = new DNA(dnaSeq);
        
        var reverseFrames = inverseComplementDNAObj.getThreeFrameTranslation(geneticCode);
        
        forwardFrames.set('ONE_IC', reverseFrames.get('ONE'));
        forwardFrames.set('TWO_IC', reverseFrames.get('TWO'));
        forwardFrames.set('THREE_IC', reverseFrames.get('THREE'));
        
        return forwardFrames;
    }
    
    /**
     * Returns the position of the first start codon or -1 if one isn't found
     * @param	geneticCode
     * @param	frame
     * @return
     */
    public function getFirstStartCodonPositionByFrame(geneticCode: GeneticCodes, frame : Frame) : Int {
        var startCodons : Array<Int> = this.getStartCodonPositions(geneticCode, frame, true);
        
        if(startCodons.length == 0){
            return -1;
        }else{
            return startCodons[0];
        }
    }
    
    /**
     * Returns empty list if no starting codons can be found in the frame requested.
     */
    @:throws('ac.uk.sgc.ox.sgc.HaxeException')
    public function getStartCodonPositions(geneticCode : GeneticCodes, frame : Frame, stopAtFirst : Bool) : Array<Int> {
        var offSet = 0;
        
        if(frame==Frame.TWO){
            offSet = 1;
        }else if(frame==Frame.THREE){
            offSet = 2;           
        }
        
        var seqLength : Int = this.sequence.length;
        
        var startingIndex = offSet;
        
        if(seqLength<startingIndex+3) throw new HaxeException("Insufficient DNA length to find codon start position for frame "+Std.string(frame));
        
        var startCodonPositions : Array<Int> = new Array<Int>();
        
        var finalCodonPosition = seqLength - ((seqLength-offSet) % 3);
        
        var geneticCode : GeneticCode = GeneticCodeRegistry.getRegistry().getGeneticCodeByEnum(geneticCode);
        
        var startIndex : Int = startingIndex;
        
        while(startIndex < finalCodonPosition){ //should be <= but see below explanation of +2/+3
            var endIndex : Int = startIndex + 3; //+3 rather than +2 as substring goes to endIndex-1 
            
            var codon : String = this.sequence.substring(startIndex, endIndex);
            
            if(geneticCode.isStartCodon(codon)){
                startCodonPositions.push(startIndex);
                
                if(stopAtFirst){
                    break;
                }
            }
            
            startIndex = endIndex;
        }
        
        return startCodonPositions;
    }
    
    public function getFirstStopCodonPosition(geneticCode: GeneticCodes, frame : Frame) : Int {
        var startCodons : List<Int> = this.getStopCodonPositions(geneticCode, frame, true);
        
        if(startCodons.isEmpty()){
            return -1;
        }else{
            return startCodons.first();
        }
    }
    
    public function getStopCodonPositions(geneticCode : GeneticCodes, frame : Frame, stopAtFirst : Bool){
        var offSet = 0;
        
        if(frame==Frame.TWO){
            offSet = 1;
        }else if(frame==Frame.THREE){
            offSet = 2;           
        }
        
        var seqLength : Int = this.sequence.length;
        
        var startingIndex = offSet;
        
        if(seqLength<startingIndex+3) throw new HaxeException("Insufficient DNA length to find codon start position for frame "+Std.string(frame));
        
        var startCodonPositions : List<Int> = new List<Int>();
        
        var finalCodonPosition = seqLength - ((seqLength-offSet) % 3);
        
        var geneticCode : GeneticCode = GeneticCodeRegistry.getRegistry().getGeneticCodeByEnum(geneticCode);
        
        var startIndex : Int = startingIndex;
        
        while(startIndex < finalCodonPosition){ //should be <= but see below explanation of +2/+3
            var endIndex : Int = startIndex + 3; //+3 rather than +2 as substring goes to endIndex-1 
            
            var codon : String = this.sequence.substring(startIndex, endIndex);
            
            if(geneticCode.isStopCodon(codon)){
                startCodonPositions.add(startIndex);
                
                if(stopAtFirst){
                    break;
                }
            }
            
            startIndex = endIndex;
        }
        
        return startCodonPositions;
    }
    
    public function canHaveCodons() : Bool {
        return this.sequence.length >= 3 ? true : false;
    }

    public function getFrameRegion(frame : Frame, start : Int, stop : Int) : String{
        var dnaStart, dnaStop : Int;

        if(frame == Frame.ONE){
            dnaStart = start * 3 - 2;
            dnaStop = stop * 3;
        }else if(frame == Frame.TWO){
            dnaStart = start * 3 - 1;
            dnaStop = stop * 3 + 1;
        }else if(frame == Frame.THREE){
            dnaStart = start * 3 ;
            dnaStop = stop * 3 + 2;
        }else{
            return null;
        }

        return sequence.substring(dnaStart - 1, dnaStop);
    }

    public function mutateResidue(frame : Frame, geneticCode : GeneticCodes, pos : Int, mutAA : String){
        var nucPos = getCodonStartPosition(frame, pos);

        if(nucPos >= sequence.length){
            throw new HaxeException('Sequence not long enough for requested frame and position');
        }

        var geneticCode : GeneticCode = GeneticCodeRegistry.getRegistry().getGeneticCodeByEnum(geneticCode);

        var codon = geneticCode.getFirstCodon(mutAA);

        return sequence.substring(0, nucPos -1) + codon + sequence.substring(nucPos+2, sequence.length);
    }

    public function getCodonStartPosition(frame : Frame, start : Int){
        var dnaStart : Int;

        if(frame == Frame.ONE){
            dnaStart = start * 3 - 2;
        }else if(frame == Frame.TWO){
            dnaStart = start * 3 - 1;
        }else if(frame == Frame.THREE){
            dnaStart = start * 3 ;
        }else{
            return null;
        }

        return dnaStart;
    }

    public function getCodonStopPosition(frame : Frame, stop : Int){
        var dnaStop : Int;

        if(frame == Frame.ONE){
            dnaStop = stop * 3;
        }else if(frame == Frame.TWO){
            dnaStop = stop * 3 + 1;
        }else if(frame == Frame.THREE){
            dnaStop = stop * 3 + 2;
        }else{
            return null;
        }

        return dnaStop;
    }

    public function getRegion(start : Int, stop : Int){
        return sequence.substr(start-1, stop - start +1);
    }

    public function getFrom(start : Int, len : Int){
        return sequence.substr(start-1, len);
    }

    override public function findMatchingLocuses(regex : String, ? mode = null) : Array<LocusPosition>{
        var direction = Direction.Forward;

        if(StringTools.startsWith(regex, 'r')){
            var templateIC = new DNA(getInverseComplement());

            var regexIC = regex.substring(1, regex.length);

            var positions = templateIC.findMatchingLocuses(regexIC, mode);

            var length = getLength();

            for(position in positions){
                var originalStart = position.start;
                position.start = (length-1) - position.end;
                position.end = (length-1) - originalStart;

                if(position.missMatchPositions != null){
                    var fPositions = new Array<Int>();
                    for(position in position.missMatchPositions){
                        fPositions.push(length - 1 - position);
                    }

                    position.missMatchPositions = fPositions;
                }
            }

            return positions;
        }else{
            return super.findMatchingLocuses(regex);
        }
    }
}

enum Frame {
    ONE;
    TWO;
    THREE;
}

class Frames {
    public static function toInt(frame : Frame){
       return switch(frame){
                case ONE : 0;
                case TWO : 1;
                case THREE : 2;
       }
    }
}

enum Direction {
    Forward;
    Reverse;
}

class DNAComposition {
    public var aCount : Int;
    public var tCount : Int;
    public var gCount : Int;
    public var cCount : Int;
        
    public function new(aCount, tCount, gCount, cCount){
        this.aCount=aCount;
        this.tCount=tCount;
        this.gCount=gCount;
        this.cCount=cCount;
    }
}

class GeneticCode {
    private var codonLookupTable : Map<String, String>;
    private var aaToCodonTable : Map<String, List<String>>;
    private var startCodons : Map<String, String>;
    private var stopCodons : Map<String, String>;
    
    public function new(){
        this.codonLookupTable = new Map<String, String>();
        this.aaToCodonTable = new Map<String, List<String>>();
        startCodons = new Map<String, String>();
        
        stopCodons = new Map<String, String>();
        
        populateTable();
    }
    
    public function addStartCodon(codon : String){
        startCodons.set(codon, "1");
    }
    
    public function isStartCodon(codon : String) : Bool{
        return startCodons.exists(codon);
    }
    
    public function addStopCodon(codon : String){
        stopCodons.set(codon, "1");
    }
    
    public function isStopCodon(codon : String) : Bool{
        return stopCodons.exists(codon);
    }
    
    public function getStopCodons() : Map<String, String>{
        return stopCodons;
    }
    
    public function getCodonCount() : Int {
        return Lambda.count(codonLookupTable);
    }
    
    public function getStartCodons() : Map<String, String> {
        var clone : Map<String, String> = new Map<String, String>();
        
        for(key in startCodons.keys()){
            clone.set(key, startCodons.get(key));
        }
        
        return clone;
    }
    
    private function populateTable(){
        
    }
    
    @:throws('sgc.molbio.DNA.InvalidCodonException') 
    public function lookupCodon(codon : String ) : String {
        if(this.codonLookupTable.exists(codon)){
            return this.codonLookupTable.get(codon);
        }else{
            return "?";
        }
    }
    
    public function getCodonLookupTable() : Map<String, String>{
        return this.codonLookupTable;
    }
    
    public function getAAToCodonTable() : Map<String, List<String>>{
        return this.aaToCodonTable;
    }

    public function getFirstCodon(aa : String) : String {
        if(this.aaToCodonTable.exists(aa)){
            var codons :List<String> = this.aaToCodonTable.get(aa);
            return codons.first();
        }else{
            return null;
        }
    }
}

class StandardGeneticCode extends GeneticCode {
    private static var instance = new StandardGeneticCode();
    
    public static var standardTable : Map<String, String> = instance.getCodonLookupTable();
    public static var aaToCodon : Map<String, List<String>> = instance.getAAToCodonTable();
    
    public static function getDefaultInstance() : GeneticCode {
        return instance;
    }
    
    public function new(){
        super();
        
        super.addStartCodon("ATG");
        super.addStopCodon("TAA");
        super.addStopCodon("TGA");
        super.addStopCodon("TAG");
    }
    
    override private function populateTable(){
        codonLookupTable.set("TTT", "F");
        codonLookupTable.set("TTC", "F");
        codonLookupTable.set("TTA", "L");
        codonLookupTable.set("TTG", "L");
        codonLookupTable.set("TCT", "S");
        codonLookupTable.set("TCC", "S");
        codonLookupTable.set("TCA", "S");
        codonLookupTable.set("TCG", "S");
        codonLookupTable.set("TAT", "Y");
        codonLookupTable.set("TAC", "Y"); 
        codonLookupTable.set("TAA", "!");
        codonLookupTable.set("TAG", "!");
        codonLookupTable.set("TGT", "C");
        codonLookupTable.set("TGC", "C"); 
        codonLookupTable.set("TGA", "!"); 
        codonLookupTable.set("TGG", "W");
        codonLookupTable.set("CTT", "L");
        codonLookupTable.set("CTC", "L");
        codonLookupTable.set("CTA", "L");
        codonLookupTable.set("CTG", "L");
        codonLookupTable.set("CCT", "P");
        codonLookupTable.set("CCC", "P");
        codonLookupTable.set("CCA", "P");
        codonLookupTable.set("CCG", "P");
        codonLookupTable.set("CAT", "H");
        codonLookupTable.set("CAC", "H");
        codonLookupTable.set("CAA", "Q");
        codonLookupTable.set("CAG", "Q");
        codonLookupTable.set("CGT", "R");
        codonLookupTable.set("CGC", "R");
        codonLookupTable.set("CGA", "R");
        codonLookupTable.set("CGG", "R");
        codonLookupTable.set("ATT", "I");
        codonLookupTable.set("ATC", "I");
        codonLookupTable.set("ATA", "I");
        codonLookupTable.set("ATG", "M");
        codonLookupTable.set("ACT", "T");
        codonLookupTable.set("ACC", "T");
        codonLookupTable.set("ACA", "T");
        codonLookupTable.set("ACG", "T");
        codonLookupTable.set("AAT", "N");
        codonLookupTable.set("AAC", "N");
        codonLookupTable.set("AAA", "K");
        codonLookupTable.set("AAG", "K");
        codonLookupTable.set("AGT", "S");
        codonLookupTable.set("AGC", "S");
        codonLookupTable.set("AGA", "R");
        codonLookupTable.set("AGG", "R");
        codonLookupTable.set("GTT", "V");
        codonLookupTable.set("GTC", "V");
        codonLookupTable.set("GTA", "V");
        codonLookupTable.set("GTG", "V");
        codonLookupTable.set("GCT", "A");
        codonLookupTable.set("GCC", "A");
        codonLookupTable.set("GCA", "A");
        codonLookupTable.set("GCG", "A");
        codonLookupTable.set("GAT", "D");
        codonLookupTable.set("GAC", "D");
        codonLookupTable.set("GAA", "E");
        codonLookupTable.set("GAG", "E");
        codonLookupTable.set("GGT", "G");
        codonLookupTable.set("GGC", "G");
        codonLookupTable.set("GGA", "G");
        codonLookupTable.set("GGG", "G");
        
        for(key in codonLookupTable.keys()){
            var aa = codonLookupTable.get(key);
            
            if(!this.aaToCodonTable.exists(aa)){
                this.aaToCodonTable.set(aa, new List<String>());
            }
            
            this.aaToCodonTable.get(aa).add(key);   
        }
    }
}

class GeneticCodeRegistry {
    private var shortNameToCodeObj : Map<String, GeneticCode>;
    
    private static var CODE_REGISTRY : GeneticCodeRegistry = new GeneticCodeRegistry();
    
    public static function getRegistry() : GeneticCodeRegistry{
        return CODE_REGISTRY;
    }
    
	public static function getDefault() : GeneticCode {
		return getRegistry().getGeneticCodeByEnum(GeneticCodes.STANDARD);
	}
	
    public function new(){
        shortNameToCodeObj = new Map<String, GeneticCode>();
        
        shortNameToCodeObj.set(Std.string(GeneticCodes.STANDARD), StandardGeneticCode.getDefaultInstance());
    }
    
    public function getGeneticCodeNames() : List<String>{
        var nameList : List<String> = new List<String>();
        
        for(key in shortNameToCodeObj.keys()){
            nameList.add(key);
        }
        
        return nameList;
    }
    
    public function getGeneticCodeByName(shortName : String) : GeneticCode {
        if(!shortNameToCodeObj.exists(shortName)){
           throw new InvalidGeneticCodeException(shortName+" doesn't correspond to a genetic code in the main registry.");
        }else{
            return shortNameToCodeObj.get(shortName);
        }
    }
    
    public function getGeneticCodeByEnum(code: GeneticCodes) : GeneticCode{
        return getGeneticCodeByName(Std.string(code));
    }


}

enum GeneticCodes{
        STANDARD;
}

class InvalidGeneticCodeException extends HaxeException {
    public function new(message : String){
       super(message);  
    }
}

class InvalidCodonException extends HaxeException {
    public function new(message : String){
        super(message);
    }
}
