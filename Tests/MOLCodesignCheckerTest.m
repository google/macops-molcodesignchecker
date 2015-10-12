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

#import <MOLCertificate/MOLCertificate.h>
#import <XCTest/XCTest.h>

#import "MOLCodesignChecker.h"

/**
  Tests for `MOLCodesignChecker`

  Most of these tests rely on some facts about `launchd`:

  * launchd is in /sbin
  * launchd is PID 1
  * launchd is signed
  * launchd's leaf cert has a CN of "Software Signing"
  * launchd's leaf cert has an OU of "Apple Software"
  * launchd's leaf cert has an ON of "Apple Inc."

  These facts are pretty stable, so shouldn't be a problem.
*/
@interface MOLCodesignCheckerTest : XCTestCase
@end

@implementation MOLCodesignCheckerTest

- (void)testInitWithBinaryPath {
  MOLCodesignChecker *sut = [[MOLCodesignChecker alloc] initWithBinaryPath:@"/sbin/launchd"];
  XCTAssertNotNil(sut);
}

- (void)testInitWithInvalidBinaryPath {
  MOLCodesignChecker *sut =
      [[MOLCodesignChecker alloc] initWithBinaryPath:@"/tmp/this/file/doesnt/exist"];
  XCTAssertNil(sut);
}

- (void)testInitWithPID {
  MOLCodesignChecker *sut = [[MOLCodesignChecker alloc] initWithPID:1];
  XCTAssertNotNil(sut);
}

- (void)testInitWithInvalidPID {
  MOLCodesignChecker *sut = [[MOLCodesignChecker alloc] initWithPID:999999999];
  XCTAssertNil(sut);
}

- (void)testInitWithSelf {
  // n.b: 'self' in this case is xctest, which should always be signed.
  MOLCodesignChecker *sut = [[MOLCodesignChecker alloc] initWithSelf];
  XCTAssertNotNil(sut);
}

- (void)testPlainInit {
  XCTAssertThrows([[MOLCodesignChecker alloc] init]);
}

- (void)testDescription {
  MOLCodesignChecker *sut = [[MOLCodesignChecker alloc] initWithPID:1];
  XCTAssertEqualObjects([sut description],
                        @"In-memory binary, signed by Apple Inc., located at: /sbin/launchd");
}

- (void)testLeafCertificate {
  MOLCodesignChecker *sut = [[MOLCodesignChecker alloc] initWithPID:1];
  XCTAssertNotNil(sut.leafCertificate);
}

- (void)testBinaryPath {
  MOLCodesignChecker *sut = [[MOLCodesignChecker alloc] initWithPID:1];
  XCTAssertEqualObjects(sut.binaryPath, @"/sbin/launchd");
}

- (void)testSigningInformationMatches {
  MOLCodesignChecker *sut1 = [[MOLCodesignChecker alloc] initWithBinaryPath:@"/sbin/launchd"];
  MOLCodesignChecker *sut2 = [[MOLCodesignChecker alloc] initWithPID:1];
  XCTAssertTrue([sut1 signingInformationMatches:sut2]);
}

- (void)testCodeRef {
  MOLCodesignChecker *sut = [[MOLCodesignChecker alloc] initWithSelf];
  XCTAssertNotNil((id)sut.codeRef);
}

- (void)testSigningInformation {
  MOLCodesignChecker *sut = [[MOLCodesignChecker alloc] initWithPID:1];
  XCTAssertNotNil(sut.signingInformation);
  XCTAssertEqualObjects(sut.signingInformation[@"source"], @"embedded");
}

@end
