function Component()
{

}

Component.prototype.createOperations = function()
{
    component.createOperations();
    
    if (systemInfo.productType === "windows") {
        component.addOperation("CreateShortcut", "@TargetDir@/build/qt/SATurn.exe", "@StartMenuDir@/SATurn.lnk", "@TargetDir@/build http://localhost:8091 ALL --disable-web-security",
            "workingDirectory=@TargetDir@", "iconPath=%SystemRoot%/system32/SHELL32.dll",
            "iconId=2", "description=Launch SATurn");
            
         //component.addElevatedOperation("Execute", "netsh","advfirewall","firewall","add","rule","name=node","dir=in","action=block","program='@TargetDir@\build\bin\node\node.exe'","enable=yes");
         //component.addElevatedOperation("Execute", "netsh","advfirewall","firewall","add","rule","name=node","dir=out","action=block","program='@TargetDir@\build\bin\node\node.exe'","enable=yes");
    }
}
