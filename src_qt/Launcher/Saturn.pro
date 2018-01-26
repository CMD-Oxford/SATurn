# Additional import path used to resolve QML modules in Qt Creator's code model
#QML2_IMPORT_PATH = File

CONFIG += static
CONFIG += console

TEMPLATE = app

QT += qml quick widgets webenginewidgets

SOURCES += main.cpp \
    process.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = File

QML2_IMPORT_PATH = File

QML_IMPORT_TRACE=1

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    process.h

RC_ICONS = saturn.ico


