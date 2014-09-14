#import "NSDictionary+VMExtension.h"

@interface NSMutableDictionary (VMExtension)

- (BOOL)merge:(NSDictionary *)dictionary type:(VMDictionaryMergeType)type error:(NSError **)error;

@end
