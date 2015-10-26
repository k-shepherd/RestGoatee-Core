/* Copyright (c) 6/10/14, Ryan Dignard
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
#import "NSObject+RG_SharedImpl.h"
#import "RGDeserializationDelegate.h"
#import "NSString+RGCanonicalValue.h"

FILE_START

@interface NSObject (RGForwardDeclarations)

+ (PREFIX_NONNULL id) insertNewObjectForEntityForName:(PREFIX_NONNULL NSString*)entityName inManagedObjectContext:(PREFIX_NONNULL id)context;

@end

static NSArray GENERIC(id) * SUFFIX_NONNULL rg_unpackArray(NSArray* SUFFIX_NULLABLE json, id SUFFIX_NULLABLE context) {
    NSMutableArray* ret = [NSMutableArray new];
    for (__strong id obj in json) {
        if (rg_isDataSourceClass([obj class])) {
            Class objectClass = NSClassFromString(obj[kRGSerializationKey]);
            obj = rg_isDataSourceClass(objectClass) || !objectClass ? obj : [objectClass objectFromDataSource:obj inContext:context];
        }
        [ret addObject:obj];
    }
    return ret;
}

@implementation NSObject (RG_Deserialization)

+ (PREFIX_NONNULL NSMutableArray GENERIC(id) *) objectsFromArraySource:(PREFIX_NULLABLE id<NSFastEnumeration>)source {
    return [self objectsFromArraySource:source inContext:nil];
}

+ (PREFIX_NONNULL NSMutableArray GENERIC(id) *) objectsFromArraySource:(PREFIX_NULLABLE id<NSFastEnumeration>)source inContext:(PREFIX_NULLABLE NSManagedObjectContext*)context {
    NSMutableArray GENERIC(id) * objects = [NSMutableArray new];
    for (NSDictionary* object in source) {
        if (rg_isDataSourceClass([object class])) {
            [objects addObject:[self objectFromDataSource:object inContext:context]];
        }
    }
    return objects;
}

+ (PREFIX_NONNULL instancetype) objectFromDataSource:(PREFIX_NULLABLE id<RGDataSourceProtocol>)source {
    NSAssert(![self isSubclassOfClass:rg_sNSManagedObject], @"Managed object subclasses must be initialized within a managed object context.  Use +objectFromJSON:inContext:");
    return [self objectFromDataSource:source inContext:nil];
}

+ (PREFIX_NONNULL instancetype) objectFromDataSource:(PREFIX_NULLABLE id<RGDataSourceProtocol>)source inContext:(PREFIX_NULLABLE NSManagedObjectContext*)context {
    NSObject<RGDeserializationDelegate>* ret;
    if ([self isSubclassOfClass:rg_sNSManagedObject]) {
        NSAssert(context, @"A subclass of NSManagedObject must be created within a valid NSManagedObjectContext.");
        ret = [rg_sNSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context];
    } else {
        ret = [self new];
    }
    return [ret extendWith:source inContext:context];
}

- (void) rg_initCanonically:(PREFIX_NONNULL NSString*)key withValue:(PREFIX_NULLABLE id)value inContext:(PREFIX_NULLABLE id)context {
    NSUInteger index = [[[self class] rg_propertyList][kRGPropertyCanonicalName] indexOfObject:key.rg_canonicalValue];
    if (index != NSNotFound) {
        if (rg_topClassDeclaringPropertyNamed([self class], [[self class] rg_propertyList][index][kRGPropertyName]) != [NSObject class]) {
            @try {
                [self rg_initProperty:[[self class] rg_propertyList][index][kRGPropertyName] withValue:value inContext:context];
            } @catch (NSException* e) { /* Should this fail the property is left alone */
                RGLog(@"initializing property %@ on type %@ failed: %@", [[self class] rg_propertyList][index][kRGPropertyName], [self class], e);
            }
        }
    }
}

/**
 This method can be considered at a high level to be performing `self.key = value`.  It inserts type coercion where appropriate, and optionally allows the object to override the default behavior at the property level.
 
 JSON types when deserialized from NSData are: NSNull, NSNumber (number or boolean), NSString, NSArray, NSDictionary.
 RGXMLNode is odd, but it can be used as nil, NSString, NSDictionary, or NSArray where required.
 */
