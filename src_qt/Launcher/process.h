/*http://www.xargs.com/qml/process.html*/
#include <QProcess>
#include <QVariant>
#include <QTemporaryFile>
#include <QFile>
#include <QTextStream>
#include <QIODevice>

class Process : public QProcess {
    Q_OBJECT

public:
    Process(QObject *parent = 0) : QProcess(parent) { }

    Q_INVOKABLE void start(const QString &program, const QVariantList &arguments);

    Q_INVOKABLE QByteArray readAll();

    Q_INVOKABLE bool running();

    Q_INVOKABLE QString getTemporaryFileName();

    Q_INVOKABLE QString writeFile(const QString &fileName,const QString &contents);

    Q_INVOKABLE QString readFile(const QString &fileName);

    Q_INVOKABLE QString waitForClose();
};

