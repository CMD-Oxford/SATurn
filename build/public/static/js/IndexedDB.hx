/**
 * ...
 * @author David R. Damerell
 */
@:native('indexedDB')
extern class IndexedDB {
	public static function open(name : String, version : Int) : Dynamic;
}