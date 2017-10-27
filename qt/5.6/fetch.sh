#!/bin/bash

set -e

BASEDIR=$(dirname "$0")

source $BASEDIR/../../config.sh

if [[ -z "$QT_VERSION" ]]; then
	echo "QT_VERSION not set";
    exit -1
fi

if [[ -z "$BUILD_VERSION" ]]; then
	echo "BUILD_VERSION string not set";
    exit -1
fi


if [ `uname -o` == "GNU/Linux" ]; then
    CLONE_QT_SRC="$QT_SRC_DIR"
else
    CLONE_QT_SRC=qt-src
fi

if [ `uname -o` == "Cygwin" ]; then
    CLONE_QT_SRC=`cygpath -a $QT_SRC_DIR`
fi

# clean up
rm -f *.zip

if [ "$QT_NO_CLEAN_SRC" != "1" ]; then
    if [ -e $CLONE_QT_SRC ]; then
        sudo rm -rf $CLONE_QT_SRC
    fi
fi

rm -f *.txt

# get Qt5 main repo
QT_GIT_REPO=http://code.qt.io/cgit/qt/qt5.git
if [ "$QT_USE_GITHUB" == "1" ]; then
    QT_GIT_REPO=https://github.com/qt/qt5.git
elif [ "$QT_GIT_REPO_OVERRIDE" != "" ]; then
    QT_GIT_REPO=$QT_GIT_REPO_OVERRIDE
fi

git clone $QT_GIT_REPO --branch v$QT_VERSION $CLONE_QT_SRC

if [ `uname -o` == "Cygwin" ]; then
    chmod -R a+rwx $CLONE_QT_SRC
fi

# init subrepos
cd $CLONE_QT_SRC

if [ "$QT_NO_CLEAN_SRC" == "1" ]; then
    git submodule foreach --recursive "git clean -dfx"
else
    git submodule init qtbase qtconnectivity qtdeclarative qtdoc qtgraphicaleffects qtimageformats qtlocation qtmultimedia qtqa 
    git submodule init qtquickcontrols qtquickcontrols2 qtrepotools qtscript qtsensors  qtserialbus qtserialport qtsvg qttools
    git submodule init qttranslations qtwayland qtwebchannel qtwebsockets qtwebview qtwinextras qtx11extras qtxmlpatterns
    git submodule update

    # init subsubrepos
    cd qtxmlpatterns; git submodule update --init; cd ..
    cd qtdeclarative; git submodule update --init; cd ..

    # independently pull QtWebEngine based on the version defined in config.sh
    if [ -e qtwebengine ]; then
        rm -rf qtwebengine
    fi
    
    if [ -e qtwebkit ]; then
        rm -rf qtwebkit
    fi

    git clone https://github.com/qt/qtwebengine.git qtwebengine
    git clone https://github.com/qt/qtwebkit.git qtwebkit -b $QTWEBKIT_VERSION
fi

# Enable GStreamer 1.0 support
cd qtmultimedia
grep GST_VERSION .qmake.conf || echo "GST_VERSION=1.0">>.qmake.conf
cd ..
cd qtwebkit
grep GST_VERSION .qmake.conf || echo "GST_VERSION=1.0">>.qmake.conf
cd ..

# apply patch: protection against accessing destroyed QDBusConnectionManager
#cd qtbase
#patch -f -Np1 -i "$QT_PATCH_DIR/0006-dbus-connectionmanager-destroy.patch"
#cd ..

# fix memory leaks regarding QtWaylandCompositors handling of shell integration objects
#cd qtwayland
#patch -f -Np1 -i "$QT_PATCH_DIR/0015-qtwaylandcomp-shellintegrationleak.patch"
#cd ..

cd qtwebengine
git checkout tags/v$QTWEBENGINE_VERSION
git submodule update --init --recursive

# apply proxy patch - should already be in 5.7.1
#echo "patching 0002-disable-proxy-for-localhost"
#patch -f -Np1 -i "$QT_PATCH_DIR/0002-disable-proxy-for-localhost.patch"

# apply http status code patch
echo "patching 0007-enableHttpStatusCode"
patch -f -Np1 -i "$QT_PATCH_DIR/0007-enableHttpStatusCode.patch"

# fix QtWebEngine 5.8.0 build with 5.7.1 Qt framework
#echo "patching 0011-qtwebengine-versionFixup"
#patch -f -Np1 -i "$QT_PATCH_DIR/0011-qtwebengine-versionFixup.patch"

echo "patching 0012-qtwebengine-hidewincrash.patch"
patch -f -Np1 -i "$QT_PATCH_DIR/0012-qtwebengine-hidewincrash.patch"


# apply webchannel transport patch
#echo "patching 0005-qtwebengine-5.7-reload-channel"
#patch -f -Np1 -i "$QT_PATCH_DIR/0005-qtwebengine-5.7-reload-channel.patch"

# apply QtWebEngine proxy authentication bypass patch
#echo "patching 0008-webengine-application-proxy"
#patch -f -Np1 -i "$QT_PATCH_DIR/0008-webengine-application-proxy.patch"
cd ..


# apply in-process-gpu & vaapi patch
cd qtwebengine/src/3rdparty/chromium/
echo "patching 0009-qtwebengine-hwaccel"
patch -f -Np1 -i "$QT_PATCH_DIR/0009-qtwebengine-hwaccel.patch"
patch -f -Np2 -i "$QT_PATCH_DIR/0009-qtwebengine-hwaccel2.patch"

# echo "patching 0010-qtwebengine-mirects"
# patch -f -Np1 -i "$QT_PATCH_DIR/0010-qtwebengine-mirects.patch"

# echo "patching 0013-qtwebengine-getlasterrorwgl.patch"
# patch -f -Np1 -i "$QT_PATCH_DIR/0013-qtwebengine-getlasterrorwgl.patch"

#enable proprietary codecs in webengine
cd ../../../
grep use_proprietary_codecs .qmake.conf || echo "WEBENGINE_CONFIG+=use_proprietary_codecs">>.qmake.conf
cd ..
