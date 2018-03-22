#ifndef FILEREADER_H
#define FILEREADER_H

#include <QObject>

class FileReader : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE QByteArray read(const QString &filename);
    Q_INVOKABLE QString read_b64(const QString &filename);
    Q_INVOKABLE void moveFile(const QString &oldName, const QString &newName);
};

#endif // FILEREADER_H
