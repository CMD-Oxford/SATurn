/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.phylo5;

import saturn.core.Util;

typedef HasAnnotationType = {
    var hasAnnot: Bool;
    var text: String;
    var color: String;
    var defImage: Int;
}
class Phylo5Annotation {



    public var type: Int;
    public var summary: String;
    public var summary_img: Dynamic; //stored on in root's annotation, so we'll use the same img for all the leaves
    public var imgtest: String;
   // public var list: Array<Bool>;
    public var annotImg:Array<Dynamic>; // Icon appear in leaf stored on in root's annotation, so we'll use the same img for all the leaves
    public var defaultImg:Int; // Icon appear in leaf stored on in root's annotation, so we'll use the same img for all the leaves
    public var shape:String;
    public var color:Dynamic;
    public var mysqlAlias:String;
    public var text:String;
    public var options:Array<Dynamic>;
    public var optionSelected:Int;
    public var dbData:Dynamic;
    public var legend:String;
    public var hasClass:String;
    public var hasMethod: String;
    public var divMethod: String;
    public var familyMethod: String;
    public var hasAnnot: Bool=false;
    public var alfaAnnot: Array<Phylo5Annotation>;
    public var splitresults:Bool;

    public var myleaf: Phylo5TreeNode;


    public function new(){
    //    this.list=new Array();
        //color=new Array();
        this.text="";
        this.splitresults=false;
    }

    public function uploadImg(imgList:Array<Dynamic>){
        var i:Int;
        this.annotImg=new Array();
        for (i in 0 ... imgList.length){
            this.annotImg[i] = js.Browser.document.createElement("img"); // js.Browser.document.createElement("img");
            this.annotImg[i].src = imgList[i];
            this.annotImg[i].onload = function () {
                            //this.ctx.drawImage(this.summary_img, tx, ty);
            }
        }
    }

    public function  saveAnnotationData(annotation:Int, data: Dynamic){ //depending on the annotation, DATA will be different

        this.type=annotation;
        this.dbData=new Array();
        this.dbData=data;
        this.color=Util.clone(this.myleaf.root.annotations[annotation].color);


        var hook:Dynamic;
        var r : HasAnnotationType = {hasAnnot: true, text:'',color:'',defImage:100};
        var clazz,method:String;

        if((this.myleaf.root.annotations[annotation].hasClass!=null)&&(this.myleaf.root.annotations[annotation].hasMethod!=null)){
            clazz=this.myleaf.root.annotations[annotation].hasClass;
            method=this.myleaf.root.annotations[annotation].hasMethod;
            hook = Reflect.field(Type.resolveClass(clazz), method);
            hook(this.myleaf.name,this.dbData, this.myleaf.root, function(r:HasAnnotationType){
                this.defaultImg=r.defImage;
                if (this.color[0]!=null) this.color[0].color=r.color;
                this.text=r.text;
                this.hasAnnot=r.hasAnnot;
            }
            );
        }
        else {
// by default we expect we don't need any other task to do
            this.hasAnnot=true;
            this.color=this.myleaf.root.annotations[annotation].color;
        }
    }

    public function delAnnotation(annotation:Int){

    }


}

