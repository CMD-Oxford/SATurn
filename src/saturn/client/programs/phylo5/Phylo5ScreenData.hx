/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.phylo5;

class Phylo5ScreenData {

    public var point: Int; //it will tell us whether the annotation icon position is based on 1 = middle point, 2 = left top point, 3=...
    public var x: Int; //x and y positions
    public var y: Int;
    public var width: Int;
    public var height: Int;
    public var annotation: Phylo5Annotation;
    public var created:Bool; //whether the DIV is already created
    public var target:String;
    public var annot:Int;
    public var root: Phylo5TreeNode;
    public var div:Dynamic;
    public var divAccessed:Bool;
    public var suboption: Int=0;


    public function new(){
        this.annotation=new Phylo5Annotation();
        this.created=false;
        this.divAccessed=false;
    }

    public function checkMouse(mx:Int,my:Int){
        switch(this.point){

            case 3: // square, image
                if(((x<mx)&&(mx<(x+width/2)))&&((my<y)&&(my>y-height/2)))return true;
                else return false;
            case 1: if((mx>x-width)&&(mx<x)&&(my<(y+height))&&(my>y)) {
                /*WorkspaceApplication.getApplication().debug('x is '+x);
                WorkspaceApplication.getApplication().debug('mx is '+mx);
                WorkspaceApplication.getApplication().debug('width is '+width);*/
                return true;
            }
                    else return false;
            case 2://text
                if((mx>x)&&(mx<(x+width))&&(my>y-(height/2))&&(my<(y+(height/2)))){

              /*  WorkspaceApplication.getApplication().debug('x is '+x);
                WorkspaceApplication.getApplication().debug('mx is '+mx);
                WorkspaceApplication.getApplication().debug('width is '+width);
                    WorkspaceApplication.getApplication().debug('y is '+y);
                    WorkspaceApplication.getApplication().debug('my is '+my);
                    WorkspaceApplication.getApplication().debug('height is '+height);*/
                return true;
            }else{

                    return false;}
            default:return false;
        }
    }

}

