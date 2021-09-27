FROM envoyproxy/envoy:v1.17.1

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# copy the bootstrap config to where envoy expects it to be
COPY config/epic-config.yaml /etc/envoy/envoy.yaml

# install some useful debugging tools
RUN apt-get update && apt-get -q install -y \
    curl iproute2 tcpdump iputils-ping telnet jq

RUN setcap cap_net_bind_service=+ep /usr/local/bin/envoy

ADD https://github.com/projectcalico/calicoctl/releases/download/v3.18.4/calicoctl /usr/local/bin/calicoctl
RUN chmod +x /usr/local/bin/calicoctl
