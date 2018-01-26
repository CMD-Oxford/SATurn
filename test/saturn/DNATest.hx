/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Copyright (C) 2015  Structural Genomics Consortium
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package saturn;

import saturn.core.Ligation;
import saturn.core.CutProductDirection;
import saturn.core.exceptions.LocusPrimerMissingException;
import saturn.core.exceptions.MultiLocusPrimerException;
import saturn.core.LigationProduct;
import saturn.core.PCRProduct;
import saturn.core.Protein;
import saturn.core.Primer;
import saturn.core.RestrictionSite;
import saturn.core.TmCalc;
import saturn.util.StringUtils;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import saturn.core.DNA;
import saturn.core.DNA.DNAComposition;
import saturn.core.DNA.StandardGeneticCode;
import saturn.core.DNA.GeneticCodeRegistry;
import saturn.core.DNA.GeneticCodes;
import saturn.core.DNA.InvalidGeneticCodeException;
import saturn.core.DNA.InvalidCodonException;
import saturn.core.DNA.Frame;
import saturn.core.PrimerRegistry;
import saturn.core.BasePrimer;
import saturn.core.DoubleDigest;

import saturn.util.HaxeException;
//import js.Lib;

import saturn.util.MathUtils;

class DNATest 
{
	var instance:DNA; 
	
	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{
	}
	
	@After
	public function tearDown():Void
	{
	}
	
	@Test function testGetInverse(){
	    var dna : DNA=new DNA("ATGC");
        Assert.areEqual("CGTA", dna.getInverse());
	}
	
	@Test function testGetComplement(){
        var dna : DNA=new DNA("ATGC");
        Assert.areEqual("TACG", dna.getComplement());
    }
	
	@Test
	public function testGetInverseComplement(){
	    var dna : DNA=new DNA("ATGC");
        Assert.areEqual("GCAT", dna.getInverseComplement());
	}
	
	@Test
    public function testGetNumGC(){
        var dna : DNA=new DNA("ATGCC");
        Assert.areEqual(3, dna.getNumGC());
    }
    
    @Test
    public function testGetLength(){
        var dna : DNA=new DNA("ATGCC");
        Assert.areEqual(5, dna.getLength());
    }
    
    @Test
    public function testGetMeltingTemperature(){
        var dna : DNA=new DNA("CATGTTAGACCCATG");
        Assert.areEqual(44, MathUtils.sigFigs(dna.getMeltingTemperature(),1));
        
        var dna : DNA=new DNA("CTGGATTACCAGTTAGGGATC");
        Assert.areEqual(62, MathUtils.sigFigs(dna.getMeltingTemperature(),1));
        
        var dna : DNA=new DNA("TACCAGGATTACGATGATCGATCGTGATGTTCTTTA");
        Assert.areEqual(100, MathUtils.sigFigs(dna.getMeltingTemperature(),1));
    }
    
    @Test
    public function testGetComposition(){
        var dna : DNA=new DNA("CATGTTAGACCCATG");
        var dnaComposition : DNAComposition = dna.getComposition();
     
        Assert.areEqual(4,dnaComposition.aCount);
        Assert.areEqual(4,dnaComposition.tCount);
        Assert.areEqual(3,dnaComposition.gCount);
        Assert.areEqual(4,dnaComposition.cCount);
    }    
    
    @Test
    public function testGetMolecularWeight(){
        var dna : DNA=new DNA("CATGTTAGACCCATG");
        Assert.areEqual(4552.04, dna.getMolecularWeight(false));
        
        var dna : DNA=new DNA("TACCAGGATTACGATGATCGATCGTGATGTTCTTTA");
        Assert.areEqual(11080.24, MathUtils.sigFigs(dna.getMolecularWeight(false),3));
    }
    
    @Test
    public function testGetGCFraction(){
        var dna : DNA=new DNA("CATGTTAGACCCATG");
    
        Assert.areEqual(7/(7+8), dna.getGCFraction());
    }
    
    @Test
    public function testGetHydrogenBondCount(){
        var dna : DNA=new DNA("CATGTTAGACCCATG");
    
        Assert.areEqual((7*3)+(8*2), dna.getHydrogenBondCount());
    }
    
    @Test
    public function testStandardGeneticCode(){
        Assert.areEqual("F", StandardGeneticCode.standardTable.get("TTT"));
        
        var codons : List<String> = StandardGeneticCode.aaToCodon.get("F");
        
        Assert.areEqual(2, codons.length);
		
		var found : Map<String, String> = new Map<String, String>();
		for ( codon in codons) {
			found.set(codon, '');
		}
        
        Assert.areEqual(true, found.exists("TTT"));
        Assert.areEqual(true, found.exists("TTC"));
    }
    
    @Test
    public function testGeneticCodeRegistryInit(){
        Assert.isNotNull(GeneticCodeRegistry.getRegistry());
        try{
            GeneticCodeRegistry.getRegistry().getGeneticCodeByName('STANDARD');
        }catch(exception : InvalidGeneticCodeException){
           Assert.isTrue(false);
        }
        
        var failed : Bool = false;
        try{
            GeneticCodeRegistry.getRegistry().getGeneticCodeByName('STANDARD_A');
            failed=true;
        }catch(exception : InvalidGeneticCodeException){
           //catch only
        }
        
        Assert.isFalse(failed);
        
        try{
            GeneticCodeRegistry.getRegistry().getGeneticCodeByEnum(GeneticCodes.STANDARD);
        }catch(exception : InvalidGeneticCodeException){
            Assert.isTrue(false);
        }
    }
    
