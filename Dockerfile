FROM registry.gitlab.com/acnodal/envoy-for-egw:bare-v1.16.3 as acnodal
FROM envoyproxy/envoy:v1.17.1

COPY --from=acnodal /docker-entrypoint.sh /

# copy the bootstrap config to where envoy expects it to be
COPY config/epic-config.yaml /etc/envoy/envoy.yaml

# install some useful debugging tools
RUN apt-get update && apt-get -q install -y \
    curl iproute2 tcpdump iputils-ping telnet

RUN setcap cap_net_bind_service=+ep /usr/local/bin/envoy