- (void) rg_initProperty:(PREFIX_NONNULL NSString*)key withValue:(PREFIX_NULLABLE id)value inContext:(PREFIX_NULLABLE id)context {
    static NSDateFormatter* dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
    });
    
    /* first ask if there's a custom implementation */
    if ([self respondsToSelector:@selector(shouldTransformValue:forProperty:inContext:)]) {
        if (![(id<RGDeserializationDelegate>)self shouldTransformValue:value forProperty:key inContext:context]) {
            return;
        }
    }
    
    /* Can't initialize the value of a property if the property doesn't exist */
    if ([key isKindOfClass:[NSNull class]] || [key isEqual:kRGPropertyListProperty] || ![[self class] rg_declarationForProperty:key]) {
        return;
    }
    
    if (!value || [value isKindOfClass:[NSNull class]]) {
        self[key] = [self rg_isPrimitive:key] ? @0 : nil;
        return;
    }
    
    Class propertyType = [self rg_classForProperty:key];
    
    if ([value isKindOfClass:[NSArray class]]) { /* If the array we're given contains objects which we can create, create those too */
        value = rg_unpackArray(value, context);
    }
    
    id mutableVersion = [value respondsToSelector:@selector(mutableCopyWithZone:)] ? [value mutableCopy] : nil;
    if ([mutableVersion isMemberOfClass:propertyType]) { /* if the target is a mutable of a immutable type we already have */
        self[key] = mutableVersion;
        return;
    } /* This is the one instance where we can quickly cast down the value */
    
    if ([value isKindOfClass:propertyType]) { /* NSValue */
        self[key] = value;
        return;
    } /* If JSONValue is already a subclass of propertyType theres no reason to coerce it */
    
    /* Otherwise... this mess */
    
    if (rg_isMetaClassObject(propertyType)) { /* the property's type is Meta-class so its a reference to Class */
        self[key] = NSClassFromString([value description]);
    } else if ([propertyType isSubclassOfClass:[NSDictionary class]] && ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[RGXMLNode class]])) { /* NSDictionary */
        if ([value isKindOfClass:[RGXMLNode class]]) @throw @"Sorry this hasn't been implemented yet"; // TODO
        self[key] = [[propertyType alloc] initWithDictionary:value];
    } else if (rg_isCollectionObject(propertyType) && ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[RGXMLNode class]])) { /* NSArray, NSSet, or NSOrderedSet */
        if ([value isKindOfClass:[RGXMLNode class]]) value = [value childNodes];
        self[key] = [[propertyType alloc] initWithArray:value];
    } else if ([propertyType isSubclassOfClass:[NSDecimalNumber class]] && ([value isKindOfClass:[NSNumber class]] ||
                                                                            [value isKindOfClass:[NSString class]] ||
                                                                            [value isKindOfClass:[RGXMLNode class]])) {
        /* NSDecimalNumber, subclasses must go first */
        if ([value isKindOfClass:[RGXMLNode class]]) value = [value innerXML];
        if ([value isKindOfClass:[NSNumber class]]) value = [value stringValue];
        self[key] = [propertyType decimalNumberWithString:value];
    } else if ([propertyType isSubclassOfClass:[NSNumber class]] && ([value isKindOfClass:[NSNumber class]] ||
                                                                     [value isKindOfClass:[NSString class]] ||
                                                                     [value isKindOfClass:[RGXMLNode class]])) {
        /* NSNumber */
        if ([value isKindOfClass:[RGXMLNode class]]) value = [value innerXML];
        if ([value isKindOfClass:[NSString class]]) value = @([value doubleValue]);
        self[key] = value; /* Note: setValue: will unwrap the value if the destination is a primitive */
    } else if ([propertyType isSubclassOfClass:[NSValue class]] && ([value isKindOfClass:[NSNumber class]] ||
                                                                    [value isKindOfClass:[NSString class]] ||
                                                                    [value isKindOfClass:[RGXMLNode class]])) {
        /* NSValue */
        if ([value isKindOfClass:[RGXMLNode class]]) value = [value innerXML];
        if ([value isKindOfClass:[NSString class]]) value = @([value doubleValue]);
        self[key] = value; /* This is an NSNumber, which is a subclass of NSValue hence it's a valid assignment */
    } else if (([propertyType isSubclassOfClass:[NSString class]] || [propertyType isSubclassOfClass:[NSURL class]]) && ([value isKindOfClass:[NSNumber class]] ||
                                                                                                                         [value isKindOfClass:[NSString class]] ||
                                                                                                                         [value isKindOfClass:[RGXMLNode class]] ||
                                                                                                                         [value isKindOfClass:[NSArray class]])) {
        /* NSString, NSURL */
        if ([value isKindOfClass:[RGXMLNode class]]) value = [value innerXML];
        if ([value isKindOfClass:[NSArray class]]) value = [value componentsJoinedByString:@","];
        if ([value isKindOfClass:[NSNumber class]]) value = [value stringValue];
        self[key] = [[propertyType alloc] initWithString:value];
    } else if ([propertyType isSubclassOfClass:[NSDate class]]) { /* NSDate */
        if ([value isKindOfClass:[RGXMLNode class]]) value = [value innerXML];
        NSString* dateFormat = [[self class] respondsToSelector:@selector(dateFormatForProperty:)] ? [[self class] dateFormatForProperty:key] : nil;
        if (dateFormat) {
            dateFormatter.dateFormat = dateFormat;
            self[key] = [dateFormatter dateFromString:value];
            return; /* Let's not second-guess the developer... */
        } else {
            for (NSString* predefinedFormat in rg_dateFormats()) {
                dateFormatter.dateFormat = predefinedFormat;
                self[key] = [dateFormatter dateFromString:value];
                if (self[key]) break;
            }
        }
        
    /* At this point we've exhausted the supported foundation classes for the LHS... these handle sub-objects */
    } else if (!rg_isInlineObject(propertyType) && !rg_isCollectionObject(propertyType) && ([value isKindOfClass:[NSDictionary class]] ||
                                                                                            [value isKindOfClass:[RGXMLNode class]])) {
        /* lhs is some kind of user defined object, since the source has keys, but doesn't match NSDictionary */
        self[key] = [propertyType objectFromDataSource:value inContext:context];
    } else if ([value isKindOfClass:[NSArray class]]) { /* single entry arrays are converted to an inplace object */
        [(NSArray*)value count] > 1 ? RGLog(@"Warning, data loss on property %@ on type %@", key, [self class]) : VOID_NOOP;
        id firstValue = [value firstObject];
        if (!firstValue || [firstValue isKindOfClass:propertyType]) {
            self[key] = value;
        }
    } else if ([propertyType isSubclassOfClass:[NSObject class]] && [value isKindOfClass:propertyType]) { /* if there is literally nothing else we know about the property */
        self[key] = value;
    }
    
    self[key] ? VOID_NOOP : RGLog(@"Warning, initialization failed on property %@ on type %@", key, [self class]);
}

