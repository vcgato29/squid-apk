#!/bin/sh

export PKG_NAME="Squid"
export PKG_ETC_DIR="$APKG_PKG_DIR/etc"
export PKG_VAR_DIR="$APKG_PKG_DIR/var"

export USER=admin
export GROUP=administrators

case "$APKG_PKG_STATUS" in
		install|upgrade)
				if [ "$APKG_PKG_STATUS" = "upgrade" ]; then
					cp -aRf $APKG_TEMP_DIR/* $APKG_PKG_DIR/
				fi
				ln -s $APKG_PKG_DIR/libexec/cachemgr.cgi $APKG_PKG_DIR/www/index.cgi
				chown -R $USER:$GROUP $APKG_PKG_DIR/
				;;
		*)
				;;
esac

mkdir -p $PKG_TMP_DIR

exit 0
