#!/bin/sh

export PKG_ETC_DIR="$APKG_PKG_DIR/etc"

case "$APKG_PKG_STATUS" in
	install)
		;;
	upgrade)
		cp -af $PKG_ETC_DIR/* $APKG_TEMP_DIR
		;;
	*)
		;;
esac

exit 0
