#import "NSDictionary+VMExtension.h"
#import "NSArray+VMExtension.h"

const NSInteger NSDictionaryObjectCannotBeCopiedErrorCode = 100;
const NSInteger NSDictionaryObjectCannotBeMergedErrorCode = 101;
NSString * const NSDictionaryVMExtensionDomain = @"ru.visulamyth.blumenkranz.NSDictionary_VMExtension";

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
            id object = [dictionary objectForKey:keyForMerge];
            if (needToCopyObjects) {
                if ([object respondsToSelector:@selector(copy)]) {
                    object = [object copy];
                } else {
                    *error = [NSDictionary vm_objectCopyError:keyForMerge];
                    return nil;
                }
            }
            [resultDictionary setObject:object forKey:keyForMerge];
        }
    }

    BOOL needToReplaceExistingKeys = (type & VMDictionaryMergeExistingKeysReplace);
    BOOL needToProcessIntersectionKeys = (type & (VMDictionaryMergeExistingKeysJoin | VMDictionaryMergeExistingKeysReplace));

    if (needToProcessIntersectionKeys) {
        NSSet *keysForMerge = [[dictionary allKeys] intersection:[self allKeys]];

        for (id keyForMerge in [keysForMerge allObjects]) {
            id mergeObject = [dictionary objectForKey:keyForMerge];
            id existingObject = [self objectForKey:keyForMerge];

            if (needToReplaceExistingKeys) {

                if (needToCopyObjects) {
                    if ([mergeObject respondsToSelector:@selector(copy)]) {
                        mergeObject = [mergeObject copy];
                    } else {
                        *error = [NSDictionary vm_objectCopyError:keyForMerge];
                        return nil;
                    }
                }
                [resultDictionary setObject:mergeObject forKey:keyForMerge];

            } else {

                if ([mergeObject isKindOfClass:[NSDictionary class]] && [existingObject isKindOfClass:[NSDictionary class]]) {

                    NSDictionary *deepMergeResult = [(NSDictionary *)existingObject dictionaryByMerge:mergeObject type:type error:error];
                    if (deepMergeResult) {
                        [resultDictionary setObject:deepMergeResult forKey:keyForMerge];
                    } else {
                        return nil;
                    }

                } else if ([mergeObject isKindOfClass:[NSArray class]] && [existingObject isKindOfClass:[NSArray class]]) {

                    VMArrayMergeType deepMergeType = (needToCopyObjects ? VMArrayMergeCopy : VMArrayMergeNone);
                    NSArray *deepMergeResult = [(NSArray *)existingObject arrayByMerge:mergeObject type:deepMergeType error:error];
                    if (deepMergeResult) {
                        [resultDictionary setObject:deepMergeResult forKey:keyForMerge];
                    } else {
                        return nil;
                    }

                } else {
                    *error = [NSDictionary vm_objectDeepMergeError:existingObject with:mergeObject];
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
