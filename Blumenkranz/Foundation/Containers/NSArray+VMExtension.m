#import "NSArray+VMExtension.h"

const NSInteger NSArrayObjectCannotBeCopiedErrorCode = 100;
NSString * const NSArrayVMExtensionDomain = @"ru.visulamyth.blumenkranz.NSArray_VMExtension";

@implementation NSArray (VMExtension)

+ (NSArray *)arrayByMerge:(NSArray *)target with:(NSArray *)source type:(VMArrayMergeType)type error:(NSError **)error {
    return [target arrayByMerge:source type:type error:error];
}

- (NSArray *)arrayByMerge:(NSArray *)array type:(VMArrayMergeType)type error:(NSError **)error {
    NSMutableArray *resultArray = [self mutableCopy];

    BOOL needToCopyObjects = (type & VMArrayMergeCopy);
    NSSet *exclusion = [array exclusion:self];
    for (id object in [exclusion allObjects]) {
        id objectToMerge = object;
        if (needToCopyObjects) {
            if ([objectToMerge respondsToSelector:@selector(copy)]) {
                objectToMerge = [objectToMerge copy];
            } else {
                if (error) {
                    *error = [NSArray vm_objectCopyError:object];
                }
                return nil;
            }
        }
        [resultArray addObject:objectToMerge];
    }

    return [resultArray copy];
}

- (NSSet *)intersection:(NSArray *)array {
    NSMutableSet *resultSet = [NSMutableSet setWithArray:self];
    [resultSet intersectSet:[NSSet setWithArray:array]];
    return [resultSet copy];
}

- (NSSet *)exclusion:(NSArray *)array {
    NSMutableSet *resultSet = [NSMutableSet setWithArray:self];
    [resultSet minusSet:[NSSet setWithArray:array]];
    return [resultSet copy];
}

+ (NSError *)vm_objectCopyError:(id)object {
    return [NSError errorWithDomain:NSArrayVMExtensionDomain
                               code:NSArrayObjectCannotBeCopiedErrorCode
                           userInfo:@{
                                   NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Object [%@] cannot be copied.", object]
                           }
    ];
}

@end
