# syntax=docker/dockerfile:1

FROM docker.io/library/alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a
ARG VERSION
# The nftset build is the reason for this image (nftset= for allowlists), fail if the option is missing
RUN \
    apk add --no-cache dnsmasq-dnssec-nftset="${VERSION}" \
    && dnsmasq --version | grep -q ' nftset' \
    && rm -rf /tmp/*
ENTRYPOINT ["/usr/sbin/dnsmasq", "--keep-in-foreground"]
