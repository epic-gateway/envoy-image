FROM envoyproxy/envoy:v1.14.1


RUN apt-get update && apt-get -q install -y \
    curl iproute2 tcpdump iputils-ping