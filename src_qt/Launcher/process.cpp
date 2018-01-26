/*http://www.xargs.com/qml/process.html*/
#include "process.h"

void Process::start(const QString &program, const QVariantList &arguments) {
    QStringList args;

    // convert QVariantList from QML to QStringList for QProcess

    for (int i = 0; i < arguments.length(); i++)
        args << arguments[i].toString();

    QProcess::start(program, args);
}

bool Process::running(){
    return this->state() == QProcess::Running ? true : false;
}

QByteArray Process::readAll() {
    return QProcess::readAll();
}

QString Process::getTemporaryFileName(){
    QTemporaryFile file;

    file.setAutoRemove(false);

    if(file.open()){
        file.close();
        return file.fileName();
    }else{
        return NULL;
    }
}

QString Process::writeFile(const QString &fileName,const QString &contents){
    QFile file(fileName);

    if(file.open(QIODevice::WriteOnly)){
        QTextStream stream(&file);
        stream << contents << endl;
        file.flush();
        file.close();

        return NULL;
    }else{
        return "Unable to open file writing";
    }
}

QString Process::readFile(const QString &fileName){
    QFile file(fileName);
    if(file.open(QFile::ReadOnly | QFile::Text)){
        QTextStream stream(&file);
        QString contents = stream.readAll();

        file.close();

        return contents;
    }else{
        return NULL;
    }
}

QString Process::waitForClose(){
    bool retVal = this->waitForFinished();

    QProcess::ExitStatus status = this->exitStatus();

    if(status == 0 && retVal == true){
        return NULL;
    }else{
        return "External process returned a non-zero exit status";
    }
}
