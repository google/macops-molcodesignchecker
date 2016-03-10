/// Copyright 2015 Google Inc. All rights reserved.
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///    http://www.apache.org/licenses/LICENSE-2.0
///
///    Unless required by applicable law or agreed to in writing, software
///    distributed under the License is distributed on an "AS IS" BASIS,
///    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///    See the License for the specific language governing permissions and
///    limitations under the License.

#import "MOLCodesignChecker.h"

#import <MOLCertificate/MOLCertificate.h>
#import <Security/Security.h>

/**
  kStaticSigningFlags are the flags used when validating signatures on disk.

  Don't validate resources but do validate nested code. Ignoring resources _dramatically_ speeds
  up validation (see below) but does mean images, plists, etc will not be checked and modifying
  these will not be considered invalid. To ensure any code inside the binary is still checked,
  we check nested code.

  Timings with different flags:
    Checking Xcode 5.1.1 bundle:
       kSecCSDefaultFlags:                                   3.895s
       kSecCSDoNotValidateResources:                         0.013s
       kSecCSDoNotValidateResources | kSecCSCheckNestedCode: 0.013s

    Checking Google Chrome 36.0.1985.143 bundle:
       kSecCSDefaultFlags:                                   0.529s
       kSecCSDoNotValidateResources:                         0.032s
       kSecCSDoNotValidateResources | kSecCSCheckNestedCode: 0.033s
*/
static const SecCSFlags kStaticSigningFlags = kSecCSDoNotValidateResources | kSecCSCheckNestedCode;

/**
  kSigningFlags are the flags used when validating signatures for running binaries.

  No special flags needed currently.
*/
static const SecCSFlags kSigningFlags = kSecCSDefaultFlags;

@interface MOLCodesignChecker ()
/// Array of `MOLCertificate's` representing the chain of certs the represented
/// executable was signed with.
@property NSMutableArray *certificates;

/// Cached designated requirement
@property SecRequirementRef requirement;
@end

@implementation MOLCodesignChecker

#pragma mark Init/dealloc

- (instancetype)initWithSecStaticCodeRef:(SecStaticCodeRef)codeRef error:(NSError **)error {
  self = [super init];

  if (self) {
    OSStatus status = errSecSuccess;
    CFErrorRef cfError = NULL;

    // First check the signing is valid.
    if (CFGetTypeID(codeRef) == SecStaticCodeGetTypeID()) {
      status = SecStaticCodeCheckValidityWithErrors(codeRef, kStaticSigningFlags, NULL, &cfError);
    } else if (CFGetTypeID(codeRef) == SecStaticCodeGetTypeID()) {
      status = SecCodeCheckValidityWithErrors((SecCodeRef)codeRef, kSigningFlags, NULL, &cfError);
    }

    if (status != errSecSuccess) {
      if (error) {
        *error = CFBridgingRelease(cfError);
      }
    }

    // Get CFDictionary of signing information for binary
    CFDictionaryRef signingDict = NULL;
    status = SecCodeCopySigningInformation(codeRef, kSecCSSigningInformation, &signingDict);
    _signingInformation = CFBridgingRelease(signingDict);

    // Get array of certificates.
    NSArray *certs = _signingInformation[(id)kSecCodeInfoCertificates];
    _certificates = [MOLCertificate certificatesFromArray:certs];

    _codeRef = codeRef;
    CFRetain(_codeRef);
  }

  return self;
}

- (instancetype)initWithSecStaticCodeRef:(SecStaticCodeRef)codeRef {
  NSError *error;
  self = [self initWithSecStaticCodeRef:codeRef error:&error];
  return (error) ? nil : self;
}

- (instancetype)initWithBinaryPath:(NSString *)binaryPath error:(NSError **)error {
  OSStatus status = errSecSuccess;
  SecStaticCodeRef codeRef = NULL;

  // Get SecStaticCodeRef for binary
  status = SecStaticCodeCreateWithPath((__bridge CFURLRef)[NSURL fileURLWithPath:binaryPath],
                                       kSecCSDefaultFlags, &codeRef);
  if (status != errSecSuccess) {
    if (error) {
      *error = [self errorWithCode:status];
    }
    return nil;
  }

  self = [self initWithSecStaticCodeRef:codeRef error:error];
  if (codeRef) CFRelease(codeRef);  // it was retained above
  return self;
}

