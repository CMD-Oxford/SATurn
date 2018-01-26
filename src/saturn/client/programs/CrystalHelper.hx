/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.client.programs.SimpleExtJSProgram;
import saturn.client.WorkspaceApplication;

import bindings.Ext;

import saturn.client.workspace.CrystalHelperDataWO;

class CrystalHelper extends SimpleExtJSProgram {
	static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ CrystalHelperDataWO ];
	
    var theComponent : Dynamic;
	var theTable : Dynamic;
    var internalFrameId : String = 'INTERNAL_FRAME';
	
	var pageUrl : String = '';

    public function new(){
        super();

        emptyInit();
    }

    override public function emptyInit() {
		super.emptyInit();
		
        var self : CrystalHelper  = this;
		
		Ext.create('Ext.data.Store', {
			storeId:'crystalStore',
			fields:['ROWNUMBER', 'XTAL_MOUNT_ID', 'SCREENNUMBER','TRASH','QUALITY','POSITION','NAME', 'PINID']
		});
		
		theComponent = Ext.create('Ext.panel.Panel', {
            title: 'Crystal Helper',
            width:'100%',
            height: '95%',
            autoScroll : true,
            layout : {
				type: 'vbox',
				align : 'stretch',
				pack  : 'start',
			},
			items : [
				{
					region : 'center',
					xtype : 'button',
					text : 'Save',
					handler : function() {
						self.update();
					}
				},{
                region : 'center',
                xtype : 'button',
                text : 'Refresh',
                handler : function() {
                    self.refresh(true);
                }
                }

			],
            listeners : { 
                'render' : function(obj) { 
					self.theComponent = obj;
					
					self.initialiseDOMComponent(); 
				}
            }
        });  
    }
	
	override public function initialiseDOMComponent() {
		super.initialiseDOMComponent();
		
		var me = this;
		
		haxe.Timer.delay(function() {
			me.completeSetup();
		},2000);
	}
	
	function completeSetup() {
		var icmClient : ICMClient = ICMClient.getClient();
		
		var self = this;
		
		icmClient.runCommand(
            'sgc.CrystalHelper.showQueries()\n'+
			'jsonTable = sgc.CrystalHelper.getPuckTable();\n'+
			'params[\'jsonTable\']=jsonTable;\n',
			function data(data) {
				var puckList : Array<Dynamic> = data.jsonTable;
				Ext.create('Ext.data.Store', {
					storeId:'puckStore',
					fields:['Puck_Name'],
					data: puckList,
                pageSize: 1000
				});
				
				var puckComboDef : Dynamic = {
					xtype:'combo', 
					store: Ext.data.StoreManager.lookup('puckStore'),
					displayField:'Puck_Name',
					valueField: 'Puck_Name',
					queryMode: 'local',
					editable : false
				};
				
				Ext.create('Ext.data.Store', {
					storeId:'positionStore',
					fields:['position'],
					data : [
						{"position":"1"}, {"position":"2"}, {"position":"3"},
						{"position":"4"}, {"position":"5"}, {"position":"6"},
						{"position":"7"}, {"position":"8"}, {"position":"9"},
						{"position":"10"}, {"position":"11"},
						{"position":"12"}, {"position":"13"}, {"position":"14"},
						{"position":"15"}, {"position":"16"}, {"position":""}
					]
				});
				
				var positionComboDef : Dynamic = {
					xtype:'combo', 
					store: Ext.data.StoreManager.lookup('positionStore'),
					displayField:'position',
					valueField: 'position',
					queryMode: 'local',
					editable : false
				};
				
				var tableColumns : Array<Dynamic> =  [
						{ header: 'Crystal ID', dataIndex: 'XTAL_MOUNT_ID', flex:1},
						{ header: 'Screen Number', dataIndex: 'SCREENNUMBER', flex:1},
						{ header: 'Trash', dataIndex: 'TRASH', flex:1},
						{ header: 'Quality', dataIndex: 'QUALITY', flex:1},
						{ header: 'Pin ID', dataIndex: 'PINID', flex:1 },
						{ header: 'Position', dataIndex: 'POSITION' , editor: positionComboDef, flex:1  },
						{ header: 'Name', dataIndex: 'NAME' , editor   : puckComboDef, flex:1 }
						
				];
				
				self.theTable = Ext.create('Ext.grid.Panel', {
					selType: 'cellmodel',
					plugins: [
						Ext.create('Ext.grid.plugin.CellEditing', {
							clicksToEdit: 1
						})
					],
					width:'100%',
					height: '95%',
					flex: 1,
					autoScroll : true,
					layout : 'fit',
					region : 'south',
					store: Ext.data.StoreManager.lookup('crystalStore'),
					columns: tableColumns,
					listeners : { 
						'render' : function() { 
							refresh(false);
						}
					}
				});  
				
				self.theComponent.add(self.theTable);
			}
		);
	}

    public function refresh(isRefresh : Bool){
        ICMClient.getClient().runCommand(
            'jsonTable = sgc.CrystalHelper.getHelperTable();\n' +
            'params = Collection(\'jsonTable\',jsonTable);\n',
            function(data,err) {
                if(err == null){
                    var jsonTable : Array<Dynamic> = data.jsonTable;
                    Ext.data.StoreManager.lookup('crystalStore').loadData(jsonTable,false);

                    if(isRefresh){
                        getApplication().showMessage('Crystal Helper','Refreshed view');
                    }
                }else{
                    getApplication().showMessage('Crystal Helper','An error has occurred refreshing the view');
                }
            }
        );
    }

    override
    public function onFocus(){	
        super.onFocus();
		
		if (isNaked()) {
			return;
		}
		
		var me = this;
		
		getApplication().getFileMenu().add({
            text : 'Update',
            handler : function() {
				me.update();
            }
        });
    }
	
	public function update() {
		var crystalStore = Ext.data.StoreManager.lookup('crystalStore');
				
		var objList = new Array<Dynamic>();
        var records = new Array<Dynamic>();
				
		for ( i in 0...crystalStore.getCount() ) {
			var record = crystalStore.getAt(i);
					
			var obj = { 
				'PINID':record.get('PINID'), 
				'NAME': record.get('NAME'), 
				'POSITION' : record.get('POSITION') 
			};

            if(record.dirty){
                objList.push(obj);
                records.push(record);
            }
		}

        var pinCount = objList.length;

        if(pinCount == 0){
            getApplication().showMessage('Crystal Helper','No pins to update!');
            return;
        }
				
		var jsonStr = haxe.Json.stringify(objList);
				
		var icmClient = ICMClient.getClient();
				
		var icmSetCommand = icmClient.generateSetStringCommand('JSON_STR',jsonStr);
				
		icmClient.runCommand(
			icmSetCommand +
			'delete JSON_OBJ\n' + 
			'read json input=JSON_STR name="JSON_OBJ"\n' + 
			'sgc.CrystalHelper.updatePinInfo(JSON_OBJ)\n',
			function(data, ex){
                if(ex != null){
                    getApplication().showMessage('Crystal Helper Exception','An error has occurred during save, please contact your Scarab administrator<br/>'+ex.message);
                }else{
                    var plural = '';
                    if(pinCount > 1){
                        plural = 's';
                    }

                    getApplication().showMessage('Crystal Helper', 'Successfully updated ' + pinCount + ' pin location' + plural);

                    for(record in records){
                        record.commit();
                    }
                }
            }
		);
	}

    override public function setActiveObject(objectId : String) {
		
	}

    override public function setTitle(title : String){
        theComponent.setTitle(title);
    }

    override public function getComponent() : Dynamic {
        return theComponent;
    }
}
