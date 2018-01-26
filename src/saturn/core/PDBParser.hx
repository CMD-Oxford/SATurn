/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

#if !js
import StringTools;
import sys.io.FileOutput;
#end

/**
 * ...
 * @author David Damerell
 */
class PDBParser{

	public function new() {
		
	}	
	
/*              
	PDB three letter codes to single letter codes have been taken from the 
	SCOPData BioPython Module

	http://biopython.org/DIST/docs/api/Bio.Data.SCOPData-pysrc.html

	Biopython License Agreement

	Permission to use, copy, modify, and distribute this software and its
	documentation with or without modifications and for any purpose and
	without fee is hereby granted, provided that any copyright notices
	appear in all copies and that both those copyright notices and this
	permission notice appear in supporting documentation, and that the
	names of the contributors or copyright holders not be used in
	advertising or publicity pertaining to distribution of the software
	without specific prior permission.

	THE CONTRIBUTORS AND COPYRIGHT HOLDERS OF THIS SOFTWARE DISCLAIM ALL
	WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL THE
	CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY SPECIAL, INDIRECT
	OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
	OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
	OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE
	OR PERFORMANCE OF THIS SOFTWARE
*/

	public static var pdb3To1 : Map < String, String >  = [
	  '00C'=>'C','01W'=>'X','02K'=>'A','03Y'=>'C','07O'=>'C', 
      '08P'=>'C','0A0'=>'D','0A1'=>'Y','0A2'=>'K','0A8'=>'C', 
      '0AA'=>'V','0AB'=>'V','0AC'=>'G','0AD'=>'G','0AF'=>'W', 
      '0AG'=>'L','0AH'=>'S','0AK'=>'D','0AM'=>'A','0AP'=>'C', 
      '0AU'=>'U','0AV'=>'A','0AZ'=>'P','0BN'=>'F','0C '=>'C', 
      '0CS'=>'A','0DC'=>'C','0DG'=>'G','0DT'=>'T','0FL'=>'A', 
      '0G '=>'G','0NC'=>'A','0SP'=>'A','0U '=>'U','0YG'=>'YG', 
      '10C'=>'C','125'=>'U','126'=>'U','127'=>'U','128'=>'N', 
      '12A'=>'A','143'=>'C','175'=>'ASG','193'=>'X','1AP'=>'A', 
      '1MA'=>'A','1MG'=>'G','1PA'=>'F','1PI'=>'A','1PR'=>'N', 
      '1SC'=>'C','1TQ'=>'W','1TY'=>'Y','1X6'=>'S','200'=>'F', 
      '23F'=>'F','23S'=>'X','26B'=>'T','2AD'=>'X','2AG'=>'A', 
      '2AO'=>'X','2AR'=>'A','2AS'=>'X','2AT'=>'T','2AU'=>'U', 
      '2BD'=>'I','2BT'=>'T','2BU'=>'A','2CO'=>'C','2DA'=>'A', 
      '2DF'=>'N','2DM'=>'N','2DO'=>'X','2DT'=>'T','2EG'=>'G', 
      '2FE'=>'N','2FI'=>'N','2FM'=>'M','2GT'=>'T','2HF'=>'H', 
      '2LU'=>'L','2MA'=>'A','2MG'=>'G','2ML'=>'L','2MR'=>'R', 
      '2MT'=>'P','2MU'=>'U','2NT'=>'T','2OM'=>'U','2OT'=>'T', 
      '2PI'=>'X','2PR'=>'G','2SA'=>'N','2SI'=>'X','2ST'=>'T', 
      '2TL'=>'T','2TY'=>'Y','2VA'=>'V','2XA'=>'C','32S'=>'X', 
      '32T'=>'X','3AH'=>'H','3AR'=>'X','3CF'=>'F','3DA'=>'A', 
      '3DR'=>'N','3GA'=>'A','3MD'=>'D','3ME'=>'U','3NF'=>'Y', 
      '3QN'=>'K','3TY'=>'X','3XH'=>'G','4AC'=>'N','4BF'=>'Y', 
      '4CF'=>'F','4CY'=>'M','4DP'=>'W','4F3'=>'GYG','4FB'=>'P', 
      '4FW'=>'W','4HT'=>'W','4IN'=>'W','4MF'=>'N','4MM'=>'X', 
      '4OC'=>'C','4PC'=>'C','4PD'=>'C','4PE'=>'C','4PH'=>'F', 
      '4SC'=>'C','4SU'=>'U','4TA'=>'N','4U7'=>'A','56A'=>'H', 
      '5AA'=>'A','5AB'=>'A','5AT'=>'T','5BU'=>'U','5CG'=>'G', 
      '5CM'=>'C','5CS'=>'C','5FA'=>'A','5FC'=>'C','5FU'=>'U', 
      '5HP'=>'E','5HT'=>'T','5HU'=>'U','5IC'=>'C','5IT'=>'T', 
      '5IU'=>'U','5MC'=>'C','5MD'=>'N','5MU'=>'U','5NC'=>'C', 
      '5PC'=>'C','5PY'=>'T','5SE'=>'U','5ZA'=>'TWG','64T'=>'T', 
      '6CL'=>'K','6CT'=>'T','6CW'=>'W','6HA'=>'A','6HC'=>'C', 
      '6HG'=>'G','6HN'=>'K','6HT'=>'T','6IA'=>'A','6MA'=>'A', 
      '6MC'=>'A','6MI'=>'N','6MT'=>'A','6MZ'=>'N','6OG'=>'G', 
      '70U'=>'U','7DA'=>'A','7GU'=>'G','7JA'=>'I','7MG'=>'G', 
      '8AN'=>'A','8FG'=>'G','8MG'=>'G','8OG'=>'G','9NE'=>'E', 
      '9NF'=>'F','9NR'=>'R','9NV'=>'V','A  '=>'A','A1P'=>'N', 
      'A23'=>'A','A2L'=>'A','A2M'=>'A','A34'=>'A','A35'=>'A', 
      'A38'=>'A','A39'=>'A','A3A'=>'A','A3P'=>'A','A40'=>'A', 
      'A43'=>'A','A44'=>'A','A47'=>'A','A5L'=>'A','A5M'=>'C', 
      'A5N'=>'N','A5O'=>'A','A66'=>'X','AA3'=>'A','AA4'=>'A', 
      'AAR'=>'R','AB7'=>'X','ABA'=>'A','ABR'=>'A','ABS'=>'A', 
      'ABT'=>'N','ACB'=>'D','ACL'=>'R','AD2'=>'A','ADD'=>'X', 
      'ADX'=>'N','AEA'=>'X','AEI'=>'D','AET'=>'A','AFA'=>'N', 
      'AFF'=>'N','AFG'=>'G','AGM'=>'R','AGT'=>'C','AHB'=>'N', 
      'AHH'=>'X','AHO'=>'A','AHP'=>'A','AHS'=>'X','AHT'=>'X', 
      'AIB'=>'A','AKL'=>'D','AKZ'=>'D','ALA'=>'A','ALC'=>'A', 
      'ALM'=>'A','ALN'=>'A','ALO'=>'T','ALQ'=>'X','ALS'=>'A', 
      'ALT'=>'A','ALV'=>'A','ALY'=>'K','AN8'=>'A','AP7'=>'A', 
      'APE'=>'X','APH'=>'A','API'=>'K','APK'=>'K','APM'=>'X', 
      'APP'=>'X','AR2'=>'R','AR4'=>'E','AR7'=>'R','ARG'=>'R', 
      'ARM'=>'R','ARO'=>'R','ARV'=>'X','AS '=>'A','AS2'=>'D', 
      'AS9'=>'X','ASA'=>'D','ASB'=>'D','ASI'=>'D','ASK'=>'D', 
      'ASL'=>'D','ASM'=>'X','ASN'=>'N','ASP'=>'D','ASQ'=>'D', 
      'ASU'=>'N','ASX'=>'B','ATD'=>'T','ATL'=>'T','ATM'=>'T', 
      'AVC'=>'A','AVN'=>'X','AYA'=>'A','AYG'=>'AYG','AZK'=>'K', 
      'AZS'=>'S','AZY'=>'Y','B1F'=>'F','B1P'=>'N','B2A'=>'A', 
      'B2F'=>'F','B2I'=>'I','B2V'=>'V','B3A'=>'A','B3D'=>'D', 
      'B3E'=>'E','B3K'=>'K','B3L'=>'X','B3M'=>'X','B3Q'=>'X', 
      'B3S'=>'S','B3T'=>'X','B3U'=>'H','B3X'=>'N','B3Y'=>'Y', 
      'BB6'=>'C','BB7'=>'C','BB8'=>'F','BB9'=>'C','BBC'=>'C', 
      'BCS'=>'C','BE2'=>'X','BFD'=>'D','BG1'=>'S','BGM'=>'G', 
      'BH2'=>'D','BHD'=>'D','BIF'=>'F','BIL'=>'X','BIU'=>'I', 
      'BJH'=>'X','BLE'=>'L','BLY'=>'K','BMP'=>'N','BMT'=>'T', 
      'BNN'=>'F','BNO'=>'X','BOE'=>'T','BOR'=>'R','BPE'=>'C', 
      'BRU'=>'U','BSE'=>'S','BT5'=>'N','BTA'=>'L','BTC'=>'C', 
      'BTR'=>'W','BUC'=>'C','BUG'=>'V','BVP'=>'U','BZG'=>'N', 
      'C  '=>'C','C12'=>'TYG','C1X'=>'K','C25'=>'C','C2L'=>'C', 
      'C2S'=>'C','C31'=>'C','C32'=>'C','C34'=>'C','C36'=>'C', 
      'C37'=>'C','C38'=>'C','C3Y'=>'C','C42'=>'C','C43'=>'C', 
      'C45'=>'C','C46'=>'C','C49'=>'C','C4R'=>'C','C4S'=>'C', 
      'C5C'=>'C','C66'=>'X','C6C'=>'C','C99'=>'TFG','CAF'=>'C', 
      'CAL'=>'X','CAR'=>'C','CAS'=>'C','CAV'=>'X','CAY'=>'C', 
      'CB2'=>'C','CBR'=>'C','CBV'=>'C','CCC'=>'C','CCL'=>'K', 
      'CCS'=>'C','CCY'=>'CYG','CDE'=>'X','CDV'=>'X','CDW'=>'C', 
      'CEA'=>'C','CFL'=>'C','CFY'=>'FCYG','CG1'=>'G','CGA'=>'E', 
      'CGU'=>'E','CH '=>'C','CH6'=>'MYG','CH7'=>'KYG','CHF'=>'X', 
      'CHG'=>'X','CHP'=>'G','CHS'=>'X','CIR'=>'R','CJO'=>'GYG', 
      'CLE'=>'L','CLG'=>'K','CLH'=>'K','CLV'=>'AFG','CM0'=>'N', 
      'CME'=>'C','CMH'=>'C','CML'=>'C','CMR'=>'C','CMT'=>'C', 
      'CNU'=>'U','CP1'=>'C','CPC'=>'X','CPI'=>'X','CQR'=>'GYG', 
      'CR0'=>'TLG','CR2'=>'GYG','CR5'=>'G','CR7'=>'KYG','CR8'=>'HYG', 
      'CRF'=>'TWG','CRG'=>'THG','CRK'=>'MYG','CRO'=>'GYG','CRQ'=>'QYG', 
      'CRU'=>'EYG','CRW'=>'ASG','CRX'=>'ASG','CS0'=>'C','CS1'=>'C', 
      'CS3'=>'C','CS4'=>'C','CS8'=>'N','CSA'=>'C','CSB'=>'C', 
      'CSD'=>'C','CSE'=>'C','CSF'=>'C','CSH'=>'SHG','CSI'=>'G', 
      'CSJ'=>'C','CSL'=>'C','CSO'=>'C','CSP'=>'C','CSR'=>'C', 
      'CSS'=>'C','CSU'=>'C','CSW'=>'C','CSX'=>'C','CSY'=>'SYG', 
      'CSZ'=>'C','CTE'=>'W','CTG'=>'T','CTH'=>'T','CUC'=>'X', 
      'CWR'=>'S','CXM'=>'M','CY0'=>'C','CY1'=>'C','CY3'=>'C', 
      'CY4'=>'C','CYA'=>'C','CYD'=>'C','CYF'=>'C','CYG'=>'C', 
      'CYJ'=>'X','CYM'=>'C','CYQ'=>'C','CYR'=>'C','CYS'=>'C', 
      'CZ2'=>'C','CZO'=>'GYG','CZZ'=>'C','D11'=>'T','D1P'=>'N', 
      'D3 '=>'N','D33'=>'N','D3P'=>'G','D3T'=>'T','D4M'=>'T', 
      'D4P'=>'X','DA '=>'A','DA2'=>'X','DAB'=>'A','DAH'=>'F', 
      'DAL'=>'A','DAR'=>'R','DAS'=>'D','DBB'=>'T','DBM'=>'N', 
      'DBS'=>'S','DBU'=>'T','DBY'=>'Y','DBZ'=>'A','DC '=>'C', 
      'DC2'=>'C','DCG'=>'G','DCI'=>'X','DCL'=>'X','DCT'=>'C', 
      'DCY'=>'C','DDE'=>'H','DDG'=>'G','DDN'=>'U','DDX'=>'N', 
      'DFC'=>'C','DFG'=>'G','DFI'=>'X','DFO'=>'X','DFT'=>'N', 
      'DG '=>'G','DGH'=>'G','DGI'=>'G','DGL'=>'E','DGN'=>'Q', 
      'DHA'=>'S','DHI'=>'H','DHL'=>'X','DHN'=>'V','DHP'=>'X', 
      'DHU'=>'U','DHV'=>'V','DI '=>'I','DIL'=>'I','DIR'=>'R', 
      'DIV'=>'V','DLE'=>'L','DLS'=>'K','DLY'=>'K','DM0'=>'K', 
      'DMH'=>'N','DMK'=>'D','DMT'=>'X','DN '=>'N','DNE'=>'L', 
      'DNG'=>'L','DNL'=>'K','DNM'=>'L','DNP'=>'A','DNR'=>'C', 
      'DNS'=>'K','DOA'=>'X','DOC'=>'C','DOH'=>'D','DON'=>'L', 
      'DPB'=>'T','DPH'=>'F','DPL'=>'P','DPP'=>'A','DPQ'=>'Y', 
      'DPR'=>'P','DPY'=>'N','DRM'=>'U','DRP'=>'N','DRT'=>'T', 
      'DRZ'=>'N','DSE'=>'S','DSG'=>'N','DSN'=>'S','DSP'=>'D', 
      'DT '=>'T','DTH'=>'T','DTR'=>'W','DTY'=>'Y','DU '=>'U', 
      'DVA'=>'V','DXD'=>'N','DXN'=>'N','DYG'=>'DYG','DYS'=>'C', 
      'DZM'=>'A','E  '=>'A','E1X'=>'A','ECC'=>'Q','EDA'=>'A', 
      'EFC'=>'C','EHP'=>'F','EIT'=>'T','ENP'=>'N','ESB'=>'Y', 
      'ESC'=>'M','EXB'=>'X','EXY'=>'L','EY5'=>'N','EYS'=>'X', 
      'F2F'=>'F','FA2'=>'A','FA5'=>'N','FAG'=>'N','FAI'=>'N', 
      'FB5'=>'A','FB6'=>'A','FCL'=>'F','FFD'=>'N','FGA'=>'E', 
      'FGL'=>'G','FGP'=>'S','FHL'=>'X','FHO'=>'K','FHU'=>'U', 
      'FLA'=>'A','FLE'=>'L','FLT'=>'Y','FME'=>'M','FMG'=>'G', 
      'FMU'=>'N','FOE'=>'C','FOX'=>'G','FP9'=>'P','FPA'=>'F', 
      'FRD'=>'X','FT6'=>'W','FTR'=>'W','FTY'=>'Y','FVA'=>'V', 
      'FZN'=>'K','G  '=>'G','G25'=>'G','G2L'=>'G','G2S'=>'G', 
      'G31'=>'G','G32'=>'G','G33'=>'G','G36'=>'G','G38'=>'G', 
      'G42'=>'G','G46'=>'G','G47'=>'G','G48'=>'G','G49'=>'G', 
      'G4P'=>'N','G7M'=>'G','GAO'=>'G','GAU'=>'E','GCK'=>'C', 
      'GCM'=>'X','GDP'=>'G','GDR'=>'G','GFL'=>'G','GGL'=>'E', 
      'GH3'=>'G','GHG'=>'Q','GHP'=>'G','GL3'=>'G','GLH'=>'Q', 
      'GLJ'=>'E','GLK'=>'E','GLM'=>'X','GLN'=>'Q','GLQ'=>'E', 
      'GLU'=>'E','GLX'=>'Z','GLY'=>'G','GLZ'=>'G','GMA'=>'E', 
      'GMS'=>'G','GMU'=>'U','GN7'=>'G','GND'=>'X','GNE'=>'N', 
      'GOM'=>'G','GPL'=>'K','GS '=>'G','GSC'=>'G','GSR'=>'G', 
      'GSS'=>'G','GSU'=>'E','GT9'=>'C','GTP'=>'G','GVL'=>'X', 
      'GYC'=>'CYG','GYS'=>'SYG','H2U'=>'U','H5M'=>'P','HAC'=>'A', 
      'HAR'=>'R','HBN'=>'H','HCS'=>'X','HDP'=>'U','HEU'=>'U', 
      'HFA'=>'X','HGL'=>'X','HHI'=>'H','HHK'=>'AK','HIA'=>'H', 
      'HIC'=>'H','HIP'=>'H','HIQ'=>'H','HIS'=>'H','HL2'=>'L', 
      'HLU'=>'L','HMR'=>'R','HOL'=>'N','HPC'=>'F','HPE'=>'F', 
      'HPH'=>'F','HPQ'=>'F','HQA'=>'A','HRG'=>'R','HRP'=>'W', 
      'HS8'=>'H','HS9'=>'H','HSE'=>'S','HSL'=>'S','HSO'=>'H', 
      'HTI'=>'C','HTN'=>'N','HTR'=>'W','HV5'=>'A','HVA'=>'V', 
      'HY3'=>'P','HYP'=>'P','HZP'=>'P','I  '=>'I','I2M'=>'I', 
      'I58'=>'K','I5C'=>'C','IAM'=>'A','IAR'=>'R','IAS'=>'D', 
      'IC '=>'C','IEL'=>'K','IEY'=>'HYG','IG '=>'G','IGL'=>'G', 
      'IGU'=>'G','IIC'=>'SHG','IIL'=>'I','ILE'=>'I','ILG'=>'E', 
      'ILX'=>'I','IMC'=>'C','IML'=>'I','IOY'=>'F','IPG'=>'G', 
      'IPN'=>'N','IRN'=>'N','IT1'=>'K','IU '=>'U','IYR'=>'Y', 
      'IYT'=>'T','IZO'=>'M','JJJ'=>'C','JJK'=>'C','JJL'=>'C', 
      'JW5'=>'N','K1R'=>'C','KAG'=>'G','KCX'=>'K','KGC'=>'K', 
      'KNB'=>'A','KOR'=>'M','KPI'=>'K','KST'=>'K','KYQ'=>'K', 
      'L2A'=>'X','LA2'=>'K','LAA'=>'D','LAL'=>'A','LBY'=>'K', 
      'LC '=>'C','LCA'=>'A','LCC'=>'N','LCG'=>'G','LCH'=>'N', 
      'LCK'=>'K','LCX'=>'K','LDH'=>'K','LED'=>'L','LEF'=>'L', 
      'LEH'=>'L','LEI'=>'V','LEM'=>'L','LEN'=>'L','LET'=>'X', 
      'LEU'=>'L','LEX'=>'L','LG '=>'G','LGP'=>'G','LHC'=>'X', 
      'LHU'=>'U','LKC'=>'N','LLP'=>'K','LLY'=>'K','LME'=>'E', 
      'LMF'=>'K','LMQ'=>'Q','LMS'=>'N','LP6'=>'K','LPD'=>'P', 
      'LPG'=>'G','LPL'=>'X','LPS'=>'S','LSO'=>'X','LTA'=>'X', 
      'LTR'=>'W','LVG'=>'G','LVN'=>'V','LYF'=>'K','LYK'=>'K', 
      'LYM'=>'K','LYN'=>'K','LYR'=>'K','LYS'=>'K','LYX'=>'K', 
      'LYZ'=>'K','M0H'=>'C','M1G'=>'G','M2G'=>'G','M2L'=>'K', 
      'M2S'=>'M','M30'=>'G','M3L'=>'K','M5M'=>'C','MA '=>'A', 
      'MA6'=>'A','MA7'=>'A','MAA'=>'A','MAD'=>'A','MAI'=>'R', 
      'MBQ'=>'Y','MBZ'=>'N','MC1'=>'S','MCG'=>'X','MCL'=>'K', 
      'MCS'=>'C','MCY'=>'C','MD3'=>'C','MD6'=>'G','MDH'=>'X', 
      'MDO'=>'ASG','MDR'=>'N','MEA'=>'F','MED'=>'M','MEG'=>'E', 
      'MEN'=>'N','MEP'=>'U','MEQ'=>'Q','MET'=>'M','MEU'=>'G', 
      'MF3'=>'X','MFC'=>'GYG','MG1'=>'G','MGG'=>'R','MGN'=>'Q', 
      'MGQ'=>'A','MGV'=>'G','MGY'=>'G','MHL'=>'L','MHO'=>'M', 
      'MHS'=>'H','MIA'=>'A','MIS'=>'S','MK8'=>'L','ML3'=>'K', 
      'MLE'=>'L','MLL'=>'L','MLY'=>'K','MLZ'=>'K','MME'=>'M', 
      'MMO'=>'R','MMT'=>'T','MND'=>'N','MNL'=>'L','MNU'=>'U', 
      'MNV'=>'V','MOD'=>'X','MP8'=>'P','MPH'=>'X','MPJ'=>'X', 
      'MPQ'=>'G','MRG'=>'G','MSA'=>'G','MSE'=>'M','MSL'=>'M', 
      'MSO'=>'M','MSP'=>'X','MT2'=>'M','MTR'=>'T','MTU'=>'A', 
      'MTY'=>'Y','MVA'=>'V','N  '=>'N','N10'=>'S','N2C'=>'X', 
      'N5I'=>'N','N5M'=>'C','N6G'=>'G','N7P'=>'P','NA8'=>'A', 
      'NAL'=>'A','NAM'=>'A','NB8'=>'N','NBQ'=>'Y','NC1'=>'S', 
      'NCB'=>'A','NCX'=>'N','NCY'=>'X','NDF'=>'F','NDN'=>'U', 
      'NEM'=>'H','NEP'=>'H','NF2'=>'N','NFA'=>'F','NHL'=>'E', 
      'NIT'=>'X','NIY'=>'Y','NLE'=>'L','NLN'=>'L','NLO'=>'L', 
      'NLP'=>'L','NLQ'=>'Q','NMC'=>'G','NMM'=>'R','NMS'=>'T', 
      'NMT'=>'T','NNH'=>'R','NP3'=>'N','NPH'=>'C','NPI'=>'A', 
      'NRP'=>'LYG','NRQ'=>'MYG','NSK'=>'X','NTY'=>'Y','NVA'=>'V', 
      'NYC'=>'TWG','NYG'=>'NYG','NYM'=>'N','NYS'=>'C','NZH'=>'H', 
      'O12'=>'X','O2C'=>'N','O2G'=>'G','OAD'=>'N','OAS'=>'S', 
      'OBF'=>'X','OBS'=>'X','OCS'=>'C','OCY'=>'C','ODP'=>'N', 
      'OHI'=>'H','OHS'=>'D','OIC'=>'X','OIP'=>'I','OLE'=>'X', 
      'OLT'=>'T','OLZ'=>'S','OMC'=>'C','OMG'=>'G','OMT'=>'M', 
      'OMU'=>'U','ONE'=>'U','ONH'=>'A','ONL'=>'X','OPR'=>'R', 
      'ORN'=>'A','ORQ'=>'R','OSE'=>'S','OTB'=>'X','OTH'=>'T', 
      'OTY'=>'Y','OXX'=>'D','P  '=>'G','P1L'=>'C','P1P'=>'N', 
      'P2T'=>'T','P2U'=>'U','P2Y'=>'P','P5P'=>'A','PAQ'=>'Y', 
      'PAS'=>'D','PAT'=>'W','PAU'=>'A','PBB'=>'C','PBF'=>'F', 
      'PBT'=>'N','PCA'=>'E','PCC'=>'P','PCE'=>'X','PCS'=>'F', 
      'PDL'=>'X','PDU'=>'U','PEC'=>'C','PF5'=>'F','PFF'=>'F', 
      'PFX'=>'X','PG1'=>'S','PG7'=>'G','PG9'=>'G','PGL'=>'X', 
      'PGN'=>'G','PGP'=>'G','PGY'=>'G','PHA'=>'F','PHD'=>'D', 
      'PHE'=>'F','PHI'=>'F','PHL'=>'F','PHM'=>'F','PIA'=>'AYG', 
      'PIV'=>'X','PLE'=>'L','PM3'=>'F','PMT'=>'C','POM'=>'P', 
      'PPN'=>'F','PPU'=>'A','PPW'=>'G','PQ1'=>'N','PR3'=>'C', 
      'PR5'=>'A','PR9'=>'P','PRN'=>'A','PRO'=>'P','PRS'=>'P', 
      'PSA'=>'F','PSH'=>'H','PST'=>'T','PSU'=>'U','PSW'=>'C', 
      'PTA'=>'X','PTH'=>'Y','PTM'=>'Y','PTR'=>'Y','PU '=>'A', 
      'PUY'=>'N','PVH'=>'H','PVL'=>'X','PYA'=>'A','PYO'=>'U', 
      'PYX'=>'C','PYY'=>'N','QLG'=>'QLG','QMM'=>'Q','QPA'=>'C', 
      'QPH'=>'F','QUO'=>'G','R  '=>'A','R1A'=>'C','R4K'=>'W', 
      'RC7'=>'HYG','RE0'=>'W','RE3'=>'W','RIA'=>'A','RMP'=>'A', 
      'RON'=>'X','RT '=>'T','RTP'=>'N','S1H'=>'S','S2C'=>'C', 
      'S2D'=>'A','S2M'=>'T','S2P'=>'A','S4A'=>'A','S4C'=>'C', 
      'S4G'=>'G','S4U'=>'U','S6G'=>'G','SAC'=>'S','SAH'=>'C', 
      'SAR'=>'G','SBL'=>'S','SC '=>'C','SCH'=>'C','SCS'=>'C', 
      'SCY'=>'C','SD2'=>'X','SDG'=>'G','SDP'=>'S','SEB'=>'S', 
      'SEC'=>'A','SEG'=>'A','SEL'=>'S','SEM'=>'S','SEN'=>'S', 
      'SEP'=>'S','SER'=>'S','SET'=>'S','SGB'=>'S','SHC'=>'C', 
      'SHP'=>'G','SHR'=>'K','SIB'=>'C','SIC'=>'DC','SLA'=>'P', 
      'SLR'=>'P','SLZ'=>'K','SMC'=>'C','SME'=>'M','SMF'=>'F', 
      'SMP'=>'A','SMT'=>'T','SNC'=>'C','SNN'=>'N','SOC'=>'C', 
      'SOS'=>'N','SOY'=>'S','SPT'=>'T','SRA'=>'A','SSU'=>'U', 
      'STY'=>'Y','SUB'=>'X','SUI'=>'DG','SUN'=>'S','SUR'=>'U', 
      'SVA'=>'S','SVV'=>'S','SVW'=>'S','SVX'=>'S','SVY'=>'S', 
      'SVZ'=>'X','SWG'=>'SWG','SYS'=>'C','T  '=>'T','T11'=>'F', 
      'T23'=>'T','T2S'=>'T','T2T'=>'N','T31'=>'U','T32'=>'T', 
      'T36'=>'T','T37'=>'T','T38'=>'T','T39'=>'T','T3P'=>'T', 
      'T41'=>'T','T48'=>'T','T49'=>'T','T4S'=>'T','T5O'=>'U', 
      'T5S'=>'T','T66'=>'X','T6A'=>'A','TA3'=>'T','TA4'=>'X', 
      'TAF'=>'T','TAL'=>'N','TAV'=>'D','TBG'=>'V','TBM'=>'T', 
      'TC1'=>'C','TCP'=>'T','TCQ'=>'Y','TCR'=>'W','TCY'=>'A', 
      'TDD'=>'L','TDY'=>'T','TFE'=>'T','TFO'=>'A','TFQ'=>'F', 
      'TFT'=>'T','TGP'=>'G','TH6'=>'T','THC'=>'T','THO'=>'X', 
      'THR'=>'T','THX'=>'N','THZ'=>'R','TIH'=>'A','TLB'=>'N', 
      'TLC'=>'T','TLN'=>'U','TMB'=>'T','TMD'=>'T','TNB'=>'C', 
      'TNR'=>'S','TOX'=>'W','TP1'=>'T','TPC'=>'C','TPG'=>'G', 
      'TPH'=>'X','TPL'=>'W','TPO'=>'T','TPQ'=>'Y','TQI'=>'W', 
      'TQQ'=>'W','TRF'=>'W','TRG'=>'K','TRN'=>'W','TRO'=>'W', 
      'TRP'=>'W','TRQ'=>'W','TRW'=>'W','TRX'=>'W','TS '=>'N', 
      'TST'=>'X','TT '=>'N','TTD'=>'T','TTI'=>'U','TTM'=>'T', 
      'TTQ'=>'W','TTS'=>'Y','TY1'=>'Y','TY2'=>'Y','TY3'=>'Y', 
      'TY5'=>'Y','TYB'=>'Y','TYI'=>'Y','TYJ'=>'Y','TYN'=>'Y', 
      'TYO'=>'Y','TYQ'=>'Y','TYR'=>'Y','TYS'=>'Y','TYT'=>'Y', 
      'TYU'=>'N','TYW'=>'Y','TYX'=>'X','TYY'=>'Y','TZB'=>'X', 
      'TZO'=>'X','U  '=>'U','U25'=>'U','U2L'=>'U','U2N'=>'U', 
      'U2P'=>'U','U31'=>'U','U33'=>'U','U34'=>'U','U36'=>'U', 
      'U37'=>'U','U8U'=>'U','UAR'=>'U','UCL'=>'U','UD5'=>'U', 
      'UDP'=>'N','UFP'=>'N','UFR'=>'U','UFT'=>'U','UMA'=>'A', 
      'UMP'=>'U','UMS'=>'U','UN1'=>'X','UN2'=>'X','UNK'=>'X', 
      'UR3'=>'U','URD'=>'U','US1'=>'U','US2'=>'U','US3'=>'T', 
      'US5'=>'U','USM'=>'U','VAD'=>'V','VAF'=>'V','VAL'=>'V', 
      'VB1'=>'K','VDL'=>'X','VLL'=>'X','VLM'=>'X','VMS'=>'X', 
      'VOL'=>'X','WCR'=>'GYG','X  '=>'G','X2W'=>'E','X4A'=>'N', 
      'X9Q'=>'AFG','XAD'=>'A','XAE'=>'N','XAL'=>'A','XAR'=>'N', 
      'XCL'=>'C','XCN'=>'C','XCP'=>'X','XCR'=>'C','XCS'=>'N', 
      'XCT'=>'C','XCY'=>'C','XGA'=>'N','XGL'=>'G','XGR'=>'G', 
      'XGU'=>'G','XPR'=>'P','XSN'=>'N','XTH'=>'T','XTL'=>'T', 
      'XTR'=>'T','XTS'=>'G','XTY'=>'N','XUA'=>'A','XUG'=>'G', 
      'XX1'=>'K','XXY'=>'THG','XYG'=>'DYG','Y  '=>'A','YCM'=>'C', 
      'YG '=>'G','YOF'=>'Y','YRR'=>'N','YYG'=>'G','Z  '=>'C', 
      'Z01'=>'A','ZAD'=>'A','ZAL'=>'A','ZBC'=>'C','ZBU'=>'U', 
      'ZCL'=>'F','ZCY'=>'C','ZDU'=>'U','ZFB'=>'X','ZGU'=>'G', 
      'ZHP'=>'N','ZTH'=>'T','ZU0'=>'T','ZZJ'=>'A' ];
	