- (instancetype)initWithBinaryPath:(NSString *)binaryPath {
  NSError *error;
  self = [self initWithBinaryPath:binaryPath error:&error];
  return (error) ? nil : self;
}

- (instancetype)initWithPID:(pid_t)pid error:(NSError **)error {
  OSStatus status = errSecSuccess;
  SecCodeRef codeRef = NULL;
  NSDictionary *attributes = @{ (__bridge NSString *)kSecGuestAttributePid : @(pid) };

  status = SecCodeCopyGuestWithAttributes(NULL, (__bridge CFDictionaryRef)attributes,
                                          kSecCSDefaultFlags, &codeRef);
  if (status != errSecSuccess) {
    if (error) {
      *error = [self errorWithCode:status];
    }
    return nil;
  }

  self = [self initWithSecStaticCodeRef:codeRef error:error];
  if (codeRef) CFRelease(codeRef);  // it was retained above
  return self;
}

- (instancetype)initWithPID:(pid_t)pid {
  NSError *error;
  self = [self initWithPID:pid error:&error];
  return (error) ? nil : self;
}

- (instancetype)initWithSelfError:(NSError **)error {
  SecCodeRef codeSelf = NULL;
  OSStatus status = SecCodeCopySelf(kSecCSDefaultFlags, &codeSelf);

  if (status != errSecSuccess) {
    if (error) {
      *error = [self errorWithCode:status];
    }
    return nil;
  }

  self = [self initWithSecStaticCodeRef:codeSelf error:error];
  if (codeSelf) CFRelease(codeSelf);  // it was retained above
  return self;
}

- (instancetype)initWithSelf {
  NSError *error;
  self = [self initWithSelfError:&error];
  return (error) ? nil : self;
}

- (instancetype)init {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)dealloc {
  if (_codeRef) {
    CFRelease(_codeRef);
    _codeRef = NULL;
  }
  if (_requirement) {
    CFRelease(_requirement);
    _requirement = NULL;
  }
}

#pragma mark Description

- (NSString *)description {
  NSString *binarySource;
  if (CFGetTypeID(self.codeRef) == SecStaticCodeGetTypeID()) {
    binarySource = @"On-disk";
  } else {
    binarySource = @"In-memory";
  }

  return [NSString stringWithFormat:@"%@ binary, signed by %@, located at: %@",
              binarySource, self.leafCertificate.orgName, self.binaryPath];
}

#pragma mark Public accessors

- (SecRequirementRef)requirement {
  if (!_requirement) {
    SecCodeCopyDesignatedRequirement(self.codeRef, kSecCSDefaultFlags, &_requirement);
  }
  return _requirement;
}

- (MOLCertificate *)leafCertificate {
  return [self.certificates firstObject];
}

- (NSString *)binaryPath {
  CFURLRef path;
  OSStatus status = SecCodeCopyPath(self.codeRef, kSecCSDefaultFlags, &path);
  NSURL *pathURL = CFBridgingRelease(path);
  if (status != errSecSuccess) return nil;
  return [pathURL path];
}

- (BOOL)signingInformationMatches:(MOLCodesignChecker *)otherChecker {
  return [self.certificates isEqual:otherChecker.certificates];
}

- (BOOL)validateWithRequirement:(SecRequirementRef)requirement {
  if (!requirement) return NO;
  return (SecStaticCodeCheckValidity(self.codeRef, kStaticSigningFlags,
                                     requirement) == errSecSuccess);
}

#pragma mark Private

- (NSError *)errorWithCode:(OSStatus)code {
  CFStringRef cfErrorString = SecCopyErrorMessageString(code, NULL);
  NSString *errorStr = CFBridgingRelease(cfErrorString);

  NSDictionary *userInfo = @{
    NSLocalizedDescriptionKey: errorStr
  };

  return [NSError errorWithDomain:@"com.google.molcodesignchecker" code:code userInfo:userInfo];
}

@end
