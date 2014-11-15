@interface UIImage (VMExtension)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)hollowPattern;

+ (UIImage *)screenshotFromView:(UIView *)target;

+ (UIImage *)blurImage:(UIImage *)target withRadius:(CGFloat)radius;

- (UIImage *)blurWithRadius:(CGFloat)radius;

@end
