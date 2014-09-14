#import "VMCircularLoaderView.h"

static const CGFloat kInnerCircleRadius = 0.2f;
static const CGFloat kOutterCircleRadius = 0.8f;

@interface VMCircularLoaderView ()
@property (nonatomic, strong) UILabel *text;
@property (nonatomic, weak) CAShapeLayer *circleInner;
@property (nonatomic, weak) CAShapeLayer *circleOutter;
@property (nonatomic, weak) CAShapeLayer *circleOutterFill;
@property (nonatomic, assign) uint8_t value;
@end

static void initialize(VMCircularLoaderView *self) {
    self.value = 0;
    
    self.text = [[UILabel alloc] initWithFrame:CGRectZero];
    self.text.autoresizingMask = UIViewAutoresizingNone;
    self.text.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30.0f];
    self.text.textAlignment = NSTextAlignmentCenter;
    self.text.backgroundColor = [UIColor clearColor];
    self.text.textColor = [UIColor blackColor];
}

@implementation VMCircularLoaderView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        initialize(self);
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    initialize(self);
}

- (void)drawRect:(CGRect)rect {
    for (NSUInteger idx = [[self.layer sublayers] count]; idx > 0; idx--) {
        CALayer *layer = [[self.layer sublayers] objectAtIndex:(idx - 1)];
        if ([layer isKindOfClass:[CAShapeLayer class]]) {
            [layer removeAllAnimations];
            [layer removeFromSuperlayer];
        }
    }
    
    CAShapeLayer *circleOutter = [self drawCircle:(self.bounds.size.height * kOutterCircleRadius / 2) width:28.0f fillColor:[[UIColor clearColor] CGColor] strokeColor:[[UIColor lightGrayColor] CGColor]];
    [self.layer insertSublayer:circleOutter atIndex:0];
    self.circleOutter = circleOutter;
    
    CAShapeLayer *circleOutterFill = [self drawCircle:(self.bounds.size.height * kOutterCircleRadius / 2) width:28.0f fillColor:[[UIColor clearColor] CGColor] strokeColor:[[UIColor greenColor] CGColor]];
    circleOutterFill.strokeEnd = 0.0f;
    [self.layer insertSublayer:circleOutterFill atIndex:1];
    self.circleOutterFill = circleOutterFill;
    
    CAShapeLayer *circleInner = [self drawCircle:(self.bounds.size.height * kInnerCircleRadius / 2) width:1.0f fillColor:[[UIColor lightGrayColor] CGColor] strokeColor:[[UIColor blackColor] CGColor]];
    [self.layer addSublayer:circleInner];
    self.circleInner = circleInner;
    
    CGFloat side = (self.bounds.size.height * kInnerCircleRadius);
    self.text.frame = CGRectMake(CGRectGetMidX(self.bounds) - side / 2, CGRectGetMidY(self.bounds) - side / 2, side, side);
    if (self.value < 100) {
        self.text.text = [NSString stringWithFormat:@"%02d", self.value];
    } else {
        self.text.text = @"100";
    }
    
    [self addSubview:self.text];
}

- (CAShapeLayer *)drawCircle:(CGFloat)radius width:(CGFloat)width fillColor:(CGColorRef)fillColor strokeColor:(CGColorRef)strokeColor {
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2 * radius, 2 * radius) cornerRadius:radius].CGPath;
    circle.anchorPoint = CGPointMake(.5f, .5f);
    circle.frame = CGRectMake(CGRectGetMidX(self.bounds) - radius, CGRectGetMidY(self.bounds) - radius, 2 * radius, 2 * radius);
    
    if (fillColor) {
        circle.fillColor = fillColor;
    }
    
    if (strokeColor) {
        circle.strokeColor = strokeColor;
    }
    
    circle.lineWidth = width;
    return circle;
}

