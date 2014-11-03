#import "NSArray+VMExtension.h"
#import "NSObject+VMExtension.h"

const NSInteger NSArrayObjectCannotBeCopiedErrorCode = 100;
NSString * const NSArrayVMExtensionDomain = @"ru.visualmyth.blumenkranz.NSArray_VMExtension";

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
            if (vmObjectCanBeCopied(objectToMerge)) {
                objectToMerge = [objectToMerge copy];
            } else {
                if (error) {
                    *error = [NSArray vm_objectCopyError:object underlyingError:nil];
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

- (NSMutableArray *)deepMutableCopy {
    NSMutableArray *copyResult = [NSMutableArray array];
    for (id object in self) {
        if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
            [copyResult addObject:[object deepMutableCopy]];
        } else {
            [copyResult addObject:object];
        }
    }
    return copyResult;
}

- (NSArray *)deepImmutableCopy {
    NSMutableArray *copyResult = [NSMutableArray array];
    for (id object in self) {
        if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
            [copyResult addObject:[object deepImmutableCopy]];
        } else {
            [copyResult addObject:object];
        }
    }
    return [NSArray arrayWithArray:copyResult];
}

- (NSMutableArray *)deepMutableClone:(BOOL *)success error:(NSError **)error {
    NSMutableArray *copyResult = [NSMutableArray array];
    NSMutableArray *errorFields = [NSMutableArray array];
    NSUInteger count = [self count];

    for (NSUInteger idx = 0; idx < count; idx++) {
        id object = self[idx];
        if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {

            BOOL underlyingSuccess;
            [copyResult addObject:[object deepMutableClone:&underlyingSuccess error:nil]];
            if (!underlyingSuccess) {
                [errorFields addObject:@(idx)];
            }

        } else if (vmObjectCanBeCopiedMutably(object)) {

            [copyResult addObject:[object mutableCopy]];

        } else if (vmObjectCanBeCopied(object)) {

            [copyResult addObject:[object copy]];

        } else {

            [errorFields addObject:@(idx)];
            [copyResult addObject:object];

        }
    }

    [self vm_triggerCopyError:error state:success fields:errorFields];

    return copyResult;
}

- (NSArray *)deepImmutableClone:(BOOL *)success error:(NSError **)error {
    NSMutableArray *copyResult = [NSMutableArray array];
    NSMutableArray *errorFields = [NSMutableArray array];
    NSUInteger count = [self count];

    for (NSUInteger idx = 0; idx < count; idx++) {
        id object = self[idx];
        if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {

            BOOL underlyingSuccess;
            [copyResult addObject:[object deepImmutableClone:&underlyingSuccess error:nil]];
            if (!underlyingSuccess) {
                [errorFields addObject:@(idx)];
            }

        } else if (vmObjectCanBeCopied(object)) {

            [copyResult addObject:[object copy]];

        } else {

            [errorFields addObject:@(idx)];
            [copyResult addObject:object];

        }
    }

    [self vm_triggerCopyError:error state:success fields:errorFields];

    return [NSArray arrayWithArray:copyResult];
}

#pragma mark Inner methods
+ (NSError *)vm_objectCopyError:(id)object underlyingError:(NSError *)underlyingError {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NSLocalizedDescriptionKey] = [NSString stringWithFormat:@"Object [%@] cannot be copied.", [object description]];
    if (underlyingError) {
        userInfo[NSUnderlyingErrorKey] = underlyingError;
    }

    return [NSError errorWithDomain:NSArrayVMExtensionDomain
                               code:NSArrayObjectCannotBeCopiedErrorCode
                           userInfo:[NSDictionary dictionaryWithDictionary:userInfo]
    ];
}

- (void)vm_triggerCopyError:(NSError **)error state:(BOOL *)success fields:(NSArray *)errorFields {
    if (error) {
        if ([errorFields count]) {
            *success = NO;
            NSString *description = [NSString stringWithFormat:@"Can't fully copy object at indexes: %@", [errorFields componentsJoinedByString:@", "]];
            NSError *underlyingError = [NSError errorWithDomain:NSArrayVMExtensionDomain
                                                           code:NSArrayObjectCannotBeCopiedErrorCode
                                                       userInfo:@{
                                                               NSLocalizedDescriptionKey: description
                                                       }];
            *error = [[self class] vm_objectCopyError:self underlyingError:underlyingError];
        } else {
            *success = YES;
            *error = nil;
        }
    }
}

@end
