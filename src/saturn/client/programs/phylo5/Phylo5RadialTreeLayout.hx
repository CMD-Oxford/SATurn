/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.phylo5;

class Phylo5RadialTreeLayout{

    public var cx: Float;
    public var cy: Float;

    public function new (width: Float, height: Float){

        this.cx=width/2;
        this.cy=height/2;

    }

    public function render (treeNode: Phylo5TreeNode, renderer: Phylo5CanvasRenderer, annotations:Dynamic){

        var i=0;
        var x=treeNode.x;
        var y=treeNode.y;


        while(i<treeNode.children.length){
            treeNode.children[i].space=0;
            if(treeNode.children[i].isLeaf()) {
                renderer.drawLine(x,y,treeNode.children[i].x,treeNode.children[i].y,"rgb(28,102,224)");
                var t:Int;
                if(treeNode.children[i].angle>(Math.PI/2) && treeNode.children[i].angle < (3*Math.PI/2)){
                    renderer.drawText(treeNode.children[i].name, treeNode.children[i].x,treeNode.children[i].y, -2, 3,treeNode.children[i].angle+Math.PI+Math.PI/20,"end",'#585b5f');
                    t= renderer.mesureText(treeNode.children[i].name)+10; // calculate the width of the text in pixels and we add padding

                }
                else{
                    // we add ' ' in front of the label, otherwise it's shown too close to the edge
                    renderer.drawText(' '+treeNode.children[i].name, treeNode.children[i].x,treeNode.children[i].y, -2, 3,treeNode.children[i].angle+Math.PI/20,"start",'#585b5f');
                    t= renderer.mesureText(treeNode.children[i].name)+10; // calculate the width of the text in pixels and we add padding
                }

                var j:Int;
                for( j in 1...annotations.length ) {

                    if(annotations[j]==true){
                        var added:Bool;
                        added=addAnnotation(treeNode.children[i],j, t, renderer);

//here we must check if the annotations has AlfaAnnotations
                        if((treeNode.children[i].annotations[j]!=null)&&(treeNode.children[i].annotations[j].alfaAnnot!=null)&&(treeNode.children[i].annotations[j].alfaAnnot.length>0)){
                            var u=0;
                            treeNode.children[i].space=treeNode.children[i].space+1;
                            for (u in 0...treeNode.children[i].annotations[j].alfaAnnot.length){
                                added=addAlfaAnnotation(treeNode.children[i],treeNode.children[i].annotations[j].alfaAnnot[u],j, t, renderer);
                                if(added==true)treeNode.children[i].space=treeNode.children[i].space+1;
                            }
                        }else  if(added==true)treeNode.children[i].space=treeNode.children[i].space+1;
                    }
                }
            }
            else{
                this.render(treeNode.children[i],renderer, annotations); //the edge here is already drawn
                renderer.drawLine(x,y,treeNode.children[i].x,treeNode.children[i].y,"rgb(28,102,224)");
            }
            i++;
        }
    }

