# syntax=docker/dockerfile:1

FROM docker.io/library/alpine:3.24.4@sha256:93b41ef40b1677fce8fcc64ff4af09daddfacf5040afde618bc46c1e2d1cc7d4
ARG VERSION
# The nftset build is the reason for this image (nftset= for allowlists), fail if the option is missing
RUN \
    apk add --no-cache dnsmasq-dnssec-nftset="${VERSION}" \
    && dnsmasq --version | grep -q ' nftset' \
    && rm -rf /tmp/*
ENTRYPOINT ["/usr/sbin/dnsmasq", "--keep-in-foreground"]
