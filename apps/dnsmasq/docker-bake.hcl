target "docker-metadata-action" {}

variable "APP" {
  default = "dnsmasq"
}

variable "VERSION" {
  // renovate: datasource=repology depName=alpine_3_24/dnsmasq-dnssec-nftset versioning=apk
  default = "2.92_p2-r0"
}

variable "SOURCE" {
  default = "https://thekelleys.org.uk/dnsmasq/doc.html"
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
