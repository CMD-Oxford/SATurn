/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtWebEngine 1.1
import QtQuick.Dialogs 1.1
import QtWebChannel 1.0
import File 1.0
import Process 1.0
import QtQuick.Dialogs 1.0

ApplicationWindow {
    id: app
    width: 1280
    height: 720
    visible: true

    FileDialog {
        id: fileDialog
        title: "Please choose a File"
        WebChannel.id: "fileDialog"
        folder: shortcuts.home
        onAccepted: {
            var fileName = fileDialog.fileUrls.toString();

            if(Qt.platform.os === "windows"){
                fileName = fileName.replace('file:///','');
            }else{
                fileName = fileName.replace('file://','');
            }

            fileSelected(fileName)
        }

        onRejected: {
            console.log("Canceled")
        }

        visible: false

        signal fileSelected(string fileName);
    }

    FileReader {
            id: filereader
            WebChannel.id: "HostFileReader"
    }



    QtObject {
        id: myObject

        property int i:0;

        // the identifier under which this object
        // will be known on the JavaScript side
        WebChannel.id: "foo"



        // signals, methods and properties are
        // accessible to JavaScript code
        signal someSignal(string message);

        function someMethod(message) {
            console.log(message);
            someSignal(message);
            return "foobar";
        }

        function openFileDialog(){
            fileDialog.visible = true;
        }

        function createNewProcess(){
            i++;

            var processId = "object" + i;

            var p = processFactory.createObject(processFactory.parent,{'WebChannel.id': processId});

            webview.webChannel.registerObject(processId, p);

            return processId;
        }

        function createNewDialog(){
            i++;

            var objectId = "object" + i;

            var p = dialogFactory.createObject(app,{'WebChannel.id': objectId});

            webview.webChannel.registerObject(objectId, p);

            return objectId;
        }


        property string hello: "world"
    }

    WebEngineView {
        id: webview
        url: Qt.application.arguments[2]
        anchors.fill: parent
        webChannel.registeredObjects:[myObject, filereader, fileDialog]

        Component.onCompleted: {
            WebEngine.defaultProfile.downloadRequested.connect(downloadme);
            webview.settings.localContentCanAccessRemoteUrls = true;
        }

        function downloadme(download){
            //downloadMessage.text = download.path
            //downloadMessage.visible = true

            download.accept()
            fileDialog2.saveDownload(download)
        }

        MessageDialog {
            id:downloadMessage
            title: 'Downloaded'
            visible: false
        }

        Component {
            id: processFactory

            Process {}
        }

        Component {
            id: dialogFactory

            FileDialog {
                folder: shortcuts.home
                onAccepted: {
                    var fileName = fileUrls.toString()
                    if(Qt.platform.os === "windows"){
                        fileName = fileName.replace('file:///','');
                    }else{
                        fileName = fileName.replace('file://','');
                    }

                    fileSelected(fileName)
                }

                onRejected: {
                    console.log("Canceled")
                }

                visible: false

                signal fileSelected(string fileName);
            }
        }

        FileDialog {
            id: fileDialog2
            title: "Please choose a file"
            folder: shortcuts.home
            property var downloadItem: {}
            selectExisting: false
            nameFilters: [  "All files (*)" ]
                    selectedNameFilter: "All files (*)"
            onAccepted: {
                var destPath = fileDialog2.fileUrls.toString();
                //var destPath = fileDialog2.fileUrls.toString();

                if(Qt.platform.os === "windows"){
                    destPath = destPath.replace('file:///','');
                }else{
                    destPath = destPath.replace('file://','');
                }

                downloadMessage.text = "Downloaded " + destPath
                downloadMessage.visible = true
                filereader.moveFile(downloadItem.path, destPath);

            }

            onRejected: {
                console.log("Canceled")
            }

            function saveDownload(download){

                downloadItem = download
                visible = true

            }

            visible: false
        }
    }

    DropArea {
            anchors.fill: parent
            onEntered: {

            }
            onExited: {

            }
            onDropped: {
                drop.acceptProposedAction()
                var fileName = drop.urls.toString();

                if(Qt.platform.os === "windows"){
                    fileName = fileName.replace('file:///','');
                }else{
                    fileName = fileName.replace('file://','');
                }

                webview.runJavaScript('WK.openFile(new saturn.core.FileShim("'+fileName+'","'+filereader.read_b64(fileName)+'"),true);')  // Assuming you've defined
                /*var request = new XMLHttpRequest()
                request.open('GET', fileName)
                request.onreadystatechange = function(event) {
                    if (request.readyState == XMLHttpRequest.DONE) {
                         webview.runJavaScript('window.a=new saturn.core.FileShim("'+fileName+'","'+Qt.btoa(request.responseText)+'");')  // Assuming you've defined

                    }                                             // lines as a property
                }
                request.send()*/


            }
        }

}
