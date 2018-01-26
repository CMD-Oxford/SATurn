/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client;

import saturn.client.WorkspaceApplication.ScreenMode;
import bindings.Ext;

class SingleAppContainer {
    var hbox : Dynamic;
    var centralPanel : Dynamic;

    var controlToolBar : Dynamic;
    var modeToolBar : Dynamic;

    var program : Program;

    public function new() {
        hbox = Ext.create('Ext.panel.Panel', {
            layout: 'hbox',
            width: '100%',
            height: '100%',
            region: 'north',
            border: false,
            flex: 1
        });

        createComponents();
    }

    public function createComponents(){
        createModeToolBar();
        createControlToolBar();

        createCentralPanel();
    }

    public function createCentralPanel(){
        centralPanel = Ext.create('Ext.panel.Panel', {
            layout: 'border',
            width: '100%',
            height: '100%',
            region: 'north',
            border: false,
            flex: 1
        });

        /*centralPanel = Ext.create('Ext.Container',{
        layout : 'border',
        height : '100%',
        width: '100%'
        });*/

        hbox.add(centralPanel);
    }

    public function createControlToolBar(?attachPosition = 1){
        controlToolBar = Ext.create('Ext.toolbar.Toolbar', {
            width: '20px',
            height: '100%',
            border: false,
            vertical: true
        });

        controlToolBar.add({
            xtype : 'button',
            text : 'Back',
            glyph: "2302",
            handler: function(){
                getApplication().setMode(ScreenMode.DEFAULT);
            }
        });

        hbox.insert(attachPosition, controlToolBar);
    }

    public function clearControlToolBar(){
        var attachPosition = hbox.items.findIndex('id', controlToolBar.id);

        hbox.remove(controlToolBar);

        createControlToolBar(attachPosition);
    }

    public function hideControlToolBar(){
        controlToolBar.hide();
    }

    public function showControlToolBar(){
        controlToolBar.show();
    }

    public function createModeToolBar(){
        modeToolBar = Ext.create('Ext.toolbar.Toolbar', {
            width: '20px',
            height: '100%',
            border: false,
            vertical: true
        });



        //hbox.add(modeToolBar);
    }

    public function getControlToolBar(){
        return controlToolBar;
    }

    public function getModeToolBar(){
        return modeToolBar;
    }

    public function getComponent(){
        return hbox;
    }

    public function setProgram(program : Program){
        this.program = program;

        var progComponent = this.program.getComponent();

        centralPanel.add(progComponent);
        centralPanel.doLayout();

        progComponent.doLayout();
        progComponent.show();

        centralPanel.doLayout();

        program.focusProgram();
    }

    public function getApplication() : WorkspaceApplication{
        return WorkspaceApplication.getApplication();
    }

    public function getCentralContainer() : Dynamic {
        return centralPanel;
    }
}