    @Test
    public function testStandardCodonIntegrity(){
        var registry : GeneticCodeRegistry = GeneticCodeRegistry.getRegistry();
        var geneticCode : GeneticCode = registry.getGeneticCodeByEnum(GeneticCodes.STANDARD);
        
        Assert.isTrue(geneticCode.isStartCodon("ATG"));
        Assert.isFalse(geneticCode.isStartCodon("ATT"));
        
        Assert.areEqual(geneticCode.getCodonCount(), 64);
        
        Assert.isTrue(geneticCode.isStopCodon("TAA"));
        Assert.isTrue(geneticCode.isStopCodon("TGA"));
        Assert.isTrue(geneticCode.isStopCodon("TAG"));
        
        Assert.isFalse(geneticCode.isStopCodon("ATG"));
        
        Assert.areEqual(Lambda.count(geneticCode.getStopCodons()),3);
        Assert.areEqual(Lambda.count(geneticCode.getStartCodons()),1);
    }
    
    @Test
    public function translationTests(){
        var nucTest1 : String = "TTTTTCTTATTGTCTTCCTCATCGTATTACTAATAGTGTTGCTGATGGC"+
                                "TTCTCCTACTGCCTCCCCCACCGCATCACCAACAGCGTCGCCGACGGAT"+
                                "TATCATAATGACTACCACAACGAATAACAAAAAGAGTAGCAGAAGGGTT"+
                                "GTCGTAGTGGCTGCCGCAGCGGATGACGAAGAGGGTGGCGGAGGG";
                                
        var protTest1 : String = "FFLLSSSSYY!!CC!WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
        
        var dnaObj1 : DNA = new DNA(nucTest1);
        
        try{
            var translationOne1 : String = dnaObj1.getTranslation(GeneticCodes.STANDARD,0,false);
            Assert.areEqual(protTest1, translationOne1);
            Assert.areNotEqual("RANDOM", translationOne1);
        }catch(exception : HaxeException){
            //js.Lib.alert(exception.getMessage());
            Assert.isTrue(false);
        }catch(exception : Dynamic){
            //js.Lib.alert("Other exception"+exception);
			trace(exception);
            Assert.isTrue(false);
        }
        
        
        //To be extended.......
    }
    
    @Test
    public function testStartCodonDetection(){
        var nucTest1 : String = "TTTATGTATGTATGTTCCTCATCGTATTACTAATAGTGTTGCTGATGGC"+
                                "TTCTCCTACTGCCTCCCCCACCGCATCACCAACAGCGTCGCCGACGGAT"+
                                "TATCATAATGACTACCACAACGAATAACAAAAAGAGTAGCAGAAGGGTT"+
                                "GTCGTAGTGGCTGCCGCAGCGGATGACGAAGAGGGTGGCGGAGGG";
                                
        var dnaObj1 : DNA = new DNA(nucTest1);
        
        Assert.areEqual(dnaObj1.getFirstStartCodonPositionByFrame(GeneticCodes.STANDARD, Frame.ONE),3);
        Assert.areEqual(dnaObj1.getFirstStartCodonPositionByFrame(GeneticCodes.STANDARD, Frame.TWO),7);
        Assert.areEqual(dnaObj1.getFirstStartCodonPositionByFrame(GeneticCodes.STANDARD, Frame.THREE),11);
        
        Assert.areNotEqual(dnaObj1.getFirstStartCodonPositionByFrame(GeneticCodes.STANDARD, Frame.ONE),4);
    }
	
	@Test
	public function testDNALocusCount() {
		var dnaObj :DNA = new DNA('AAAA');
		
		Assert.areEqual(3, dnaObj.getLocusCount('AA') );
		
		Assert.areEqual(0, dnaObj.getLocusCount('TT') );
		
		Assert.areEqual(1, dnaObj.getLocusCount('AAAA') );
	}
	
