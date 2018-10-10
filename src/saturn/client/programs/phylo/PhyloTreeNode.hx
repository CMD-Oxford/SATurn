package saturn.client.programs.phylo;
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

import saturn.client.programs.phylo.PhyloCanvasRenderer.PhyloDrawingMode;
import saturn.client.programs.phylo.PhyloHubMath;
import saturn.client.programs.phylo.PhyloTreeNode;
import saturn.core.Util;
class PhyloTreeNode {
    public var parent: PhyloTreeNode;
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
    public var root: PhyloTreeNode;
    public var rad:Dynamic; //trigonometry
    public var quad:Int; //trigonometry
    public var annotations: Array<PhyloAnnotation>;
    public var activeAnnotation: Array<Bool>;
    public var targets: Array<String>;
    public var screen: Array<PhyloScreenData>;
    public var divactive:Int;
    public var space:Int=0;
    public var colour : String;

    public var children: Array<PhyloTreeNode>;
    public var dist : Int = 50; // constant que definim nosaltres
    public var ratio : Float = 0.00006;
    public var leaves : Int = 0;
    public var numchild : Int = 0;

    public var leafNameToNode : Map<String, PhyloTreeNode>;
    public var nodeIdToNode : Map<Int, PhyloTreeNode>;

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

    public var wedgeColour : String = null;
    public var newickString : String;
    public var fasta : String;

