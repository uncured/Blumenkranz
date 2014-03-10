@interface VMRandom : NSObject

+ (UIView *)randomView;

+ (CGPoint)randomPoint;

+ (CGSize)randomSize;

+ (CGRect)randomRect;

+ (UIColor *)randomColor;

+ (NSString *)randomWord:(NSUInteger)length;

+ (NSInteger)randomIntegerFrom:(NSInteger)from to:(NSInteger)to;

+ (CGFloat)randomFloat;

+ (CGFloat)randomFloatFrom:(NSInteger)from to:(NSInteger)to;

@end
