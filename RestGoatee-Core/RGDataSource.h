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

#import "RGDefines.h"

RG_FILE_START

/**
 These are the methods that a data source must implement in order to be consumable by the `+[NSObject objectFromDataSource:inContext:]` family of methods.
 
 Currently `NSDictionary` and `RGXMLNode` (the parsed output from `NSXMLParser`) are supported implicitly.
 
 must be able to `for X in id<RGDataSource>`
 */
@protocol RGDataSource <NSObject, NSFastEnumeration>

@required

/**
 The data source must support `id value = [dataSource valueForKeyPath:@"foo.bar"]`.
 */
- (RG_PREFIX_NULLABLE id) valueForKeyPath:(RG_PREFIX_NONNULL NSString*)string;

/**
 Returns an array of the keys which are present in this data source (but NOT sub data sources).
 */
- (RG_PREFIX_NONNULL NSArray RG_GENERIC(NSString*) *) allKeys;

@end

RG_FILE_END
