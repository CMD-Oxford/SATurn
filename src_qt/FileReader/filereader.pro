TEMPLATE = lib
CONFIG += plugin
QT += qml quick

DESTDIR = File
TARGET = filereaderplugin


HEADERS += filereader.h filereaderplugin.h

SOURCES += filereader.cpp filereaderplugin.cpp

OTHER_FILES += app.qml

QML2_IMPORT_PATH = File
QML_IMPORT_PATH = File

