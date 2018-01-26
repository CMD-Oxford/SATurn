//https://rschroll.github.io/beru/2013/08/14/reading-files-with-a-c++-plugin-in-qml.html

#include "filereaderplugin.h"
#include "filereader.h"
#include <qqml.h>

void FileReaderPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<FileReader>(uri, 1, 0, "FileReader");
}
