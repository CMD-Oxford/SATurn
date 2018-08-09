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

class ChromoHubMath{

    static public function degreesToRadians (a:Float):Float{
        return a*(Math.PI/180);
    }

    static public function radiansToDegrees (b:Float):Float{
        return b*(180/Math.PI);
    }

    static public function getMaxOfArray (a:Array<Float>):Float{

        var i:Int;
        var n:Float;
        n=a[0];
        for (i in 1...a.length){
            if(n<a[i])  n=a[i];
        }
        return n;
    }
}
