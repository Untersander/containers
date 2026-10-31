# containers

Container images for [home-ops](https://github.com/Untersander/home-ops), based on [home-operations/containers](https://github.com/home-operations/containers): one folder per app or release channel in [`apps/`](./apps) with a `Dockerfile` and a `docker-bake.hcl`, whose `VERSION` Renovate keeps up to date.

The source is on the cluster's Forgejo (`git.k8s.garden/jan/containers`) and mirrored to [github.com/Untersander/containers](https://github.com/Untersander/containers).

| App | Image | Contents |
| --- | --- | --- |
| [dnsmasq](./apps/dnsmasq) | `ghcr.io/untersander/dnsmasq`, `git.k8s.garden/jan/dnsmasq` | Alpine's `dnsmasq-dnssec-nftset` (dnsmasq with nftables sets), entrypoint `dnsmasq --keep-in-foreground` |
| [bazarr](./apps/bazarr) | `ghcr.io/untersander/bazarr`, `git.k8s.garden/jan/bazarr` | Stable GitHub release |
| [bazarr-develop](./apps/bazarr-develop) | Same image, pre-release tags | GitHub pre-release |
| [prowlarr](./apps/prowlarr) | `ghcr.io/untersander/prowlarr`, `git.k8s.garden/jan/prowlarr` | Stable GitHub release (`master` branch) |
| [prowlarr-develop](./apps/prowlarr-develop) | Same image, pre-release tags | Pre-release (`develop` branch) |
| [radarr](./apps/radarr) | `ghcr.io/untersander/radarr`, `git.k8s.garden/jan/radarr` | Stable GitHub release (`master` branch) |
| [radarr-develop](./apps/radarr-develop) | Same image, pre-release tags | Pre-release (`develop` branch) |
| [sabnzbd](./apps/sabnzbd) | `ghcr.io/untersander/sabnzbd`, `git.k8s.garden/jan/sabnzbd` | Stable GitHub release |
| [sabnzbd-develop](./apps/sabnzbd-develop) | Same image, pre-release tags | GitHub pre-release |
| [sonarr](./apps/sonarr) | `ghcr.io/untersander/sonarr`, `git.k8s.garden/jan/sonarr` | Stable GitHub release (`main` branch) |
| [sonarr-develop](./apps/sonarr-develop) | Same image, pre-release tags | Pre-release (`develop` branch) |

## Tags

Like home-operations: the semantic version (`2.92.0`), the upstream version without the Alpine release (`2.92_p2`) and `rolling`.
Rebuilds (new Alpine base, new `-rN` package) overwrite the tags, so pin the digest: `ghcr.io/untersander/dnsmasq:2.92.0@sha256:...`.

Pre-releases are semver, from `TAG` in the bake file, plus `rolling-dev`: `5.0.0-dev.2870` for Sonarr, Radarr and Prowlarr, `1.6.3-beta.23` for Bazarr and `5.2.0-beta.2` for SABnzbd (upstream `5.2.0Beta2`). Semver has no fourth number and Docker tags can't contain `+`, so the upstream build number is the last pre-release identifier.

Stable tags need no Renovate rule: docker versioning, Renovate's default, ignores `-dev` tags as another flavour of the image. To follow pre-releases, use a three-part or pre-release tag and add this rule in the repository that uses the image:

```json5
{
  description: 'Follow Sonarr pre-releases',
  matchPackageNames: ['ghcr.io/untersander/sonarr'],
  versioning: 'semver',
  ignoreUnstable: false,
}
```

| Tag | Without the rule | With the rule |
| --- | --- | --- |
| `4.0.20` | Stable releases | Stable releases and pre-releases |
| `5.0.0-dev.2870` | No updates | Stable releases and pre-releases |
| `4.0.20.3014` | Stable releases | No updates, not semver |

A stable release sorts above its own pre-releases, so `4.0.19-dev.3011` is skipped if `4.0.19` is already out, and following resumes at the next pre-release of a higher version.

## Builds

[`.forgejo/workflows/release.yaml`](./.forgejo/workflows/release.yaml) runs on pushes that change `apps/` and builds each changed app on the rootless buildkitd in the cluster (home-ops [`apps/buildkit`](https://github.com/Untersander/home-ops/tree/main/apps/buildkit)).
The runner has no Docker, so the job uses a standalone `buildx` with the remote driver and the bake files work the same as locally.

- `main`: build and push to both registries.
- Other branches (Renovate): build only. Renovate automerges app updates once this build has passed.
- Manual: Actions → Release → Run workflow, with the app name (optionally without cache).

Build locally with Docker:

```bash
cd apps/dnsmasq
docker buildx bake                     # image-local: dnsmasq:<version> in the local Docker
docker run --rm dnsmasq:2.92_p2-r0 --version
```

## Renovate

[`.forgejo/workflows/renovate.yaml`](./.forgejo/workflows/renovate.yaml) runs nightly, with the rules in [`.renovaterc.json5`](./.renovaterc.json5).
Package versions come from Repology (`alpine_3_24/<package>`). When the Alpine base moves to a new minor, update these names and `allowedVersions` together.
Stable versions come from GitHub releases, where Renovate skips releases marked as pre-release. The Sonarr, Radarr and Prowlarr `-develop` apps follow the `develop` branch through the Servarr update services (`customDatasources`, same as home-operations). A new Sonarr major needs a bump of `version=` in `sonarr-develop`. The Bazarr and SABnzbd `-develop` apps take only the pre-releases from GitHub.

## Setup

1. Actions on: repository → Settings → Units → Actions.
2. Secrets (repository → Settings → Actions → Secrets, or once for all repositories under user settings):

   | Secret | Value |
   | --- | --- |
   | `REGISTRY_TOKEN` | Forgejo access token with `package` read/write |
   | `GHCR_TOKEN` | GitHub classic token with `write:packages` |
   | `RENOVATE_TOKEN` | Forgejo access token with repository and issue read/write |
   | `RENOVATE_GITHUB_COM_TOKEN` | GitHub token without scopes (presets, release notes, rate limits) |

3. Mirror to GitHub: repository → Settings → Repository → Push mirrors, `https://github.com/Untersander/containers.git` with a GitHub token that can push to it.
4. After the first push of a new app: on GitHub, set the ghcr.io package visibility to public (Package settings → Change visibility). Packages pushed with a token start out private. The `org.opencontainers.image.source` label links the package to the GitHub repository.
