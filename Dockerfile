FROM registry.gitlab.com/acnodal/envoy-for-egw:bare-v1.16.3

# copy the bootstrap config to where envoy expects it to be
COPY config/egw-config.yaml /etc/envoy/envoy.yaml

# experiment with envoy disk_layer runtime config overrides. we'll set
# up one override in the v0 directory and you can move the softlink to
# v1 or v2 to change to different sets of overrides.
#
# For example:
# $ kubectl exec -n egw-sample -it pod/envoy-sample-acnodal-59f994dddd-f72qb -- /bin/bash -l
# # cd /etc/envoy/overrides
# # mkdir v1/health_check
# # echo 42 > v1/health_check/min_interval
# # ln -s v1 new
# # mv -Tf new current
#
# https://www.envoyproxy.io/docs/envoy/latest/configuration/operations/runtime#updating-runtime-values-via-symbolic-link-swap
# this example overrides the health_check.min_interval parameter
WORKDIR /etc/envoy/overrides
RUN mkdir -p v0/health_check
RUN echo 27 > v0/health_check/min_interval
RUN ln -s v0 current
RUN mkdir -p v1 v2

# install some useful debugging tools
RUN apt-get update && apt-get -q install -y \
    curl iproute2 tcpdump iputils-ping telnet

RUN setcap cap_net_bind_service=+ep /usr/local/bin/envoy
