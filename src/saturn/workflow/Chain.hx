/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.workflow;

import saturn.db.Provider;

import saturn.core.Util.*;

class Chain {
    var items : Array<ChainUnit>;

    var pos : Int;
    var provider : Provider;

    var done : String->Void;

    public function new() {
        items = new Array<ChainUnit>();
        pos = 0;


        this.provider = getProvider();
    }

    public function add(item : Dynamic, config : saturn.workflow.Object){
        items.push(new ChainUnit(item, config));
    }

    public function next(){
        if(pos <= items.length -1){
            var unit : ChainUnit = items[pos++];

            var handler = function(resp : saturn.workflow.Object){
                debug('Workflow returning');
                var error : String = resp.getError();
                if(error != null){
                    die(error); return;
                }else{
                    unit.getConfig().setResponse(resp);

                    next();
                }
            }

            var config = unit.getConfig();

            if(pos > 1){
                config.setData(items[pos-2].getConfig().getResponse());
            }

            if(unit.isDirectMethod()){
                unit.getDirectMethod()(config, handler);
            }else{
                debug('Workflow running unit: ' + unit.getQName());
                provider.getByNamedQuery(
                    'saturn.workflow',
                    [unit.getQName(), config],
                    unit.getResponseClass(),
                    true,
                    function(objs : Array<Dynamic>, error : Dynamic){
                        if(error != null){
                            die(error);
                        }else{
                            handler(objs[0]);
                        }
                    }
                );
            }
        }else{
            done(null);
        }
    }

    public function start(cb : String->Void){
        done = cb;

        next();
    }

    public function die(error : Dynamic){
        done(error);
    }
}

class ChainUnit {
    var qualifiedName : String;
    var packageName : String;

    var qualifiedClassName : String;
    var methodName : String;

    var responseClassName : String;

    var config : saturn.workflow.Object;

    var method : Dynamic;

    public function new(item : Dynamic, config : saturn.workflow.Object){
        this.config = config;
        this.method = null;

        if(Std.is(item, String)){
            var qName :String = item;
            var lastI = qName.lastIndexOf('.');

            qualifiedClassName = qName.substring(0, lastI);
            methodName = qName.substring(lastI+1, qName.length);

            packageName = qualifiedClassName.substring(0, qualifiedClassName.lastIndexOf('.'));

            var classShortName = qualifiedClassName.substring(qualifiedClassName.lastIndexOf('.')+1, qualifiedClassName.length);

            qualifiedName = qName;

            responseClassName =  packageName + '.' + classShortName + 'Response';
        }else{
            method = item;
        }
    }

    public function isDirectMethod() : Bool{
        return method != null;
    }

    public function getDirectMethod() : Dynamic{
        return method;
    }

    public function setConfig(config : saturn.workflow.Object){
        this.config = config;
    }

    public function getQName() : String {
        return qualifiedName;
    }

    public function getMethodName() : String {
        return methodName;
    }

    public function getClassName() : String {
        return qualifiedClassName;
    }

    public function getResponseClass() : Class<Dynamic>{
        return Type.resolveClass(responseClassName);
    }

    public function getConfig() : saturn.workflow.Object {
        return config;
    }
}
