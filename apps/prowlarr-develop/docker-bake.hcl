target "docker-metadata-action" {}

// Same image as apps/prowlarr
variable "APP" {
  default = "prowlarr"
}

variable "VERSION" {
  // renovate: datasource=custom.servarr-develop depName=prowlarr versioning=loose
  default = "3.0.1.5752"
}

// Semver tag of the pre-release
variable "TAG" {
  default = regex_replace(VERSION, "\\.([0-9]+)$", "-dev.$1")
}

variable "SOURCE" {
  default = "https://github.com/Prowlarr/Prowlarr"
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
RUN --mount=from=tests,target=/tests PROWLARR__SERVER__PORT=19696 bash /tests/startup.sh 19696
EOT
  output = ["type=cacheonly"]
}
