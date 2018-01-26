/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.phylo5;

class Phylo5NewickParser{

    public function new (){

    }

    public function parse(newickString:String):Phylo5TreeNode{
        var rootNode : Phylo5TreeNode;
        rootNode = new Phylo5TreeNode();

        var currentNode=rootNode;
        var a:String;



        var branch:Dynamic;
        var charArray=newickString.split('');
        var j=0;
        for(j in 0...charArray.length){
            var i=j;
            if(charArray[i]=='(' && charArray[i+1]=='('){
                // New child and the child is not a leaf
                var childNode=new Phylo5TreeNode(currentNode, '', false, 0);
                currentNode=childNode;
            }else if( (charArray[i]=='(' && charArray[i+1]!='(')
                    || (charArray[i] == ',' && charArray[i + 1] != '(')){

                // New child but the child is a leaf
                i++;

                var name='';
                while(charArray[i] != ':' && charArray[i] != ',' && charArray[i] != ')'){
                    name+=charArray[i];
                    i++;
                }

                if(charArray[i]==':'){
                    i++;

                    branch='';

                    while(charArray[i] != ',' && charArray[i] != ')' && charArray[i] != ';'){
                        branch+=charArray[i];
                        i++;
                    }

                    i--;

                    branch=Std.parseFloat(branch);
                }else{
                    branch=1;
                }

                var child=new Phylo5TreeNode(currentNode, name, true, branch);
            }else if(charArray[i]==',' && charArray[i+1]=='('){
                // more children that are not leaves
                var child=new Phylo5TreeNode(currentNode, '', false, 0);
                currentNode=child;
            }else if(charArray[i]==')'){
                // no more children
                if(charArray[i+1]==':'){
                    i+=2;
                    branch='';
                    while(charArray[i]!=',' && charArray[i]!=')' && charArray[i]!=';'){
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
