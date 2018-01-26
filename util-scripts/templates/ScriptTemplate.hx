package saturn.scripts;

import saturn.client.CommonCore;
import js.Node;

@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":async"))
class <NAME> extends BaseScript{
    @:async override function usage(){
        if(getArgCount() != 1){
            die('Usage\tParam 1\n');
        }else{
            var param = getArg(1);
        }
    }

    @:async override function run(){
        print('Starting');
    }
}
