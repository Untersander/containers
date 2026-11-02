target "docker-metadata-action" {}

// Same image as apps/sonarr
variable "APP" {
  default = "sonarr"
}

variable "VERSION" {
  // renovate: datasource=custom.sonarr-develop depName=sonarr versioning=loose
  default = "5.0.0.2907"
}

// Semver tag of the pre-release
variable "TAG" {
  default = regex_replace(VERSION, "\\.([0-9]+)$", "-dev.$1")
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
RUN --mount=from=tests,target=/tests SONARR__SERVER__PORT=18989 bash /tests/startup.sh 18989
EOT
  output = ["type=cacheonly"]
}
