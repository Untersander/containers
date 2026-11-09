target "docker-metadata-action" {}

// Same image as apps/radarr
variable "APP" {
  default = "radarr"
}

variable "VERSION" {
  // renovate: datasource=custom.servarr-develop depName=radarr versioning=loose
  default = "7.0.2.10888"
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

// Needs --allow=fs.read=../../tests
target "test" {
  contexts = {
    app   = "target:image"
    tests = "../../tests"
  }
  dockerfile-inline = <<EOT
FROM app
RUN --mount=from=tests,target=/tests RADARR__SERVER__PORT=17878 bash /tests/startup.sh 17878
EOT
  output = ["type=cacheonly"]
}
