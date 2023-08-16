FROM envoyproxy/envoy:v1.23.2

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# install some useful debugging tools
RUN apt-get update && apt-get -q install -y \
    curl iproute2 tcpdump iputils-ping telnet jq socat

RUN setcap cap_net_bind_service=+ep /usr/local/bin/envoy

ADD https://github.com/projectcalico/calicoctl/releases/download/v3.18.4/calicoctl /usr/local/bin/calicoctl
RUN chmod +x /usr/local/bin/calicoctl
