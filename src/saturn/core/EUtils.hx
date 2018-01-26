/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

#if NODE
import js.Node;
#end

import saturn.core.DNA.GeneticCodes;
using saturn.core.Util;

import saturn.core.DNA.Frame;

import saturn.core.Util.*;

class EUtils {
    #if (NODE && NCBI_EUTILS)
    static var eutils :Dynamic = Node.require('ncbi-eutils');
    #else
    static var eutils : Dynamic = null;//js.Lib.require('ncbi-eutils');
    #end

    public function new() {

    }

    public static function getProteinsForGene(geneId : Int, cb : String->Array<Protein>->Void){
        getProteinGIsForGene(geneId, function(err : String, ids : Array<Int>){
            if(err != null){
                cb(err, null);
            }else{
                getProteinInfo(ids, true, function(err : String, objs : Array<Protein>){
                    cb(err, objs);
                });
            }
        });
    }

    public static function getProteinInfo(ids : Array<Int>,  lookupDNA : Bool = false, cb: String->Array<Protein>->Void){
        var c1 = eutils.efetch({
            db: 'protein', id: ids, retmode: 'xml'
        }).then(function(d : Dynamic){
            if(! Reflect.hasField(d, 'GBSet')){
                cb('Unable to retrieve proteins for  ' + ids.toString(),null);
                return;
            }

            var objs : Array<Dynamic>;

            //TODO check if this is coming from EUtils or the XML->JSON convertor
            if(Std.is(d.GBSet.GBSeq, Array)){
                objs = d.GBSet.GBSeq;
            }else{
                objs = [d.GBSet.GBSeq];
            }

            if(objs == null || objs.length == 0){
                cb('Unable to retrieve proteins for  ' + ids.join(','),null);
                return;
            }

            var protObjs = new Array<Protein>();

            for(seqObj in objs){
                var protein = new Protein(seqObj.GBSeq_sequence);

                protObjs.push(protein);

                protein.setMoleculeName(Reflect.field(seqObj,'GBSeq_accession-version'));

                if(Reflect.hasField(seqObj, 'GBSeq_other-seqids')){
                    var seqIdElems : Array<Dynamic> = Reflect.field(Reflect.field(seqObj, 'GBSeq_other-seqids'), 'GBSeqid');

                    for(seqIdElem in seqIdElems){
                        var seqId : String = seqIdElem;

                        if(seqId.indexOf('gi|') == 0){
                            protein.setAlternativeName(seqId);
                            break;
                        }
                    }
                }

                if(Reflect.hasField(seqObj, 'GBSeq_feature-table')){
                    var table = Reflect.field(seqObj, 'GBSeq_feature-table');

                    var features :Array<Dynamic> = table.GBFeature;
                    for(feature in features){

                        if(feature.GBFeature_key == 'CDS'){
                            var feature_quals :Array<Dynamic> = feature.GBFeature_quals.GBQualifier;
                            for(feature in feature_quals){
                                if(feature.GBQualifier_name == 'coded_by'){
                                    var acStr = feature.GBQualifier_value;
                                    var parts :Array<String> = acStr.split(':');

                                    if(parts.length > 2){
                                        cb('Parts greater than two for  ' + protein.getMoleculeName(), null); return;
                                    }else{
                                        var dna = new DNA(null);

                                        var name = parts[0];//.substring(0, parts[0].indexOf('.'));

                                        dna.setMoleculeName(name);

                                        dna.addProtein('default', protein);

                                        //protein.setDNA(dna);
                                        protein.setReferenceCoordinates(parts[1]);
                                    }
                                }
                            }
                        }
                    }
               }
            }

            if(lookupDNA){
                var dnaRefs = new Array<String>();

                for(protObj in protObjs){
                    dnaRefs.push(protObj.getDNA().getMoleculeName());
                }

                getDNAForAccessions(dnaRefs, function(err : String, dnaObjs : Array<DNA>){
                    if(err != null){
                        cb(err, null);
                    }else{
                        var refMap = new Map<String, DNA>();

                        for(obj in dnaObjs){
                            refMap.set(obj.getMoleculeName(), obj);
                        }

                        for(protObj in protObjs){
                            var dnaAccession = protObj.getDNA().getMoleculeName();
                            if(refMap.exists(dnaAccession)){
                                var dna : DNA = refMap.get(dnaAccession);
                                protObj.setDNA(dna);

                                var coords = protObj.getReferenceCoordinates().split('..');

                                if(coords.length > 2){
                                    cb('Invalid coordinate string for ' + protObj.getMoleculeName() + ' ' + protObj.getReferenceCoordinates(), null); return;
                                }

                                dna.setSequence(dna.getRegion(Std.parseInt(coords[0]), Std.parseInt(coords[1])));

                                var protSeq = dna.getFrameTranslation(GeneticCodes.STANDARD, Frame.ONE);
                            }else{
                                cb(dnaAccession + ' not found', null); return;
                            }
                        }

                        cb(null, protObjs);
                    }
                });
            }else{
                cb(null, protObjs);
            }


        });

        //Catch is a keyword in Haxe
        untyped __js__('c1.catch(function(d){cb(d)});');
    }