	@Test
	public function testPrimerClass() {
		var primerObj : Primer = new Primer('ATTGCC');
		
		Assert.areEqual('ATTGCC', primerObj.getPrimerSequence(false));
		Assert.areEqual('ATTGCC', primerObj.getPrimerSequence(true));
		
		primerObj.set5PrimeExtensionLength(3);
		
		Assert.areEqual('ATTGCC', primerObj.getPrimerSequence(true));
		Assert.areEqual('GCC', primerObj.getPrimerSequence(false));
		
		primerObj = new Primer('GCC');
		
		Assert.areEqual('GCC', primerObj.getPrimerSequence(false));
		
		primerObj.set5PrimeExtension('ATT');
		
		Assert.areEqual('ATTGCC', primerObj.getPrimerSequence(true));
		Assert.areEqual('GCC', primerObj.getPrimerSequence(false));
		
		Assert.areEqual('ATT', primerObj.get5PrimeExtensionSequence());
		
		var clonedPrimer : Primer = primerObj.clonePrimer();
		
		Assert.areEqual(primerObj.getPrimerSequence(false), clonedPrimer.getPrimerSequence(false));
		Assert.areEqual(primerObj.getPrimerSequence(true), clonedPrimer.getPrimerSequence(true)); 
		
		/*var reg :PrimerRegistry = PrimerRegistry.getDefaultInstance();
		var licF : Primer = reg.getBasePrimer(BasePrimer.LIC_FORWARD);
		
		Assert.isNotNull(licF);
		
		var test1 : Primer = licF.clonePrimer();
		
		test1.extend3Prime('ATG');
		
		Assert.areEqual('ATG', test1.get3PrimeExtendedSequence());
		Assert.areEqual(21, test1.get5PrimeExtensionLength());
		Assert.areEqual('TTAAGAAGGAGATATACTATG', test1.get5PrimeExtensionSequence());
		
		Assert.areEqual('TTAAGAAGGAGATATACTATGATG', test1.getSequence());
		
		Assert.isTrue(test1.isValid());
		
		var test2 : Primer = licF.clonePrimer();
		
		test2.extend3Prime('AGG');
		
		Assert.isFalse(test2.isValid());
		
		var test3 : Primer = licF.clonePrimer();
		
		test3.extend3Prime('AG');
		
		Assert.isFalse(test3.isValid());
		
		var test4 : Primer = licF.clonePrimer();
		
		test4.extend3Prime('AGGATG');
		
		Assert.isTrue(test4.isValid());
		
		var test5 : Primer = licF.clonePrimer();
		
		test5.extend3Prime('AGATG');
		
		Assert.isFalse(test5.isValid());*/
	}
	
	@Test
	public function testPrimerMatchExact() {
		var fPrimer : Primer = new Primer('ATGATGA');
		var rPrimer : Primer = new Primer('CGCTGT');
		
		var srcDNA : DNA = new DNA('ATGATGACGATCATCATTTTTACGACTACTACTACACTACAGCG');
		
		var fPos : Int = srcDNA.getFirstPosition( fPrimer.getPrimerSequence( false ) );
		
		Assert.areEqual(0, fPos);
		
		var icSrcDNA : DNA = new DNA( srcDNA.getInverseComplement() );
		
		Assert.areEqual('CGCTGTAGTGTAGTAGTAGTCGTAAAAATGATGATCGTCATCAT', icSrcDNA.getSequence());
		
		var rPos : Int = icSrcDNA.getFirstPosition( rPrimer.getPrimerSequence( false ) );
		
		Assert.areEqual(0, rPos);
	}
	
	@Test
	public function test1PCRProductClass() {
		var srcDNA : DNA = new DNA('ATGATGACGATCATCATTTTTACGACTACTACTACACTACAGCG');
		var fPrimer : Primer = new Primer('ATGATGA');
		var rPrimer : Primer = new Primer('CGCTGT');
		
		var pcrProduct : PCRProduct = new PCRProduct(srcDNA, fPrimer, rPrimer);
		
		Assert.areEqual('ATGATGACGATCATCATTTTTACGACTACTACTACACTACAGCG', pcrProduct.getSequence());
	}
	
	@Test
	public function test2PCRProductClass() {
		var srcDNA : DNA = new DNA('ATGATGACGATCATCATTTTTACGACTACTACTACACTACAGCG');
		var fPrimer : Primer = new Primer('ATGATGA');
		var rPrimer : Primer = new Primer('TGTAGTG');
		
		var pcrProduct : PCRProduct = new PCRProduct(srcDNA, fPrimer, rPrimer);
		
		Assert.areEqual('ATGATGACGATCATCATTTTTACGACTACTACTACACTACA', pcrProduct.getSequence());
	}
	
	@Test
	public function test3PCRProductClass() {
		var srcDNA : DNA = new DNA('ATGATGACGATCATCATTTTTACGACTACTACTACACTACAGCG');
		var fPrimer : Primer = new Primer('CGAT');
		var rPrimer : Primer = new Primer('TGTAGTG');
		
		var pcrProduct : PCRProduct = new PCRProduct(srcDNA, fPrimer, rPrimer);
		
		Assert.areEqual('CGATCATCATTTTTACGACTACTACTACACTACA', pcrProduct.getSequence());
	}
	
	@Test
	public function test4ForwardExtensionPCRProductClass() {
		var srcDNA : DNA = new DNA('ATGATGACGATCATCATTTTTACGACTACTACTACACTACAGCG');
		var fPrimer : Primer = new Primer('CGAT'); fPrimer.set5PrimeExtension('GGGGG');
		var rPrimer : Primer = new Primer('TGTAGTG');
		
		var pcrProduct : PCRProduct = new PCRProduct(srcDNA, fPrimer, rPrimer);
		
		Assert.areEqual('GGGGGCGATCATCATTTTTACGACTACTACTACACTACA', pcrProduct.getSequence());
		
		Assert.areEqual( 'CGATCATCATTTTTACGACTACTACTACACTACA' , pcrProduct.getPCRProduct( false ) );
	}
	
