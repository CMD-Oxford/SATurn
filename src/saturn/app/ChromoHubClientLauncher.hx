package saturn.app;

import saturn.client.WorkspaceApplication;

class ChromoHubClientLauncher {
    public function new() {

    }

    public static function main() {
        var inScarab = false;

        var client : ChromoHubClient = new ChromoHubClient('ChromoHub','Workspace', 'Notifications', 'Outline', 'Editor', 'Search gene symbols', false, 'Search gene symbols');


        WorkspaceApplication.setApplication(client);
    }
}