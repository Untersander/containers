#!/usr/bin/env bash
# The runner has no Docker: standalone buildx with the remote driver, so the bake files work as with
# `docker buildx bake` locally
set -euo pipefail

cd /usr/local/bin
curl -fsSLo "buildx-${BUILDX_VERSION}.linux-amd64" \
  "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64"
curl -fsSL "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/checksums.txt" \
  | grep " \*buildx-${BUILDX_VERSION}.linux-amd64$" | sha256sum -c
mv "buildx-${BUILDX_VERSION}.linux-amd64" buildx
chmod +x buildx
buildx create --name buildkitd --driver remote --use tcp://buildkitd.buildkit.svc.cluster.local:1234
buildx inspect --bootstrap