	static var whiteSpaceReg = ~/\s+/g; 
	static var onlyWhiteSpaceReg = ~/^\s+$/g; 
	static var pdbCodeReg : EReg = ~/^pdb([0-9A-Za-z]+)/;
    static var re_terminalWhiteSpace = ~/\s+$/;
	
	static var reg_mol_id : EReg = ~/^\s*MOL_ID:\s*([0-9]+)\s*;/;
	static var reg_mol_chains : EReg = ~/^ CHAIN:\s*([A-Za-z0-9,\s]+)\s*/;

    //Host expression
	static var reg_host_expression_name : EReg = ~/^\s*EXPRESSION_SYSTEM:\s*([^;]+);/;
    static var reg_host_expression_id : EReg = ~/^\s*EXPRESSION_SYSTEM_TAXID:\s*([^;]+);/;

    //Origin
    static var reg_gene_expression_name : EReg = ~/^\s*ORGANISM_SCIENTIFIC:\s*([^;]+);/;
    static var reg_gene_expression_id : EReg = ~/^\s*ORGANISM_TAXID:\s*([^;]+);/;


    static var attribute_to_regex = [
                                     'SOURCE'=>[
                                        'EXPRESSION_SYSTEM'=>reg_host_expression_name,
                                        'EXPRESSION_SYSTEM_ID'=>reg_host_expression_id,
                                        'ORGANISM_SCIENTIFIC'=>reg_gene_expression_name,
                                        'ORGANISM_TAXID'=>reg_gene_expression_id
                                     ],
                                     'REMARK'=>[
                                        'HIGH_RES' => ~/REMARK\s+2\s+RESOLUTION.\s+([\d\.]+)/
                                     ]
    ];

