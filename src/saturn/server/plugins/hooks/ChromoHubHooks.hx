package saturn.server.plugins.hooks;
import saturn.core.Util;

import haxe.Serializer;

class ChromoHubHooks {
    public static function hookInsertUpdatedTree(query : String, params : Array<Dynamic>, clazz : String, cb : Dynamic->String->Void){
        var provider = Util.getProvider();
        var sql : String = '';
        var boundParameters: Array<Dynamic>;
        boundParameters=new Array();

        boundParameters.push(params[0].family);
        boundParameters.push(params[0].domain);
        sql="DELETE FROM probes_tree2.updated_trees WHERE familyName = ? and domainbase = ?";
        provider.getConnection(null, function(err, connection){
            if(err != null){
                cb(null, err);
            }else{
                try {
                    connection.execute(sql, boundParameters, function(err, results){
                        Util.debug('Named query returning');

                        if(err != null){
                            cb(null, err);
                        }else{
                            var boundParameters: Array<Dynamic>;
                            boundParameters=new Array();
                            sql="INSERT INTO updated_trees (nodeId, familyName, domainbase, nodeX, nodeY, angle, clock) VALUES";

                            var blocks = [];
                            while(params.length>0){

                                var auxpop=params.pop();
                                var s="(?,?,?,?,?,?,?)";
                                blocks.push(s);
                                boundParameters.push(auxpop.nodeId);
                                boundParameters.push(auxpop.family);
                                boundParameters.push(auxpop.domain);
                                boundParameters.push(auxpop.nodeX);
                                boundParameters.push(auxpop.nodeY);
                                boundParameters.push(auxpop.angle);
                                boundParameters.push(auxpop.clock);
                            }

                            var i=0;
                            for (i in 0...blocks.length-1){
                                sql=sql+blocks[i]+",";
                            }
                            sql=sql+blocks[i];
                            //we need to remove the last "," of the sql string

                            Util.debug(sql);
                            provider.getConnection(null, function(err, connection){
                                if(err != null){
                                    cb(null, err);
                                }else{
                                    try {
                                        connection.execute(sql, boundParameters, function(err, results){
                                            Util.debug('Named query returning');

                                            if(err != null){
                                                cb(null, err);
                                            }else{
                                                cb(results, null);
                                            }

                                            provider.closeConnection(connection);
                                        });
                                    }catch(e:Dynamic){
                                        provider.closeConnection(connection);

                                        cb(null, e);
                                    }
                                }
                            });
                            cb(results, null);
                        }

                        provider.closeConnection(connection);
                    });
                }catch(e:Dynamic){
                    provider.closeConnection(connection);

                    cb(null, e);
                }
            }
        });
    }

    public static function hookDeleteUpdatedTree(query : String, params : Array<Dynamic>, clazz : String, cb : Dynamic->String->Void){


        var provider = Util.getProvider();
        var sql : String = '';
        var boundParameters: Array<Dynamic>;
        boundParameters=new Array();

        boundParameters.push(params[0].family);
        boundParameters.push(params[0].domain);
        sql="DELETE FROM probes_tree2.updated_trees WHERE familyName = ? and domainbase = ?";
        provider.getConnection(null, function(err, connection){
            if(err != null){
                cb(null, err);
            }else{
                try {
                    connection.execute(sql, boundParameters, function(err, results){
                        Util.debug('Named query returning');

                        if(err != null){
                            cb(null, err);
                        }else{
                            cb(results, null);
                        }

                        provider.closeConnection(connection);
                    });
                }catch(e:Dynamic){
                    provider.closeConnection(connection);

                    cb(null, e);
                }
            }
        });


    }

