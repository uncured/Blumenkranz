#import "NSString+VMExtension.h"

@implementation NSString (VMExtension)

+ (NSString *)stringWithCharacterSet:(NSCharacterSet *)characterSet {
    NSData *characterSetData = [characterSet bitmapRepresentation];
    NSMutableString *resultString = [NSMutableString string];
    
    uint64_t unicharMax = (1ull << (CHAR_BIT * sizeof(unichar)));
    const uint8_t *ptr = [characterSetData bytes];
    
    for (unichar idx = 0; idx < unicharMax; idx++) {
        if ( ptr[ idx>>3 ] & ( 1u << (idx & 7) ) ) {
            [resultString appendString:[NSString stringWithCharacters:&idx length:1]];
        }
    }

    return [resultString copy];
}

+ (NSString *)stringWithCurrentCharacterSet {
    static dispatch_once_t predicate;
    static NSString *resultString = nil;

    dispatch_once(&predicate, ^{
        resultString = [NSString stringWithCharacterSet:[[NSLocale currentLocale] objectForKey:NSLocaleExemplarCharacterSet]];
    });

    return resultString;
}


@end
