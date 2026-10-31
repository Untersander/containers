target "docker-metadata-action" {}

// Same image as apps/radarr
variable "APP" {
  default = "radarr"
}

variable "VERSION" {
  // renovate: datasource=custom.servarr-develop depName=radarr versioning=loose
  default = "7.0.0.10815"
}

// Semver tag of the pre-release
variable "TAG" {
  default = regex_replace(VERSION, "\\.([0-9]+)$", "-dev.$1")
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
  tags = ["${APP}:${TAG}"]
}

target "image-all" {
  inherits = ["image"]
  # buildkitd runs on cp-0 (amd64) without QEMU
  platforms = [
    "linux/amd64"
  ]
}
