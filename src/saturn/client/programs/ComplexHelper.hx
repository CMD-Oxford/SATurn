package saturn.client.programs;
import saturn.core.ComplexPlan;
class ComplexHelper extends BasicTableViewer{
    public function new(){
        super();
    }

    override public function onFocus(){
        super.onFocus();

        getApplication().getToolBar().add({
            iconCls :'x-btn-calculate',
            text:'Generate IDs',
            handler: function(){
                var table = getComplexTable();
                table.generateIds(function(error){
                    if(error != null){
                        WorkspaceApplication.getApplication().showMessage('Upload Error', error);
                    }else{
                        updateTable(table);
                    }
                });
            }
        });

        getApplication().getToolBar().add({
            iconCls :'x-btn-calculate',
            text:'Save',
            handler: function(){
                var table = getComplexTable();
                table.save(function(error){
                    if(error != null){
                        WorkspaceApplication.getApplication().showMessage('Upload Error', error);
                    }else{
                        updateTable(table);

                        WorkspaceApplication.getApplication().showMessage('Complex Targets Generated', 'Complex Targets Generated');
                    }


                });
            }
        });
    }

    public function getComplexTable() : ComplexPlan{
        return cast(getUpdatedTable(), ComplexPlan);
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-protein',
                html:'Complex<br/>Helper',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new ComplexPlan(true), true);
                },
                tooltip: {dismissDelay: 10000, text: 'Design Complexes'}
            }
        ];
    }
}
