#!/bin/sh

cd ../build-Saturn-Desktop_Qt_5_10_1_clang_64bit-Release

cp -r ../build-filereader-Desktop_Qt_5_10_1_clang_64bit-Release/File/ Saturn.app/Contents/MacOS
cp -r ../Launcher/File/qmldir Saturn.app/Contents/MacOS/File/

~/Qt/5.10.1/clang_64/bin/macdeployqt Saturn.app/ -executable=Saturn.app/Contents/MacOS/Saturn -qmldir=../Launcher/ -verbose=3

install_name_tool -change @rpath/QtWebEngineWidgets.framework/Versions/5/QtWebEngineWidgets @executable_path/../frameworks/QtWebEngineWidgets.framework/Versions/5/QtWebEngineWidgets Saturn.app/Contents/MacOS/Saturn

install_name_tool -change @rpath/QtPrintSupport.framework/Versions/5/QtPrintSupport @executable_path/../frameworks/QtPrintSupport.framework/Versions/5/QtPrintSupport Saturn.app/Contents/MacOS/Saturn

install_name_tool -change @rpath/QtWebEngineCore.framework/Versions/5/QtWebEngineCore @executable_path/../frameworks/QtWebEngineCore.framework/Versions/5/QtWebEngineCore Saturn.app/Contents/MacOS/Saturn

install_name_tool -change @rpath/QtQuick.framework/Versions/5/QtQuick @executable_path/../frameworks/QtQuick.framework/Versions/5/QtQuick Saturn.app/Contents/MacOS/Saturn

install_name_tool -change @rpath/QtQml.framework/Versions/5/QtQml @executable_path/../frameworks/QtQml.framework/Versions/5/QtQml Saturn.app/Contents/MacOS/Saturn

install_name_tool -change @rpath/QtNetwork.framework/Versions/5/QtNetwork @executable_path/../frameworks/QtNetwork.framework/Versions/5/QtNetwork Saturn.app/Contents/MacOS/Saturn

install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore @executable_path/../frameworks/QtCore.framework/Versions/5/QtCore Saturn.app/Contents/MacOS/Saturn

install_name_tool -change @rpath/QtWebChannel.framework/Versions/5/QtWebChannel @executable_path/../frameworks/QtWebChannel.framework/Versions/5/QtWebChannel Saturn.app/Contents/MacOS/Saturn


install_name_tool -change @rpath/QtPositioning.framework/Versions/5/QtPositioning @executable_path/../frameworks/QtPositioning.framework/Versions/5/QtPositioning Saturn.app/Contents/MacOS/Saturn

install_name_tool -change @rpath/QtGui.framework/Versions/5/QtGui @executable_path/../frameworks/QtGui.framework/Versions/5/QtGui Saturn.app/Contents/MacOS/Saturn

install_name_tool -change @rpath/QtWebEngine.framework/Versions/5/QtWebEngine @executable_path/../frameworks/QtWebEngine.framework/Versions/5/QtWebEngine Saturn.app/Contents/MacOS/Saturn

install_name_tool -change @rpath/QtWidgets.framework/Versions/5/QtWidgets @executable_path/../frameworks/QtWidgets.framework/Versions/5/QtWidgets Saturn.app/Contents/MacOS/Saturn

###

install_name_tool -change @rpath/QtQuick.framework/Versions/5/QtQuick @executable_path/../frameworks/QtQuick.framework/Versions/5/QtQuick Saturn.app/Contents/PlugIns/quick/libqtwebengineplugin.dylib

install_name_tool -change @rpath/QtQml.framework/Versions/5/QtQml @executable_path/../frameworks/QtQml.framework/Versions/5/QtQml Saturn.app/Contents/PlugIns/quick/libqtwebengineplugin.dylib

install_name_tool -change @rpath/QtNetwork.framework/Versions/5/QtNetwork @executable_path/../frameworks/QtNetwork.framework/Versions/5/QtNetwork Saturn.app/Contents/PlugIns/quick/libqtwebengineplugin.dylib

install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore @executable_path/../frameworks/QtCore.framework/Versions/5/QtCore Saturn.app/Contents/PlugIns/quick/libqtwebengineplugin.dylib

