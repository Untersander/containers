# syntax=docker/dockerfile:1

FROM docker.io/library/alpine:3.24.4@sha256:93b41ef40b1677fce8fcc64ff4af09daddfacf5040afde618bc46c1e2d1cc7d4
ARG TARGETARCH
ARG VERSION

# Stable releases, unlike home-operations/containers, which builds develop
ENV DOTNET_EnableDiagnostics=0 \
    PROWLARR__UPDATE__BRANCH=master

USER root
WORKDIR /app

RUN \
    apk add --no-cache --upgrade \
        bash \
        ca-certificates \
        catatonit \
        coreutils \
        curl \
        icu-libs \
        jq \
        libintl \
        nano \
        tzdata \
    && mkdir -p /app/bin \
    && curl -fsSL "https://github.com/Prowlarr/Prowlarr/releases/download/v${VERSION}/Prowlarr.${PROWLARR__UPDATE__BRANCH}.${VERSION}.linux-musl-core-${TARGETARCH/amd64/x64}.tar.gz" \
        | tar xzf - -C /app/bin --strip-components=1 \
    && printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[Untersander](https://github.com/Untersander)\n" "${PROWLARR__UPDATE__BRANCH}" "${VERSION}" > /app/package_info \
    && chown -R root:root /app && chmod -R 755 /app \
    && rm -rf /tmp/* /app/bin/Prowlarr.Update

COPY entrypoint.sh /entrypoint.sh

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]
