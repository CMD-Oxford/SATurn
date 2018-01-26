/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

import saturn.core.Util.*;

class Generator<T> {
    private var limit : Int;
    private var processed : Int;
    private var done : Bool;
    private var cb : Dynamic;
    private var endCb : String->Void;
    private var maxAtOnce : Int;

    private var items : Array<Dynamic>;

    public function new(limit : Int) {
        this.limit = limit;
        this.processed = 0;
        this.done = false;
        this.items = new Array<Dynamic>();
        this.maxAtOnce = 1;
    }

    public function push(item : Dynamic){
        this.items.push(item);
    }

    public function pop(item : Dynamic) : Dynamic{
        return this.items.pop();
    }

    public function die(err : String){
        debug(err);

        stop(err);
    }

    function stop(err : String){
        finished();

        endCb(err);
    }

    public function next(){
        if((done && items.length == 0) || (limit != -1 && processed == limit)){
                endCb(null);

                return;
        }else{
            if(items.length > 0){
                if(maxAtOnce != 1){
                    var list = new Array<Dynamic>();
                    var added = 0;
                    while(items.length > 0){
                        var item = items.pop();

                        //js.Node.console.log('ITEM: '+item);

                        list.push(item);

                        processed++;

                        added++;

                        if(added == maxAtOnce){
                            break;
                        }
                    }

                    cb(list, function(){
                        haxe.Timer.delay(next, 1);
                    }, this);
                }else{
                    var item = items.pop();

                    processed++;

                    cb(item, function(){
                        haxe.Timer.delay(next, 1);
                    }, this);
                }
            }else{
                debug('waiting');
                haxe.Timer.delay(next, 100);
            }
        }
    }

    public function count(){
        return processed;
    }

    public function setMaxAtOnce(maxAtOnce : Int){
        this.maxAtOnce = maxAtOnce;
    }

    public function setLimit(limit : Int){
        this.limit = limit;
    }

    public function onEnd(cb : String->Void){
        this.endCb = cb;
    }

    public function onNext(cb : Dynamic){
        this.cb = cb;
        next();
    }

    public function finished(){
        done = true;
    }
}
