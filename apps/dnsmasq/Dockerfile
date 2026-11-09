# syntax=docker/dockerfile:1

FROM docker.io/library/alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf
ARG VERSION
# The nftset build is the reason for this image (nftset= for allowlists), fail if the option is missing
RUN \
    apk add --no-cache dnsmasq-dnssec-nftset="${VERSION}" \
    && dnsmasq --version | grep -q ' nftset' \
    && rm -rf /tmp/*
ENTRYPOINT ["/usr/sbin/dnsmasq", "--keep-in-foreground"]
