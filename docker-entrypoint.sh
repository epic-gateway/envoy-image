#!/usr/bin/env sh
set -e

# Figure out eth0's IP address. This JQ query is more complex than it
# should be because the "ip" command in the Envoy pods outputs a
# couple of weird empty objects along with the eth0 object and we need
# to handle that.
ETH0_IP=$(ip -json addr show dev eth0 | jq --raw-output ".[].addr_info[] | select(.label==\"eth0\") | .local")
echo eth0 IP address: $ETH0_IP

# patch Marin3r's Envoy bootstrap config to bind the admin interface to eth0 only
sed --in-place=.bak "s/\"address\":\"0.0.0.0\"/\"address\":\"${ETH0_IP}\"/" /etc/envoy/bootstrap/config.json

# If this is a TrueIngress LB, then set up routes to send traffic by
# default through net1 (the TrueIngress/Multus interface) with pod and
# internal service network traffic going through eth0, the k8s
# interface. TrueIngress is the default, so it needs to be explicitly
# disabled.
if [ "$TRUEINGRESS" != "disabled" ] ; then
    # If the POD_CIDR env var is set then re-do the route that sends
    # internal pod traffic so it goes to the k8s/default interface
    if [ "X$POD_CIDR" != "X" ] ; then
        ip route del "$POD_CIDR"
        ip route add "$POD_CIDR" dev eth0
    fi

    # If the SERVICE_CIDR env var is set, add a route to send internal
    # service traffic to the k8s/default interface
    if [ "X$SERVICE_CIDR" != "X" ] ; then
        ip route add "$SERVICE_CIDR" dev eth0
    fi

    # If the HOST_IP env var is set, add a route to send internal
    # service traffic to the k8s/default interface
    if [ "X$HOST_IP" != "X" ] ; then
        ip route add "$HOST_IP" dev eth0
    fi

    # set up routes to send traffic by default through net1
    ip route delete 0.0.0.0/0
    ip route add 0.0.0.0/0 dev net1
fi

loglevel="${loglevel:-}"

# if the first argument look like a parameter (i.e. start with '-'), run Envoy
if [ "${1#-}" != "$1" ]; then
        set -- envoy "$@"
fi

if [ "$1" = 'envoy' ]; then
        # set the log level if the $loglevel variable is set
        if [ -n "$loglevel" ]; then
                set -- "$@" --log-level "$loglevel"
        fi
fi

if [ "$ENVOY_UID" != "0" ]; then
    if [ -n "$ENVOY_UID" ]; then
        usermod -u "$ENVOY_UID" envoy
    fi
    if [ -n "$ENVOY_GID" ]; then
        groupmod -g "$ENVOY_GID" envoy
    fi
    # Ensure the envoy user is able to write to container logs
    chown envoy:envoy /dev/stdout /dev/stderr
    su-exec envoy "${@}"
else
    exec "${@}"
fi