    static var attribute_to_range  : Map<String, Map<String, Map<String, Dynamic>>> = [
                                   'TITLE'=> ['TITLE'=>['REGEX'=>null, 'START'=>10, 'STOP'=>79]],
                                   'AUTHOR'=> ['AUTHOR'=>['REGEX'=>null, 'START'=>10, 'STOP'=>78]],
                                   'EXPDTA'=> ['EXP_TYPE'=>['REGEX'=>null, 'START'=>10, 'STOP'=>78]],
                                   'HEADER'=>['DEPOSITION_DATE'=>['REGEX'=>null, 'START'=>50, 'STOP'=>59]]
    ];

    static var sourceOrder = ['EXPRESSION_SYSTEM', 'EXPRESSION_SYSTEM_ID', 'ORGANISM_SCIENTIFIC', 'ORGANISM_TAXID'];
    static var attributeOrder =['DEPOSITION_DATE'];

    public static function extractPDBID( fileName ) : String {
		//pdbCodeReg.match(fileName);
		
		//return pdbCodeReg.matched(1);
        return fileName;
	}
	
	#if !js
	public static function getExpression( fileContent : String, pdbCode : String, outFd : FileOutput) : Map<String, Dynamic> {
	#else
	public static function getExpression( fileContent : String, pdbCode : String, outFd : Dynamic) : Map<String, Dynamic> {
	#end
		var lines = fileContent.split('\n'); //split file into array
		
		var molToChain = new Map<String, Array<String>>();
        var attributes = new Map<String, Dynamic>();
        var readingChains = false;

        attributes.set('SOURCE', new Map<String, String>());
        attributes.set('CHAINS', new Map<String, String>());

        attributes.set('PDB_CODE', pdbCode);

		var currentMolId = '-1';
        var srcMolId = '-1';

		for (line in lines) {
			var type = line.substr(0, 6);

            type = whiteSpaceReg.replace(type, '');

            var desc = line.substr(10, 70);

            if (type == 'SOURCE') {
                if (reg_mol_id.match(desc)) {
                    srcMolId = reg_mol_id.matched(1);

                    srcMolId = whiteSpaceReg.replace(srcMolId, '');

                    attributes.get('SOURCE').set(srcMolId, new Map<String, String>());

                    continue;
                }
            }

            if(type == 'REVDAT'){
                var modType = line.substr(31,1);

                if(modType == '0'){
                    var relDate = line.substring(13, 22);

                    attributes.set('RELDATE', relDate);
                }
            }

            if(attribute_to_regex.exists(type)){
                for(attribute_name in attribute_to_regex.get(type).keys()){
                    var regex = attribute_to_regex.get(type).get(attribute_name);

                    if(type == 'SOURCE'){
                        if(regex.match(desc)){
                            var attribute_value = regex.matched(1);

                            if(type == 'SOURCE'){
                                trace(srcMolId);

                                attributes.get('SOURCE').get(srcMolId).set(attribute_name, attribute_value);
                            }
                        }
                    }else{
                        if(regex.match(line)){
                            var attribute_value = regex.matched(1);

                            if(attributes.exists(attribute_name)){
                                attributes.set(attribute_name, attributes.get(attribute_name ) + attribute_value);
                            }else{
                                attributes.set(attribute_name, attribute_value);
                            }
                        }
                    }
                }
            }else if(attribute_to_range.exists(type)){
                if(type == 'REMARK'){
                    var remark_id = line.substr(7, 9);

                    remark_id = whiteSpaceReg.replace(remark_id,'');

                    type = type + ':' + remark_id;
                }

                for(attribute_name in attribute_to_range.get(type).keys()){
                    var regex = attribute_to_range.get(type).get(attribute_name).get('REGEX');
                    if(regex != null){


                    }

                    var start = attribute_to_range.get(type).get(attribute_name).get('START');
                    var stop = attribute_to_range.get(type).get(attribute_name).get('STOP');

                    var attribute_value = line.substring(start, stop);

                    attribute_value = re_terminalWhiteSpace.replace(attribute_value, '');

                    if(attributes.exists(attribute_name)){
                        attributes.set(attribute_name, attributes.get(attribute_name ) + attribute_value);
                    }else{
                        attributes.set(attribute_name, attribute_value);
                    }
                }
            }else if (type == 'COMPND') {
				var desc = line.substr(10, 70);
				
				if (reg_mol_id.match(desc)) {
					var molId = reg_mol_id.matched(1);
					
					currentMolId = whiteSpaceReg.replace(molId, '');
					
					molToChain.set(currentMolId, new Array<String>());

                    readingChains = false;
				}else{
                    var chainStr =  '';
                    if(readingChains){
                        chainStr = line.substring(10, 80);
                    }else{
                        if (reg_mol_chains.match(desc)) {
                            chainStr = reg_mol_chains.matched(1);
                        }else{
                            continue;
                        }
                    }

                    readingChains = line.indexOf(';') == -1;
					
					var chainList = new Array<String>();
					if (chainStr.indexOf(',') != -1) {
						
						chainList = chainStr.split(',');
						for (i in 0...chainList.length) {
							chainList[i]=whiteSpaceReg.replace(chainList[i],'');
						}
					}else {
						chainList.push(whiteSpaceReg.replace(chainStr,''));
					}
					
					for (i in 0...chainList.length) {
						molToChain.get(currentMolId).push(chainList[i]);

                        attributes.get('CHAINS').set(chainList[i], currentMolId);
					}
				}
			}else if (type == 'ATOM  ' || type == 'HETATM') {
				break;
			}
		}

        if(outFd != null){
            var keyIt :Iterator<Dynamic> = attributes.get('CHAINS').keys();
            for( chain in keyIt ){
                var molId = attributes.get('CHAINS').get(chain);

                outFd.writeString(
                                    pdbCode + '~' +
                                    chain + '~' +
                                    molId + '~' +
                                    attributes.get('DEPOSITION_DATE') + '~' +
                                    attributes.get('HIGH_RES') + '~' +
                                    attributes.get('EXP_TYPE') + '~' +
                                    StringTools.replace(attributes.get('TITLE'),'~','-') + '~' +
                                    attributes.get('AUTHOR') );

                if(attributes.get('SOURCE').exists(molId)){
                    var source_def = attributes.get('SOURCE').get(molId);

                    for(col in sourceOrder){
                        if(source_def.exists(col)){
                            outFd.writeString('~' + source_def.get(col));
                        }else{
                            outFd.writeString('~-');
                        }
                    }
                }else{
                    for(col in sourceOrder){
                        outFd.writeString('~-');
                    }
                }

                outFd.writeString('~' + attributes.get('RELDATE'));

                outFd.writeString('\n');

            }
        }

		return attributes;
	}
	
	
	#if !js
	public static function getSequences( fileContent : String, pdbCode : String, fastaFd : FileOutput) : Array<FastaEntity> {	
	#else
	public static function getSequences( fileContent : String, pdbCode : String, fastaFd : Dynamic) : Array<FastaEntity> {	
	#end
				
		var lines = fileContent.split('\n'); //split file into array
		
		var lastResNum = '-1A'; //set to impossible value
		var lastChain = '0000000'; //set to impossible value
		
		var chainsSeen : Map<String, String> = new Map<String, String>();
		
		var seqResChains : Map < String, String > = new Map < String, String>();
		
		var skipping : Bool = false;
		
		var atomReached : Bool = false;
		
		var fastaObjs : Array<FastaEntity> = new Array<FastaEntity>();
		var fastaEntity : FastaEntity = null;

        var first = true;

		for (line in lines) {
			var type = line.substr(0, 6);
			
			/**
			 * SEQRES: Retrieve Protein Sequences
			 */
			if ( atomReached == false && type == 'SEQRES') {
				var chain = line.substr(11, 1);
				
				if (chain != lastChain) { 
					// When the chain has changed print FASTA header

					if ( first ) {
                        first = false;
                    }else{
						// When the last chain wasn't the first chain terminate last chain's sequence
						if(fastaFd != null){
							fastaFd.writeString('\n');
						}
					}

                    lastChain = chain; // Record the current chain
					
					seqResChains[chain] = 'Y'; // Record the chains listed in the SEQRES
					
					if (fastaEntity != null) {
						fastaObjs.push(fastaEntity);
					}
					
					if (fastaFd == null) {
						fastaEntity = new FastaEntity('>'+pdbCode+'_S_'+chain +'\n','');
					}else {
						fastaFd.writeString('>'+pdbCode+'_S_'+chain +'\n'); // Write out the FASTA header line
					}
				}
				
				var resListStr : String = line.substr(19, 51); // Get residues
				var resStrs : Array<String> = whiteSpaceReg.split(resListStr); // Create residue array
				
				for ( resName in resStrs) {
					// Loop over residues
					
					if (resName == null || resName == '') {
						// Skip trailing empty residue block
						continue;
					}
					var singleResName = pdb3To1[resName]; // Convert three letter to one letter (includes some mods)
				
					if (singleResName == null) {
						// Convert unknown residue types to X
						
						singleResName = 'X';
					}
				
					// Append current residue to FASTA sequence
					if (fastaFd == null) {
						fastaEntity.append(singleResName);
					}else{
						fastaFd.writeString(singleResName);
					}
				}
			}
			
			if (type == 'TER   ') {
				/**
				 * Prevent HETATM records being accepted that are outside of
				 * a chain that hasn't been seen before				 * 
				 */
				lastChain = '0000000';
			}
			
			if (type == 'ATOM  ' || type == 'HETATM') {
				if (atomReached == false) {
					lastChain = '0000000';
					atomReached = true;
				}
				
				var resNum = line.substr(22, 4);
				
				if ( lastResNum != resNum ) {
					lastResNum = resNum;
				}else {
					//already, seen this residue so continue
					continue;
				}
				
				var chain = line.substr(21, 1);
				
				if ( lastChain != chain ) { //check if chain has changed
					lastChain = chain;
					
					if (chainsSeen.exists(chain) || !seqResChains.exists(chain)) { //if chain has changed back to a previous one skip it
						skipping = true;
						continue;
					}else {
						skipping = false;
					}
					
					chainsSeen[chain] = 'Y'; //record that we have seen this chain
					
					var chain = whiteSpaceReg.replace(chain, '');
					var resNum = whiteSpaceReg.replace(resNum, '');

                    if ( first ) {
                        first = false;
                    }else{
                        // When the last chain wasn't the first chain terminate last chain's sequence
                        if(fastaFd != null){
                            fastaFd.writeString('\n');
                        }
                    }
					
					if(fastaFd != null){
						fastaFd.writeString('>' + pdbCode + '_A_' + chain + '_' + resNum +'\n');
					}else {
						if (fastaEntity != null) {
							fastaObjs.push(fastaEntity);
						}
						
						fastaEntity = new FastaEntity('>' + pdbCode + '_A_' + chain + '_' + resNum +'\n', '');
					}
				}
				
				if (skipping == false) { //if not skipping chain
					var resName = line.substr(17, 3);
					
					var singleResName = pdb3To1[resName]; //convert three letter to one letter (includes some mods)
				
					if (singleResName == null) {
						singleResName = 'X';
					}
				
					if(fastaFd != null){
						fastaFd.writeString(singleResName);
					}else {
						fastaEntity.append(singleResName);
					}
				}
			}
		}

        if(fastaFd != null){
            fastaFd.writeString('\n');
        }

		fastaObjs.push(fastaEntity);
		
		return fastaObjs;
	}
}