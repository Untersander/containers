target "docker-metadata-action" {}

// Same image as apps/radarr
variable "APP" {
  default = "radarr"
}

variable "VERSION" {
  // renovate: datasource=custom.servarr-develop depName=radarr versioning=loose
  default = "7.0.0.10815"
}

// Semver pre-release identifier, the build follows it: 7.0.0.10815 -> 7.0.0-dev.10815
variable "PRERELEASE" {
  default = "dev"
}

variable "SOURCE" {
  default = "https://github.com/Radarr/Radarr"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${regex_replace(VERSION, "\\.([0-9]+)$", "-${PRERELEASE}.$1")}"]
}

target "image-all" {
  inherits = ["image"]
  # buildkitd runs on cp-0 (amd64) without QEMU
  platforms = [
    "linux/amd64"
  ]
}
