/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.scripts;

import saturn.db.query_lang.IsNotNull;
import saturn.db.query_lang.IsNull;
import saturn.db.query_lang.ValueList;
import saturn.db.query_lang.In;
import saturn.db.query_lang.Equals;
import saturn.db.query_lang.Field;
import saturn.db.query_lang.Count;
import saturn.db.query_lang.SQLVisitor;
import saturn.db.query_lang.Value;
import saturn.db.query_lang.Max;
import saturn.client.core.CommonCore;
import saturn.db.query_lang.Query;
import saturn.core.EntityType;
import saturn.core.domain.Molecule;
import saturn.core.ReactionRole;
import saturn.core.ReactionComponent;
import saturn.core.ReactionType;
import saturn.core.Reaction;
import saturn.core.Protein;
import saturn.core.EUtils;
import saturn.db.DefaultProvider;
import saturn.db.DefaultProvider;
import saturn.db.BatchFetch;
import saturn.db.Model;
import saturn.core.domain.MoleculeAnnotation;
import saturn.core.domain.DataSource;
import saturn.core.domain.Entity;
import saturn.workflow.DBtoFASTA.DBtoFASTAConfig;
import saturn.workflow.DBtoFASTA.SequenceType;

import saturn.workflow.HMMer.HMMerConfig;
import saturn.workflow.HMMer.HMMerProgram;
import saturn.workflow.Chain;

import saturn.db.Model;

@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":async"))
class QueryTestScript extends BaseScript{
    @:async override function run(){
        print('Starting Query Tests');

        test1();
        test2();
        test3();
        test4();
        test5();
        test6();
        test7();
    }

    public function test1(){
        var p = CommonCore.getDefaultProvider(null, 'sgcdata');

        var query = new Query(p);

        query.getSelect().addToken(new Max(new Value(10)));

        var visitor = new SQLVisitor(p);
        var translation = visitor.translate(query);
        print('Translation finished');

        var expected = ' SELECT MAX(  :0  ) FROM ';
        if(translation == expected){
            print(translation);
        }else{
            die('Failed Test 1: expected-' + expected + '- but got -' + translation+'-');
        }
    }

    public function test2(){
        var p = CommonCore.getDefaultProvider(null, 'sgcdata');

        var query = new Query(p);

        query.getSelect().addToken(new Max(new Count(new Value(10))));

        var visitor = new SQLVisitor(p);
        var translation = visitor.translate(query);
        print('Translation finished');

        var expected = ' SELECT MAX( COUNT(  :0  ) ) FROM ';
        if(translation == expected){
            print(translation);
        }else{
            die('Failed Test 1: expected-' + expected + '- but got -' + translation+'-');
        }
    }

    public function test3(){
        var p = CommonCore.getDefaultProvider(null, 'sgcdata');

        var query = new Query(p);

        query.getSelect().addToken(new Max(new Field(saturn.core.domain.SgcAllele, 'alleleId')));

        var visitor = new SQLVisitor(p);
        var translation = visitor.translate(query);
        print('Translation finished');

        var expected = ' SELECT MAX( SGC.ALLELE.ALLELE_ID ) FROM  SGC.ALLELE ';
        if(translation == expected){
            print(translation);
        }else{
            die('Failed Test 1: expected-' + expected + '- but got -' + translation+'-');
        }
    }

    public function test4(){
        var p = CommonCore.getDefaultProvider(null, 'sgcdata');

        var query = new Query(p);

        query.getSelect().addToken(new Max(new Field(saturn.core.domain.SgcAllele, 'alleleId')));
        query.getSelect().addToken(new Field(saturn.core.domain.SgcAllele, 'id'));

        var visitor = new SQLVisitor(p);
        var translation = visitor.translate(query);
        print('Translation finished');

        var expected = ' SELECT MAX( SGC.ALLELE.ALLELE_ID ),SGC.ALLELE.PKEY FROM  SGC.ALLELE ';
        if(translation == expected){
            print(translation);
        }else{
            die('Failed Test 1: expected-' + expected + '- but got -' + translation+'-');
        }
    }

    public function test5(){
        var p = CommonCore.getDefaultProvider(null, 'sgcdata');

        var query = new Query(p);

        query.getSelect().addToken(new Max(new Field(saturn.core.domain.SgcAllele, 'alleleId')));
        query.getSelect().addToken(new Field(saturn.core.domain.SgcAllele, 'id'));
        query.getWhere().addToken(new Field(saturn.core.domain.SgcAllele, 'id')).addToken(new Equals(new Value('BRD1A-m001')));

        var visitor = new SQLVisitor(p);
        var translation = visitor.translate(query);
        print('Translation finished');

        var expected = ' SELECT MAX( SGC.ALLELE.ALLELE_ID ),SGC.ALLELE.PKEY FROM  SGC.ALLELE  WHERE SGC.ALLELE.PKEY  =  :0 ';
        if(translation == expected){
            print(translation);
        }else{
            die('Failed Test 1: expected-' + expected + '- but got -' + translation+'-');
        }
    }

    public function test6(){
        var p = CommonCore.getDefaultProvider(null, 'sgcdata');

        var query = new Query(p);

        query.getSelect().addToken(new Max(new Field(saturn.core.domain.SgcAllele, 'alleleId')));
        query.getSelect().addToken(new Field(saturn.core.domain.SgcAllele, 'id'));
        query.getWhere().addToken(new Field(saturn.core.domain.SgcAllele, 'id')).addToken(new In(new ValueList(['BRD1A-m001', 'BRD2A-m002'])));

        var visitor = new SQLVisitor(p);
        var translation = visitor.translate(query);
        print('Translation finished');

        var expected = ' SELECT MAX( SGC.ALLELE.ALLELE_ID ),SGC.ALLELE.PKEY FROM  SGC.ALLELE  WHERE SGC.ALLELE.PKEY  IN  ( :0,:1 ) ';
        if(translation == expected){
            print(translation);
        }else{
            die('Failed Test 1: expected-' + expected + '- but got -' + translation+'-');
        }
    }

    public function test7(){
        var p = CommonCore.getDefaultProvider(null, 'sgcdata');

        var query = new Query(p);

        var allele :Dynamic = new saturn.core.domain.SgcAllele();
        allele.alleleId = 'BRD1A-a001';
        allele.dnaSeq = new IsNull();
        allele.id = new IsNotNull();

        query.getSelect().addToken(new Max(new Field(saturn.core.domain.SgcAllele, 'alleleId')));
        query.getSelect().addToken(new Field(saturn.core.domain.SgcAllele, 'id'));
        query.addExample(allele);

        var visitor = new SQLVisitor(p);
        var translation = visitor.translate(query);
        print('Translation finished');

        var expected = ' SELECT MAX( SGC.ALLELE.ALLELE_ID ),SGC.ALLELE.PKEY FROM  SGC.ALLELE  WHERE SGC.ALLELE.PKEY  IN  ( :0,:1 ) ';
        if(translation == expected){
            print(translation);
        }else{
            die('Failed Test 1: expected-' + expected + '- but got -' + translation+'-');
        }
    }
}