    public function addAnnotation(leave:Phylo5TreeNode, annotation:Int,  long: Int, renderer: Phylo5CanvasRenderer):Bool{

        var res:Bool=false;
        var data:Phylo5ScreenData;
        data=new Phylo5ScreenData();

        data.target=leave.name;
        data.annot=annotation;

        data.annotation=leave.annotations[annotation];

//we need to check if the leave has this annotation
        var rootN=leave.root;
        switch rootN.annotations[annotation].shape {
            case "cercle":
                if(leave.activeAnnotation[annotation]==true){
                    if(leave.annotations[annotation].hasAnnot==true){
                        if(leave.space==0) long=long+1;
                        else long=long+(27*leave.space);

                        var nx=leave.x+Math.cos(leave.angle+Math.PI/20)*long;
                        var ny=leave.y+Math.sin(leave.angle+Math.PI/20)*long;
                        renderer.drawCircle(nx,ny,leave.annotations[annotation].color[0].color);

                        var aux=nx*renderer.scale;
                        data.x=Math.round(aux);
                        aux=ny*renderer.scale;
                        data.y=Math.round(aux);
                        aux=7*renderer.scale;
                        data.width=Math.round(aux);
                        data.height=Math.round(aux);
                        data.point=1;
                        res=true;
                    }
                    else return false;
                }
            case "image": //Summary
                    //here we will do whatever we need to show this annotation
                    //first, add image next to label
                if(leave.activeAnnotation[annotation]==true){
                    if(leave.annotations[annotation].hasAnnot==true){
                        if(leave.space==0) long=long+7;
                        else long=long+(27*leave.space);
                        var aux_x:Float=leave.x;
                        var aux_y:Float=leave.y;

                        if(leave.root.annotations[annotation].annotImg[leave.annotations[annotation].defaultImg]!=null){
                            aux_x=leave.x-(leave.root.annotations[annotation].annotImg[leave.annotations[annotation].defaultImg].width/2);
                            aux_y=leave.y-leave.root.annotations[annotation].annotImg[leave.annotations[annotation].defaultImg].height/2;

                            var nx=aux_x+Math.cos(leave.angle+Math.PI/20)*long;
                            var ny=aux_y+Math.sin(leave.angle+Math.PI/20)*long;
                            var imge=leave.root.annotations[annotation].annotImg[leave.annotations[annotation].defaultImg];
                            if (imge!=null) {
                                renderer.drawImg(nx,ny,imge);
                                var aux=nx*renderer.scale;
                                data.x=Math.round(aux);
                                aux=ny*renderer.scale;
                                data.y=Math.round(aux);

                                aux=22*renderer.scale;
                                data.width=Math.round(aux);
                                aux=21*renderer.scale;
                                data.height=Math.round(aux);
                                data.point=1;
                            }

                        }
                        res=true;
                    }
                    else return false;

                }
            case "square":
                if(leave.activeAnnotation[annotation]==true){
                    if(leave.annotations[annotation].hasAnnot==true){
                        if(leave.space==0) long=long+1;
                        else long=long+(27*leave.space);
                        var aux_x:Float=leave.x;
                        var aux_y:Float=leave.y;

                        aux_x=leave.x-7;
                        aux_y=leave.y-7;

                        var nx=aux_x+Math.cos(leave.angle+Math.PI/20)*long;
                        var ny=aux_y+Math.sin(leave.angle+Math.PI/20)*long;
                        renderer.drawSquare(nx,ny,leave.annotations[annotation].color[0].color);

                        data.point=1;
                        var aux=nx*renderer.scale;
                        data.x=Math.round(aux);
                        aux=ny*renderer.scale;
                        data.y=Math.round(aux);
                        aux=20*renderer.scale;
                        data.width=Math.round(aux);
                        aux=20*renderer.scale;
                        data.height=Math.round(aux);
                        res=true;
                    }
                    else return false;
                }
            case "text":
                if(leave.activeAnnotation[annotation]==true){
                    if(leave.annotations[annotation].hasAnnot==true){
                        if(leave.space==0) long=long+5;
                        else long=long+(25*leave.space);
                        var aux_x:Float=leave.x;
                        var aux_y:Float=leave.y;

                        aux_x=leave.x-7;
                        aux_y=leave.y-7;
                        data.point=2;

                        var nx=aux_x+Math.cos(leave.angle+Math.PI/20)*long;
                        var ny=aux_y+Math.sin(leave.angle+Math.PI/20)*long;
                        renderer.drawText(leave.annotations[annotation].text,nx,ny, -2, 3,0,"start",leave.annotations[annotation].color[0].color);

                        var aux=nx*renderer.scale;
                        data.x=Math.round(aux)-12;
                        aux=ny*renderer.scale;
                        data.y=Math.round(aux);
                        aux=leave.annotations[annotation].text.length*renderer.scale; //width is the lenght of the text
                        data.width=7*Math.round(aux);
                        aux=10*renderer.scale;
                        data.height=Math.round(aux);
                        res=true;

                    }
                    else return false;
                }

        }

        leave.root.screen[leave.root.screen.length]=data;
        return res;
    }