	@Test
	public function test5ReverseExtensionPCRProductClass() {
		var srcDNA : DNA = new DNA('ATGATGACGATCATCATTTTTACGACTACTACTACACTACAGCG');
		var fPrimer : Primer = new Primer('CGAT'); 
		var rPrimer : Primer = new Primer('TGTAGTG'); rPrimer.set5PrimeExtension('GGGGG');
		
		var pcrProduct : PCRProduct = new PCRProduct(srcDNA, fPrimer, rPrimer);
		
		Assert.areEqual('CGATCATCATTTTTACGACTACTACTACACTACACCCCC', pcrProduct.getSequence());
		
		Assert.areEqual( 'CGATCATCATTTTTACGACTACTACTACACTACA' , pcrProduct.getPCRProduct( false ) );
	}
	
	@Test
	public function test5BothExtensionPCRProductClass() {
		var srcDNA : DNA = new DNA('ATGATGACGATCATCATTTTTACGACTACTACTACACTACAGCG');
		var fPrimer : Primer = new Primer('CGAT'); fPrimer.set5PrimeExtension('GGGGG');
		var rPrimer : Primer = new Primer('TGTAGTG'); rPrimer.set5PrimeExtension('GGGGG');
		
		var pcrProduct : PCRProduct = new PCRProduct(srcDNA, fPrimer, rPrimer);
		
		Assert.areEqual( 'GGGGGCGATCATCATTTTTACGACTACTACTACACTACACCCCC' , pcrProduct.getSequence());
		
		Assert.areEqual( 'CGATCATCATTTTTACGACTACTACTACACTACA' , pcrProduct.getPCRProduct( false ) );
	}
	
	@Test
	public function testForwardPrimerMultiPCRProductClass() {
		var srcDNA : DNA = new DNA('ATGATGACGATCATCATTTTTACGACTACTACTACACTACAGCG');
		var fPrimer : Primer = new Primer('AT');
		var rPrimer : Primer = new Primer('TGTAGTG');
		
		var exp : HaxeException = null;
		try{
			var pcrProduct : PCRProduct = new PCRProduct(srcDNA, fPrimer, rPrimer);
		}catch (exception : MultiLocusPrimerException) {
			exp = exception;
		}
		
		Assert.isNotNull(exp);
		Assert.isType(exp, MultiLocusPrimerException);
		Assert.areSame( cast( exp, MultiLocusPrimerException ).getPrimer() , fPrimer ); 
	}
	
	@Test
	public function testReversePrimerMultiPCRProductClass() {
		var srcDNA : DNA = new DNA('ATGATGACGATCATCATTTTTACGACTACTACTACACTACAGCG');
		var fPrimer : Primer = new Primer('CGAT');
		var rPrimer : Primer = new Primer('TA');
		
		var exp : HaxeException = null;
		try{
			var pcrProduct : PCRProduct = new PCRProduct(srcDNA, fPrimer, rPrimer);
		}catch (exception : HaxeException) {
			exp = exception;
		}
		
		Assert.isNotNull(exp);
		Assert.isType(exp, MultiLocusPrimerException);
		Assert.areSame( cast( exp, MultiLocusPrimerException ).getPrimer() , rPrimer ); 
	}
	
	@Test
	public function testForwardPrimerMissingPCRProductClass() {
		var srcDNA : DNA = new DNA('ATGATGACGATCATCATTTTTACGACTACTACTACACTACAGCG');
		var fPrimer : Primer = new Primer('GGGGGGGGGG');
		var rPrimer : Primer = new Primer('TGTAGTG');
		
		var exp : HaxeException = null;
		try{
			var pcrProduct : PCRProduct = new PCRProduct(srcDNA, fPrimer, rPrimer);
		}catch (exception : HaxeException) {
			exp = exception;
		}
		
		Assert.isNotNull(exp);
		Assert.isType(exp, LocusPrimerMissingException);
		Assert.areSame( cast( exp, LocusPrimerMissingException ).getPrimer() , fPrimer ); 
	}
	
	@Test
	public function testReversePrimerMissingPCRProductClass() {
		var srcDNA : DNA = new DNA('ATGATGACGATCATCATTTTTACGACTACTACTACACTACAGCG');
		var fPrimer : Primer = new Primer('CGAT');
		var rPrimer : Primer = new Primer('GGGGGGGGG');
		
		var exp : HaxeException = null;
		try{
			var pcrProduct : PCRProduct = new PCRProduct(srcDNA, fPrimer, rPrimer);
		}catch (exception : HaxeException) {
			exp = exception;
		}
		
		Assert.isNotNull(exp);
		Assert.isType(exp, LocusPrimerMissingException);
		Assert.areSame( cast( exp, LocusPrimerMissingException ).getPrimer() , rPrimer ); 
	}
	
	@Test
	public function testLocusCount() {
			var srcDNA : DNA = new DNA('ATGCATGC');
			
			Assert.areEqual(srcDNA.getLocusCount('ATG'), 2);
			Assert.areEqual(srcDNA.getLocusCount('TTT'), 0);
			Assert.areEqual(srcDNA.getLocusCount(''), 0);
	}
	
	@Test
	public function testLastLocusPosition() {
		var template : DNA = new DNA('ATGCAAATGC');
		Assert.areEqual(6,template.getLastPosition('ATGC'));
	}
	
