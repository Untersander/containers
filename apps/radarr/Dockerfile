# syntax=docker/dockerfile:1

FROM docker.io/library/alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf
ARG TARGETARCH
ARG VERSION

# Stable releases, unlike home-operations/containers, which builds develop
ENV DOTNET_EnableDiagnostics=0 \
    RADARR__UPDATE__BRANCH=master

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
        krb5-libs \
        libintl \
        nano \
        tzdata \
    && mkdir -p /app/bin \
    && curl -fsSL "https://github.com/Radarr/Radarr/releases/download/v${VERSION}/Radarr.${RADARR__UPDATE__BRANCH}.${VERSION}.linux-musl-core-${TARGETARCH/amd64/x64}.tar.gz" \
        | tar xzf - -C /app/bin --strip-components=1 \
    && printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[Untersander](https://github.com/Untersander)\n" "${RADARR__UPDATE__BRANCH}" "${VERSION}" > /app/package_info \
    && chown -R root:root /app && chmod -R 755 /app \
    && rm -rf /tmp/* /app/bin/Radarr.Update

COPY entrypoint.sh /entrypoint.sh

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]
