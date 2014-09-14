#import "NSMutableArray+VMExtension.h"

@implementation NSMutableArray (VMExtension)

- (BOOL)merge:(NSArray *)array type:(VMArrayMergeType)type error:(NSError **)error {
    NSArray *resultArray = [self arrayByMerge:array type:type error:error];
    if (resultArray) {
        [self removeAllObjects];
        for (id objectForMerge in resultArray) {
            [self addObject:objectForMerge];
        }
        return YES;
    }
    return NO;
}

@end