	@Test
	public function testRestrictionStarIdentification() {
		var resSite : RestrictionSite = new RestrictionSite('ATGC*AAA');
		
		Assert.areEqual(resSite.getStarPosition(), 4);
		Assert.areEqual(resSite.getSequence(), 'ATGCAAA');
	}
	
	@Test
	public function testRestrictionSiteCutPosition1() {
		var resSite : RestrictionSite = new RestrictionSite('ATGC*AAA');
		var template : DNA = new DNA('TTGGCATGCAAA');
		
		Assert.areEqual(resSite.getCutPosition(template),9);
	}
	
	@Test
	public function testRestrictionSiteCutLastPosition1() {
		var resSite : RestrictionSite = new RestrictionSite('ATGC*AAA');
		var template : DNA = new DNA('TTGGCATGCAAATTATGCAAA');
		
		Assert.areEqual(resSite.getLastCutPosition(template), 18);
		
		template = new DNA('AAATTATGCAAA');
		
		Assert.areEqual(1, template.getLocusCount('ATGCAAA'));
		Assert.areEqual(5, template.getLastPosition('ATGCAAA'));
		
		Assert.areEqual(9,resSite.getLastCutPosition(template));
	}
	
	@Test
	public function testRestrictionSiteAfterCutSeq1() {
		var resSite : RestrictionSite = new RestrictionSite('ATGC*AAA');
		var template : DNA = new DNA('TTGGCATGCAAA');
		
		Assert.areEqual('AAA',resSite.getAfterCutSequence(template));
	}
	@Test
	public function testRestrictionSiteBeforeCutSeq1() {
		var resSite : RestrictionSite = new RestrictionSite('ATGC*AAA');
		var template : DNA = new DNA('TTGGCATGCAAA');
		
		Assert.areEqual('TTGGCATGC',resSite.getBeforeCutSequence(template));
	}
	
	@Test
	public function testRestrictionSiteLastBeforeCutSequence1() {
		var resSite : RestrictionSite = new RestrictionSite('ATGC*AAA');
		var template : DNA = new DNA('TTGGCATGCAAATTATGCAAA');
		
		Assert.areEqual(resSite.getLastBeforeCutSequence(template),'TTGGCATGCAAATTATGC');
	}
	
	@Test
	public function testRestrictionSiteLastAfterCutLastSequence1() {
		var resSite : RestrictionSite = new RestrictionSite('ATGC*AAA');
		var template : DNA = new DNA('TTGGCATGCAAATTATGCAAA');
		
		Assert.areEqual(resSite.getLastAfterCutSequence(template),'AAA');
	}
	
	@Test
	public function testRestrictionSiteCutBothSequence1() {
		var resSite : RestrictionSite = new RestrictionSite('ATGC*AAA');
		var template : DNA = new DNA('TTGGCATGCAAATTATGCAAA');
		
		var cutStr : String = resSite.getAfterCutSequence(template);
		
		Assert.areEqual('AAATTATGCAAA',cutStr);
		
		cutStr = resSite.getLastBeforeCutSequence(new DNA(cutStr));
		
		Assert.areEqual('AAATTATGC',cutStr);
	}
	
	@Test
	public function testDoubleDigest() {
		var resSite : RestrictionSite = new RestrictionSite('TA*ATA');
		
		Assert.areEqual(2, resSite.getStarPosition());
		
		var template : DNA = new DNA('TAATAGGGGGGGGTAATA');
		
		var dDigest : DoubleDigest = new DoubleDigest(template, resSite, resSite);
		
		Assert.areEqual('TA', dDigest.getLeftProduct().getSequence());
		Assert.areEqual('ATAGGGGGGGGTA', dDigest.getCenterProduct().getSequence());
		Assert.areEqual('ATA', dDigest.getRightProduct().getSequence());
	}
	
	@Test
	public function testLigationProduct() {
		var resSite : RestrictionSite = new RestrictionSite('TA*ATA');
		
		var donorSeq : DNA = new DNA('TAATAGGGGGGGGTAATA');
		
		var donorDigest : DoubleDigest = new DoubleDigest(donorSeq, resSite, resSite);
		
		var acceptorSeq : DNA = new DNA('TAATAGGGGGGGGTAATA');
		
		var acceptorDigest : DoubleDigest = new DoubleDigest(acceptorSeq, resSite, resSite);
		
		var ligationProduct : LigationProduct = new LigationProduct(acceptorDigest, donorDigest);
		
		Assert.areEqual('TAATAGGGGGGGGTAATA',ligationProduct.getSequence());
	}
	
	@Test
	public function testDeltaH() {
		try{
		
			var fwdPrimer : DNA = new DNA('AAAAAAAAAAAAAAAAAAAA');
			
			var testDeltaH : TmCalc = new TmCalc();
			
			Assert.areEqual(-145500, testDeltaH.getDeltaH(fwdPrimer));
		} catch (e:HaxeException) {
			trace(e.getMessage());
            throw e;
		}
	}
	
	@Test
	public function testDeltaS() {
		try{
		
			var fwdPrimer : DNA = new DNA('AAAAAAAAAAAAAAAAAAAA');
			
			var testDeltaS : TmCalc = new TmCalc();
			
			Assert.areEqual(-413.60, MathUtils.sigFigs(testDeltaS.getDeltaS(fwdPrimer),2));
		} catch (e:HaxeException) {
			trace(e.getMessage());
            throw e;
		}
	}
	