    public function addAlfaAnnotation(leave:Phylo5TreeNode, alfaAnnot:Phylo5Annotation, annotation:Int,  long: Int, renderer: Phylo5CanvasRenderer):Bool{

        var res:Bool=false;
        var data:Phylo5ScreenData;
        data=new Phylo5ScreenData();

        data.target=leave.name;
        data.annot=annotation;

        data.annotation=alfaAnnot;

//we need to check if the leave has this annotation
        var rootN=leave.root;
        switch rootN.annotations[annotation].shape {
            case "cercle":
                if(leave.activeAnnotation[annotation]==true){
                    if(alfaAnnot.hasAnnot==true){
                        if(leave.space==0) long=long+1;
                        else long=long+(27*leave.space);

                        var nx=leave.x+Math.cos(leave.angle+Math.PI/20)*long;
                        var ny=leave.y+Math.sin(leave.angle+Math.PI/20)*long;
                        renderer.drawCircle(nx,ny,alfaAnnot.color[0].color);

                        var aux=nx*renderer.scale;
                        data.x=Math.round(aux);
                        aux=ny*renderer.scale;
                        data.y=Math.round(aux);
                        aux=7*renderer.scale;
                        data.width=Math.round(aux);
                        data.height=Math.round(aux);
                        data.point=1;
                        res=true;
                    }
                    else return false;
                }
            case "image": //Summary
//here we will do whatever we need to show this annotation
//first, add image next to label
                if(leave.activeAnnotation[annotation]==true){
                    if(alfaAnnot.hasAnnot==true){
                        if(leave.space==0) long=long+7;
                        else long=long+(27*leave.space);
                        var aux_x:Float=leave.x;
                        var aux_y:Float=leave.y;

                        if(leave.root.annotations[annotation].annotImg[alfaAnnot.defaultImg]!=null){
                            aux_x=leave.x-(leave.root.annotations[annotation].annotImg[alfaAnnot.defaultImg].width/2);
                            aux_y=leave.y-leave.root.annotations[annotation].annotImg[alfaAnnot.defaultImg].height/2;

                            var nx=aux_x+Math.cos(leave.angle+Math.PI/20)*long;
                            var ny=aux_y+Math.sin(leave.angle+Math.PI/20)*long;
                            var imge=leave.root.annotations[annotation].annotImg[alfaAnnot.defaultImg];
                            if (imge!=null) {
                                renderer.drawImg(nx,ny,imge);
                                var aux=nx*renderer.scale;
                                data.x=Math.round(aux);
                                aux=ny*renderer.scale;
                                data.y=Math.round(aux);

                                aux=22*renderer.scale;
                                data.width=Math.round(aux);
                                aux=21*renderer.scale;
                                data.height=Math.round(aux);
                                data.point=1;
                            }

                        }
                        res=true;
                    }
                    else return false;

                }
            case "square":
                if(leave.activeAnnotation[annotation]==true){
                    if(alfaAnnot.hasAnnot==true){
                        if(leave.space==0) long=long+1;
                        else long=long+(27*leave.space);
                        var aux_x:Float=leave.x;
                        var aux_y:Float=leave.y;

                        aux_x=leave.x-7;
                        aux_y=leave.y-7;

                        var nx=aux_x+Math.cos(leave.angle+Math.PI/20)*long;
                        var ny=aux_y+Math.sin(leave.angle+Math.PI/20)*long;
                        renderer.drawSquare(nx,ny,alfaAnnot.color[0].color);

                        data.point=1;
                        var aux=nx*renderer.scale;
                        data.x=Math.round(aux);
                        aux=ny*renderer.scale;
                        data.y=Math.round(aux);
                        aux=20*renderer.scale;
                        data.width=Math.round(aux);
                        aux=20*renderer.scale;
                        data.height=Math.round(aux);
                        res=true;
                    }
                    else return false;
                }
            case "text":
                if(leave.activeAnnotation[annotation]==true){
                    if(alfaAnnot.hasAnnot==true){
                        if(leave.space==0) long=long+5;
                        else long=long+(25*leave.space);
                        var aux_x:Float=leave.x;
                        var aux_y:Float=leave.y;

                        aux_x=leave.x-7;
                        aux_y=leave.y-7;
                        data.point=2;

                        var nx=aux_x+Math.cos(leave.angle+Math.PI/20)*long;
                        var ny=aux_y+Math.sin(leave.angle+Math.PI/20)*long;
                        renderer.drawText(alfaAnnot.text,nx,ny, -2, 3,0,"start",alfaAnnot.color[0].color);

                        var aux=nx*renderer.scale;
                        data.x=Math.round(aux)-12;
                        aux=ny*renderer.scale;
                        data.y=Math.round(aux);
                        aux=alfaAnnot.text.length*renderer.scale; //width is the lenght of the text
                        data.width=7*Math.round(aux);
                        aux=10*renderer.scale;
                        data.height=Math.round(aux);
                        res=true;

                    }
                    else return false;
                }

        }

        leave.root.screen[leave.root.screen.length]=data;
        return res;
    }

    public function addScreenPos(annotation:Int,nx:Float,ny:Float, root:Phylo5TreeNode){
        var x0:Int;
        var y0:Int;
        x0=Math.round(nx);
        y0=Math.round(ny);
        switch annotation{
            case 1: //circle
            case 2: //image 22x20
               // root.screen[x0]=y0;
        }

    }
}
