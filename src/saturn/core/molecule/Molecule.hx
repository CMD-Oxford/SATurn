/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.molecule;

import saturn.core.domain.MoleculeAnnotation;

class Molecule {
    static var newLineReg  = ~/\n/g;
    static var carLineReg = ~/\r/g;
    static var whiteSpaceReg = ~/\s/g;
    static var reg_starReplace = ~/\*/;

    var sequence :String;
    var starPosition : Int;
    var originalSequence : String;
    public var linkedOriginField : String;
    public var sequenceField : String;

    var floatAttributes : Map<String,Float>;
    var stringAttributes : Map<String,String>;

    var name : String;
    var alternativeName : String;

    public var annotations : Map<String, Array<MoleculeAnnotation>>;
    public var rawAnnotationData : Map<String, Dynamic>;
    public var annotationCRC : Map<String, String>;

    var crc : String;

    public var allowStar = false;
    public var parent :Dynamic;
    public var linked = false;

    public function new(seq :String){
        floatAttributes = new Map<String, Float>();
        stringAttributes = new Map<String, String>();

        annotations = new Map<String, Array<MoleculeAnnotation>>();
        rawAnnotationData = new Map<String, Dynamic>();
        annotationCRC = new Map<String, String>();

        setSequence(seq);
    }

    public function getValue() : Dynamic{
        return getSequence();
    }

    public function isLinked() : Bool{
        return linked;
    }

    public function setParent(parent : Dynamic){
        this.parent = parent;
    }

    public function getParent() : Dynamic {
        return this.parent;
    }

    public function isChild() : Bool{
        return this.parent != null;
    }

    public function setCRC(crc : String){
        this.crc = crc;
    }

    public function updateCRC(){
        if(sequence != null){
            this.crc = haxe.crypto.Md5.encode(sequence);
        }
    }

    public function getAnnotationCRC(annotationName : String){
        return annotationCRC.get(annotationName);
    }

    public function getCRC() : String{
        return this.crc;
    }

    public function setRawAnnotationData(rawAnnotationData : Dynamic, annotationName : String){
        this.rawAnnotationData.set(annotationName, rawAnnotationData);
    }

    public function getRawAnnotationData(annotationName : String) : Dynamic{
        return this.rawAnnotationData.get(annotationName);
    }

    public function setAllAnnotations(annotations : Map<String, Array<MoleculeAnnotation>>){
        removeAllAnnotations();

        for(annotationName in annotations.keys()){
            setAnnotations(annotations.get(annotationName), annotationName);
        }
    }

    public function removeAllAnnotations(){
        for(annotationName in annotations.keys()){
            annotations.remove(annotationName);
            annotationCRC.remove(annotationName);
        }
    }

    public function setAnnotations(annotations : Array<MoleculeAnnotation>, annotationName :String){
        this.annotations.set(annotationName, annotations);

        this.annotationCRC.set(annotationName, getCRC());
    }

    public function getAnnotations(name : String){
        return this.annotations.get(name);
    }

    public function getAllAnnotations() : Map<String,Array<MoleculeAnnotation>>{
        return this.annotations;
    }

    public function getAlternativeName() : String{
        return alternativeName;
    }

    public function setAlternativeName(altName : String){
        this.alternativeName = altName;
    }

    public function getMoleculeName() : String {
        return name;
    }

    public function setMoleculeName(name : String){
        this.name = name;
    }

    public function getName() : String{
        return getMoleculeName();
    }

    public function setName(name :String){
        setMoleculeName(name);
    }

    public function getSequence() : String {
        return sequence;
    }

    public function setSequence(seq : String) : Void {
        if(seq != null){
            seq = seq .toUpperCase();

            seq = whiteSpaceReg.replace(seq, "");
            seq = newLineReg.replace(seq,"");
            seq = carLineReg.replace(seq, "");

            starPosition = seq.indexOf('*');

            if(!allowStar){
                originalSequence = seq;

                seq = reg_starReplace.replace(seq, '');
            }

            this.sequence = seq;
        }

        updateCRC();
    }

    /**
	 * Method returns the position of nucSeq within this DNA sequence.
	 *
	 * @param	nucSeq
	 * @return ( -1 if the sequence is missing )
	 */
    public function getFirstPosition( seq : String ) : Int {
        return sequence.indexOf( seq );
    }

    public function getLastPosition( seq : String) : Int {
        if (seq == '') return -1;

        var c : Int = 0;

        var lastMatchPos :Int = -1;
        var lastLastMatchPos : Int = -1;

        while ( true ) {
            lastMatchPos = sequence.indexOf(seq, lastMatchPos + 1);

            if ( lastMatchPos != -1  ) {
                lastLastMatchPos = lastMatchPos;

                c++;
            }else {
                break;
            }
        }

        return lastLastMatchPos;
    }