- (PREFIX_NONNULL instancetype) extendWith:(PREFIX_NULLABLE NSObject<RGDataSourceProtocol>*)source inContext:(PREFIX_NULLABLE NSManagedObjectContext*)context {
    NSDictionary* overrides = [[self class] respondsToSelector:@selector(overrideKeysForMapping)] ? [[self class] overrideKeysForMapping] : nil;
    NSMutableArray GENERIC(NSString*) * intializedProperties = [NSMutableArray new];
    for (NSString* key in source) {
        if (overrides[key]) continue;
        [self rg_initCanonically:key withValue:source[key] inContext:context];
        [intializedProperties addObject:key.rg_canonicalValue];
    }
    for (NSString* key in overrides) { /* The developer provided an override keypath */
        if ([intializedProperties containsObject:key.rg_canonicalValue]) continue;
        id value = [source valueForKeyPath:key];
        if (!value) continue; // empty dictionary entry doesn't get pushed
        @try {
            [self rg_initProperty:overrides[key] withValue:value inContext:context];
            [intializedProperties addObject:[overrides[key] rg_canonicalValue]];
        } @catch (NSException* e) { /* Should this fail the property is left alone */
            RGLog(@"initializing property %@ on type %@ failed: %@", overrides[key], [self class], e);
        }
    }
    return self;
}

- (PREFIX_NONNULL instancetype) extendWith:(PREFIX_NULLABLE NSObject<RGDataSourceProtocol>*)object {
    return [self extendWith:object inContext:nil];
}

@end

FILE_END
