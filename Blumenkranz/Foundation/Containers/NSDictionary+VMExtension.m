#import "NSDictionary+VMExtension.h"
#import "NSArray+VMExtension.h"
#import "NSObject+VMExtension.h"

const NSInteger NSDictionaryObjectCannotBeCopiedErrorCode = 100;
const NSInteger NSDictionaryObjectCannotBeMergedErrorCode = 101;
NSString * const NSDictionaryVMExtensionDomain = @"ru.visualmyth.blumenkranz.NSDictionary_VMExtension";

@implementation NSDictionary (VMExtension)

+ (NSDictionary *)dictionaryByMerge:(NSDictionary *)target with:(NSDictionary *)source type:(VMDictionaryMergeType)type error:(NSError **)error {
    return [target dictionaryByMerge:source type:type error:error];
}

- (NSDictionary *)dictionaryByMerge:(NSDictionary *)dictionary type:(VMDictionaryMergeType)type error:(NSError **)error {
    NSMutableDictionary *resultDictionary = [self mutableCopy];

    BOOL needToCopyObjects = (type & VMDictionaryMergeCopy);
    BOOL needToInsertNewKeys = (type & VMDictionaryMergeNewKeys);

    if (needToInsertNewKeys) {
        NSSet *keysForMerge = [[dictionary allKeys] exclusion:[self allKeys]];

        for (id keyForMerge in [keysForMerge allObjects]) {
            id object = dictionary[keyForMerge];
            if (needToCopyObjects) {
                if (vmObjectCanBeCopied(object)) {
                    object = [object copy];
                } else {
                    if (error) {
                        *error = [NSDictionary vm_objectCopyError:keyForMerge underlyingError:nil];
                    }
                    return nil;
                }
            }
            resultDictionary[keyForMerge] = object;
        }
    }

    BOOL needToReplaceExistingKeys = (type & VMDictionaryMergeExistingKeysReplace);
    BOOL needToJoinExistingKeys = (type & VMDictionaryMergeExistingKeysJoin);
    BOOL needToProcessIntersectionKeys = (type & (VMDictionaryMergeExistingKeysJoin | VMDictionaryMergeExistingKeysReplace));

    if (needToProcessIntersectionKeys) {
        NSSet *keysForMerge = [[dictionary allKeys] intersection:[self allKeys]];

        for (id keyForMerge in [keysForMerge allObjects]) {
            id mergeObject = dictionary[keyForMerge];
            id existingObject = self[keyForMerge];

            BOOL isMergingDictionaries = [mergeObject isKindOfClass:[NSDictionary class]] && [existingObject isKindOfClass:[NSDictionary class]];
            BOOL isMergingArrays = [mergeObject isKindOfClass:[NSArray class]] && [existingObject isKindOfClass:[NSArray class]];

            if (needToReplaceExistingKeys && !(needToJoinExistingKeys && (isMergingDictionaries || isMergingArrays))) {

                if (needToCopyObjects) {
                    if (vmObjectCanBeCopied(mergeObject)) {
                        mergeObject = [mergeObject copy];
                    } else {
                        if (error) {
                            *error = [NSDictionary vm_objectCopyError:keyForMerge underlyingError:nil];
                        }
                        return nil;
                    }
                }
                resultDictionary[keyForMerge] = mergeObject;

            } else if (isMergingDictionaries) {

                NSDictionary *deepMergeResult = [(NSDictionary *)existingObject dictionaryByMerge:mergeObject type:type error:error];
                if (deepMergeResult) {
                    resultDictionary[keyForMerge] = deepMergeResult;
                } else {
                    if (error) {
                        *error = [NSDictionary vm_objectDeepMergeError:existingObject with:mergeObject];
                    }
                    return nil;
                }

            } else if (isMergingArrays) {

                VMArrayMergeType deepMergeType = (needToCopyObjects ? VMArrayMergeCopy : VMArrayMergeNone);
                NSArray *deepMergeResult = [(NSArray *)existingObject arrayByMerge:mergeObject type:deepMergeType error:error];
                if (deepMergeResult) {
                    resultDictionary[keyForMerge] = deepMergeResult;
                } else {
                    if (error) {
                        *error = [NSDictionary vm_objectDeepMergeError:existingObject with:mergeObject];
                    }
                    return nil;
                }

            }
        }
    }

    return [resultDictionary copy];
}

