#import "NSArray+VMExtension.h"

@interface NSMutableArray (VMExtension)

- (BOOL)merge:(NSArray *)array type:(VMArrayMergeType)type error:(NSError **)error;

@end
