// https://rschroll.github.io/beru/2013/08/14/reading-files-with-a-c++-plugin-in-qml.html

#ifndef FILEREADER_H
#define FILEREADER_H

#include <QObject>

class FileReader : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE QByteArray read(const QString &filename);
    Q_INVOKABLE QString read_b64(const QString &filename);
};

#endif // FILEREADER_H
