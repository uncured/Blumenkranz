@interface UIImage (VMExtension)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)hollowPattern;

+ (UIImage *)imageFromPattern:(UIImage *)pattern withColor:(UIColor *)color;

+ (UIImage *)roundedRectImageWithSize:(CGSize)size color:(UIColor *)color corners:(UIRectCorner)corners cornerRadius:(CGFloat)radius;

+ (UIImage *)screenshotFromView:(UIView *)target;

+ (UIImage *)blurImage:(UIImage *)target withRadius:(CGFloat)radius;

- (UIImage *)blurWithRadius:(CGFloat)radius;

@end
