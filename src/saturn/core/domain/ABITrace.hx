/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core.domain;

import haxe.Json;
import saturn.util.StringUtils;
class ABITrace {
    public var id : Int;
    public var name : String;

    public var CH1 : Array<Float>;
    public var CH2 : Array<Float>;
    public var CH3 : Array<Float>;
    public var CH4 : Array<Float>;
    public var LABELS : Array<String>;
    public  var SEQ : Array<String>;

    public var ALN_LABELS : Array<String>;

    public var ANNOTATIONS : Array<String>;

    public var alignment : saturn.core.Alignment;

    public var traceDataJson : String;

    public function new(){
        setup();
    }

    public function setup(){
        CH1 = new Array<Float>();
        CH2 = new Array<Float>();
        CH3 = new Array<Float>();
        CH4 = new Array<Float>();
        LABELS = new Array<String>();
        SEQ = new Array<String>();
        ALN_LABELS = new Array<String>();
        ANNOTATIONS = new Array<String>();
        alignment = null;

        if(traceDataJson != null){
            setData(Json.parse(traceDataJson));
        }
    }

    public function isEmpty() : Bool{
        return CH1.length == 0 && CH2.length == 0 && CH3.length == 0 && CH4.length == 0 ;
    }

    public function setData(traceData : Dynamic){
        CH1 = traceData.CH1;
        CH2 = traceData.CH2;
        CH3 = traceData.CH3;
        CH4 = traceData.CH4;
        LABELS = traceData.LABELS;
        SEQ = traceData.SEQ;

        traceDataJson = Json.stringify(traceData);
    }

    public function getSequence() : String {
        var strBuf = new StringBuf();
        for(char in SEQ){
            strBuf.add(char);
        }

        return strBuf.toString();
    }


    /**
    * trim returns the trace trimmed between start and stop
    **/
    public function trim(start : Int, stop : Int){
        var trimmedTraceData = new ABITrace();
        trimmedTraceData.CH1 = new Array<Float>();
        trimmedTraceData.CH2 = new Array<Float>();
        trimmedTraceData.CH3 = new Array<Float>();
        trimmedTraceData.CH4 = new Array<Float>();
        trimmedTraceData.LABELS = new Array<String>();
        trimmedTraceData.SEQ = new Array<String>();

        for(i in start...stop){
            trimmedTraceData.CH1.push(CH1[i]);
            trimmedTraceData.CH2.push(CH2[i]);
            trimmedTraceData.CH3.push(CH3[i]);
            trimmedTraceData.CH4.push(CH4[i]);

            trimmedTraceData.LABELS.push(LABELS[i]);

            if(trimmedTraceData.LABELS[i] != ''){
                trimmedTraceData.SEQ.push(trimmedTraceData.LABELS[i]);
            }
        }

        if(ALN_LABELS.length > 0){
            for(i in start...stop){
                trimmedTraceData.ALN_LABELS.push(ALN_LABELS[i]);
            }
        }

        return trimmedTraceData;
    }

    public function align(aln : Dynamic, isForwards){
        var alnStrs = aln.getAlignmentRegion();

        //var template = alnStrs[0];

        //var template = isForwards ? alnStrs[0]: StringUtils.reverse(alnStrs[0]);
        //var query = isForwards ? alnStrs[1]: StringUtils.reverse(alnStrs[1]);


        var template = alnStrs[0];
        var query = alnStrs[1];

        var newTrace = new ABITrace();
        var seqPos = 0;
        for(i in 0...getReadingCount()){
            if(CH1[i] == -1){
                //already aligned against another sequence, so ignore gap readings and spacer readings
                continue;
            }

            var c = LABELS[i];

            if(c != ''){
                while(true){
                    var alnChar = template.charAt(seqPos);

                    if(alnChar == '-'){
                        for(j in 0...2){
                            newTrace.CH1.push(-1);
                            newTrace.CH2.push(-1);
                            newTrace.CH3.push(-1);
                            newTrace.CH4.push(-1);
                            newTrace.LABELS.push('');
                            newTrace.ALN_LABELS.push('');
                        }

                        newTrace.CH1.push(-1);
                        newTrace.CH2.push(-1);
                        newTrace.CH3.push(-1);
                        newTrace.CH4.push(-1);
                        newTrace.LABELS.push('-');
                        newTrace.ALN_LABELS.push(query.charAt(seqPos));

                        for(j in 0...2){
                            newTrace.CH1.push(-1);
                            newTrace.CH2.push(-1);
                            newTrace.CH3.push(-1);
                            newTrace.CH4.push(-1);
                            newTrace.LABELS.push('');
                            newTrace.ALN_LABELS.push('');
                        }
                        seqPos++;
                    }else{
                        newTrace.ALN_LABELS.push(query.charAt(seqPos++));
                        break;
                    }
                }
            }else{
                newTrace.ALN_LABELS.push('');
            }

            newTrace.CH1.push(CH1[i]);
            newTrace.CH2.push(CH2[i]);
            newTrace.CH3.push(CH3[i]);
            newTrace.CH4.push(CH4[i]);
            newTrace.LABELS.push(LABELS[i]);
            newTrace.SEQ.push(SEQ[i]);
        }

        newTrace.alignment = aln;

        return newTrace;
    }

    public function getReadingCount(){
        return CH1.length;
    }

    public function setName(name : String){
        this.name = name;
    }
}
