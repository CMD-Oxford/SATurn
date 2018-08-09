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


class ChromoHubNewickParser{

    public function new (){

    }

    public function parse(newickString:String):ChromoHubTreeNode{
        var rootNode : ChromoHubTreeNode;
        rootNode = new ChromoHubTreeNode();

        var currentNode=rootNode;
        var a:String;



        var branch:Dynamic;
        var charArray=newickString.split('');
        var j=0;
        for(j in 0...charArray.length){
            var i=j;
            if(charArray[i]=='(' && charArray[i+1]=='('){
                // New child and the child is not a leaf
                var childNode=new ChromoHubTreeNode(currentNode, '', false, 0);
                currentNode=childNode;
            }else if( (charArray[i]=='(' && charArray[i+1]!='(' && charArray[i-1]!='/')
                    || (charArray[i] == ',' && charArray[i + 1] != '(')){

                // New child but the child is a leaf
                i++;

                var name='';
                while(charArray[i] != ':' && charArray[i] != ',' && (charArray[i] != ')' || (charArray[i] == ')' && charArray[i-1] == '/'))){
                    //we need to check if = /
                    var p=charArray[i];
                    if((charArray[i] == '/')&&((charArray[i+1] == '[')||(charArray[i+1] == '('))) i++; //we just need to skip it and not check the next character.
                    if(charArray[i]=='[') name+='(';
                    else if (charArray[i]==']')  name+=')';
                    else name+=charArray[i];
                    i++;
                }

                if(charArray[i]==':'){
                    i++;

                    branch='';

                    while(charArray[i] != ',' && (charArray[i] != ')' || (charArray[i] == ')' && charArray[i-1] == '/')) && charArray[i] != ';'){
                        branch+=charArray[i];
                        i++;
                    }

                    i--;

                    branch=Std.parseFloat(branch);
                }else{
                    branch=1;
                }

                var child=new ChromoHubTreeNode(currentNode, name, true, branch);
            }else if(charArray[i]==',' && charArray[i+1]=='('){
                // more children that are not leaves
                var child=new ChromoHubTreeNode(currentNode, '', false, 0);
                currentNode=child;
            }else if(charArray[i]==')' && charArray[i-1]!='/'){
                // no more children
                if(charArray[i+1]==':'){
                    i+=2;
                    branch='';
                    while(charArray[i]!=',' && (charArray[i]!=')' || (charArray[i]==')'&& charArray[i-1]!='/'))&& charArray[i]!=';'){
                       branch+=charArray[i];
                       i++;
                    }

                    i--;
                    currentNode.branch=Std.parseFloat(branch);
                }
                currentNode=currentNode.parent;
            }
        }
        if(currentNode==null){
            return rootNode;
        }
        else return currentNode;
    }
}