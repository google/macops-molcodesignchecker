load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "build_bazel_rules_apple",
    sha256 = "8ac4c7997d863f3c4347ba996e831b5ec8f7af885ee8d4fe36f1c3c8f0092b2c",
    url = "https://github.com/bazelbuild/rules_apple/releases/download/2.5.0/rules_apple.2.5.0.tar.gz",
)

load("@build_bazel_rules_apple//apple:repositories.bzl", "apple_rules_dependencies")

apple_rules_dependencies()

git_repository(
    name = "MOLCertificate",
    remote = "https://github.com/google/macops-molcertificate.git",
    tag = "v2.1",
)
