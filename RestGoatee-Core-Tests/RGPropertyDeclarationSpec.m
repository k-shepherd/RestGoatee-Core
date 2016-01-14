/* Copyright (c) 11/19/15, Ryan Dignard
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

#import "RGPropertyDeclaration.h"
#import "RestGoatee-Core.h"
#import "RGTestObject2.h"

CLASS_SPEC(RGPropertyDeclaration)

- (void) testInit {
    @try {
        [RGPropertyDeclaration new];
        XCTAssert(NO, @"init did not raise");
    } @catch (NSException* e) {
        XCTAssert([e.name isEqual:NSGenericException]);
    }
}

#pragma mark - rg_canonical
- (void) testSpaces {
    XCTAssert([rg_canonical_form("          ") isEqual:@""]);
}

- (void) testNumbers {
    XCTAssert([rg_canonical_form("1234add1234") isEqual:@"1234add1234"]);
}

- (void) testCapitals {
    XCTAssert([rg_canonical_form("ABCDE") isEqual:@"abcde"]);
}

- (void) testSymbols {
    XCTAssert([rg_canonical_form("!@#$abcde&*!@#") isEqual:@"abcde"]);
}

- (void) testUnicode {
    XCTAssert([rg_canonical_form("abc💅bcd") isEqual:@"abcbcd"]);
}

- (void) testShortString {
    XCTAssert([rg_canonical_form("") isEqual:@""]);
}

- (void) testLongString {
    char* str = "sjkdfslkhasajskhdl2746981237JAgkHKJSGFKJHSKJSFHKJAGSd jdksdhflk sdklfh lksdjf l!&#^*&!%$)(!)$*@&@&@&@$&@*$^JKgsdajdajsdhaskdahr";
    XCTAssert([rg_canonical_form(str) isEqual:@"sjkdfslkhasajskhdl2746981237jagkhkjsgfkjhskjsfhkjagsdjdksdhflksdklfhlksdjfljkgsdajdajsdhaskdahr"]);
}

SPEC_END
