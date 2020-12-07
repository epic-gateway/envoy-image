FROM envoyproxy/envoy:v1.16-latest

COPY config/egw-config.yaml /etc/envoy/envoy.yaml

RUN apt-get update && apt-get -q install -y \
    curl iproute2 tcpdump iputils-ping telnet

RUN setcap cap_net_bind_service=+ep /usr/local/bin/envoy