    public function getLocusCount( seq : String ) : Int {
        if (seq == '') return 0;

        var c : Int = 0;

        var lastMatchPos :Int = -1;

        while ( true ) {
            lastMatchPos = sequence.indexOf(seq, lastMatchPos + 1);

            if ( lastMatchPos != -1  ) {
                c++;
            }else {
                break;
            }
        }

        return c;
    }

    public function contains(seq : String) : Bool{
        if ( sequence.indexOf( seq ) > -1 ) {
            return true;
        }else {
            return false;
        }
    }

    /**
	 * Method returns the length
	 * @return
	 */
    public function getLength() : Int {
        return this.sequence.length;
    }

    /**
	 * Returns the position of the cleavage site (zero-based)
	 * @return
	 */
    public function getStarPosition() : Int {
        return starPosition;
    }

    /**
	 * Set the position of the cleavage site (zero-based)
	 * @param	starPosition
	 */
    public function setStarPosition(starPosition : Int) : Void {
        this.starPosition = starPosition;
    }

    public function getStarSequence() :String{
        return originalSequence;
    }

    /**
	 * Returns true if the sequence and star position of both restriction sites match
	 * @param	other
	 * @return
	 */
    public function equals(other : RestrictionSite) : Bool {
        if (other.getStarPosition() != getStarPosition()) {
            return false;
        }else if (getSequence() != other.getSequence()) {
            return false;
        }

        return true;
    }

    /*
	 * Returns the nucleotide position before the cut (1 counting) and after cut (0 couting)
	 * @param	template
	 */
    public function getCutPosition(template : Molecule) {
        if (template.getLocusCount(getSequence())> 0) {
            var siteStartPosition = template.getFirstPosition(getSequence());
            return siteStartPosition + starPosition;
        }else {
            return -1;
        }
    }

    /**
	 * Get the sequence after the cut position
	 * @param	template
	 */
    public function getAfterCutSequence(template : Molecule) {
        var cutPosition : Int = getCutPosition(template);

        if (cutPosition == -1) {
            return '';
        }else {
            var seq : String = template.getSequence();
            return seq.substring(cutPosition, seq.length );
        }
    }

    /**
	 * Get the sequence before the cut position
	 * @param	template
	 */
    public function getBeforeCutSequence(template : Molecule) {
        var cutPosition : Int = getCutPosition(template);

        if (cutPosition == -1) {
            return '';
        }else {
            var seq : String = template.getSequence();
            return seq.substring(0, cutPosition );
        }
    }

    /**
	 * Returns the nucleotide position before the cut (1 counting) and after cut (0 couting)
	 * @param	template
	 */
    public function getLastCutPosition(template : Molecule) {
        if (template.getLocusCount(getSequence())> 0) {
            var siteStartPosition = template.getLastPosition(getSequence());
            return siteStartPosition + starPosition;
        }else {
            return -1;
        }
    }

    /**
	 * Get the sequence before the last occurrence of the cut position
	 * @param	template
	 */
    public function getLastBeforeCutSequence(template : Molecule) {
        var cutPosition : Int = getLastCutPosition(template);

        if (cutPosition == -1) {
            return '';
        }else {
            var seq : String = template.getSequence();
            return seq.substring(0, cutPosition);
        }
    }

    /**
	 * Get the sequence after the last occurrence of the cut position
	 * @param	template
	 */
    public function getLastAfterCutSequence(template : Molecule) {
        var cutPosition : Int = getLastCutPosition(template);

        if (cutPosition == -1) {
            return '';
        }else {
            var seq : String = template.getSequence();
            return seq.substring(cutPosition, seq.length);
        }
    }

    public function getCutProduct(template : Molecule,direction :CutProductDirection){
        if(direction == CutProductDirection.UPSTREAM){
            return getBeforeCutSequence(template);
        }else if(direction == CutProductDirection.DOWNSTREAM){
            return getAfterCutSequence(template);
        }else if(direction == CutProductDirection.UPDOWN){
            var startPos = getCutPosition(template);
            var endPos = getLastCutPosition(template) - getLength();

            return template.getSequence().substring(startPos, endPos);
        }else {
            return null;
        }
    }

    public function getFloatAttribute(attr : MoleculeFloatAttribute) : Float{
        return _getFloatAttribute(Std.string(attr));
    }

    public function _getFloatAttribute(attributeName : String){
        if(floatAttributes.exists(attributeName)){
            return floatAttributes.get(attributeName);
        }

        return null;
    }

    public function setValue(value : String){
        setSequence(value);
    }

    public function _setFloatAttribute(attributeName : String, val : Float){
        floatAttributes.set(attributeName,val);
    }

    public function setFloatAttribute(attr : MoleculeFloatAttribute, val : Float){
        _setFloatAttribute(Std.string(attr),val);
    }

    public function getStringAttribute(attr : MoleculeStringAttribute) : String{
        return _getStringAttribute(Std.string(attr));
    }

    public function _getStringAttribute(attributeName : String){
        if(stringAttributes.exists(attributeName)){
            return stringAttributes.get(attributeName);
        }

        return null;
    }