- (void)tick:(uint8_t)value {
    
    CAShapeLayer *circleInner = [self drawCircle:(self.bounds.size.height * kInnerCircleRadius / 2) width:1.0f fillColor:[[UIColor clearColor] CGColor] strokeColor:[[UIColor greenColor] CGColor]];
    CAShapeLayer *circleOuter = [self drawCircle:(self.bounds.size.height * kOutterCircleRadius / 2 + 13.0f) width:1.0f fillColor:[[UIColor clearColor] CGColor] strokeColor:[[UIColor greenColor] CGColor]];
    
    circleInner.strokeStart = (CGFloat)self.value / 100;
    circleOuter.strokeStart = (CGFloat)self.value / 100;
    
    if ((self.value + value) > 100) {
        self.value = 100;
    } else {
        self.value += value;
    }
    
    circleInner.strokeEnd = (CGFloat)self.value / 100;
    circleOuter.strokeEnd = (CGFloat)self.value / 100;
    
    NSNumber *n = @(self.value);
    
    [self.layer insertSublayer:circleInner atIndex:1];
    
    CAKeyframeAnimation *strokeAnim = [CAKeyframeAnimation animationWithKeyPath:@"lineWidth"];
    strokeAnim.duration = 1.2f;
    strokeAnim.repeatCount = 1;
    [strokeAnim setKeyTimes:@[@(0), @(.7f), @(1.0f)]];
    [strokeAnim setValues:@[@(1.0f), @(7.0f), @(7.0f)]];
    strokeAnim.removedOnCompletion = YES;
    [circleInner addAnimation:strokeAnim forKey:@"strokeAnim"];
    circleInner.lineWidth = 7.0f;
    
    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnim.duration = 1.2f;
    scaleAnim.repeatCount = 1;
    [scaleAnim setKeyTimes:@[@(0), @(.7f), @(.75f), @(.8f), @(.85f), @(.9f), @(.95f), @(1.0f)]];
    [scaleAnim setValues:@[@(1.0f), @(1.0f), @(1.1f), @(1.3f), @(1.7f), @(2.3f), @(4.0f)]];
    scaleAnim.delegate = self;
    scaleAnim.removedOnCompletion = YES;
    [scaleAnim setValue:n forKey:@"arc"];
    [scaleAnim setValue:circleInner forKey:@"arc.layer"];
    [circleInner addAnimation:scaleAnim forKey:@"scaleAnim"];
    circleInner.transform = CATransform3DMakeScale(4.0f, 4.0f, 0);
    
    if ([n intValue] < 100) {
        [self.layer insertSublayer:circleOuter atIndex:0];
        
        CAKeyframeAnimation *scaleOutterAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        scaleOutterAnim.duration = 1.8f;
        scaleOutterAnim.repeatCount = 1;
        [scaleOutterAnim setKeyTimes:@[@(0), @(0.66f), @(0.75f), @(0.85f), @(0.95f), @(1.0f)]];
        [scaleOutterAnim setValues:@[@(1.0f), @(1.0f), @(1.12f), @(1.16f), @(1.18f), @(1.2f)]];
        scaleOutterAnim.removedOnCompletion = YES;
        [circleOuter addAnimation:scaleOutterAnim forKey:@"scaleOutterAnim"];
        
        CAKeyframeAnimation *fadeOutterAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        fadeOutterAnim.duration = 1.8f;
        fadeOutterAnim.repeatCount = 1;
        [scaleOutterAnim setKeyTimes:@[@(0), @(0.66f), @(0.75f), @(0.85f), @(0.95f), @(1.0f)]];
        [fadeOutterAnim setValues:@[@(1.0f), @(1.0f), @(0.6f), @(0.5f), @(0.3f), @(0.2f)]];
        fadeOutterAnim.removedOnCompletion = YES;
        fadeOutterAnim.delegate = self;
        [fadeOutterAnim setValue:circleOuter forKey:@"arc.layer"];
        [circleOuter addAnimation:fadeOutterAnim forKey:@"fadeOutterAnim"];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!flag) {
        return;
    }
    NSNumber *n = [anim valueForKey:@"arc"];
    if (n) {
        if ([n intValue] < 100) {
            self.text.text = [NSString stringWithFormat:@"%02d", [n intValue]];
        } else {
            self.text.text = @"100";
            [self complete];
        }
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.circleOutterFill.strokeEnd = (CGFloat)[n doubleValue] / 100;
        [CATransaction commit];
    }
    CAShapeLayer *l = [anim valueForKey:@"arc.layer"];
    [l removeFromSuperlayer];
}

- (void)complete {
    [self.circleOutter removeFromSuperlayer];
    
    CAKeyframeAnimation *scaleOutterAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleOutterAnim.duration = 0.6f;
    scaleOutterAnim.repeatCount = 1;
    [scaleOutterAnim setKeyTimes:@[@(0), @(0.35f), @(0.45f), @(0.5f), @(0.55f), @(0.65f), @(1.0f)]];
    [scaleOutterAnim setValues:@[@(1.0f), @(1.12f), @(1.16f), @(1.2f), @(1.0f), @(0.5f), @(0.25f)]];
    scaleOutterAnim.removedOnCompletion = YES;
    [self.circleOutterFill addAnimation:scaleOutterAnim forKey:@"scaleOutterAnim"];
    
    CAKeyframeAnimation *fadeOutterAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    fadeOutterAnim.duration = 0.6f;
    fadeOutterAnim.repeatCount = 1;
    [fadeOutterAnim setKeyTimes:@[@(0), @(0.35f), @(0.45f), @(0.5f), @(0.55f), @(0.65f), @(1.0f)]];
    [fadeOutterAnim setValues:@[@(0.4f), @(0.6f), @(0.8f), @(1.0f), @(0.8f), @(0.6f), @(0.4f)]];
    fadeOutterAnim.removedOnCompletion = YES;
    fadeOutterAnim.delegate = self;
    [fadeOutterAnim setValue:self.circleOutterFill forKey:@"arc.layer"];
    [self.circleOutterFill addAnimation:fadeOutterAnim forKey:@"fadeOutterAnim"];
}

- (void)reset {
    self.value = 0;
    [self setNeedsDisplay];
}

@end
