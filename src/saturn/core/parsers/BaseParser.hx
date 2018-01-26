/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.parsers;

import saturn.core.Generator;
import saturn.core.domain.Entity;
import saturn.core.domain.MoleculeAnnotation;

import saturn.core.Util.*;

using saturn.core.Util;

class BaseParser<T> extends Generator<T> {
    var doneCB : String->Void;

    var path : String;
    var content : String;

    var lineCount = 0;

    public function new(path : String, handler : Array<T>->Generator<T>->Void, done : String->Void) {
        super(-1);

        this.doneCB = done;
        this.path = path;

        setMaxAtOnce(200);

        onEnd(done);

        onNext(function(objs :Array<T>, next : Void->Void, c : Generator<T>){
            handler(objs, this);
        });

        if(path != null){
            read();
        }
    }

    public function setContent(content : String){
        this.content = content;

        read();
    }

    function read(){
        if(path != null){
            open(path, function(err : Dynamic, line : String){
                if(err != null){
                    die('Error reading file');
                }else{
                    lineCount++;

                    if(line == null){
                        debug('Lines read: ' + lineCount);

                        finished();
                    }else{
                        var obj = parseLine(line);

                        if(obj != null){
                            push(obj);
                        }
                    }
                }
            });
        }else if(content != null){
            var lines = content.split('\n');
            for(line in lines){
                var obj = parseLine(line);

                if(obj != null){
                    push(obj);
                }
            }

            finished();
        }

    }

    function parseLine(line : String) : Dynamic{
        return null;
    }
}