install_name_tool -change @rpath/QtWebChannel.framework/Versions/5/QtWebChannel @executable_path/../frameworks/QtWebChannel.framework/Versions/5/QtWebChannel Saturn.app/Contents/PlugIns/quick/libqtwebengineplugin.dylib


install_name_tool -change @rpath/QtPositioning.framework/Versions/5/QtPositioning @executable_path/../frameworks/QtPositioning.framework/Versions/5/QtPositioning Saturn.app/Contents/PlugIns/quick/libqtwebengineplugin.dylib

install_name_tool -change @rpath/QtGui.framework/Versions/5/QtGui @executable_path/../frameworks/QtGui.framework/Versions/5/QtGui Saturn.app/Contents/PlugIns/quick/libqtwebengineplugin.dylib

install_name_tool -change @rpath/QtWebEngine.framework/Versions/5/QtWebEngine @executable_path/../frameworks/QtWebEngine.framework/Versions/5/QtWebEngine Saturn.app/Contents/PlugIns/quick/libqtwebengineplugin.dylib

install_name_tool -change @rpath/QtWidgets.framework/Versions/5/QtWidgets @executable_path/../frameworks/QtWidgets.framework/Versions/5/QtWidgets Saturn.app/Contents/PlugIns/quick/libqtwebengineplugin.dylib

##

install_name_tool -change @rpath/QtWebEngineWidgets.framework/Versions/5/QtWebEngineWidgets @executable_path/../../../../../QtWebEngineWidgets.framework/Versions/5/QtWebEngineWidgets Saturn.app/Contents/Frameworks/QtWebEngineCore.framework/Helpers/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess 

install_name_tool -change @rpath/QtWebEngineCore.framework/Versions/5/QtWebEngineCore @executable_path/../../../../../QtWebEngineCore.framework/Versions/5/QtWebEngineCore Saturn.app/Contents/Frameworks/QtWebEngineCore.framework/Helpers/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess


install_name_tool -change @rpath/QtQuick.framework/Versions/5/QtQuick @executable_path/../../../../..//QtQuick.framework/Versions/5/QtQuick Saturn.app/Contents/Frameworks/QtWebEngineCore.framework/Helpers/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess

install_name_tool -change @rpath/QtQml.framework/Versions/5/QtQml @executable_path/../../../../..//QtQml.framework/Versions/5/QtQml Saturn.app/Contents/Frameworks/QtWebEngineCore.framework/Helpers/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess

install_name_tool -change @rpath/QtNetwork.framework/Versions/5/QtNetwork @executable_path/../../../../..//QtNetwork.framework/Versions/5/QtNetwork Saturn.app/Contents/Frameworks/QtWebEngineCore.framework/Helpers/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess

install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore @executable_path/../../../../../QtCore.framework/Versions/5/QtCore Saturn.app/Contents/Frameworks/QtWebEngineCore.framework/Helpers/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess

install_name_tool -change @rpath/QtWebChannel.framework/Versions/5/QtWebChannel @executable_path/../../../../../QtWebChannel.framework/Versions/5/QtWebChannel Saturn.app/Contents/Frameworks/QtWebEngineCore.framework/Helpers/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess


install_name_tool -change @rpath/QtPositioning.framework/Versions/5/QtPositioning @executable_path/../../../../../QtPositioning.framework/Versions/5/QtPositioning Saturn.app/Contents/Frameworks/QtWebEngineCore.framework/Helpers/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess

install_name_tool -change @rpath/QtGui.framework/Versions/5/QtGui @executable_path/../../../../../QtGui.framework/Versions/5/QtGui Saturn.app/Contents/Frameworks/QtWebEngineCore.framework/Helpers/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess

install_name_tool -change @rpath/QtWebEngine.framework/Versions/5/QtWebEngine @executable_path/../../../../../QtWebEngine.framework/Versions/5/QtWebEngine Saturn.app/Contents/Frameworks/QtWebEngineCore.framework/Helpers/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess

install_name_tool -change @rpath/QtWidgets.framework/Versions/5/QtWidgets @executable_path/../../../../../QtWidgets.framework/Versions/5/QtWidgets Saturn.app/Contents/Frameworks/QtWebEngineCore.framework/Helpers/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess

cp -r Saturn.app ../../build/qt/ 
