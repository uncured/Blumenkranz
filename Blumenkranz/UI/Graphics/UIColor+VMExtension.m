#import "UIColor+VMExtension.h"
#import "UIImage+VMExtension.h"
#import "VMSingletone.h"

@implementation UIColor (VMExtension)

+ (UIColor *)randomColor {
    return [UIColor colorWithRedComponent:(arc4random() % 255)
                           greenComponent:(arc4random() % 255)
                            blueComponent:(arc4random() % 255)
                                    alpha:1];
}

+ (UIColor *)colorWithRedComponent:(CGFloat)red greenComponent:(CGFloat)green blueComponent:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0f
                           green:green/255.0f
                            blue:blue/255.0f
                           alpha:alpha];
}

+ (UIColor *)colorWithArray:(NSArray *)colorArray {
    switch ([colorArray count]) {
        case 4: {
            return [UIColor colorWithRedComponent:[[colorArray objectAtIndex:0] floatValue]
                                   greenComponent:[[colorArray objectAtIndex:1] floatValue]
                                    blueComponent:[[colorArray objectAtIndex:2] floatValue]
                                            alpha:[[colorArray objectAtIndex:3] floatValue] / 255];
        }
        case 3: {
            return [UIColor colorWithRedComponent:[[colorArray objectAtIndex:0] floatValue]
                                   greenComponent:[[colorArray objectAtIndex:1] floatValue]
                                    blueComponent:[[colorArray objectAtIndex:2] floatValue]
                                            alpha:1.0f];
        }
        default: {
            return nil;
        }
    }
}

+ (UIColor *)colorWithHex:(NSString *)hexString {
    NSScanner *colorScanner;
    NSMutableArray *colorArray = [NSMutableArray array];
    for (NSUInteger pos = 1; pos < [hexString length]; pos += 2) {
        colorScanner = [NSScanner scannerWithString:[hexString substringWithRange:NSMakeRange(pos, 2)]];
        uint32_t colorComponent;
        [colorScanner scanHexInt:&colorComponent];
        [colorArray addObject:[NSNumber numberWithInteger:colorComponent]];
    }
    return [UIColor colorWithArray:colorArray];
}

+ (UIColor *)hollowBackgroundColor {
    VMStoreAndReturn( [UIColor colorWithPatternImage:[UIImage hollowPattern]] )
}

- (NSString *)hexValue {
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return [NSString stringWithFormat:@"#%02X%02X%02X%02X", (int32_t)(red * 255.0f), (int32_t)(green * 255.0f), (int32_t)(blue * 255.0f), (int32_t)(alpha * 255.0f)];
}

@end
