/* Copyright (c) 6/22/14, Ryan Dignard
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

#ifndef RG_FILE_START
    #define RG_FILE_START \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wgnu\"")
#endif

#ifndef RG_FILE_END
    #define RG_FILE_END \
    _Pragma("clang diagnostic pop")
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"

#ifndef RG_NULLABLE_PROPERTY
    #if __has_feature(nullability)
        #define RG_NULLABLE_PROPERTY(...) (nullable, ## __VA_ARGS__)
        #define RG_NONNULL_PROPERTY(...) (nonnull, ## __VA_ARGS__)
        #define RG_NULL_RESETTABLE_PROPERTY(...) (null_resettable, ## __VA_ARGS__)
        #define RG_PREFIX_NULLABLE nullable
        #define RG_SUFFIX_NULLABLE __nullable
        #define RG_PREFIX_NONNULL nonnull
        #define RG_SUFFIX_NONNULL __nonnull
    #else
        #define RG_NULLABLE_PROPERTY(...) (__VA_ARGS__)
        #define RG_NONNULL_PROPERTY(...) (__VA_ARGS__)
        #define RG_NULL_RESETTABLE_PROPERTY(...) (__VA_ARGS__)
        #define RG_PREFIX_NULLABLE
        #define RG_SUFFIX_NULLABLE
        #define RG_PREFIX_NONNULL
        #define RG_SUFFIX_NONNULL
    #endif
#endif

#ifndef RG_GENERIC
    #if __has_feature(objc_generics)
        #define RG_GENERIC(...) < __VA_ARGS__ >
    #else
        #define RG_GENERIC(...)
    #endif
#endif

#pragma clang diagnostic pop

/* `NULL` and `nil` are typed `void*` and I need it to be typed `void` */
#ifndef RG_VOID_NOOP
    #define RG_VOID_NOOP ((void)0)
#endif

/* enables a selector declarations to be used in place of an `NSString`, provides spell checking. */
#ifndef RG_STRING_SEL
    #define RG_STRING_SEL(sel) NSStringFromSelector(@selector(sel))
#endif
