@interface UIColor (VMExtension)

+ (UIColor *)colorWithRedComponent:(CGFloat)red greenComponent:(CGFloat)green blueComponent:(CGFloat)blue alpha:(CGFloat)alpha;

+ (UIColor *)colorWithArray:(NSArray *)colorArray;

+ (UIColor *)colorWithHex:(NSString *)hexString;

+ (UIColor *)randomColor;

+ (UIColor *)hollowBackgroundColor;

- (NSString *)hexValue;

@end
