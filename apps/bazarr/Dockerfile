# syntax=docker/dockerfile:1

FROM docker.io/library/python:3.14.10-alpine3.24@sha256:a18b20ad69e74df6cf6d2e1b1a260d7a1ecf5380fd83b310f83ba88c461cf894
ARG VERSION

ENV \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_NO_CACHE=true \
    UV_SYSTEM_PYTHON=true \
    UV_EXTRA_INDEX_URL="https://wheel-index.linuxserver.io/alpine-3.24/"

ENV \
    BAZARR__PORT=6767 \
    BAZARR_PACKAGE_AUTHOR=Untersander \
    BAZARR_PACKAGE_VERSION=${VERSION} \
    BAZARR_VERSION=${VERSION}

USER root
WORKDIR /app

RUN \
    apk add --no-cache --upgrade \
        bash \
        ca-certificates \
        catatonit \
        coreutils \
        curl \
        ffmpeg \
        jq \
        libxml2 \
        libpq \
        libxslt \
        mediainfo \
        nano \
        trurl \
        tzdata \
        unzip \
    && \
    apk add --no-cache --virtual .build-deps \
        build-base \
        cargo \
        libffi-dev \
        libpq-dev \
        libxml2-dev \
        libxslt-dev \
    && \
    curl -fsSL -o /tmp/app.zip "https://github.com/morpheus65535/bazarr/releases/download/${VERSION}/bazarr.zip" \
    && unzip -q /tmp/app.zip -d /app/bin \
    && sed -i '/Pillow>/s/ --only-binary=Pillow//; /Pillow>/a --only-binary=Pillow' /app/bin/requirements.txt \
    && pip install uv \
    && uv pip install \
        --requirement /app/bin/requirements.txt \
        --requirement /app/bin/postgres-requirements.txt \
    && chown -R root:root /app && chmod -R 755 /app \
    && pip uninstall --yes uv && apk del --purge .build-deps \
    && rm -rf /root/.cache /root/.cargo /tmp/* /app/bin/bin

COPY entrypoint.sh /entrypoint.sh

COPY --from=ghcr.io/linuxserver/unrar:7.2.7@sha256:48c0ce2609bb3c35764956bbd9395e95b177421e3c74b3628c3676029f24f2e0 /usr/bin/unrar-alpine /usr/bin/unrar

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]
