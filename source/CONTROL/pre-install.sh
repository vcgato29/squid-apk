#!/bin/sh

export PKG_ETC_DIR="$APKG_PKG_DIR/etc"
export PKG_VAR_DIR="$APKG_PKG_DIR/var"

case "$APKG_PKG_STATUS" in
	install)
		;;
	upgrade)
		cp -aRf $PKG_ETC_DIR $APKG_TEMP_DIR
		cp -aRf $PKG_VAR_DIR $APKG_TEMP_DIR
		;;
	*)
		;;
esac

exit 0