    public static function hookHasInhibitors(query : String, params : Array<Dynamic>, clazz : String, cb : Dynamic->String->Void){

        var provider = Util.getProvider();
        var sql : String = '';
        var boundParameters: Array<Dynamic>;
        boundParameters=new Array();

        boundParameters[0]=params[0].familyTree;

        var ligand_select= params[0].ligand_select;
        var chemi_sel= params[0].chemi_sel;

        var img_lig_per_row = 4;

        var lig_cond = "";

        switch(ligand_select){
            case "1":
                lig_cond = "";
            case "5":
                lig_cond = " AND tlj.ic50 < 5";
            case "2":
                lig_cond = " AND tlj.ic50 < 2";
            case "0":
                lig_cond = " AND tlj.ic50 < 0.5";
        }

        if(chemi_sel==true){
            lig_cond += " AND tlj.is_chemical_probe IS NOT NULL AND tlj.is_chemical_probe='yes' ";
        }

        var st_family_or_genes = '';
        if (params[0].searchGenes == null) {
            st_family_or_genes = ' ftj.family_id = ? ';
        }

        else {
            var placeholders = new Array<String>();
            var i = 0;
            var searchGenes : Array<Dynamic> = params[0].searchGenes;
            for (key in searchGenes) {
                placeholders.push('?');
            }

            st_family_or_genes = " ftj.target_id IN ("+placeholders.join(',')+") ";
            boundParameters = params[0].searchGenes;
        }

        if (params[0].treeType=='gene') {
            sql = 'SELECT distinct ftj.target_id, null target_name_index, variant_index, tlj.ic50, tlj.tmshift, tlj.type, l.pkey, l.name, l.smiles, tlj.pmid_list as pmid,
					tlj.reference as ref
					FROM target_ligand_join tlj,  ligand l, family_target_join ftj, variant v
					WHERE '+st_family_or_genes+'
						AND ftj.target_id=v.target_id
						AND v.is_default=1
						AND ftj.pkey=tlj.family_target_join_pkey
						AND tlj.ligand_pkey = l.pkey '+lig_cond;
        } else {
            sql = 'select distinct dh.target_id, dh.name_index target_name_index, dh.variant_index, tlj.ic50, tlj.tmshift, tlj.type, l.pkey, l.name, l.smiles, tlj.pmid_list as pmid, tlj.reference as ref
					FROM target_ligand_join tlj, ligand l, family_target_join ftj, domain_highlighted dh, target_ligand_join_domainremoved
					WHERE '+st_family_or_genes+'
					AND ftj.pkey = tlj.family_target_join_pkey
					AND dh.on_tree=1
					AND ftj.family_id=dh.family_id
					AND ftj.target_id= dh.target_id
					AND dh.pkey NOT IN (SELECT domain_highlighted_pkey FROM target_ligand_join_domainremoved WHERE ligand_pkey=tlj.ligand_pkey)
					and tlj.ligand_pkey = l.pkey'+lig_cond;
        }

        provider.getConnection(null, function(err, connection){
            if(err != null){
                cb(null, err);
            }else{
                try {
                    connection.execute(sql, boundParameters, function(err, results){
                        Util.debug('Named query returning');

                        if(err != null){
                            cb(null, err);
                        }else{
                            var l="lenght is:"+results.length;
                            Util.debug(l);
                            cb(results, null);
                        }

                        provider.closeConnection(connection);
                    });
                }catch(e:Dynamic){
                    provider.closeConnection(connection);

                    cb(null, e);
                }
            }
        });

    }

    public static function hookHasStructure(query : String, params : Array<Dynamic>, clazz : String, cb : Dynamic->String->Void){
        var provider = Util.getProvider();

        var sql : String = '';
        var boundParameters: Array<Dynamic>;
        boundParameters=new Array();
        boundParameters[0] = params[0].familyTree;

        var st_type_cond = "";

        switch(params[0].st_select){
            case 2:
                st_type_cond = " and s.type REGEXP 'cofactor' ";
            case 3:
                st_type_cond = " and s.type REGEXP 'peptide' ";
            case 4:
                st_type_cond = " and s.type REGEXP 'inhibitor' ";
        }

        var st_cutoff = "";
        var st_percent_cond = " and s.percent_id IS NOT NULL ";
        switch(params[0].cutoff){
            case "best":
                st_cutoff = "_best";
            case "low":
                st_cutoff = "_40";
            default : // "95% or best":
                st_cutoff = "";
                st_percent_cond += " and s.percent_id >= 94.5 ";
        }

        var xray_cond='';
        if(params[0].xray=='true'){
            xray_cond = " and pdb.has_xray = 1 ";
        }
        else xray_cond = "";


        var st_family_or_genes = '';
        if (params[0].searchGenes == null) {
            st_family_or_genes = ' ftj.family_id = ?';
        }

        else {
            var placeholders = new Array<String>();
            var i = 0;
            var searchGenes : Array<Dynamic> = params[0].searchGenes;
            for (key in searchGenes) {
                placeholders.push('?');
            }

            st_family_or_genes = " ftj.target_id IN ("+placeholders.join(',')+") ";
            boundParameters = params[0].searchGenes;
        }

        if(params[0].st_select == '1'){ //=dom
            //st_family_or_genes = ' ftj.family_id = ? ';
            if(params[0].treeType=='gene') {
                sql = "SELECT distinct d.target_id, null target_name_index, v.variant_index, max(pdb.is_sgc) as sgc, max(pdb.has_xray) as xray	FROM structure_highlighted sh, structure s, domain_highlighted d, pdb, variant v, family_target_join ftj WHERE sh.structure_pkey=s.pkey AND s.pdb_id=pdb.id AND sh.domain_highlighted_pkey=d.pkey AND dh.variant_index = v.variant_index and d.target_id=v.target_id and v.is_default=1 AND "+st_family_or_genes+" "+st_type_cond+st_percent_cond+xray_cond+" GROUP BY d.target_id, target_name_index, v.variant_index ORDER BY d.target_id, target_name_index, v.variant_index";
            } else {
                sql = "SELECT distinct d.target_id, d.name_index target_name_index, d.variant_index, max(pdb.is_sgc) as sgc, max(pdb.has_xray) as xray, ftj.family_id FROM structure_highlighted sh, structure s, family_target_join ftj, domain_highlighted d, pdb WHERE sh.structure_pkey=s.pkey AND s.pdb_id=pdb.id AND sh.domain_highlighted_pkey=d.pkey AND on_tree=1 AND "+st_family_or_genes+" and d.target_id = ftj.target_id "+st_type_cond+st_percent_cond+xray_cond+" GROUP BY d.target_id, d.name_index, d.variant_index ORDER BY d.target_id, d.name_index, d.variant_index";
            }
        }else{
            if(params[0].treeType=='gene') {
                sql = "SELECT distinct ftj.target_id, null target_name_index, variant_index, max(pdb.is_sgc) as sgc, max(pdb.has_xray) as xray, ftj.family_id FROM structure s, family_target_join ftj, pdb, variant v WHERE "+st_family_or_genes+" and ftj.target_id = v.target_id and pdb.id=s.pdb_id and v.is_default=1 and v.pkey=s.variant_pkey "+st_type_cond+st_percent_cond+xray_cond+" GROUP BY ftj.target_id, target_name_index, variant_index ORDER BY ftj.target_id, target_name_index, variant_index";

            } else {
                sql = "SELECT distinct d.target_id, d.name_index as target_name_index, d.variant_index, max(pdb.is_sgc) as sgc, max(pdb.has_xray) as xray, ftj.family_id FROM structure s, family_target_join ftj, domain_highlighted d, pdb, variant v WHERE "+st_family_or_genes+" and d.target_id = v.target_id and d.variant_index = v.variant_index and v.pkey=s.variant_pkey and pdb.id=s.pdb_id and on_tree=1 and d.target_id = ftj.target_id"+st_type_cond+st_percent_cond+xray_cond+" GROUP BY target_id, target_name_index, d.variant_index ORDER BY target_id, target_name_index, d.variant_index";
            }
        }

        Util.debug(sql);

        provider.getConnection(null, function(err, connection){
            if(err != null){
                cb(null, err);
            }else{
                try {
                    connection.execute(sql, boundParameters, function(err, results){
                        Util.debug('Named query returning');

                        if(err != null){
                            cb(null, err);
                        }else{
                            cb(results, null);
                        }

                        provider.closeConnection(connection);
                    });
                }catch(e:Dynamic){
                    provider.closeConnection(connection);

                    cb(null, e);
                }
            }
        });
    }

