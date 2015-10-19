/* Copyright (c) 10/12/15, Ryan Dignard
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

#import "NSObject+RG_Deserialization.h"
#import "RGTestObject2.h"

CATEGORY_SPEC(NSObject, RG_Deserialization)

#pragma mark - rg_initProperty:withValue:inContext: with NSString
- (void) testStringToString {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(stringProperty) withValue:@"foobar" inContext:nil];
    XCTAssert([object.stringProperty isEqual:@"foobar"]);
}

- (void) testStringToURL {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(urlProperty) withValue:@"http://google.com" inContext:nil];
    XCTAssert([object.urlProperty isEqual:[NSURL URLWithString:@"http://google.com"]]);
}

- (void) testStringToNumber {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(numberProperty) withValue:@"10" inContext:nil];
    XCTAssert([object.numberProperty isEqual:@10]);
}

- (void) testStringToDecimal {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(decimalProperty) withValue:@"10.00" inContext:nil];
    XCTAssert([object.decimalProperty isEqual:[NSDecimalNumber decimalNumberWithString:@"10.00"]]);
}

- (void) testStringToValue {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(valueProperty) withValue:@"1231" inContext:nil];
    XCTAssert([object.valueProperty isEqual:@1231]);
}

- (void) testStringToId {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(idProperty) withValue:@"abcd" inContext:nil];
    XCTAssert([object.idProperty isEqual:@"abcd"]);
}

- (void) testStringToClass {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(classProperty) withValue:@"NSObject" inContext:nil];
    XCTAssert([object.classProperty isEqual:[NSObject class]]);
}

- (void) testStringToArray {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(arrayProperty) withValue:@"acde" inContext:nil];
    XCTAssert(object.arrayProperty == nil);
}

- (void) testStringToDictionary {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(dictionaryProperty) withValue:@"abcs" inContext:nil];
    XCTAssert(object.dictionaryProperty == nil);
}

#pragma mark - rg_initProperty:withValue:inContext: with NSNull
- (void) testNullToString {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(stringProperty) withValue:[NSNull null] inContext:nil];
    XCTAssert(object.stringProperty == nil);
}

- (void) testNullToURL {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(urlProperty) withValue:[NSNull null] inContext:nil];
    XCTAssert(object.urlProperty == nil);
}

- (void) testNullToNumber {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(numberProperty) withValue:[NSNull null] inContext:nil];
    XCTAssert(object.numberProperty == nil);
}

- (void) testNullToDecimal {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(decimalProperty) withValue:[NSNull null] inContext:nil];
    XCTAssert(object.decimalProperty == nil);
}

- (void) testNullToValue {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(valueProperty) withValue:[NSNull null] inContext:nil];
    XCTAssert(object.valueProperty == nil);
}

- (void) testNullToId {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(idProperty) withValue:[NSNull null] inContext:nil];
    XCTAssert(object.idProperty == nil);
}

- (void) testNullToClass {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(classProperty) withValue:[NSNull null] inContext:nil];
    XCTAssert(object.classProperty == nil);
}

- (void) testNullToArray {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(arrayProperty) withValue:[NSNull null] inContext:nil];
    XCTAssert(object.arrayProperty == nil);
}

- (void) testNullToDictionary {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:STRING_SEL(dictionaryProperty) withValue:[NSNull null] inContext:nil];
    XCTAssert(object.dictionaryProperty == nil);
}

#pragma mark - objectFromDataSource:
- (void) testStringProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ STRING_SEL(stringProperty) : @"foobar" }];
    XCTAssert([object.stringProperty isEqual:@"foobar"]);
}

- (void) testURLProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ STRING_SEL(urlProperty) : @"http://google.com" }];
    XCTAssert([object.urlProperty isEqual:[NSURL URLWithString:@"http://google.com"]]);
}

- (void) testNumberProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ STRING_SEL(numberProperty) : @1 }];
    XCTAssert([object.numberProperty isEqual:@1]);
}

- (void) testDecimalProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ STRING_SEL(decimalProperty) : @"10.0" }];
    XCTAssert([object.decimalProperty isEqual:[NSDecimalNumber decimalNumberWithString:@"10.0"]]);
}

- (void) testValueProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ STRING_SEL(valueProperty) : @1 }];
    XCTAssert([object.valueProperty isEqual:@1]);
}

- (void) testIdProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ STRING_SEL(idProperty) : @"foobar" }];
    XCTAssert([object.idProperty isEqual:@"foobar"]);
}

- (void) testClassProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ STRING_SEL(classProperty) : @"NSObject" }];
    XCTAssert([object.classProperty isEqual:[NSObject class]]);
}

- (void) testArrayProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ STRING_SEL(arrayProperty) : @[ @"foo", @"bar" ] }];
    XCTAssert([object.arrayProperty isEqual:(@[ @"foo", @"bar" ])]);
}

- (void) testDictionaryProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ STRING_SEL(dictionaryProperty) : @{ @"foo" : @"bar" } }];
    XCTAssert([object.dictionaryProperty isEqual:(@{ @"foo" : @"bar" })]);
}

SPEC_END
