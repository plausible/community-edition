#!/bin/sh
set -e
CONFDIR=/etc/exim4

# By default, send email directly to the recipient.
DC_EXIMCONFIG_CONFIGTYPE="internet"

# By default, only hosts on the private network can use the smart host (ie,
# only other containers, not the whole internet); a thin layer of protection
# in case port 25 is accidentally exposed to the public internet.
DC_RELAY_NETS="10.0.0.0/8;172.16.0.0/12;192.168.0.0/16"

# If RELAY_HOST has been set then switch to smart host configuration.
if [ "x$RELAY_HOST" != "x" ]; then
    DC_EXIMCONFIG_CONFIGTYPE="satellite"
    DC_SMARTHOST="$RELAY_HOST::${RELAY_PORT:-25}"
    if [ "x$RELAY_USERNAME" != "x" ] && [ "x$RELAY_PASSWORD" != "x" ]; then
        printf '%s\n' "*:$RELAY_USERNAME:$RELAY_PASSWORD" > "$CONFDIR/passwd.client"
    fi
fi

# Set which hosts can use the smart host.
if [ "x$RELAY_NETS" != "x" ]; then
    DC_RELAY_NETS="$RELAY_NETS"
fi

# Write exim configuration.
cat << EOF > "$CONFDIR/update-exim4.conf.conf"
dc_eximconfig_configtype='$DC_EXIMCONFIG_CONFIGTYPE'
dc_other_hostnames=''
dc_local_interfaces=''
dc_readhost=''
dc_relay_domains=''
dc_minimaldns='false'
dc_relay_nets='$DC_RELAY_NETS'
dc_smarthost='${DC_SMARTHOST:-}'
CFILEMODE='644'
dc_use_split_config='false'
dc_hide_mailname='true'
dc_mailname_in_oh='true'
dc_localdelivery='mail_spool'
EOF

# Set primary_hostname.
if [ "x$MAILNAME" != "x" ]; then
    printf '%s\n' "$MAILNAME" > /etc/mailname
    printf '%s\n' "MAIN_HARDCODE_PRIMARY_HOSTNAME=$MAILNAME" >> "$CONFDIR/update-exim4.conf.conf"
fi

# Apply exim configuration.
update-exim4.conf

exec "$@"
