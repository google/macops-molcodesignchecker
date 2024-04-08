# MOLCodesignChecker

Provides an easy way to do code signature validation in Objective-C

## Usage

```objc
#import <MOLCertificate/MOLCertificate.h>
#import <MOLCodesignChecker/MOLCodesignChecker.h>

- (BOOL)validateMySignature {
  MOLCodesignChecker *csInfo = [[MOLCodesignChecker alloc] initWithSelf];
  if (csInfo) {
    // I'm signed! Check the certificate
    NSLog(@"%@, %@", csInfo.leafCertificate, csInfo.leafCertificate.SHA256);
    return YES;
  }
  return NO;
}

- (BOOL)validateFile:(NSString *)filePath {
  MOLCodesignChecker *csInfo = [[MOLCodesignChecker alloc] initWithBinaryPath:filePath];
  if (csInfo) {
    // I'm signed! Check the certificate
    NSLog(@"%@, %@", csInfo.leafCertificate, csInfo.leafCertificate.SHA256);
    return YES;
  }
  return NO;
}
```

## Installation

#### Using [Bazel](http://bazel.build) Modules

Add the following to your MODULE.bazel:

```bazel
bazel_dep("molcodesignchecker", version = "3.0")
git_override(
    module_name = "molcodesignchecker",
    remote = "https://github.com/google/macops-molcodesignchecker.git",
    tag = "v3.0",
)
```

#### Using [Bazel](http://bazel.build) WORKSPACE

Add the following to your WORKSPACE:

```
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "MOLCodesignChecker",
    remote = "https://github.com/google/macops-molcodesignchecker.git",
    tag = "v3.0",
)
```

### Adding dependency in BUILD

In your BUILD file, add MOLCodesignChecker as a dependency:

<pre>
objc_library(
    name = "MyAwesomeApp_lib",
    srcs = ["src/MyAwesomeApp.m", "src/MyAwesomeApp.h"],
    <strong>deps = ["@molcodesignchecker//:MOLCodesignChecker"],</strong>
)
</pre>

## Contributing

Patches to this library are very much welcome. Please see the
[CONTRIBUTING](https://github.com/google/macops-molcodesignchecker/blob/master/CONTRIBUTING.md)
file.
