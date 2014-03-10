#import "VMRandom.h"
#import "UIColor+VMExtension.h"
#import "VMAssertion.h"
#import "NSString+VMExtension.h"

@implementation VMRandom

- (instancetype)init {
    VMAbstract
    return nil;
}

+ (UIView *)randomView {
    UIView *result = [[UIView alloc] initWithFrame:[self randomRect]];
    result.backgroundColor = [self randomColor];
    return result;
}

+ (CGPoint)randomPoint {
    CGSize base = [[[UIApplication sharedApplication] keyWindow] bounds].size;
    return CGPointMake([self randomIntegerFrom:0 to:(NSInteger)base.width], [self randomIntegerFrom:0 to:(NSInteger)base.height]);
}

+ (CGSize)randomSize {
    CGSize base = [[[UIApplication sharedApplication] keyWindow] bounds].size;
    return CGSizeMake([self randomIntegerFrom:0 to:(NSInteger)base.width], [self randomIntegerFrom:0 to:(NSInteger)base.height]);
}

+ (CGRect)randomRect {
    CGRect result = CGRectZero;
    result.size = [self randomSize];
    result.origin = [self randomPoint];
    return result;
}

+ (UIColor *)randomColor {
    return [UIColor randomColor];
}

+ (NSString *)randomWord:(NSUInteger)length {
    NSMutableString *resultString = [NSMutableString stringWithCapacity:length];
    NSString *localeCharacters = [NSString stringWithCurrentCharacterSet];
    NSUInteger localeCharactersLength = [localeCharacters length];
    
    for (NSUInteger idx = 0; idx < length; idx++) {
        [resultString appendString:[localeCharacters substringWithRange:NSMakeRange(arc4random() % localeCharactersLength, 1)]];
    }
    
    return [resultString copy];
}

+ (NSInteger)randomIntegerFrom:(NSInteger)from to:(NSInteger)to {
    return (from + (arc4random() % to)) % to;
}

+ (CGFloat)randomFloat {
    CGFloat base = (CGFloat)arc4random() / arc4random();
    return base - floor(base);
}

+ (CGFloat)randomFloatFrom:(NSInteger)from to:(NSInteger)to {
    return [self randomIntegerFrom:from to:to] + [self randomFloat];
}

@end
