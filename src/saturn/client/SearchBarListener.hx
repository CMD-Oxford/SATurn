/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client;

interface SearchBarListener {
	/**
	 * Called when a search term is clicked
	 * 
	 * You MUST call it.next() if you want other listeners to be informed of this event
	 * 
	 * @param	app
	 * @param	objSelected
	 * @param	it
	 */
	function objectSelected( app : WorkspaceApplication, objSelected : Dynamic,it : Dynamic ) : Void;
	
	/**
	 * Called when the text of the search bar has been changed.
	 * 
	 * You MUST call it.next() if you want other listeners to be informed of this event
	 * 
	 * @param	app
	 * @param	txt
	 * @param	it
	 */
	function textChanged( app : WorkspaceApplication, txt : String, it : Dynamic ) : Void;
}
