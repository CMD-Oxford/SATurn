/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQuick/QQuickView>
#include <QtGui/QGuiApplication>

#include <QtWebEngineWidgets/QtWebEngineWidgets>
#include <QtWebEngineWidgets/QWebEngineView>

#include <QProcess>
#include <QDebug>
#include <QThread>

#include "process.h"


int main(int argc, char *argv[]){
    QString baseDir = argv[1];
    QString debugMode = argv[3];

    if(debugMode == "ALL"){
        debugMode = "*";
    }else if(debugMode == "NONE"){
        debugMode = "";
    }

    qmlRegisterType<Process>("Process", 1, 0, "Process");

    QProcess *node;
    QProcess *redis = NULL;

    if(baseDir == "__DEFAULT__"){
        baseDir = QFileInfo(QDir::currentPath()).path();
    }

    if(baseDir != "__REMOTE__"){
        qDebug() << "Base Directory: " << baseDir;

        // Start Redis
        QString redisDir = baseDir + "/bin/redis";

        #ifdef Q_OS_MACX
            QString redisProgram = redisDir + "/src/redis-server";
        #elif Q_OS_WIN
            QString redisProgram = redisDir + "/redis-server.exe";
        #endif

        qDebug() << "Redis directory: " << redisDir;
        qDebug() << "Redis executable: " << redisProgram;

        QProcess *redis = new QProcess();
        redis->setWorkingDirectory(redisDir);
        redis->setProcessChannelMode(QProcess::ForwardedChannels);

        QStringList redisArguments;
        redisArguments << redisDir + "/redis.conf";

        redis->start(redisProgram, redisArguments);

        //Start NodeJS
        QString nodeDir = baseDir + "/bin/node";
        #ifdef Q_OS_MACX
             QString nodeProgram = nodeDir + "/bin/node";
        #elif Q_OS_WIN
            QString nodeProgram = nodeDir + "/node.exe";
        #endif
        QStringList nodeArguments;
        nodeArguments << "SaturnServer.js";
        nodeArguments << "services/ServicesLocalLite.json";

        qDebug() << "Node directory: " << nodeDir;
        qDebug() << "Node executable" << nodeProgram;
        qDebug() << "Node arguments: " << nodeArguments;
        qDebug() << "Debug Mode " << debugMode;

        QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
        env.insert("NODE_PATH", nodeDir + "/node_modules");
        env.insert("DEBUG", debugMode);

        //Node needs this set otherwise you might get an errorno 203 thrown
        env.insert("TMP", QDir::tempPath());

        node = new QProcess();
        node->setProcessEnvironment(env);
        node->setWorkingDirectory(baseDir);
       // node->setProcessChannelMode(QProcess::ForwardedChannels);
        node->setStandardOutputFile(baseDir + "/node.stdout");
        node->setStandardErrorFile(baseDir + "/node.stderr");
        node->start(nodeProgram, nodeArguments);

        QThread::sleep(4);
    }
    //Looks like current QT binaries are too old for below
    //QWebEngineSettings::globalSettings()->setAttribute(QWebEngineSettings::Q, enable);
    // Wait for Node to start-up

    QProcessEnvironment::systemEnvironment().insert("QTWEBENGINE_REMOTE_DEBUGGING", "9000");

    QApplication app(argc, argv);



    //qmlRegisterType<FileIO>("org.sgc", 1, 0, "FileIO");

 //  QtWebEngine::initialize();

    QWebEngineSettings::globalSettings()->setAttribute(QWebEngineSettings::LocalContentCanAccessFileUrls, true);
    QWebEngineSettings::globalSettings()->setAttribute(QWebEngineSettings::LocalContentCanAccessRemoteUrls, true);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    QWindow *qmlWindow = qobject_cast<QWindow*>(engine.rootObjects().at(0));

    QWebEngineView *browser = qobject_cast<QWebEngineView*>(qmlWindow->children().at(0));


    //browser->page()->runJavaScript("var fileref=document.createElement('script');fileref.setAttribute('type','text/javascript');fileref.setAttribute('src', 'qrc:///qtwebchannel/qwebchannel.js');document.getElementsByTagName('head'')[0].appendChild(fileref);");


    int r = app.exec();

    if(redis != NULL){
        redis->close();
    }

    if(node != NULL){
        node->close();
    }

    qDebug() << "Exiting";

    return r;
}