	@Test
	public function testSaltCorr() {
		try {
			
			var fwdPrimer : DNA = new DNA('AAAAAAAAAAAAAAAAAAAA');
			
			var saltConc = 50;
			
			var testSaltCorr : TmCalc = new TmCalc();
			
			Assert.areEqual(-434.55, MathUtils.sigFigs(testSaltCorr.saltCorrection(fwdPrimer, saltConc),2));
		} catch (e:HaxeException) {
			trace(e.getMessage());
            throw e;
		}
	}
	
	@Test
	public function testTmCalc() {
		var testDataSet = [ 
			{ seq:'AAAAAAAAAAAAAAAAAAAA', value:39.24 } ,
			{ seq:'ATGGCGCGATATGCCGTTA', value:57.86 } ,
			{ seq: 'ATGCCACACACACCCCACACAC', value:62.98 } ,
			{ seq: 'ATGGCGGGCGGGACGGACGGAGCCGGGAACTCCCTGA', value:75 } ,
		];
		
		for(testData in testDataSet){
			try {
				var fwdPrimer : DNA = new DNA(testData.seq);
				
				var saltConc = 50;
				
				var primerConc = 300;
				
				var testTmCalc : TmCalc = new TmCalc();
				
				Assert.areEqual(testData.value, MathUtils.sigFigs(testTmCalc.tmCalculation(fwdPrimer, saltConc, primerConc), 2));
			} catch (e:HaxeException) {
				trace(e.getMessage());
				throw e;
			}
		}


	}

    @Test
    public function testFirstCodonDetection(){
        var dna = new DNA('ATG');

        Assert.areEqual(0, dna.getFirstStartCodonPosition(GeneticCodes.STANDARD));
        Assert.areEqual('M',dna.getTranslation(GeneticCodes.STANDARD,0,true));

        dna = new DNA('ATTATG');
        Assert.areEqual(3, dna.getFirstStartCodonPosition(GeneticCodes.STANDARD));
        Assert.areEqual('M',dna.getTranslation(GeneticCodes.STANDARD,3,true));

        dna = new DNA('ATT');
        Assert.areEqual(-1, dna.getFirstStartCodonPosition(GeneticCodes.STANDARD));
    }

    @Test
    public function testDigestionSupport(){
        var protein = new Protein('MHHHHHHSSGVDLGTENLYFQSMDMVKLVEVPNDGGPLGIHVVPFSARGGRTLGLLVKRLEKGGKAEHENLFRENDCIVRINDGDLRNRRFEQAQHMFRQAMRTPIIWFHVVPAANKE');

        var ez = new Protein('ENLYFQ*');
        var eNoTag = 'SMDMVKLVEVPNDGGPLGIHVVPFSARGGRTLGLLVKRLEKGGKAEHENLFRENDCIVRINDGDLRNRRFEQAQHMFRQAMRTPIIWFHVVPAANKE';
        var oNoTag = ez.getCutProduct(protein, CutProductDirection.DOWNSTREAM);

        Assert.areEqual(eNoTag,oNoTag);
    }

