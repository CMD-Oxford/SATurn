package saturn.client.programs.chromohub;
/**
 * Authors Dr David R. Damerell (david.damerell@sgc.ox.ac.uk) (University of Oxford)
 *         Sefa Garsot (sefa.garsot@sgc.ox.ac.uk) (Universtiy of Oxford)
 *         Paul Barrett (paul.barrett@sgc.ox.ac.uk) (University of Oxford)
 *         Xi Ting (Seacy) Zhen (University of Toronto) (original PHP version)
 *         
 * Group Leaders: 
 *         Dr Brian Marsden (brian.marsden@sgc.ox.ac.uk) (University of Oxford)
 *         Dr Matthieu Schapira (matthieu.schapira@utoronto.ca) (University of Toronto)
 * 
 * ChromoHubRendererI should be implemented for each of the surfaces that you wish
 * to draw phylogenetic trees to using any of the "ChromoHub" layout engines.
 * 
 * For example ChromoHubCanvasRenderer can be passed to ChromoHubRadialTreeLayout to
 * render directly to an HTML5 canvas.
 * 
 * @returns {undefined}
 */
interface ChromoHubRendererI {
    
    /**
     * Method draws a line based on the line style stored in the "colour" argument
     * and the pen operations stored in the argument "path".  Path is a 2D array
     * where "path[i][0]" represents the "i'th" "X" coordinate and "path[i][1]"
     * represents the "i'th" "Y" coordinate.
     *
     * The very first set of coordinates located at path[0] represent the starting
     * position of the line (i.e in canvas speak that's context.moveTo(path[0][0], path[0][1])).
     *
     * The remaining coordinate pairs "path[1..N]" represent where to draw too next
     * (i.e. in canvas speak that's context.lineTo(path[1][0], path[1][1])
     *
     * @param {type} path List of x/y coordinates.
     * @param {type} colour Line style
     *               Currently in the format rgb(x,x,x)
     * @returns {undefined}
     */
    public function drawLine (x0:Float,y0:Float, x1:Float, y1:Float,colour:Dynamic, lineWidth : Float):Void;

    /**
     * Method draws text at position x/y after translation and rotation operations
     * have been performed.  The text align attribute specifies "start" if x/y
     * specifies the start of the text string and "end" if x/y represents the
     * location of the end of the text string.
     *
     * Note that "rotation" is specified in radians - ChromoHubMath has methods to
     * convert between radians and degrees.
     *
     * @param {type} text Text to be displayed
     * @param {type} tx X translation
     * @param {type} ty Y translation
     * @param {type} x Cursor X position after translation
     * @param {type} y Cursor Y position after translation
     * @param {type} rotation Text rotation in radians
     * @param {type} textAlign Text alignment against x/y coordinates.
     *         Possible values are "start" when the text should start at x/y and
     *         "end" when the text should finish at x/y.
     */
    public function drawText (text : String, tx : Float, ty : Float, x : Float, y : Float, rotation : Float, textAlign : String, color:String):Void;

    public function startGroup (groupName : String):Void;

    public function endGroup ():Void;

}