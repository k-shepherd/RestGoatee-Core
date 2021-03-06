/* Copyright (c) 01/13/16, Ryan Dignard
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

#import "RestGoatee-Core.h"
#import "RGTestObject2.h"

extern NSString* RG_SUFFIX_NONNULL const kRGSerializationKey;

@interface RGTestObject5 : NSObject <RGSerializable>

@property (nonatomic, strong) NSString* stringProperty;
@property (nonatomic, strong) NSArray* arrayProperty;
@property (nonatomic, strong) NSNumber* numberProperty;

@end

@implementation RGTestObject5

+ (NSArray*) serializableKeys {
    return @[ RG_STRING_SEL(stringProperty), RG_STRING_SEL(numberProperty) ];
}

@end

CATEGORY_SPEC(NSObject, RGSerialization)

#pragma mark - dictionaryRepresentation
- (void)testDictionaryRepresentationBasic {
    RGTestObject2* obj = [RGTestObject2 new];
    obj.dictionaryProperty = @{ @"aKey" : @"aValue" };
    obj.arrayProperty = @[ @"aValue" ];
    NSDictionary* dictionaryRepresentation = [obj dictionaryRepresentation];
    XCTAssert([dictionaryRepresentation[RG_STRING_SEL(dictionaryProperty)] isEqual:obj.dictionaryProperty]);
    XCTAssert([dictionaryRepresentation[RG_STRING_SEL(arrayProperty)] isEqual:obj.arrayProperty]);
    XCTAssert([dictionaryRepresentation[kRGSerializationKey] isEqual:NSStringFromClass([RGTestObject2 class])]);
}

- (void)testRGSerializable {
    RGTestObject5* obj = [RGTestObject5 new];
    obj.stringProperty = @"abcd";
    obj.arrayProperty = @[ @"aValue" ];
    obj.numberProperty = @3;
    NSDictionary* dictionary = [obj dictionaryRepresentation];
    XCTAssert([dictionary[RG_STRING_SEL(stringProperty)] isEqual:@"abcd"]);
    XCTAssert(dictionary[RG_STRING_SEL(arrayProperty)] == nil);
    XCTAssert([dictionary[RG_STRING_SEL(numberProperty)] isEqual:@"3"]);
}

SPEC_END