- (NSMutableDictionary *)deepMutableCopy {
    NSMutableDictionary *copyResult = [NSMutableDictionary dictionary];
    for (id key in self) {
        id object = self[key];
        if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
            copyResult[key] = [object deepMutableCopy];
        } else {
            copyResult[key] = object;
        }
    }
    return copyResult;
}

- (NSDictionary *)deepImmutableCopy {
    NSMutableDictionary *copyResult = [NSMutableDictionary dictionary];
    for (id key in self) {
        id object = self[key];
        if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
            copyResult[key] = [object deepImmutableCopy];
        } else {
            copyResult[key] = object;
        }
    }
    return [NSDictionary dictionaryWithDictionary:copyResult];
}

- (NSMutableDictionary *)deepMutableClone:(BOOL *)success error:(NSError **)error {
    NSMutableDictionary *copyResult = [NSMutableDictionary dictionary];
    NSMutableArray *errorFields = [NSMutableArray array];

    for (id key in self) {
        id object = self[key];
        if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {

            BOOL underlyingSuccess;
            copyResult[key] = [object deepMutableClone:&underlyingSuccess error:nil];
            if (!underlyingSuccess) {
                [errorFields addObject:key];
            }

        } else if (vmObjectCanBeCopiedMutably(object)) {

            copyResult[key] = [object mutableCopy];

        } else if (vmObjectCanBeCopied(object)) {

            copyResult[key] = [object copy];

        } else {

            [errorFields addObject:key];
            copyResult[key] = object;

        }
    }

    [self vm_triggerCopyError:error state:success fields:errorFields];

    return copyResult;
}

- (NSDictionary *)deepImmutableClone:(BOOL *)success error:(NSError **)error {
    NSMutableDictionary *copyResult = [NSMutableDictionary dictionary];
    NSMutableArray *errorFields = [NSMutableArray array];

    for (id key in self) {
        id object = self[key];
        if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {

            BOOL underlyingSuccess;
            copyResult[key] = [object deepImmutableClone:&underlyingSuccess error:nil];
            if (!underlyingSuccess) {
                [errorFields addObject:key];
            }

        } else if (vmObjectCanBeCopied(object)) {

            copyResult[key] = [object copy];

        } else {

            [errorFields addObject:key];
            copyResult[key] = object;

        }
    }

    [self vm_triggerCopyError:error state:success fields:errorFields];

    return [NSDictionary dictionaryWithDictionary:copyResult];
}

#pragma mark Inner methods
+ (NSError *)vm_objectCopyError:(id)key underlyingError:(NSError *)underlyingError {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NSLocalizedDescriptionKey] = [NSString stringWithFormat:@"Object for key [%@] cannot be copied.", key];
    if (underlyingError) {
        userInfo[NSUnderlyingErrorKey] = underlyingError;
    }

    return [NSError errorWithDomain:NSDictionaryVMExtensionDomain
                               code:NSDictionaryObjectCannotBeCopiedErrorCode
                           userInfo:userInfo
    ];
}

+ (NSError *)vm_objectDeepMergeError:(id)existingObject with:(id)mergeObject {
    return [NSError errorWithDomain:NSDictionaryVMExtensionDomain
                               code:NSDictionaryObjectCannotBeMergedErrorCode
                           userInfo:@{
                                   NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Object [%@] cannot be deep merged with [%@].", existingObject, mergeObject]
                           }
    ];
}

- (void)vm_triggerCopyError:(NSError **)error state:(BOOL *)success fields:(NSArray *)errorFields {
    if (error) {
        if ([errorFields count]) {
            *success = NO;
            NSString *description = [NSString stringWithFormat:@"Can't fully copy object at keys: %@", [errorFields componentsJoinedByString:@", "]];
            NSError *underlyingError = [NSError errorWithDomain:NSDictionaryVMExtensionDomain
                                                           code:NSDictionaryObjectCannotBeCopiedErrorCode
                                                       userInfo:@{
                                                               NSLocalizedDescriptionKey: description
                                                       }];

            *error = [NSError errorWithDomain:NSDictionaryVMExtensionDomain
                                       code:NSDictionaryObjectCannotBeCopiedErrorCode
                                   userInfo:@{
                                           NSLocalizedDescriptionKey: @"Object cannot be copied.",
                                           NSUnderlyingErrorKey: underlyingError
                                   }
            ];
        } else {
            *success = YES;
            *error = nil;
        }
    }
}

@end