    @Test
    public function testPrimerRefFail1(){
        var primer = new Primer('GATTGGAAGTAGAGGTTCTCTGCTCACTGCACCCCACAGCGCATGTTGGC');
        var template = new DNA('ATGGCGGAGGCTGTACTGAGGGTCGCCCGGCGGCAGCTGAGCCAGCGCGGCGGGTCTGGAGCCCCCATCCTCCTGCGGCAGATGTTCGAGCCTGTGAGCTGCACCTTCACGTACCTGCTGGGTGACAGAGAGTCCCGGGAGGCCGTTCTGATCGACCCAGTCCTGGAAACAGCGCCTCGGGATGCCCAGCTGATCAAGGAGCTGGGGCTGCGGCTGCTCTATGCTGTGAATACCCACTGCCACGCGGACCACATTACAGGCTCGGGGCTGCTCCGTTCCCTCCTCCCTGGCTGCCAGTCTGTCATCTCCCGCCTTAGTGGGGCCCAGGCTGACTTACACATTGAGGATGGAGACTCCATCCGCTTCGGGCGCTTCGCGTTGGAGACCAGGGCCAGCCCTGGCCACACCCCAGGCTGTGTCACCTTCGTCCTGAATGACCACAGCATGGCCTTCACTGGAGATGCCCTGTTGATCCGTGGGTGTGGGCGGACAGACTTCCAGCAAGGCTGTGCCAAGACCTTGTACCACTCGGTCCATGAAAAGATCTTCACACTTCCAGGAGACTGTCTGATCTACCCTGCTCACGATTACCATGGGTTCACAGTGTCCACCGTGGAGGAGGAGAGGACTCTGAACCCTCGGCTCACCCTCAGCTGTGAGGAGTTTGTCAAAATCATGGGCAACCTGAACTTGCCTAAACCTCAGCAGATAGACTTTGCTGTTCCAGCCAACATGCGCTGTGGGGTGCAGACACCCACTGCCTGA');

        var primerReg = PrimerRegistry.getDefaultInstance();

        primerReg.autoConfigurePrimer(primer);

        primer.set5PrimeExtensionLength(primer.getLength()-14);

        var icSrcDNA = new DNA(template.getInverseComplement());

        var seq = primer.getPrimerSequence(false);



        if(icSrcDNA.getLocusCount( seq ) < 1){
            throw "Error: " + seq;
        }
    }
    /*
    @Test
    public function testGatewayPseudoDigestAndLigate(){
        var aRes1 = new RestrictionSite('');
        var aRes2 = new RestrictionSite('');

        var allele = new DNA('ACAAGTTTGTACAAAAAAGTTGGCACCATGGAGGTGGCTGTGGAGAAGGCGGCGGCGGCAGCGGCTCCGGCCGGAGGCCCCGCAGCGGCGGCGCCGAGCGGGGAGAATGAGGCCGAGAGCCGGCAGGGCCCGGACTCGGAGAGCGGCGGCGAGGCGTCCCGGCTCAACCTGTTGGACACTTGCGCCGTGTGCCACCAGAACATCCAGAGCCGGGTGCCCAAGCTGCTGCCCTGCCTGCACTCGTTCTGCCAGCGCTGTTTGCCCGCGCCGCAGCGCTATCTCATGCTGACGGCGCCCGCGCTGGGCTCGGCAGAGACCCCTCCACCCGCTCCCGCCCCCGCCCCCGCCCCGGGCTCCCCGGCCGGTGGTCCTTCGCCATTCGCCACCCAAGTTGGAGTCATTCGATGCCCAGTTTGCAGTCAAGAGTGTGCTGAGAGACACATCATAGACAACTTTTTTGTGAAGGACACCACTGAAGTTCCTAGTAGTACAGTAGAAAAGTCTAATCAGGTATGTACAAGCTGTGAAGACAATGCAGAAGCTAATGGGTTTTGTGTAGAGTGTGTTGAATGGCTCTGCAAGACATGTATTAGAGCTCACCAGAGGGTGAAGTTCACAAAAGACCACACAGTCAGGCAGAAAGAAGAAGTATCTCCAGAGGCAGTTGGGGTGACCAGTCAGCGACCAGTGTTTTGTCCCTTCCATAAAAAGGAGCAGTTGAAACTTTACTGTGAAACATGTGATAAACTGACCTGTCGAGACTGCCAGCTGCTAGAACACAAAGAACACAGGTATCAATTTATAGAAGAAGCTTTTCAGAATCAAAAAGTGATCATAGATACTCTAATCACCAAACTGATGGAAAAAACAAAATATATAAAGTATACAGGAAATCAGATCCAAAATAGGATAATTGAAATAAATCAAAACCAAAAGCAGGTGGAACAGGATATTAAAGTTGCCATCTTCACATTGATGGTGGAGATAAACAAAAAAGGGAAAGCTCTGCTGCACCAGCTTGAGAGTCTTGCAAAGGACCATCGAATGAAACTCATGCAACAACAGCAGGAAGTGGCTGGGCTTTCTAAGCAGTTAGAGCACGTCATGCATTTTTCTAAATGGGCTGTTTCCAGTGGCAGCAGCACAGCCTTGCTGTACAGCAAGCGGCTGATTACATACAGGTTACGGCACCTTCTTCGTGCAAGGTGTGATGCTTCTCCTGTGACCAACACCACCATCCAGTTTCACTGTGATCCTAGTTTCTGGGCTCAAAATATTATCAACTTGGGTTCTTTAGTAATCGAGGATAAAGAGAGCCAGCCACAAATGCCTAAGCAGAATCCTGTCGTGGAGCAGAGTTCACAGCCACCAGGTGGTTTACCTTCCAACCAGTTATCCAAGTTCCCAACACAGATCAGCCTAGCTCAGTTACGACTCCAGCATATTCAGCAACAGGTAATGGCTCAGAGGCAACAGGTGCAACGGAGGCCAGCACCTGTGGGTTTACCAAACCCTAGAATGCAGGGGCCCATCCAGCAGCCTTCCATCTCTCATCAGCATCCGCCACCACGCTTAATAAACTTTCAGAATCACAGCCCTAAGCCCAATGGACCAGTTCTTCCTCCTTATCCTCAGCAGCTGAGATATTCACCAAGCCAGAATGTACCTCGGCAGACAACAATAAAGCCCAACCCCTTGCAAATGGCTTTTTTGGCTCAACAGGCCATAAAACAGTGGCAGATCAGCAGTGTACAGGCTCCGCCCACAACTGCCAGCAGCTCCTCCTCCACGCCGTCCAGCCCCACAATCACAAGTGCAGCTGGGTACGATGGAAAAGCTTTTAGTTCACCCATGATTGATCTGAGTGCACCGGTGGGAGGGTCTTACAATCTTCCTTCTCTTCCAGATATTGATTGTTCAAGTACTATAATGTTGGACAACATTGCAAGGAAAGACACAGGTGTAGATCACGCCCAGCCGAGGCCTCCGTCAAACAGAACGGTGCAGTCACCAAATTCATCAGTGCCATCTCCAGGCCTTGCAGGGCCTGTTACTATGACTAGCGTCCATCCCCCAATACGTTCACCTAGTGCCTCCAGTGTTGGAAGTCGAGGAAGCTCTGGCTCTTCCAGCAAACCAGCAGGAGCTGATTCTACTCACAAGGTCCCAGTAGTCATGCTGGAGCCAATTCGAATAAAACAGGAAAACAGTGGACCACCTGAAAATTATGATTTTCCTGTTGTTATAGTAAAACAAGAATCAGATGAAGAATCTAGACCTCAAAATACTAACTATCCAAGAAGCATACTTACCTCCCTCCTCTTAAACAGCAGTCAGAGCTCTGCTTCTGAGGAAACCGTGTTACGATCTGATGCCCCTGATAGTACAGGAGATCAGCCTGGACTCCATCAAGAAAATTCCTCAAATGGAAAGTCTGAGTGGTCGGATGCCTCCCAGAAGTCCCCTGTGCATGTCGGAGAGACGAGGAAGGAGGATGACCCCAATGAAGACTGGTGTGCTGTTTGTCAAAATGGTGGGGAACTCCTATGCTGTGAGAAATGTCCTAAAGTATTCCATCTTACTTGTCATGTGCCCACCTTGACAAATTTTCCAAGTGGAGAATGGATCTGTACTTTCTGCCGAGACTTATCTAAGCCAGAGGTTGACTATGATTGTGATGTTCCCAGTCACCACTCAGAGAAACGGAAAAGTGAAGGCCTTACTAAGTTAACGCCAATAGACAAAAGGAAATGTGAACGCCTACTTCTGTTTCTTTACTGCCATGAAATGAGCCTGGCTTTCCAAGACCCTGTTCCTCTAACTGTGCCTGATTATTATAAAATAATTAAAAACCCAATGGACTTGTCAACCATCAAGAAAAGACTTCAGGAGGATTATTGCATGTATACAAAGCCTGAAGACTTTGTAGCTGATTTTAGATTGATCTTTCAAAACTGTGCTGAATTCAATGAGCCTGATTCTGAAGTAGCCAATGCTGGTATAAAACTTGAAAGCTATTTTGAAGAACTTCTAAAGAATCTTTATCCAGAAAAAAGGTTTCCTAAGGTAGAATTCAGGCATGAAGCAGAAGACTGTAAGTTCAGTGACGACTCAGACGATGACTTTGTACAGCCCCGGAAGAAGCGTCTCAAGAGCACCGAGGATCGCCAGCTGCTTAAGTAATACCCAACTTTCTTGTAC');

        var alleleDigestion = new DoubleDigest(allele, aRes1, aRes2);

        var vRes1 = new RestrictionSite('*ACAAGTTTGTACAAAAAAG');
        var vRes2 = new RestrictionSite('*CTTTCTTGTACAAAGTGGT');

        var vector = new DNA('ggtaccatggtgagcaagggcgaggagctgttcaccggggtggtgcccatcctggtcgagctggacggcgacgtaaacggccacaagttcagcgtgtccggcgagggcgagggcgatgccacctacggcaagctgaccctgaagttcatctgcaccaccggcaagctgcccgtgccctggcccaccctcgtgaccaccctgacctacggcgtgcagtgcttcagccgctaccccgaccacatgaagcagcacgacttcttcaagtccgccatgcccgaaggctacgtccaggagcgcaccatcttcttcaaggacgacggcaactacaagacccgcgccgaggtgaagttcgagggcgacaccctggtgaaccgcatcgagctgaagggcatcgacttcaaggaggacggcaacatcctggggcacaagctggagtacaactacaacagccacaacgtctatatcatggccgacaagcagaagaacggcatcaaggtgaacttcaagatccgccacaacatcgaggacggcagcgtgcagctcgccgaccactaccagcagaacacccccatcggcgacggccccgtgctgctgcccgacaaccactacctgagcacccagtccgccctgagcaaagaccccaacgagaagcgcgatcacatggtcctgctggagttcgtgaccgccgccgggatcactctcggcatggacgagctgtacaagggcgcgcccacaagtttgtacaaaaaagXXXXXXXXXXctttcttgtacaaagtggt');

        var vectorDigestion = new DoubleDigest(vector,vRes1,vRes2);

        var ligation = new Ligation(vectorDigestion, alleleDigestion);

        Assert.areEqual('',ligation.getSequence());
    }*/

	@Test
	public function testHydropathy(){
		var protein = new Protein('MTEKINKKDNYHLIFALIFLAIVSVVSMMIGSSFIPLQRVLMYFINPNDSMDQFTLEVLRLPRITLAILAGAALGMSGLMLQNVLKNPIASPDIIGITGGASLSAVVFIAFFSHLTIHLLPLFAVLGGAVAMMILLVFQTKGQIRPTTLIIIGISMQTLFIALVQGLLITTKQLSAAKAYTWLVGSLYGATFKDTIILGMVILAVVPLLFLVIPKMKISILDDPVAIGLGLHVQRMKLIQLITSTILVSMAISLVGNIGFVGLIAPHIAKTIVRGSYAKKLLMSAMIGAISIVIADLIGRTLFLPKEVPAGVFIAAFGAPFFIYLLLTVKKL');
		var avGravy = 1.1165662650602;

		var avGravyResult = protein.getHydrophobicity();
		Assert.areEqual(avGravy,avGravyResult);
	}
}