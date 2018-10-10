package saturn.client.programs.phylo;
class PhyloUtil {
    public function new() {

    }


    /*
        saturn.client.programs.phylo.PhyloUtil.drawRadialFromNewick('((UFSP1:0.00,UFSP2:0.00):0.77,((((SENP1:0.00,SENP2:0.00):0.70,(SENP3:0.00,SENP5:0.00):0.73):0.82,SENP8:0.00):0.99,(SENP6:0.00,SENP7:0.00):0.77):1.00,((((((((((FAM105B:0.00,(OTUD6A:0.00,OTUD6B:0.00):0.46):0.92,(OTUB1:0.00,OTUB2:0.00):0.55):0.99,OTUD1:0.00):0.99,YOD1:0.00):0.99,(OTUD3:0.00,OTUD5:0.00):0.86):0.99,OTUD4:0.00):0.99,ZRANB1:0.00):0.99,TNFAIP3:0.00):0.99,(OTUD7A:0.00,OTUD7B:0.00):0.48):0.99,VCPIP1:0.00):1.00,(((KHNYN:0.00,NYNRIN:0.00):0.65,N4BP1:0.00):0.86,((ZC3H12A:0.00,(ZC3H12B:0.00,ZC3H12C:0.00):0.53):0.64,ZC3H12D:0.00):0.65):0.94,(BAP1:0.00,((UCHL1:0.00,UCHL3:0.00):0.46,UCHL5:0.00):0.82):0.99,(DESI1:0.00,DESI2:0.00):0.82,(((((((BRCC3:0.00,(COPS5:0.00,PSMD14:0.00):0.74):0.93,(COPS6:0.00,(EIF3F:0.00,PSMD7:0.00):0.79):0.81):0.95,EIF3H:0.00):0.99,MPND:0.00):0.99,(STAMBP:0.00,STAMBPL1:0.00):0.43):0.99,MYSM1:0.00):0.99,PRPF8:0.00):0.99,((ATXN3:0.00,ATXN3L:0.00):0.30,(JOSD1:0.00,JOSD2:0.00):0.51):0.99,((ATG4A:0.00,ATG4B:0.00):0.53,(ATG4C:0.00,ATG4D:0.00):0.63):0.80);', document.body)

        OR

        var config =  new saturn.client.programs.phylo.PhyloCanvasConfiguration();
        config.enableShadow = true;
        config.enableZoom = true;
        config.enableTools = true;
        config.enableToolbar = true;

        saturn.client.programs.phylo.PhyloUtil.drawRadialFromNewick('((UFSP1:0.00,UFSP2:0.00):0.77,((((SENP1:0.00,SENP2:0.00):0.70,(SENP3:0.00,SENP5:0.00):0.73):0.82,SENP8:0.00):0.99,(SENP6:0.00,SENP7:0.00):0.77):1.00,((((((((((FAM105B:0.00,(OTUD6A:0.00,OTUD6B:0.00):0.46):0.92,(OTUB1:0.00,OTUB2:0.00):0.55):0.99,OTUD1:0.00):0.99,YOD1:0.00):0.99,(OTUD3:0.00,OTUD5:0.00):0.86):0.99,OTUD4:0.00):0.99,ZRANB1:0.00):0.99,TNFAIP3:0.00):0.99,(OTUD7A:0.00,OTUD7B:0.00):0.48):0.99,VCPIP1:0.00):1.00,(((KHNYN:0.00,NYNRIN:0.00):0.65,N4BP1:0.00):0.86,((ZC3H12A:0.00,(ZC3H12B:0.00,ZC3H12C:0.00):0.53):0.64,ZC3H12D:0.00):0.65):0.94,(BAP1:0.00,((UCHL1:0.00,UCHL3:0.00):0.46,UCHL5:0.00):0.82):0.99,(DESI1:0.00,DESI2:0.00):0.82,(((((((BRCC3:0.00,(COPS5:0.00,PSMD14:0.00):0.74):0.93,(COPS6:0.00,(EIF3F:0.00,PSMD7:0.00):0.79):0.81):0.95,EIF3H:0.00):0.99,MPND:0.00):0.99,(STAMBP:0.00,STAMBPL1:0.00):0.43):0.99,MYSM1:0.00):0.99,PRPF8:0.00):0.99,((ATXN3:0.00,ATXN3L:0.00):0.30,(JOSD1:0.00,JOSD2:0.00):0.51):0.99,((ATG4A:0.00,ATG4B:0.00):0.53,(ATG4C:0.00,ATG4D:0.00):0.63):0.80);', document.body, config)
     */
    public static function drawRadialFromNewick(newickStr, parent, config = null,  annotationManager : PhyloAnnotationManager = null){
        var parser = new saturn.client.programs.phylo.PhyloNewickParser();

        var rootNode = parser.parse(newickStr);

        return drawRadialFromTree(rootNode, parent, config, annotationManager);
    }

    public static function drawRadialFromTree(rootNode : PhyloTreeNode, parent, config = null, annotationManager : PhyloAnnotationManager = null){
        rootNode.calculateScale();

        rootNode.postOrderTraversal();

        rootNode.preOrderTraversal(1);
        var parentWidth = parent.clientWidth;
        var parentHeight = parent.clientHeight;

        if(config == null){
            config = new saturn.client.programs.phylo.PhyloCanvasRenderer.PhyloCanvasConfiguration();
        }

        var canvas = new saturn.client.programs.phylo.PhyloCanvasRenderer(parentWidth, parentHeight, parent, rootNode, config, annotationManager);

        return canvas;
    }

    public static function showMessage(message : String, title : String){
        var dialog = new PhyloInfoWidget(js.Browser.document.body, message, title);
    }
}
