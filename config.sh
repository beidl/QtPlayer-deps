#!/bin/bash

CONFIG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

QT_VERSION="5.6.1-1"
QTWEBENGINE_VERSION="5.7.0"
QT_DIR="/opt/Qt/$QT_VERSION/gcc_64"
QT_PATCH_DIR="$CONFIG_DIR/qt/patches"
QT_NO_CLEAN_SRC=0

if [ `uname -o` != "GNU/Linux" ]; then
    alias sudo=
    if [ "$GF_QT_IS_32_BIT_BUILD" == "" ]; then
        QT_DIR_WIN="C:\Qt\\$QT_VERSION\msvc2013_64"
        OSSL_PREFIX="C:\openssl64"
    else
        QT_DIR_WIN="C:\Qt\\$QT_VERSION\msvc2013"
        OSSL_PREFIX="C:\openssl32"
    fi
fi

if [ "$QT_SRC_DIR" == "" ]; then
    QT_SRC_DIR="$CONFIG_DIR/qt/5.6/qt-src"
fi

VLC_VERSION="2.2.1"

QTAV_DEVRELEASE=1
QTAV_TAG="51fb47577a8c8bc681faa2c27180a1c65671c078"
QTAV_PATCH_DIR="$CONFIG_DIR/qtav/patches"

FFMPEG_VERSION="2.8.6"

OPENSSL_VERSION="1.0.2h"
OPENSSL_DIR=$CONFIG_DIR/openssl

LIBVA_VERSION="1.7.1"

GTKGLEXT_VERSION="04131c5f69070b2f194f02edd45b0622ca03793c"

NM_QT_VERSION="v5.20.0"

BASE_OS_VERSION="14.04.4"
BASE_ISO_FILE="lubuntu-$BASE_OS_VERSION-desktop-amd64.iso"
BASE_OS_SHA256="94fb8266b60e98421c512aef8162d803e67c6ae640dd76e305c9ec339677ceee"
ISO_BUILDSPACE=$CONFIG_DIR/create-iso/buildspace
ISO_MOUNT=/mnt/gf_iso_mount

INSTALL_PREFIX="/opt/gf-builddeps"
