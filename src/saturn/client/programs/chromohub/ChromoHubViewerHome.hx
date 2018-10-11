package saturn.client.programs.chromohub;

import phylo.PhyloAnnotation;
import phylo.PhyloAnnotation.HasAnnotationType;
import saturn.db.Provider;
import saturn.client.core.CommonCore;
import saturn.core.Util;
import bindings.Ext;

class ChromoHubViewerHome {
    public var viewer: ChromoHubViewer;
    public var uploadForm : Dynamic;
    public var annotations : Array<Dynamic>;

    public function new(viewer: ChromoHubViewer) {
        this.viewer = viewer;

    }

    public function addUploadForm(){
        var items :Array<Dynamic> = [];

        items.push({
            xtype: 'textarea',
            fieldLabel: 'FASTA upload',
            name: 'fasta_content',
        });

        items.push({
            xtype: 'button',
            text: 'Generate Tree',
            handler: function(){
                generateTreeFromFASTA(uploadForm.form.findField('fasta_content').lastValue);
            }
        });

        items.push({
            xtype: 'textarea',
            fieldLabel: 'Newick upload',
            name: 'newick_content',
        });

        items.push({
            xtype: 'button',
            text: 'Show Tree',
            handler: function(){
                viewer.setNewickStr(uploadForm.form.findField('newick_content').lastValue);
            }
        });

        items.push({
            xtype: 'textarea',
            fieldLabel: 'Annotations',
            name: 'annotation_content',
        });

        items.push({
            xtype: 'button',
            text: 'Upload',
            handler: function(){
                loadAnnotations(uploadForm.form.findField('annotation_content').lastValue);
            }
        });

        uploadForm = Ext.create('Ext.form.Panel',{
            items: items
        });

        viewer.centralTargetPanel.add(uploadForm);
    }

    public function generateTreeFromFASTA(fasta : String){
        BioinformaticsServicesClient.getClient().sendPhyloReportRequest(fasta, function(response : Dynamic, error : String){
            var phyloReport = response.json.phyloReport;

            var location : js.html.Location = js.Browser.window.location;

            var dstURL = location.protocol+'//'+location.hostname+':'+location.port+'/'+phyloReport;

            Ext.Ajax.request({
                url: dstURL,
                success: function(response, opts) {
                    var newickString = response.responseText;

                    viewer.setNewickStr(newickString);
                },
                failure: function(response, opts) {
                    //response.status
                }
            });
        });
    }

    public function handleAnnotation(alias : String, params, clazz, cb : Dynamic->String->Void){
        var annotationIndex = Std.parseInt(alias.charAt(alias.length-1));

        cb(annotations[annotationIndex], null);
    }

    public function loadAnnotations(annotationString : String){
        var lines = annotationString.split('\n');
        var header = lines[0];
        var cols = header.split(',');

        annotations = new Array<Dynamic>();

        viewer.annotationManager.jsonFile = {btnGroup:[{title:'Annotations', buttons:[]}]};

        for(i in 1...cols.length){
            annotations[i-1] = [];

            var hookName = 'STANDALONE_ANNOTATION_' + (i-1);

            var styleAnnotation = function (target: String, data: Dynamic, selected:Int, annotList:Array<PhyloAnnotation>, item:String, callBack : HasAnnotationType->Void){
                var colours = ['red', 'blue'];
                var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:colours[i-1],used:false},defImage:100};

                if(data == null || data.annotation == 'No'){
                    r.hasAnnot = false;
                }

                callBack(r);
            };

            viewer.annotationManager.jsonFile.btnGroup[0].buttons.push({
                label: cols[i],
                hookName: hookName,
                annotCode: i,
                isTitle: false,
                enabled:true,
                familyMethod: '',
                hasMethod: styleAnnotation,
                hasClass: '',
                color: [
                    {color:"#ed0e2d", used:"false"}
                ],
                shape: "cercle",
            });

            CommonCore.getDefaultProvider(function(error, provider : Provider){
                //TODO: Important!!!
                provider.resetCache();

                provider.addHook(handleAnnotation, hookName);
            });
        }

        for(i in 1...lines.length){
            var cols = lines[i].split(',');

            for(j in 1...cols.length){
                annotations[j-1].push({'target_id': cols[0], 'annotation': cols[j]});
            }
        }

        viewer.annotationManager.fillAnnotationwithJSonData();
        viewer.annotationManager.createViewOptions();


        /*{
            "btnGroup":[
            {
            "title": "Disease Annotations",
            "buttons":[
            {
            "label": "Disease Association",
            "isTitle":false,
            "helpText": "<b> Disease Associations</b>: Articles are linked to genes based on NCBI's Gene <-> Pubmed associations (human and mouse orthologs). Genes are linked to diseases based on the presence of keywords in the Abstract or MeSH Terms of Pubmed entries. Click to see the list of Abstract and MeSH terms.",
            "annotCode":1,
            "submenu": false,
            "popUpWindows":false,
            "hookName": "diseaseAssociation",
            "shape": "html",
            "color": [
            {"color":"#ededed", "used":"false"}
            ],
            "annotImg":["/static/annot/images/diseaseAssociation.png"],
            "legend":{
            "image": "/static/annot/images/diseaseAssociation-leg.png",
            "text":"Articles are linked to genes based on NCBI's Gene <-> Pubmed associations (human and mouse orthologs). Genes are linked to diseases based on the presence of keywords in the Abstract or MeSH Terms of Pubmed entries. Click to see the list of Abstract and MeSH terms.",
            "html":""
            },
            "splitresults":false,
            "hasClass":"saturn.client.programs.chromohub.annotations.DiseaseAnnotation",
            "familyMethod": "",
            "hasMethod":"hasDisease",
            "divMethod":"divDiseaseAssociation"
            },*/
    }
}
