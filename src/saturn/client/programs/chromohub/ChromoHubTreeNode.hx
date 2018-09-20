package saturn.client.programs.chromohub;
/**
 * Authors Dr David R. Damerell (david.damerell@sgc.ox.ac.uk) (University of Oxford)
 *         Sefa Garsot (sefa.garsot@sgc.ox.ac.uk) (University of Oxford)
 *         Paul Barrett (paul.barrett@sgc.ox.ac.uk) (University of Oxford)
 *         Xi Ting (Seacy) Zhen (University of Toronto) (original PHP version)
 *         
 * Group Leaders: 
 *         Dr Brian Marsden (brian.marsden@sgc.ox.ac.uk) (University of Oxford)
 *         Dr Matthieu Schapira (matthieu.schapira@utoronto.ca) (University of Toronto)
 *         
 */

import saturn.client.programs.chromohub.ChromoHubMath;
import saturn.client.programs.chromohub.ChromoHubTreeNode;
import saturn.core.Util;
class ChromoHubTreeNode {
    public var parent: ChromoHubTreeNode;
    public var nodeId:Int;
    public var name : String;
    public var targetFamily: String; //the name of the targetfamily (or tree)
    public var targetFamilyGene: Array<String>;
    public var leaf : Bool;
    public var branch : Float;
    public var angle:Float;
    public var x : Dynamic;
    public var y : Dynamic;
    public var wedge: Float;
    public var length:Int;
    public var l:Int;
    public var root: ChromoHubTreeNode;
    public var rad:Dynamic; //trigonometry
    public var quad:Int; //trigonometry
    public var annotations: Array<ChromoHubAnnotation>;
    public var activeAnnotation: Array<Bool>;
    public var targets: Array<String>;
    public var screen: Array<ChromoHubScreenData>;
    public var divactive:Int;
    public var space:Int=0;
    public var colour : String;

    public var children: Array<ChromoHubTreeNode>;
    public var dist : Int = 50; // constant que definim nosaltres
    public var ratio : Float = 0.00006;
    public var leaves : Int = 0;
    public var numchild : Int = 0;

    public var leafNameToNode : Map<String, ChromoHubTreeNode>;
    public var nodeIdToNode : Map<Int, ChromoHubTreeNode>;

    //Tree area
    public var rectangleTop:Int;
    public var rectangleRight:Int;
    public var rectangleBottom:Int;
    public var rectangleLeft:Int;
    public var results: Array<Int>;

    public var minBranch : Float = null;
    public var maxBranch : Float = null;
    public var xRandom : Float = null;
    public var yRandom : Float = null;
    public var lineWidth : Float = 1;
    public var lineMode : LineMode = LineMode.STRAIGHT;
    var angle_new : Float = 0;

    var maxNameLength = -1;

    public function new(?parent : ChromoHubTreeNode , ?name: String , ?leaf : Bool, ?branch: Int){
        this.parent=parent;
        this.children=[];
        this.name=name;
        this.leaf=leaf;

       // if(branch<0){
         //   branch=0;
        //}
        this.branch=branch;

        if(this.parent!=null){
            this.parent.addChild(this);
            this.root=this.parent.root;
        }else{//this is the rootNode
            this.targets=new Array();
            this.root=this;
            this.screen=new Array();

            this.divactive=99999;
            leafNameToNode = new Map<String, ChromoHubTreeNode>();
            nodeIdToNode = new Map<Int, ChromoHubTreeNode>();
        }

        this.angle=0;
        this.x=0;
        this.y=0;
        this.wedge=0;
        this.length = 0;

        this.targetFamilyGene=new Array();
        this.l = 0; //number of children the node has. used in postOrderTraversal function.
    }


// function that goes throw all the tree and store the children of each node
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

