load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "MOLCodesignChecker",
    srcs = ["Source/MOLCodesignChecker/MOLCodesignChecker.m"],
    hdrs = ["Source/MOLCodesignChecker/MOLCodesignChecker.h"],
    includes = ["Source"],
    sdk_frameworks = ["Security"],
    deps = ["@MOLCertificate//:MOLCertificate"],
    visibility = ["//visibility:public"],
)

objc_library(
    name = "MOLCodesignCheckerTestsLib",
    srcs = ["Tests/MOLCodesignCheckerTest.m"],
    resources = glob(["Tests/Resources/*"]),
    deps = [":MOLCodesignChecker"],
)

macos_unit_test(
    name = "MOLCodesignCheckerTests",
    minimum_os_version = "10.9",
    deps = [":MOLCodesignCheckerTestsLib"],
)