    public static function hookHasshRna(query : String, params : Array<Dynamic>, clazz : String, cb : Dynamic->String->Void){

        var provider = Util.getProvider();

        var sql : String = '';
        var boundParameters: Array<Dynamic>;
        boundParameters=new Array();

        var flagged=params[0].shrna_flag;
        var shrna_cutoff=params[0].shrna_cutoff;
        var shrna_num_cutoff=params[0].shrna_num_cutoff;
        var ftree = params[0].familyTree;
        var typetree = params[0].treeType;
        var flagresults=params[0].flagresults;


        var st_family_or_genes = '';
        var st_family_or_genes_domain = '';

        if (params[0].searchGenes == null) {
            st_family_or_genes = 'ftj.family_id = ?';
            st_family_or_genes_domain = 'dh.family_id = ?';
            boundParameters[0] =ftree;
        }

        else {
            st_family_or_genes = 'ftj.target_id = ?';
            st_family_or_genes_domain = 'dh.target_id = ?';

            var genes : Array<Dynamic> = params[0].searchGenes;
            for (gene in genes) {
                boundParameters.push(gene);
            }


        }

        boundParameters.push(shrna_cutoff);

        var allpar ='';
        for (paramString in boundParameters) {
            allpar += paramString + ' + ';
        }

        //cb(null, allpar);
        //return;


        var sql='';
        if (typetree == "domain") {
            sql = "select * from (select dh.target_id, dh.name_index, dh.variant_index, cl.cell_line, cl.log2
            from domain_highlighted dh, cancer_cell_lines_shrna cl, target t
            where "+st_family_or_genes_domain+" and (dh.target_id = t.symbol) and t.geneid = cl.geneid
            and dh.on_tree = 1 and cl.log2 <= ? ";

            sql += " union all select dh.target_id, dh.name_index, dh.variant_index, cl.cell_line, cl.log2
            from domain_highlighted dh, cancer_cell_lines_shrna cl, target t
            where "+st_family_or_genes_domain+" and (dh.target_id = t.id and t.id <> t.symbol) and t.geneid = cl.geneid
            and dh.on_tree = 1 and cl.log2 <= ?)a order by a.target_id, a.name_index, a.variant_index, a.cell_line, a.log2";

            var newBoundParameters = new Array();

            for(i in 0...2){
                for(item in boundParameters){
                    newBoundParameters.push(item);
                }
            }

            boundParameters = newBoundParameters;

            //cb(null, sql);
            //return;

        } else { //gene_based
            sql = "select * from (select ftj.target_id, null name_index, v.variant_index, cl.cell_line, cl.log2
            from family_target_join ftj, variant v, cancer_cell_lines_shrna cl, target t
            where "+st_family_or_genes+" and ftj.target_id = v.target_id and
            (ftj.target_id = t.symbol or ftj.target_id = t.id) and t.geneid = cl.geneid
            and v.is_default = 1 and cl.log2 <= ? ";


            sql += "union all select ftj.target_id, null name_index, v.variant_index, cl.cell_line,cl.log2
            from family_target_join ftj, variant v, cancer_cell_lines_shrna cl, target t
            where "+st_family_or_genes+" and ftj.target_id = v.target_id and
            (ftj.target_id = t.symbol or ftj.target_id = t.id) and t.geneid = cl.geneid
            and v.is_default = 1 and cl.log2 <= ?) a
            order by a.target_id, a.name_index, a.variant_index, a.cell_line, a.log2";