    public function new(?parent : PhyloTreeNode, ?name: String, ?leaf : Bool, ?branch: Int){
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
            leafNameToNode = new Map<String, PhyloTreeNode>();
            nodeIdToNode = new Map<Int, PhyloTreeNode>();
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


            this.children[i].wedge=((this.children[i].l/this.children[i].root.l)*2*Math.PI)+Math.PI/50;

            this.children[i].angle=n;

            n=n+this.children[i].wedge;
            this.children[i].preOrderTraversal2(mode);
            i++;
        }
    }

    public function areAllChildrenLeaf() : Bool {
        for(child in children){
            if(!child.isLeaf()){
                return false;
            }
        }

        return true;
    }

    public function preOrderTraversal(mode:Int){

        if(this.parent != null){
            if(mode==1){
                this.nodeId=this.root.numchild;
                this.root.nodeIdToNode.set(this.nodeId, this);
            }

            var a = this.getDepth() * this.root.ratio;
            if(this.angle > this.parent.angle) {
                this.angle += PhyloHubMath.degreesToRadians(a);
            } else {
                this.angle -= PhyloHubMath.degreesToRadians(a);
            }

            this.angle_new = this.angle + this.wedge / 2;

            this.x = this.parent.x + Math.cos(this.angle_new) * this.root.dist; //$u->x + cos($treeNodeObj->angle + $treeNodeObj->wedge / 2) * $r;
            this.y = this.parent.y + Math.sin(this.angle_new) * this.root.dist; // $u->y + sin($treeNodeObj->angle + $treeNodeObj->wedge / 2) * $r;
        }else{
            if(mode==1) this.nodeId=0;
        }

        var n = this.angle;

        for(child in this.children){
            if(mode==1){this.root.numchild= this.root.numchild+1;}
            child.wedge = 2 * Math.PI * child.getLeafCount() / child.root.getLeafCount();
            child.angle = n;
            child.angle_new = child.angle + child.wedge/2;

            n += child.wedge;
            child.preOrderTraversal(mode);
        }
    }

    public function calculateScale(){
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


    public function getChildren():Array<PhyloTreeNode>{
        return this.children;
    }

    public function getChildN(i:Int):PhyloTreeNode{
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

            return PhyloHubMath.getMaxOfArray(heightList);
        }
    }

    public function getMaximumLeafNameLength(renderer : PhyloRendererI = null) : Int{
        if(maxNameLength != -1){
            return maxNameLength;
        }

        var nodes = new Array<PhyloTreeNode>();
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

    public function findFirstLeaf(){
        for(child in children){
            if(child.isLeaf()){
                return child;
            }else{
                return child.findFirstLeaf();
            }
        }

        return null;
    }

    public function findLastLeaf(){
        var lastChild = null;
        for(child in children){
            if(child.isLeaf()){
                lastChild = child;
            }else{
                lastChild = child.findLastLeaf();
            }
        }

        return lastChild;
    }

    public function setLineWidth(width : Float){
        lineWidth = width;

        for(child in children){
            child.setLineWidth(width);
        }
    }

    public function setLineMode(mode : LineMode){
        lineMode = mode;

        for(child in children){
            child.setLineMode(mode);
        }
    }

    public function rotateNode(clockwise : Bool, drawingMode : PhyloDrawingMode){
        var delta = -0.3;

        if(clockwise){
            delta = 0.3;
        }

        this.x = ((this.x-this.parent.x)*Math.cos(delta))-((this.y-this.parent.y)*Math.sin(delta))+this.parent.x;
        this.y=((this.x-this.parent.x)*Math.sin(delta))+((this.y-this.parent.y)*Math.cos(delta))+this.parent.y;

        this.angle = this.angle + delta;

        var n = this.angle;

        for(child in children){

            child.wedge=((child.l/root.l)*2*Math.PI)+Math.PI/20; // we scale the angles to avoid label overlapping
            child.angle=n;

            n=n+child.wedge;

            if(drawingMode == PhyloDrawingMode.STRAIGHT){
                child.preOrderTraversal2(0);
            }else if(drawingMode == PhyloDrawingMode.CIRCULAR){
                child.preOrderTraversal(0);
            }
        }

        /*if(clock==true)alpha=0.3;
        else alpha=-0.3;
        node=this.rootNode.nodeIdToNode.get(d.nodeId);
        node.x=((d.x-d.parentx)*Math.cos(alpha))-((d.y-d.parenty)*Math.sin(alpha))+d.parentx;
        node.y=((d.x-d.parentx)*Math.sin(alpha))+((d.y-d.parenty)*Math.cos(alpha))+d.parenty;
        node.angle=node.angle+alpha;
        n=node.angle;*/

        /*var node:PhyloTreeNode;
        var alpha:Float;
        var n:Dynamic;
        if(undo==true){
            var auxpop=undolist.pop();
            d=auxpop.data;
            node=this.rootNode.nodeIdToNode.get(d.nodeId);
            node.x=auxpop.x;
            node.y=auxpop.y;
            node.angle=auxpop.angle;
            n=node.angle;
        }
        else{
            if(clock==true)alpha=0.3;
            else alpha=-0.3;
            node=this.rootNode.nodeIdToNode.get(d.nodeId);
            node.x=((d.x-d.parentx)*Math.cos(alpha))-((d.y-d.parenty)*Math.sin(alpha))+d.parentx;
            node.y=((d.x-d.parentx)*Math.sin(alpha))+((d.y-d.parenty)*Math.cos(alpha))+d.parenty;
            node.angle=node.angle+alpha;
            n=node.angle;
        }

        var i=0;
        while(i<node.children.length){

            node.children[i].wedge=((node.children[i].l/node.children[i].root.l)*2*Math.PI)+Math.PI/20; // we scale the angles to avoid label overlapping
            node.children[i].angle=n;

            n=n+node.children[i].wedge;

            if(drawingMode == ChromoHubDrawingMode.STRAIGHT){
                node.children[i].preOrderTraversal2(0);
            }else if(drawingMode == ChromoHubDrawingMode.CIRCULAR){
                node.children[i].preOrderTraversal(0);
            }

            i++;
        }*/
    }

    public function clearAnnotations(){
        annotations = new Array<PhyloAnnotation>();

        if(activeAnnotation != null){
            for(i in 0...activeAnnotation.length){
                activeAnnotation[i] = false;
            }
        }

        for(child in children){
            child.clearAnnotations();
        }
    }

    public function getNewickString() : String{
        return newickString;
    }

    public function setFasta(fasta : String){
        this.fasta = fasta;
    }

    public function getFasta() : String{
        return this.fasta;
    }

}

enum LineMode {
    STRAIGHT;
    BEZIER;
}

