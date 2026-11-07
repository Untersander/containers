target "docker-metadata-action" {}

// Same image as apps/bazarr
variable "APP" {
  default = "bazarr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=morpheus65535/bazarr
  default = "v1.6.3-beta.27"
}

// Semver tag of the pre-release
variable "TAG" {
  default = regex_replace(VERSION, "^v", "")
}

variable "SOURCE" {
  default = "https://github.com/morpheus65535/bazarr"
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
RUN --mount=from=tests,target=/tests BAZARR__PORT=16767 bash /tests/startup.sh 16767
EOT
  output = ["type=cacheonly"]
}