            var newBoundParameters = new Array();

            for(i in 0...2){
                for(item in boundParameters){
                    newBoundParameters.push(item);
                }
            }

            boundParameters = newBoundParameters;

        }

        Util.debug(sql);

        provider.getConnection(null, function(err, connection1){
            if(err != null){
                cb(null, err);
            }else{
                try {
                    connection1.execute(sql, boundParameters, function(err, results){
                        Util.debug('Named query returning');
                        if(err != null){
                            Util.debug('error-1');
                            cb(null, err);
                        }else{
                            var represented_celllines:Map<String, Int>;
                            represented_celllines = new Map();
                            var on_tree = [];
                            var j=0;
                            for (j in 0...results.length) {
                                var combo = results[j].cell_line+"-"+results[j].target_id+results[j].variant_index;
                                if (represented_celllines.exists(combo)==false){
                                    represented_celllines.set(combo,1);
                                }
                                else{
                                    var res=represented_celllines.get(combo);
                                    res=res+1;
                                    represented_celllines.set(combo,res);
                                }
                            }
                            var results : Array<{combo:String,value:Int}>;
                            results=new Array();
                            var i=0;
                            for (key in represented_celllines.keys()) {
                                results[i]={combo:key,value:represented_celllines.get(key)};
                                i++;
                            }

                           /* var obj = [{
                                'haxe-objects': Serializer.run(represented_celllines)
                            }];*/

                           cb(results, null);
                        }
                        provider.closeConnection(connection1);
                    });
                }catch(e:Dynamic){
                    provider.closeConnection(connection1);
                    cb(null, e);
                }
            }
        });
    }

    public static function hookHasRnaSeq(query : String, params : Array<Dynamic>, clazz : String, cb : Dynamic->String->Void){
        var provider = Util.getProvider();

        var sql : String = '';
        var boundParameters: Array<Dynamic>;
        boundParameters=new Array();

        var ftree = params[0].familyTree;
        var typetree = params[0].treeType;
        var seq_evaluator = params[0].seq_evaluator;
        var seqexp_fc_cutoff = params[0].seqexp_fc_cutoff;
        var seqexp_freq_cutoff = params[0].seqexp_freq_cutoff;
        var patient_seq_cutoff = params[0].patient_seq_cutoff;
        var seqexp_rank_cutoff = params[0].seqexp_rank_cutoff;


        var r = 7.5;
        var draw_graph =0;

        if(seq_evaluator == 'greater'){
            seq_evaluator = '>=';
        }
        if(seq_evaluator == 'less'){
            seq_evaluator = '<=';
        }

        var st_family_or_genes = '';
        if (params[0].searchGenes == null) {
            st_family_or_genes = ' ftj.family_id = ? ';
            boundParameters.push(ftree);
        }

        else {
            var placeholders = new Array<String>();
            var i = 0;
            var searchGenes : Array<Dynamic> = params[0].searchGenes;
            for (key in searchGenes) {
                placeholders.push('?');
            }

            st_family_or_genes = " ftj.target_id IN ("+placeholders.join(',')+") ";

            var genes : Array<Dynamic> = params[0].searchGenes;
            for (gene in genes) {
                boundParameters.push(gene);
            }

            //boundParameters.push(params[0].searchGenes);
            //boundParameters = params[0].searchGenes;
        }
        boundParameters.push(seqexp_fc_cutoff);
        boundParameters.push(seq_evaluator);

        if (typetree == "domain") {

            sql = "SELECT dh.target_id, dh.name_index, dh.variant_index, c.disease, c.count, c.total, c.rank FROM cancer.rnaseq_fc_freq c, probes_tree2.domain_highlighted dh, probes_tree2.family_target_join ftj
            		where c.gene = dh.target_id and
            		dh.target_id = ftj.target_id
                    and "+st_family_or_genes+"
					and dh.on_tree = 1
                    and c.fc_cutoff = ?
                    and c.evaluator = ?
					order by  dh.target_id, dh.name_index, dh.variant_index";

        } else { //gene_based

            sql = "SELECT distinct ftj.target_id, null name_index, v.variant_index, c.disease, c.count, c.total, c.rank FROM cancer.rnaseq_fc_freq c, probes_tree2.family_target_join ftj, probes_tree2.variant v
		            where c.gene = ftj.target_id
                    and "+st_family_or_genes+"
                    and c.fc_cutoff = ?
                    and c.evaluator = ?
					and v.is_default = 1
		            and v.target_id = ftj.target_id";

            /**
            var paramString = '';
            for (parameter in boundParameters) {
                paramString += parameter + ' + ';
            }
            cb(null, paramString);
            return; */
        }

        var finalresults: Array<String>;
        finalresults=new Array();
        provider.getConnection(null, function(err, connection){
                if(err != null){
                    cb(null, err);
                }else{
                    try {
                        connection.execute(sql, boundParameters, function(err, results){
                            Util.debug(sql);

                            if(err != null){
                                Util.debug('error');
                                cb(null, err);
                            }else{
                                var i=0;

                                for(i in 0...results.length){
                                    var tobeadded=true;
                                    var gene = results[i].target_id;
                                    var disease = results[i].disease;
                                    var count = results[i].count;
                                    var total = results[i].total;
                                    var rank_comment= results[i].rank;
                                    var rank_exp = rank_comment.split("/");
                                    var rank = rank_exp[0];

                                    var total_genes = rank_exp[1];
                                    var num=seqexp_rank_cutoff;
                                    var res=rank - num;
                                    if (seqexp_rank_cutoff!=null && (res>0)) {
                                        tobeadded=false;
                                    }
                                    else {
                                        results[i].freq = Math.round(100*(count / total));
                                        results[i].total_genes=total_genes;
                                        results[i].seqexp_freq_cutoff=seqexp_freq_cutoff;
                                        results[i].patient_seq_cutoff=patient_seq_cutoff;
                                        results[i].seqexp_rank_cutoff=seqexp_rank_cutoff;
                                        finalresults.push(results[i]);
                                        Util.debug("Gene added in results"+gene);
                                    }
                                }
                                cb(finalresults, null);
                            }

                            provider.closeConnection(connection);
                        });
                    }catch(e:Dynamic){
                        provider.closeConnection(connection);

                        cb(null, e);
                    }
                }
            });
    }

    public static function hookHasSomaticMutations(query : String, params : Array<Dynamic>, clazz : String, cb : Dynamic->String->Void){
        var provider = Util.getProvider();

        var sql : String = '';
        var boundParameters: Array<Dynamic>;
        boundParameters=new Array();

        var mutsig=params[0].sm_mutsig;
        var sm_mutated_dynamic=params[0].sm_mutated_dynamic;
        var sm_mutated_cutoff_box=params[0].sm_mutated_cutoff_box;
        var sm_mutated_cutoff=params[0].sm_mutated_cutoff;
        var patient_cutoff=params[0].sm_patient_cutoff;
        var sm_results_cutoff=params[0].sm_results_cutoff;
        var sm_nonsilent=params[0].sm_nonsilent;
        var sm_validated=params[0].sm_validated;

        var familyTree=params[0].familyTree;
        var treeType=params[0].treeType;

        var somatic_table='';
        if(familyTree == 'rna'){
            somatic_table = 'somatic_mutations_methsome';
        }else{
            somatic_table = 'somatic_mutations';
        }

        //sm_patient_cutoff
        var sm_patient_cutoff = ' and d.num_patients >= ?';

        var sm_validated_sql='';
        var sm_validated_opt='';
        var mutated_genes='';
        if (sm_validated==true) {
            sm_validated_sql = " and sm.validation_status = 'validated' ";
            sm_validated_opt = "&validated=1";
            mutated_genes = "validated_mutated_genes";
        } else {
            mutated_genes = "mutated_genes";
        }

        var sm_nonsilent_sql='';
        var sm_nonsilent_opt='';
        if (sm_nonsilent==true) {
            sm_nonsilent_sql = "and sm.variant_classification not in ('Silent', 'synonymous_coding', 'Silent_Mutation', 'intronic', 'downstream', 'upstream', 'Intron', 'UTR',
			'5_prime_UTR_variant',
			'3_prime_UTR_variant',
			'3prime_utr',
			'5-UTR',
			'5prime_utr',
			'3-UTR',
			'intronic',
			'intron_variant',
			'Intron',
			'intergenic_variant',
			'splice_site,intronic', 'non_coding_exon_variant', 'noncoding_rna')";
            sm_nonsilent_opt = "&nonsilent=1";
        }

        var sm_page='';
        var cutoff_sql='';
        var metadata_sql='';
        var dynamic_cutoff_chk:Dynamic;
        if (sm_mutated_dynamic==false) {
            if(sm_mutated_cutoff_box==true) {
                dynamic_cutoff_chk = 0;
                cutoff_sql = "and p."+mutated_genes+" <= "+sm_mutated_cutoff;
                metadata_sql = "and d.cutoff = "+sm_mutated_cutoff;
            }else{
                dynamic_cutoff_chk = 0;
                cutoff_sql = "";
                metadata_sql = "and d.cutoff is NULL";
                sm_mutated_cutoff = 'NULL';
            }
        }

        if(mutsig == 'true'){
            dynamic_cutoff_chk = 0;
            cutoff_sql = "";
            metadata_sql = "and d.cutoff is NULL";
            sm_mutated_cutoff = 'NULL';
        }

        boundParameters.push(patient_cutoff); //50

        var st_family_or_genes = '';
        if (params[0].searchGenes == null) {
            st_family_or_genes = 'ftj.family_id = ?';
            boundParameters.push(familyTree);
        }

        else {
            var searchGenes = params[0].searchGenes;
            st_family_or_genes = 'ftj.target_id = ?';
            boundParameters.push(searchGenes);
        }

        var allpar ='';
        for (paramString in boundParameters) {
            allpar += paramString + ' + ';
        }
        //cb(null, allpar);
        //return;

        var sm_control_sql='';
        var freq_cutoff:Dynamic;
        if(sm_mutated_dynamic == true){
            freq_cutoff = 1.5;
            if (treeType == "domain") {
                sql = "select t.id as target_id, nt.gene_name, nt.source, dh.variant_index, dh.name_index, nt.disease, nt.freq, nt.count, nt.total, nt.chromosome, nt.cancer_group
                            from
                            (SELECT sm.gene_name, g.geneid, sm.disease, 100*count(distinct sm.barcode)/d.num_patients freq, sm.source,
                            count(distinct sm.barcode) count, d.num_patients total, sm.chromosome, cd.cancer_group
                            FROM cancer."+somatic_table+" sm, cancer.somatic_mutations_patients p,
                            cancer.somatic_mutations_metadata_cutoff d, cancer.gene g, cancer.disease cd
                            WHERE  d.disease=sm.disease and d.cutoff not in (100,200,300,400,500) and sm.include = 1 and sm.barcode  = p.barcode  and p.disease=sm.disease
                            and g.gene_name = sm.gene_name "+sm_nonsilent_sql+" "+sm_control_sql+" and cd.name=sm.disease and sm.source = cd.source and
                            d.source = sm.source and p.source = sm.source "+
                sm_validated_sql+" and d.num_patients >= ? and p."+mutated_genes+" <= d.cutoff
                            group by sm.gene_name, sm.disease, sm.source
                            order by sm.gene_name) nt, target t, family_target_join ftj, domain_highlighted dh
                            where nt.geneid  = t.geneid and "+st_family_or_genes+"
                            and ftj.target_id=t.id and dh.target_id=t.id and dh.family_id=ftj.family_id and dh.on_tree=1 and nt.freq >= "+freq_cutoff+"
                            order by nt.freq desc";
            } else { //gene_based

                sql = "select t.id as target_id, nt.gene_name, nt.source, v.variant_index, null name_index, nt.disease, nt.freq, nt.count, nt.total, nt.chromosome, nt.cancer_group
                            from
                            (SELECT sm.gene_name, g.geneid, sm.disease, 100*count(distinct sm.barcode)/d.num_patients freq, sm.source,
                            count(distinct sm.barcode) count, d.num_patients total, sm.chromosome, cd.cancer_group
                            FROM cancer."+somatic_table+" sm, cancer.somatic_mutations_patients p,
                            cancer.somatic_mutations_metadata_cutoff d, cancer.gene g, cancer.disease cd
                            WHERE  d.disease=sm.disease and d.cutoff not in (100,200,300,400,500) and sm.include = 1 and sm.barcode = p.barcode and p.disease=sm.disease and cd.name=sm.disease
                            and g.gene_name = sm.gene_name and sm.source = cd.source and d.source = sm.source and p.source = sm.source "+sm_nonsilent_sql+" "+sm_control_sql+" "+
                sm_validated_sql+" and d.num_patients >= ? and p."+mutated_genes+" <= d.cutoff
                            group by sm.gene_name, sm.disease, sm.source
                            order by sm.gene_name) nt, target t, family_target_join ftj, variant v
                            where nt.geneid  = t.geneid and "+st_family_or_genes+"
                            and ftj.target_id=t.id and v.target_id=t.id and v.is_default=1 and nt.freq >= "+freq_cutoff+"
                            order by nt.freq desc";
            }
        }else{
            freq_cutoff = 1.5;
            if (treeType == "domain") {
                sql = "select DISTINCT t.id as target_id, nt.gene_name, nt.source, dh.variant_index, dh.name_index, nt.disease, nt.freq, nt.count, nt.total, nt.chromosome, nt.cancer_group
                            from
                            (SELECT sm.gene_name, g.geneid, sm.disease, 100*count(distinct sm.barcode)/d.num_patients freq, sm.source,
                            count(distinct sm.barcode) count, d.num_patients total, sm.chromosome, cd.cancer_group
                            FROM cancer."+somatic_table+" sm, cancer.somatic_mutations_patients p,
                            cancer.somatic_mutations_metadata_cutoff d, cancer.gene g, cancer.disease cd
                            WHERE  d.disease=sm.disease "+metadata_sql+" and sm.include = 1 and sm.barcode  = p.barcode  and p.disease=sm.disease
                            and g.gene_name = sm.gene_name "+sm_nonsilent_sql+" "+sm_control_sql+" and cd.name=sm.disease "+
                sm_validated_sql+" and d.num_patients >= ?  "+cutoff_sql+"
                            and sm.source = cd.source and d.source = sm.source and p.source = sm.source
                            group by sm.gene_name, sm.disease, sm.source
                            order by sm.gene_name) nt, target t, family_target_join ftj, domain_highlighted dh
                            where nt.geneid  = t.geneid and "+st_family_or_genes+"
                            and ftj.target_id=t.id and dh.target_id=t.id and dh.family_id=ftj.family_id and dh.on_tree=1 and nt.freq >= "+freq_cutoff+"
                            order by nt.freq desc";
            } else { //gene_based
                sql = "select DISTINCT t.id as target_id, nt.gene_name, nt.source, v.variant_index, null name_index, nt.disease, nt.freq, nt.count, nt.total, nt.chromosome, nt.cancer_group
                            from
                            (SELECT sm.gene_name, g.geneid, sm.disease, 100*count(distinct sm.barcode)/d.num_patients freq, sm.source,
                            count(distinct sm.barcode) count, d.num_patients total, sm.chromosome, cd.cancer_group
                            FROM cancer."+somatic_table+" sm, cancer.somatic_mutations_patients p,
                            cancer.somatic_mutations_metadata_cutoff d, cancer.gene g, cancer.disease cd
                            WHERE  d.disease=sm.disease "+metadata_sql+" and sm.include = 1 and sm.barcode = p.barcode and p.disease=sm.disease and cd.name=sm.disease
                            and g.gene_name = sm.gene_name "+sm_nonsilent_sql+" "+sm_control_sql+"
                            and sm.source = cd.source and d.source = sm.source and p.source = sm.source "+
                sm_validated_sql+" and d.num_patients >= ? "+cutoff_sql+"
                            group by sm.gene_name, sm.disease, sm.source
                            order by sm.gene_name) nt, target t, family_target_join ftj, variant v
                            where nt.geneid  = t.geneid and "+st_family_or_genes+"
                            and ftj.target_id=t.id and v.target_id=t.id and v.is_default=1 and nt.freq >= "+freq_cutoff+"
                            order by nt.freq desc";
                //cb(null, sql);
                //return;
            }

        }

        //Util.debug(sql);
        provider.getConnection(null, function(err, connection){
            if(err != null){
                cb(null, err);
            }else{
                try {
                    connection.execute(sql, boundParameters, function(err, results){
                        Util.debug('Named query returning');

                        if(err != null){
                            Util.debug('error');
                            cb(null, err);
                        }else{
                            cb(results, null);
                        }

                        provider.closeConnection(connection);
                    });
                }catch(e:Dynamic){
                    provider.closeConnection(connection);

                    cb(null, e);
                }
            }
        });
    }

    /**
    * generateFamilyOrListConstraint is a utility method for adding either gene names or the family ID as a bound parameter
    * and for returning an SQL fragment which can restrict results to either the supplied family or list of genes
    *
    * The SATurn ORM would have been better to use but we don't have time to retrofit so this is the best I can do to
    * simplify adding new annotations
    **/
    public static function generateFamilyOrListConstraint(params : Array<Dynamic>){
        var boundParameters = new Array<Dynamic>();

        // List of gene symbols
        var searchGenes :Array<String> = params[0].searchGenes;
        // Name of family
        var familyTree = params[0].familyTree;

        var sqlFamilyOrListConstraint = '';

        if(searchGenes != null){
            // We get here when a list of genes has been provided
            var placeHolders = new Array<String>();

            for(gene in searchGenes){
                placeHolders.push('?');
                boundParameters.push(gene);
            }

            sqlFamilyOrListConstraint = " ftj.target_id IN (" + placeHolders.join(',') + ") ";
        }else if(familyTree != null){
            // We get here when the tree name as been set
            sqlFamilyOrListConstraint = 'ftj.family_id = ?';

            boundParameters.push(familyTree);
        }else{
            throw new saturn.util.HaxeException('Please set familyTree or searchGenes');
        }

        return {'params':boundParameters, 'sql': sqlFamilyOrListConstraint};
    }

    /**
    * runBasicQuery is a utility method which will execute the given SQL statement with the supplied bound parameters and
    * notify the supplied callback of the result
    **/
    public static function runBasicQuery(sql : String, boundParameters : Array<Dynamic>, cb : Dynamic->String->Void){
        var provider = Util.getProvider();

        provider.getConnection(null, function(err, connection){
            if(err != null){
                cb(null, err);
            }else{
                try {
                    Util.debug(sql);
                    connection.execute(sql, boundParameters, function(err, results){
                        Util.debug('Named query returning');

                        if(err != null){
                            cb(null, err);
                        }else{
                            cb(results, null);
                        }

                        provider.closeConnection(connection);
                    });
                }catch(e:Dynamic){
                    provider.closeConnection(connection);

                    cb(null, e);
                }
            }
        });
    }

    public static function hookHasTumorLevel(query : String, params : Array<Dynamic>, clazz : String, cb : Dynamic->String->Void){
        var familyOrListInfo = null;

        try{
            familyOrListInfo = generateFamilyOrListConstraint(params);
        }catch(ex : saturn.util.HaxeException){
            cb(null, ex.getMessage()); return;
        }

        var sqlFamilyOrListConstraint = familyOrListInfo.sql;
        var boundParameters = familyOrListInfo.params;

        var sql : String = '';

        var treeType = params[0].treeType;
        var cancerType = params[0].cancer_type;
        var proteinLevels : Array<String> = params[0].protein_levels;

        if(treeType == 'domain'){
            sql = "
               SELECT
                    DISTINCT ftj.target_id, null target_name_index, variant_index
               FROM
                    protein_tumor p, family_target_join ftj, variant v
               WHERE
                    " + sqlFamilyOrListConstraint + " AND
                    ftj.target_id = v.target_id AND
                    ftj.target_id = p.target_id
               ";
        }else{
            sql = "
                SELECT
                    DISTINCT ftj.target_id, null target_name_index, variant_index
                FROM
                    protein_tumor p, family_target_join ftj, variant v
                WHERE
                    " + sqlFamilyOrListConstraint + " AND
                    ftj.target_id = v.target_id AND
                    v.is_default = 1 AND
                    ftj.target_id = p.target_id
            ";
        }

        // Constrain to the required cancer type
        if(cancerType != 'All'){
            sql += ' AND p.cancer_type = ?';

            boundParameters.push(cancerType);
        }

        // Constrain by protein level
        if(proteinLevels != null){
            // The below will look a little redundant, why not just use the value from the user if we know it matches an allowed value?
            // We don't do that because we shouldn't every concatenate a user supplied value to an SQL statement.
            // Think about the classic null-byte injection issues that languages have suffered from over the years
            var allowedProteinLevels = ['High'=>'High', 'Medium'=>'Medium', 'Low'=>'Low', 'Not detected'=> 'Not detected'];

            var levels = [];

            for(proteinLevel in proteinLevels){
                if(proteinLevel != null && allowedProteinLevels.exists(proteinLevel)){
                    levels.push('"'+allowedProteinLevels.get(proteinLevel)+'"');
                }
            }

            if(levels.length > 0){
                sql += ' AND (' + levels.join(' IS NOT NULL OR ') + ' IS NOT NULL)';
            }
        }

        runBasicQuery(sql, boundParameters, cb);
    }

    public static function hookHasCancerEssential(query : String, params : Array<Dynamic>, clazz : String, cb : Dynamic->String->Void){
        var familyOrListInfo = null;

        try{
            familyOrListInfo = generateFamilyOrListConstraint(params);
        }catch(ex : saturn.util.HaxeException){
            cb(null, ex.getMessage()); return;
        }

        var sqlFamilyOrListConstraint = familyOrListInfo.sql;
        var boundParameters = familyOrListInfo.params;
        var cancerTypes :Array<String> = params[0].cancer_types;
        var cancerScore = params[0].cancer_score;

        var sql : String = '';

        var treeType = params[0].treeType;
        if(treeType == 'domain'){
            sql = "
               SELECT
                    distinct ftj.target_id, null name_index, v.variant_index
               FROM
                    family_target_join ftj, variant v, essentiality_cancer c
               WHERE
                    " + sqlFamilyOrListConstraint + " AND
                    ftj.target_id = v.target_id
               ";
        }else{
            sql = "
                SELECT
                    distinct ftj.target_id, null name_index, v.variant_index
                FROM
                    family_target_join ftj, variant v, essentiality_cancer c
                WHERE
                    " + sqlFamilyOrListConstraint + " AND
                    ftj.target_id = v.target_id AND
                    v.is_default = 1
            ";
        }

        if(cancerTypes != null){
            var placeHolders = [];
            for(cancerType in cancerTypes){
                placeHolders.push('?');
                boundParameters.push(cancerType);
            }

            sql += ' AND c.primary_disease IN (' + placeHolders.join(',') + ')';
        }

        if(cancerScore != null){
            sql += ' AND c.median_score <= ?';

            boundParameters.push(cancerScore);
        }


        runBasicQuery(sql, boundParameters, cb);
    }
}
