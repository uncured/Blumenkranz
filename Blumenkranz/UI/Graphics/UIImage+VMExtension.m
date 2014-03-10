#import "UIImage+VMExtension.h"

@implementation UIImage (VMExtension)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect imageRect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, .0f);
    [color setFill];
    UIRectFill(imageRect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)hollowPattern {
    CGFloat side = 16;
    CGSize size = CGSizeMake(side, side);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    [[UIColor whiteColor] setFill];
    UIRectFill((CGRect){.size = size});
    
    CGRect innerFillRect = CGRectMake(0, 0, side / 2, side / 2);
    [[UIColor colorWithWhite:0.8f alpha:1] setFill];
    UIRectFill(innerFillRect);
    innerFillRect.origin = CGPointMake(side / 2, side / 2);
    UIRectFill(innerFillRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