    public static function getDNAForAccessions(accessions : Array<String>, cb: String->Array<DNA>->Void){
        var c1 = eutils.efetch({
            db: 'nucleotide', id: accessions, retmode: 'xml'
        }).then(function(d : Dynamic){
            var objs : Array<Dynamic>;

            //TODO check if this is coming from EUtils or the XML->JSON convertor
            if(Std.is(d.GBSet.GBSeq, Array)){
                objs = d.GBSet.GBSeq;
            }else{
                objs = [d.GBSet.GBSeq];
            }

            if(objs == null || objs.length == 0){
                cb('Unable to retrieve proteins for  ' + accessions.join(','),null);
                return;
            }

            var dnaObjs = new Array<DNA>();

            for(seqObj in objs){
                var dna = new DNA(seqObj.GBSeq_sequence);

                dnaObjs.push(dna);

                dna.setMoleculeName(Reflect.field(seqObj, 'GBSeq_accession-version'));

                if(Reflect.hasField(seqObj, 'GBSeq_other-seqids')){
                    var seqIdElems : Array<Dynamic> = Reflect.field(Reflect.field(seqObj, 'GBSeq_other-seqids'), 'GBSeqid');

                    for(seqIdElem in seqIdElems){
                        var seqId : String = seqIdElem;

                        if(seqId.indexOf('gi|') == 0){
                            dna.setAlternativeName(seqId);
                            break;
                        }
                    }
                }
            }

            cb(null, dnaObjs);
        });

        //Catch is a keyword in Haxe
        untyped __js__('c1.catch(function(d){cb(d)});');
    }

    public static function getProteinGIsForGene(geneId : Int, cb : String->Array<Int>->Void){
        //TODO Add support for catching pseudogenes
        var c1 = eutils.esearch({
            db: 'gene', term: geneId
        }).then(
            eutils.elink({dbto:'protein'})
        ).then(function (d : Dynamic) {
            debug('');

            var found = false;

            if(Reflect.hasField(d, 'linksets')){
                var linksets :Array<Dynamic> = d.linksets;
                if(linksets.length > 0){
                    if(Reflect.hasField(linksets[0], 'linksetdbs')){
                        var linksetdbs : Array<Dynamic> = linksets[0].linksetdbs;
                        if(linksetdbs.length > 0){
                            for(set in linksetdbs){
                                if(set.linkname == 'gene_protein_refseq'){
                                    var ids = set.links;

                                    cb(null, ids);

                                    found = true;

                                    break;
                                }
                            }
                        }
                    }
                }
            }

            if(!found){
                cb('Unable to lookup gene entry ' + geneId, null);
            }
        });

        //Catch is a keyword in Haxe
        untyped __js__('c1.catch(function(d){cb(d)});');
    }

    public static function insertProteins(objs : Array<Protein>, cb : String->Void){
        var run = null;

        run = function(){
            if(objs.length == 0){
                return;
            }

            var protein = objs.pop();

            debug('Inserting: ' + protein.getMoleculeName());

            Protein.insertTranslation(
                protein.getDNA().getMoleculeName(),
                protein.getDNA().getAlternativeName(),
                protein.getDNA().getSequence(),
                'NUCLEOTIDE',
                protein.getMoleculeName(),
                protein.getAlternativeName(),
                protein.getSequence(),
                'PROTEIN',
                '7158',
                'GENE',
                function(err : String){
                    if(err != null){
                        debug(err);
                    }else{
                        run();
                    }
                }
            );
        };

        run();
    }

    public static function getGeneInfo(geneId : Int, cb: String->Dynamic->Void){
        debug('Fetching gene record (tends to be very slow)');
        var c1 = eutils.efetch({
            db: 'gene', id: geneId
        }).then(function (d : Dynamic) {
            //TODO: Implement dot access
            var set1 =  Reflect.field(d, 'Entrezgene-Set');
            var set2 = Reflect.field(set1, 'Entrezgene');
            var set3 = Reflect.field(set2, 'Entrezgene_gene');
            var set4 = Reflect.field(set3, 'Gene-ref');

            cb(null, {
                symbol: Reflect.field(set4, 'Gene-ref_locus'),
                description: Reflect.field(set4, 'Gene-ref_desc')
            });
        });

        //Catch is a keyword in Haxe
        untyped __js__('c1.catch(function(d){cb(d)});');
    }
}
