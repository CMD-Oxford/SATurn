/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.phylo5;

class Phylo5TreeNode {

    public var parent: Phylo5TreeNode;
    public var name : String;
    public var targetFamily: String; //the name of the targetfamily (or tree)
    public var leaf : Bool;
    public var branch : Float;
    public var angle:Float;
    public var x : Float;
    public var y : Float;
    public var wedge: Float;
    public var length:Int;
    public var l:Int;
    public var root: Phylo5TreeNode;
    public var annotations: Array<Phylo5Annotation>;
    public var activeAnnotation: Array<Bool>;
    public var targets: Array<String>;
    public var screen: Array<Phylo5ScreenData>;
    public var divactive:Int;
    public var space:Int=0;

    public var auxMap: Map<String, Dynamic>;

    public var children: Array<Phylo5TreeNode>;
    public var dist : Int = 40; // constant que definim nosaltres
    var ratio : Float = 0.6;
    public var leaves : Int = 0;

    public var leafNameToNode : Map<String, Phylo5TreeNode>;


    public function new(?parent : Phylo5TreeNode , ?name: String , ?leaf : Bool, ?branch: Int){
        this.parent=parent;
        this.children=[];
        this.name=name;
        this.leaf=leaf;

        if(branch<0){
            branch=0;
        }
        this.branch=branch;

        if(this.parent!=null){
            this.parent.addChild(this);
            this.root=this.parent.root;
        }else{//this is the rootNode
            this.targets=new Array();
            this.root=this;
            this.screen=new Array();

            this.divactive=99999;
            leafNameToNode = new Map<String, Phylo5TreeNode>();
            auxMap = new Map<String, Dynamic>();
        }

        this.angle=0;
        this.x=0;
        this.y=0;
        this.wedge=0;
        this.length = 0;
        this.l = 0; //number of children the node has. used in postOrderTraversal function.
    }


// funcio que recorre l'arbre i guarda el nombre de fill de cada node
// we also use this function in order to count the leaves.
// depending on the number of the leaves, we are going to change the length of the edges, which by default is 40
    public function postOrderTraversal(){
        if (this.isLeaf() ==true) {
            this.l =1;
            this.root.targets[this.root.leaves]=this.name;
            this.root.leaves = this.root.leaves + 1;
            this.annotations= new Array();
            this.activeAnnotation= new Array();

            this.root.leafNameToNode.set(this.name, this);

//if we keep the annotation selected with a previous tree,
// here it should be when we check the annotation that are active and add them into our node structure
// this.annotation.checkAnnotations();
        }
        else{
            var i=0;
            while(i<this.children.length){
                this.children[i].postOrderTraversal();
                this.l = this.l + this.children[i].l;
                i++;
            }
        }
    }

    public function preOrderTraversal (){
        if(this.parent!=null){ //this is not a root node
            var parent = this.parent;

            this.x=parent.x+Math.cos(this.angle+this.wedge/2)*this.root.dist;
            this.y=parent.y+Math.sin(this.angle+this.wedge/2)*this.root.dist;
        }

        var n=this.angle;
        var i=0;
        while(i<this.children.length){

            this.children[i].wedge=((this.children[i].l/this.children[i].root.l)*2*Math.PI)+Math.PI/20; // we scale the angles to avoid label overlapping
            this.children[i].angle=n;

            n=n+this.children[i].wedge;
            this.children[i].preOrderTraversal();
            i++;
        }

    }


    public function getChildren():Array<Phylo5TreeNode>{
        return this.children;
    }

    public function getChildN(i:Int):Phylo5TreeNode{
        return this.children[i];
    }

    public function addChild (child){
        this.children[this.children.length]=child;
    }

    public function isLeaf(){
        return this.leaf;
    }

    public function getLeafCount ():Int{
        if(this.isLeaf()==true){
            return 1;
        }else{
            var total=0;
            var i:Int;
            i=0;
            for(i in 0...this.children.length){
                total+=this.children[i].getLeafCount();
            }

            return total;
        }
    }

    public function getDepth ():Int{
        if(this.parent == null){
            return 0;
        }else{
            return 1+this.parent.getDepth();
        }
    }

/* Find the minimum distance from the current node to all descending leaf nodes */
    public function getHeight ():Float{
        if(this.isLeaf()){
            return 0;
        }else{
            var heightList : Array<Float>= new Array();

            var i:Int;
            i=0;
            for(i in 0...this.children.length){
                heightList[i]=this.children[i].getHeight()+1;
            }

            return Phylo5Math.getMaxOfArray(heightList);
        }
    }


}

