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

#### Using [Bazel](http://bazel.build)

Add the following to your WORKSPACE:

```
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "MOLCodesignChecker",
    remote = "https://github.com/google/macops-molcodesignchecker.git",
    tag = "v2.2",
)
```

And in your BUILD file, add MOLCodesignChecker as a dependency:

<pre>
objc_library(
    name = "MyAwesomeApp_lib",
    srcs = ["src/MyAwesomeApp.m", "src/MyAwesomeApp.h"],
    <strong>deps = ["@MOLCodesignChecker//:MOLCodesignChecker"],</strong>
)
</pre>

## Contributing

Patches to this library are very much welcome. Please see the
[CONTRIBUTING](https://github.com/google/macops-molcodesignchecker/blob/master/CONTRIBUTING.md)
file.
