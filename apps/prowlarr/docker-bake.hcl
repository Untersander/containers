target "docker-metadata-action" {}

variable "APP" {
  default = "prowlarr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Prowlarr/Prowlarr versioning=loose
  default = "2.7.0.5723"
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
  tags = ["${APP}:${VERSION}"]
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
RUN --mount=from=tests,target=/tests bash /tests/startup.sh 9696
EOT
  output = ["type=cacheonly"]
}
