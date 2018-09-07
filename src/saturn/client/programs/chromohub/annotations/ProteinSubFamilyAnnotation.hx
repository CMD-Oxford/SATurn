package saturn.client.programs.chromohub.annotations;

import saturn.client.programs.chromohub.ChromoHubAnnotation.HasAnnotationType;

class ProteinSubFamilyAnnotation {
    public function new() {

    }

    static function hasSubFamily(target: String, data: Dynamic, selected:Int,annotList:Array<ChromoHubAnnotation>, item:String, cb : HasAnnotationType->Void){
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:{color:'red',used:true},defImage:0};

        if(data.family_id == 'E3_Ligase'){
            r.color.color = switch data.subfamily{
                case "BIR": AnnotationColourConstants.dGrey;
                case "DELTEX":AnnotationColourConstants.yellow;
                case "HECT":AnnotationColourConstants.darkGreen;
                case "makorin" :AnnotationColourConstants.pink;
                case "MARCH":AnnotationColourConstants.green;
                case "MDM":AnnotationColourConstants.orange;
                case "MEX":AnnotationColourConstants.blue;
                case "Misc":AnnotationColourConstants.purple3;
                case "RBR":AnnotationColourConstants.olive;
                case "TRAF":AnnotationColourConstants.red;
                case "TRIM" :AnnotationColourConstants.hotPink;
                case "UBOX" :AnnotationColourConstants.babyBlue;
                case "UBR" :AnnotationColourConstants.dBrown;
                default: "red";
            }
        }else if(data.family_id == 'E3_Complex'){
            r.color.color = switch data.subfamily {
                case "APC-coactivator":AnnotationColourConstants.darkGreen;
                case "BTB":AnnotationColourConstants.green;
                case "DCAF":AnnotationColourConstants.orange;
                case "FBXL":AnnotationColourConstants.blue;
                case "FBXO":AnnotationColourConstants.purple3;
                case "FBXW":AnnotationColourConstants.olive;
                case "SOCS":AnnotationColourConstants.red;
                case "VHL" :AnnotationColourConstants.yellow;
                default: "red";
            }
        }else if(data.family_id == 'NON_USP'){
            r.color.color = switch data.subfamily {
                case "Autophagin":AnnotationColourConstants.darkGreen;
                case "JAMM":AnnotationColourConstants.green;
                case "MINDY":AnnotationColourConstants.orange;
                case "MJD":AnnotationColourConstants.blue;
                case "OTU":AnnotationColourConstants.purple3;
                case "PPPDE":AnnotationColourConstants.olive;
                case "SENP":AnnotationColourConstants.red;
                case "UCH" :AnnotationColourConstants.yellow;
                case "UfmSP":AnnotationColourConstants.hotPink;
                case 'ZUFSP':AnnotationColourConstants.dBrown;
                default: "red";
            }
        }

        cb(r);
    }

    static function divSubFamily(screenData: ChromoHubScreenData,x:String,y:String,tree_type:String, callBack : Dynamic->Void){
        if(screenData.divAccessed==false){
            screenData.divAccessed=true;

            if(screenData.targetClean.indexOf('/')!=-1){
                var auxArray=screenData.targetClean.split('');
                var j:Int;
                var nom='';
                for(j in 0...auxArray.length){
                    if(auxArray[j]!='/') nom+=auxArray[j];
                }
                screenData.targetClean=nom;
            }
            if(screenData.target.indexOf('/')!=-1){
                var auxArray=screenData.target.split('');
                var j:Int;
                var nom='';
                for(j in 0...auxArray.length){
                    if(auxArray[j]!='/') nom+=auxArray[j];
                }
                screenData.target=nom;
            }

            var name:String;
            if (screenData.target.indexOf('(')!=-1) name=screenData.targetClean;
            else if (screenData.target.indexOf('-')!=-1) name=screenData.targetClean;
            else name=screenData.target;
            trace('Family:');

            var genePlusFamily = screenData.target + '_' + screenData.family  +  '.png';
            var path = '/pfam_images/' + genePlusFamily;
            var imgSrc = '<img src="' + path + '" />';


             var t = '<style type="text/css">
                .divMainDiv7  { }
                .divTitle{padding:5px; widht:100%!important; background-color:#dddee1; color:#6d6d6e!important; font-size:16px; margin-bottom:5px;}
                .divContent{padding:5px;widht:100%!important;}
                .divMainDiv7  a{ text-decoration:none!important;}
                .divExtraInfo{padding:5px; widht:100%!important; font-size:10px; margin-top:5px;}

                .structureResult{padding:3px 10px ;}
                </style>
                <div class="divMainDiv7 ">
                <div class="divTitle">Domain Architecture  - '+screenData.target+'</div>
                <div class="divContent">'
                + imgSrc +
                '/div>
            ';
            callBack(t);
        }
    }
}
