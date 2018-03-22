import QtQuick 2.0

Item {
    width: 300; height: 200

    FileReader {
        id: filereader
    }

    Text {
        anchors.centerIn: parent
        text: "Click to read file into console"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: console.log(filereader.read('app.qml'))
    }
}
