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

function /*class*/ Phylo5NewickParser(){
    
};

Phylo5NewickParser.prototype.parse=function(newickString){
    var rootNode=new Phylo5TreeNode();
    
    var currentNode=rootNode;
    
    var charArray=newickString.split(new RegExp(""));
    
    for(var i=0;i<charArray.length;i++){
        if(charArray[i]==='(' && charArray[i+1]==='('){
            // New child and the child is not a leaf
            var childNode=new Phylo5TreeNode(currentNode, '', false, 0);
            currentNode=childNode;
        }else if( (charArray[i]==='(' && charArray[i+1]!=='(') 
                || (charArray[i] === ',' && charArray[i + 1] !== '(')){
            
            // New child but the child is a leaf
            i++;
            
            var name='';
            while(charArray[i] !== ':' && charArray[i] !== ',' && charArray[i] !== ')'){
                name+=charArray[i];
                i++;
            }
            
            var branch;
            if(charArray[i]===':'){
                i++;
                
                branch='';
                
                while(charArray[i] !== ',' && charArray[i] !== ')' && charArray[i] !== ';'){
                    branch+=charArray[i];
                    i++;
                }
                
                i--;
                branch=parseFloat(branch);
            }else{
                branch=1;
            }
            
            var child=new Phylo5TreeNode(currentNode, name, true, branch);
        }else if(charArray[i]===',' && charArray[i+1]==='('){
            // more children that are not leaves
            var child=new Phylo5TreeNode(currentNode, '', false, 0);
            currentNode=child;
        }else if(charArray[i]===')'){
            // no more children
            if(charArray[i+1]===':'){
                i+=2;
                branch='';
                while(charArray[i]!==',' && charArray[i]!==')' && charArray[i]!==';'){
                   branch+=charArray[i];
                   i++;
                }
                
                i--;
                currentNode.branch=parseFloat(branch);
            } 
            
            currentNode=currentNode.parent;
            
            if(currentNode===null){
                return rootNode;   
            }
        }
    }
};
