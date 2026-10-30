target "docker-metadata-action" {}

// Same image as apps/sonarr
variable "APP" {
  default = "sonarr"
}

variable "VERSION" {
  // renovate: datasource=custom.sonarr-develop depName=sonarr versioning=loose
  default = "5.0.0.2870"
}

// Semver pre-release identifier, the build follows it: 5.0.0.2870 -> 5.0.0-dev.2870
variable "PRERELEASE" {
  default = "dev"
}

variable "SOURCE" {
  default = "https://github.com/Sonarr/Sonarr"
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
