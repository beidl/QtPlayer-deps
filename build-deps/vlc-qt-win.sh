#!/bin/bash

if [ -z "$VERSION" ]; then
    VERSION="2.2.3"
fi

JOBROOT=`pwd`
WD="$JOBROOT/VLC/$VERSION"
VLCQT_WD="$JOBROOT/VLC-Qt"

rm -rf $WD
unzip VLC-Blobs.zip -d $JOBROOT
mkdir -p $WD

if [ -e $VLCQT_WD ]; then
    rm -rf $VLCQT_WD
fi 

mkdir $VLCQT_WD
cd $VLCQT_WD

if [ ! -e vlc-qt ]; then
    git clone git://github.com/vlc-qt/vlc-qt.git vlc-qt
    cd vlc-qt
    git checkout 0c235025eb3160c633799dc8430261b6c2a6949d
    git submodule init
    git submodule update
    cd ..
fi

cd $JOBROOT

function create_vlc_qt_blobs_for_arch () {
    ARCH=$1
    
    cd $VLCQT_WD/vlc-qt
    
    MACHINE="/MACHINE:x86"
    if [ $ARCH = "x86_64" ]; then
        MACHINE="/MACHINE:x64"
    fi
    
    mkdir build
    mkdir install-$ARCH
    cd build
    cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="../install-$ARCH/" \
        -DLIBVLC_LIBRARY="$WD/$ARCH/libvlc.lib" \
        -DLIBVLCCORE_LIBRARY="$WD/$ARCH/libvlccore.lib" \
        -DLIBVLC_INCLUDE_DIR="$WD/$ARCH/include"
    ninja
    ninja install
    cd ..
    rm -rf build
}

create_vlc_qt_blobs_for_arch "i686"
create_vlc_qt_blobs_for_arch "x86_64"
cd $JOBROOT

zip -y -r VLC-Blobs-Qt.zip VLC
