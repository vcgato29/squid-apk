#!/bin/sh -e
export HOST_ARCH=$(uname -m)
export NAME="Squid"

#export PKG_PATH=/usr/local/AppCentral/pyload
# APKG_PGK_DIR seems not to be set :/
export APKG_PKG_DIR=/usr/local/AppCentral/squid
export PKG_DAEMON=${APKG_PKG_DIR}/sbin/squid

export USER=admin
export GROUP=administrators
export STOP_TIMEOUT=10

#export PATH="${PATH:+$PKG_PATH:}/sbin"
#export LD_LIBRARY_PATH="$PKG_PATH/lib"
export PATH="${APKG_PKG_DIR}/bin:${APKG_PKG_DIR}/sbin:$PATH"

export OPTIONS="-f ${APKG_PKG_DIR}/etc/squid.conf "

. /lib/lsb/init-functions

start_daemon () {
    start-stop-daemon --start \
    --chuid ${USER}:${GROUP} \
    --exec $PKG_DAEMON -- $OPTIONS
}

wait_pid () {
    DAEMON=`basename $1`
    TIME=0
    TIMEOUT=$2

    while [ $TIME -lt $TIMEOUT ]; do
        pidof $DAEMON > /dev/null 2>&1
        STATUS=`echo $?`

        if [ $STATUS -eq 1 ]; then
            break 1
        fi

        TIME=$((TIME+1))
        sleep 1
    done
}

case "$1" in
    start)
        echo "Starting $NAME"
        #start_daemon
        if [ ! -f $APKG_PKG_DIR/var/cache/squid/.initialized ]; then
            su -c "$PKG_DAEMON $OPTIONS -z" - admin
            touch $APKG_PKG_DIR/var/cache/squid/.initialized
        fi
        su -c "$PKG_DAEMON $OPTIONS" - admin
        ;;
    stop)
        echo "Stopping $NAME"
        #$PKG_DAEMON $OPTIONS -k shutdown
        su -c "$PKG_DAEMON $OPTIONS -k shutdown" - admin
        ;;
    restart|force-reload)
        echo "Restarting $NAME"
        $PKG_DAEMON $OPTIONS -k shutdown
        wait_pid $PKG_DAEMON $STOP_TIMEOUT
        start_daemon
        ;;
    *)
        echo "Usage: $0 {start|stop|force-reload|restart}"
        exit 2
        ;;
esac

exit 0
