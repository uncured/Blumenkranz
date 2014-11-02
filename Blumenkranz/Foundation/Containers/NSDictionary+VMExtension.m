#import "NSDictionary+VMExtension.h"
#import "NSArray+VMExtension.h"

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
                if ([object respondsToSelector:@selector(copy)] && [object respondsToSelector:@selector(copyWithZone:)]) {
                    object = [object copy];
                } else {
                    if (error) {
                        *error = [NSDictionary vm_objectCopyError:keyForMerge];
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
                    if ([mergeObject respondsToSelector:@selector(copy)] && [mergeObject respondsToSelector:@selector(copyWithZone:)]) {
                        mergeObject = [mergeObject copy];
                    } else {
                        if (error) {
                            *error = [NSDictionary vm_objectCopyError:keyForMerge];
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

+ (NSError *)vm_objectCopyError:(id)key {
    return [NSError errorWithDomain:NSDictionaryVMExtensionDomain
                    code:NSDictionaryObjectCannotBeCopiedErrorCode
                    userInfo:@{
                        NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Object for key [%@] cannot be copied.", key]
                    }
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

@end