    public function _setStringAttribute(attributeName : String, val : String){
        stringAttributes.set(attributeName, val);
    }

    public function setStringAttribute(attr : MoleculeStringAttribute, val : String) {
        return _setStringAttribute(Std.string(attr), val);
    }

    public function getMW() : Float{
        return getFloatAttribute(MoleculeFloatAttribute.MW);
    }

    public function findMatchingLocuses(locus : String, ?mode = null) : Array<LocusPosition>{
        var collookup_single = ~/^(\d+)$/;

        if(collookup_single.match(locus)){
            var num = collookup_single.matched(1);

            var locusPosition = new LocusPosition();
            locusPosition.start = Std.parseInt(num) - 1;
            locusPosition.end = locusPosition.start;

            return [locusPosition];
        }

        var collookup_double = ~/^(\d+)-(\d+)$/;

        if(collookup_double.match(locus)){
            var locusPosition = new LocusPosition();
            locusPosition.start = Std.parseInt(collookup_double.matched(1)) - 1;
            locusPosition.end = Std.parseInt(collookup_double.matched(2)) -1;

            return [locusPosition];
        }

        var collookup_toend = ~/^(\d+)-$/;
        if(collookup_toend.match(locus)){
            var locusPosition = new LocusPosition();
            locusPosition.start = Std.parseInt(collookup_toend.matched(1)) - 1;
            locusPosition.end = getLength() -1;

            return [locusPosition];
        }

        var re_missMatchTotal = ~/^(\d+)(.+)/;

        if(mode == null){
            mode = MoleculeAlignMode.REGEX;

            if(re_missMatchTotal.match(locus)){
                mode = MoleculeAlignMode.SIMPLE;
            }
        }


        if(mode == MoleculeAlignMode.REGEX){
            return findMatchingLocusesRegEx(locus);
        }else if (mode == MoleculeAlignMode.SIMPLE){
            var missMatchesAllowed = 0;

            if(re_missMatchTotal.match(locus)){
                missMatchesAllowed = Std.parseInt(re_missMatchTotal.matched(1));
                locus = re_missMatchTotal.matched(2);
            }

            return findMatchingLocusesSimple(locus, missMatchesAllowed);
        }else{
            return null;
        }
    }

    public function findMatchingLocusesSimple(locus : String, ?missMatchesAllowed : Int = 0) : Array<LocusPosition>{
        var positions :Array<LocusPosition> = new Array<LocusPosition>();

        if(locus == null || locus == ''){
            return positions;
        }

        var currentMissMatches = 0;

        var seqI = -1; //sequence position
        var lI = -1; //locus position

        var startPos = 0; //start if current block

        var missMatchLimit = missMatchesAllowed + 1;

        var missMatchPositions = new Array<Int>();

        while(true){
            lI++;
            seqI++;

            if(seqI > sequence.length -1){
                break;
            }

            if(locus.charAt(lI) != sequence.charAt(seqI)){
                currentMissMatches++;

                missMatchPositions.push(seqI);
            }

            if(lI == 0){
                startPos = seqI;
            }

            if(currentMissMatches == missMatchLimit){
                seqI = startPos;
                lI = -1;
                currentMissMatches = 0;
                missMatchPositions = new Array<Int>();
            }else if(lI == locus.length-1){
                var locusPosition = new LocusPosition();
                locusPosition.start = startPos;
                locusPosition.end = seqI;
                locusPosition.missMatchPositions = missMatchPositions;

                positions.push(locusPosition);

                lI = -1;
                currentMissMatches = 0;

                missMatchPositions = new Array<Int>();
            }
        }

        return positions;
    }

    public function findMatchingLocusesRegEx(regex : String) : Array<LocusPosition>{
        var r = new EReg(regex, "i");

        var positions :Array<LocusPosition> = new Array<LocusPosition>();

        if(regex == null || regex == ''){
            return positions;
        }

        var offSet = 0;

        var matchAgainst = sequence;
        while(matchAgainst != null){
            if(r.match(matchAgainst)){
                var locusPosition = new LocusPosition();

                var match = r.matchedPos();

                locusPosition.start = match.pos + offSet;

                locusPosition.end = match.pos + match.len -1 + offSet;

                offSet = locusPosition.end + 1;

                matchAgainst = r.matchedRight();

                positions.push(locusPosition);
            }else{
                break;
            }
        }

        return positions;
    }

    public function updateAnnotations(annotationName, config: Dynamic, annotationManager, cb :String->Array<MoleculeAnnotation>->Void){
        if(getAnnotationCRC(annotationName) == getCRC()){
           cb(null, getAnnotations(annotationName));
        }else{
            annotationManager.annotateMolecule(this, annotationName, config, function(err : Dynamic, res : Array<MoleculeAnnotation>){
                cb(err, res);
            });
        }
    }
}

enum MoleculeFloatAttribute{
    MW;
    MW_CONDESATION;
}

enum MoleculeStringAttribute{
    NAME;
}

