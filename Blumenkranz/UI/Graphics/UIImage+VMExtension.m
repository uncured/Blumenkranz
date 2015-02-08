#import "UIImage+VMExtension.h"
#import "VMSingletone.h"
#import "VMAssertion.h"

static UIImage* vm_HollowPatternInner() {
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
    VMStoreAndReturn( vm_HollowPatternInner() )
}

+ (UIImage *)imageFromPattern:(UIImage *)pattern withColor:(UIColor *)color {
    VMExist(pattern);

    CGColorRef patternColor = (color ? [color CGColor] : [[UIColor whiteColor] CGColor]);
    CGImageRef maskRef = pattern.CGImage;
    UIGraphicsBeginImageContext(CGSizeMake(CGImageGetWidth(maskRef), CGImageGetHeight(maskRef)));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, patternColor);
    CGContextFillRect(context, CGRectMake(0, 0, CGImageGetWidth(maskRef), CGImageGetHeight(maskRef)));
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGImageRef mask = CGImageMaskCreate(
            CGImageGetWidth(maskRef),
            CGImageGetHeight(maskRef),
            CGImageGetBitsPerComponent(maskRef),
            CGImageGetBitsPerPixel(maskRef),
            CGImageGetBytesPerRow(maskRef),
            CGImageGetDataProvider(maskRef),
            NULL,
            false
    );
    CGImageRef masked = CGImageCreateWithMask([colorImage CGImage], mask);
    CGImageRelease(mask);
    UIImage *result = [UIImage imageWithCGImage:masked scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(masked);
    return result;
}

+ (UIImage *)roundedRectImageWithSize:(CGSize)size color:(UIColor *)color corners:(UIRectCorner)corners cornerRadius:(CGFloat)radius {
    VMExist(color);
    VMPositive(radius);

    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat actualRadius = (corners ? radius : 0);
    UIRectCorner actualCorners = (corners ? corners : UIRectCornerAllCorners);

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) byRoundingCorners:actualCorners cornerRadii:CGSizeMake(actualRadius, actualRadius)];

    [bezierPath addClip];

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));

    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return [resultImage resizableImageWithCapInsets:UIEdgeInsetsMake(radius, radius, radius, radius)];
}

+ (UIImage *)screenshotFromView:(UIView *)target {
    CGSize fittingSize = [target sizeThatFits:CGSizeZero];
    UIGraphicsBeginImageContextWithOptions(fittingSize, target.opaque, 0.0);
    [target.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *capImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return capImage;
}

+ (UIImage *)blurImage:(UIImage *)target withRadius:(CGFloat)radius {
    return [target blurWithRadius:radius];
}

- (UIImage *)blurWithRadius:(CGFloat)radius {
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:inputImage forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:@(radius) forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[inputImage extent]];
    
    return [[UIImage alloc] initWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];
}

@end
