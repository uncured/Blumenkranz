#import "NSMutableDictionary+VMExtension.h"

@implementation NSMutableDictionary (VMExtension)

- (BOOL)merge:(NSDictionary *)dictionary type:(VMDictionaryMergeType)type error:(NSError **)error {
    NSDictionary *resultDictionary = [self dictionaryByMerge:dictionary type:type error:error];
    if (resultDictionary) {
        for (id keyForMerge in [resultDictionary allKeys]) {
            [self setObject:[resultDictionary objectForKey:keyForMerge] forKey:keyForMerge];
        }
        return YES;
    }
    return NO;
}

@end
