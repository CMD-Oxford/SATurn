/**
 * Authors Dr David R. Damerell (david.damerell@sgc.ox.ac.uk) (University of Oxford)
 *         Paul Barrett (paul.barrett@sgc.ox.ac.uk) (University of Oxford)
 *         Xi Ting (Seacy) Zhen (University of Toronto) (original PHP version)
 *         
 * Group Leaders: 
 *         Dr Brian Marsden (brian.marsden@sgc.ox.ac.uk) (University of Oxford)
 *         Dr Matthieu Schapira (matthieu.schapira@utoronto.ca) (University of Toronto)
 *         
 */

function /*TreeNode*/ Phylo5TreeNode(parent, name, leaf, branch){
    if(parent===undefined){
        parent=null;
    }
    
    if(name===undefined){
        name=null;
    }
    
    if(leaf===undefined){
        leaf=false;
    }
    
    if(branch===undefined){
        branch=0;
    }
    
    this.parent=parent;
    this.children=[];
    this.name=name;
    this.leaf=leaf;
    
    if(branch<0){
        branch=0;
    }
    this.branch=branch;
    
    if(this.parent!==null){
        this.parent.addChild(this);
        this.root=this.parent.root;
    }else{
        
        this.root=this;
    }
    
    this.angle=0;
    this.x=0;
    this.y=0;
    this.wedge=0;
};

Phylo5TreeNode.prototype.addChild=function(child){
    this.children[this.children.length]=child;
};

Phylo5TreeNode.prototype.isLeaf=function(){
  return this.leaf;  
};

Phylo5TreeNode.prototype.getLeafCount=function(){
  if(this.isLeaf()===true){
      return 1;
  }else{
      var total=0;
      
      for(var i=0;i<this.children.length;i++){
          total+=this.children[i].getLeafCount();
      }
      
      return total;
  }
};

Phylo5TreeNode.prototype.getDepth=function(){
  if(this.parent===null){
      return 0;
  }else{
      return 1+this.parent.getDepth();
  }
};

/* Find the minimum distance from the current node to all descending leaf nodes */
Phylo5TreeNode.prototype.getHeight=function(){
  if(this.isLeaf()){
      return 0;
  }else{
      var heightList=[];
      for(var i=0;i<this.children.length;i++){
          heightList[i]=this.children[i].getHeight()+1;
      }
      
      return Math.max(heightList);
  }
};

Phylo5TreeNode.prototype.preOrderTraversal=function(r, ratio){
    if(this.parent!==null){
        var parent=this.parent;
        var a=this.getDepth()*ratio;
        
        if(this.angle>parent.angle){
            this.angle+=Phylo5Math.degreesToRadians(a);
        }else{
            this.angle-=Phylo5Math.degreesToRadians(a);
        }
        
        this.x=parent.x+Math.cos(this.angle+this.wedge/2)*r;
        this.y=parent.y+Math.sin(this.angle+this.wedge/2)*r;
    }
    
    var n=this.angle;
    for(var i=0;i<this.children.length;i++){
        var child=this.children[i];
        
        child.wedge=2*Math.PI*child.getLeafCount()/child.root.getLeafCount();
        
        child.angle=n;
        
        n+=child.wedge;
        child.preOrderTraversal(r, ratio);
    }
};