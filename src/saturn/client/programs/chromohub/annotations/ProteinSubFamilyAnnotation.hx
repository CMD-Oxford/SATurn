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
}
