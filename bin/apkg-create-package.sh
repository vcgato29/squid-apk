#/bin/sh
#
# purpose : create the Optware APK package file for the specified arch or all two of 'em
# version : 20131126-1
# author  : Thomas Kupper, thomas.kupper@gmail.com
#

APP_NAME=$(basename $0)
APP_PATH=$(dirname $(readlink -f $0))
APKGTOOL=$APP_PATH/apkg-tools.py

# echo "app name: $APP_NAME, app path: $APP_PATH, APKGTOOL: $APKGTOOL"
# exit

usage () { echo "usage: $APP_NAME [i386|x86-64|all]   Create package(s) for specified NAS arch(s)"
echo "       $APP_NAME i386                Create package for 32-bit based NAS (AS-20xT/TE and AS-30xT)"
echo "       $APP_NAME x86-64              Create package for 64-bit based NAS (AS-60xT)"
echo "       $APP_NAME all                 Create packages for both 32-bit and 64-bit based NAS"
echo "       $APP_NAME [--help|-h]         Shows this help :)"
echo
echo "creates Optware asustor package for the specified NAS architecture"
}

# check if we got root permissions
if [ ! "$(whoami)" = "root" ]; then
	echo "[ERROR] script has to be run as root!"
	usage
	exit 1
fi

# simplest command line argument handling
if [ $# -ne 1 ]; then
	echo "[ERROR] pass package arch as an argument"
	usage
	exit 2 
elif [ "$1" = "i386" -o "$1" = "x86-64" ]; then
	echo "[INFO] create package for asustor $1 NAS"
	APK_ARCH=$1
elif [ "$1" = "all" ]; then
	echo "[INFO] create package for $1 asustor NAS archs"
	APK_ARCH="i386 x86-64"
elif [ "$1" = "--help" -o "$1" = "-h" ]; then
	usage
	exit 0
else
	echo "[ERROR] invalid argument '$1'"
	usage
	exit 3
fi

BASE_DIR=$APP_PATH/..
SOURCE_DIR="${BASE_DIR}/source"
BUILD_DIR="${BASE_DIR}/build"
TMP_DIR=$(mktemp -d -t fluffyXXXXXX)

for arch in $APK_ARCH; do
	echo "[INFO] clean the output folder"
	if [ -d ${BUILD_DIR} ]; then
		rm -rf ${BUILD_DIR}/*
	else
		mkdir -p ${BUILD_DIR}
	fi
	echo "[INFO] copy the files for the specified arch to SOURCE directory"
	rsync -ar --files-from="${BASE_DIR}/filelist.${arch}" ${SOURCE_DIR}/ ${BUILD_DIR}/
	if [ $? -ne 0 ]; then
		echo "[ERROR] couldn't copy files... abort"
		exit 5
	fi
	echo "[INFO] set ${arch} in config.json"
	sed -i -e "s/##ARCH##/${arch}/" ${BUILD_DIR}/CONTROL/config.json
	if [ $? -ne 0 ]; then
		echo "[ERROR] couldn't set ${arch} in config.json... abort"
		exit 6
	fi
	echo "[INFO] rename arch dependence folder in build directory"
	for f in bin sbin libexec; do
		mv ${BUILD_DIR}/${f}-${arch} ${BUILD_DIR}/${f}
	done
	# mv ${BUILD_DIR}/bin-${arch} ${BUILD_DIR}/bin
	# mv ${BUILD_DIR}/lib-${arch} ${BUILD_DIR}/lib
	# apkg-tools.py is quite a simple script - doesn't allow any output
	# directory to be specified. So we have to do it yourselfs
	echo "[INFO] finally create the APK ${arch} package in ${TMP_DIR}"
	CUR_DIR=$PWD
	cd $TMP_DIR
	#chown -R root:root ${BUILD_DIR}/*
	chown -R 999:999 ${BUILD_DIR}/*
	$APKGTOOL create "${BUILD_DIR}"
	if [ $? -ne 0 ]; then
		cd $CUR_DIR
		echo "[ERROR] couldn't create APK for ${arch}... abort"
		exit 7
	fi
	echo "[INFO] copy and rename the created APK to ${CUR_DIR}"
	OUTPUT_FILE=$(basename *${arch}.apk)
	cp -a $TMP_DIR/*${arch}.apk $CUR_DIR/${OUTPUT_FILE%.apk}_$(date +"%Y%m%d-%H%M%S").apk
	rm -f $TMP_DIR/*${arch}.apk
	cd $CUR_DIR
done
