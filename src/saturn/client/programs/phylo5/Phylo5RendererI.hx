/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs.phylo5;

interface Phylo5RendererI {
    
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
    public function drawLine (x0:Float,y0:Float, x1:Float, y1:Float,colour:Dynamic):Void;

    /**
     * Method draws text at position x/y after translation and rotation operations
     * have been performed.  The text align attribute specifies "start" if x/y
     * specifies the start of the text string and "end" if x/y represents the
     * location of the end of the text string.
     *
     * Note that "rotation" is specified in radians - Phylo5Math has methods to
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