    public function preOrderTraversal2 (mode:Int){

        //this.root.branch = this.root.maxBranch;

        if(this.parent!=null){ //this is not a root node
            var parent = this.parent;

            //this.x=parent.x+Math.cos(this.angle+this.wedge/2)*((1-((this.branch -this.root.minBranch) / (this.root.maxBranch - this.root.minBranch))) * 40);
            //this.y=parent.y+Math.sin(this.angle+this.wedge/2)*((1-((this.branch -this.root.minBranch) / (this.root.maxBranch - this.root.minBranch))) * 40);

            this.x=parent.x+Math.cos(this.angle+this.wedge/2)*this.root.dist;
            this.y=parent.y+Math.sin(this.angle+this.wedge/2)*this.root.dist;

            if(mode==1){
                this.nodeId=this.root.numchild;
                this.root.nodeIdToNode.set(this.nodeId, this);
            }

        }
        else{
            //root
            if(mode==1) this.nodeId=0;
        }

        var n=this.angle;
        var i=0;
        while(i<this.children.length){


            if(mode==1){this.root.numchild= this.root.numchild+1;}
            this.children[i].wedge=((this.children[i].l/this.children[i].root.l)*2*Math.PI)+Math.PI/20; // we scale the angles to avoid label overlapping
            this.children[i].angle=n;

            n=n+this.children[i].wedge;
            this.children[i].preOrderTraversal2(mode);
            i++;
        }

    }

    public function preOrderTraversal(mode:Int){

        if(this.parent != null){
            var a = this.getDepth() * this.root.ratio;
            if(this.angle > this.parent.angle) {
                this.angle += ChromoHubMath.degreesToRadians(a);
            } else {
                this.angle -= ChromoHubMath.degreesToRadians(a);
            }

            this.angle_new = this.angle + this.wedge / 2;

            this.x = this.parent.x + Math.cos(this.angle_new) * this.root.dist; //$u->x + cos($treeNodeObj->angle + $treeNodeObj->wedge / 2) * $r;
            this.y = this.parent.y + Math.sin(this.angle_new) * this.root.dist; // $u->y + sin($treeNodeObj->angle + $treeNodeObj->wedge / 2) * $r;
        }

        var n = this.angle;

        for(child in this.children){
            child.wedge = 2 * Math.PI * child.getLeafCount() / child.root.getLeafCount();
            child.angle = n;
            child.angle_new = child.angle + child.wedge/2;

            n += child.wedge;
            child.preOrderTraversal(0);
        }
    }

    public function calculateScale(){
        Util.debug(''+this.branch + '/' + this.root.minBranch + '/' +  this.root.maxBranch);

        if(this.branch != null){
            if(this.root.maxBranch == null || this.branch > this.root.maxBranch){
                this.root.maxBranch = this.branch;
            }

            if(this.root.minBranch == null || this.branch < this.root.minBranch){
                this.root.minBranch = this.branch;
            }
        }


        for(i in 0...this.children.length){
            this.children[i].calculateScale();
        }
    }


    public function getChildren():Array<ChromoHubTreeNode>{
        return this.children;
    }

    public function getChildN(i:Int):ChromoHubTreeNode{
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

            return ChromoHubMath.getMaxOfArray(heightList);
        }
    }

    public function getMaximumLeafNameLength(renderer : ChromoHubRendererI = null) : Int{
        if(maxNameLength != -1){
            return maxNameLength;
        }

        var nodes = new Array<ChromoHubTreeNode>();
        nodes.push(this);

        maxNameLength = 0;

        var maxName = '';

        for(node in nodes){
            if(node.isLeaf()){
                var nodeNameLength = node.name.length;

                if(nodeNameLength > maxNameLength){
                    maxNameLength = nodeNameLength;
                    maxName = node.name;
                }
            }else{
                for(child in node.children){
                    nodes.push(child);
                }
            }
        }

        if(renderer != null){
            maxNameLength = renderer.mesureText(maxName);
        }

        return maxNameLength;

    }


}

enum LineMode {
    STRAIGHT;
    BEZIER;
}

