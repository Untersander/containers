target "docker-metadata-action" {}

// Same image as apps/sabnzbd
variable "APP" {
  default = "sabnzbd"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=sabnzbd/sabnzbd versioning=loose
  default = "5.2.0Beta2"
}

// Semver tag of the pre-release
variable "TAG" {
  default = lower(regex_replace(VERSION, "([A-Za-z]+)([0-9]+)$", "-$1.$2"))
}

variable "SOURCE" {
  default = "https://github.com/sabnzbd/sabnzbd"
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

// Needs --allow=fs.read=../../tests
target "test" {
  contexts = {
    app   = "target:image"
    tests = "../../tests"
  }
  dockerfile-inline = <<EOT
FROM app
RUN --mount=from=tests,target=/tests SABNZBD__PORT=18080 bash /tests/startup.sh 18080
EOT
  output = ["type=cacheonly"]
}
