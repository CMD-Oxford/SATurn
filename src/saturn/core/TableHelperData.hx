/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.core;

import saturn.client.programs.TableHelper;
import saturn.client.programs.TableHelper.TableHelperModelData;

class TableHelperData implements TableHelperModelData{
	var data : Dynamic;
    var modelsToCopy : Array<Dynamic>;
    var models : Array<Dynamic>;
    var objs : Array<Dynamic>;
	
	public function new(?objs = null) {
		data = [];

        if(objs != null){
            setObjects(objs);
        }
	}

    public function getRawModels() : Array<Dynamic>{
        return null;
    }

    public function setRawModels(models : Array<Dynamic>) : Void{
        return null;
    }
	
	public function setData(obj : Dynamic) {
		this.data = obj;
	}

    public function setModelsToCopy(models : Array<Dynamic>) : Void{
        this.modelsToCopy = models;
    }

    public function getModelsToCopy() : Array<Dynamic>{
        return this.modelsToCopy;
    }

    public function setModels(models : Array<Dynamic>) : Void{
        this.models = models;
    }

    public function getModels() : Array<Dynamic>{
        return models;
    }
	
	public function getData(obj : Dynamic) {
		return this.data;
	}

    /*
     * setObjects method should be called when you have domain objects and not ExtJS models
     *
     * Typically these will be objects retreived via the ORM
     */
    public function setObjects(objs : Array<Dynamic>) : Void{
        this.objs = objs;
    }

    public function getObjects() : Array<Dynamic>{
        return this.objs;
    }
}