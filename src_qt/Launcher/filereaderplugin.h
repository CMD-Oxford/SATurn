//https://rschroll.github.io/beru/2013/08/14/reading-files-with-a-c++-plugin-in-qml.html

#ifndef FILEREADERPLUGIN_H
#define FILEREADERPLUGIN_H

#include <QQmlExtensionPlugin>

class FileReaderPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "io.github.rschroll.FileReader")

public:
    void registerTypes(const char *uri);
};

#endif // FILEREADERPLUGIN_H
