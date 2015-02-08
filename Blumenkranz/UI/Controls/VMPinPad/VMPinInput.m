#import "VMPinInput.h"
#import "UIColor+VMExtension.h"

static const NSInteger kMaxSymbolsDefault = 4;
static const CGFloat kCircleSize = 14.0f;
static const CGFloat kCircleOffset = 14.0f;
static const CGFloat kAnimationDuration = 0.1f;
static NSString * const kDefaultColor = @"#464646";

@interface VMPinInput () {
    BOOL _constraintsInstalled;
}
@property (nonatomic, assign, getter=isBlocked) BOOL blocked;
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSMutableArray *circles;
@property (nonatomic, strong) UIColor *inputColor;
@property (nonatomic, assign) NSInteger maxSymbols;
@end

static void initialize(VMPinInput *self) {
    self.string = @"";
    self.circles = [NSMutableArray array];
    CGColorRef color = [self.inputColor CGColor];
    for (NSUInteger idx = 0; idx < self.maxSymbols; idx++) {
        UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCircleSize, kCircleSize)];
        circle.backgroundColor = [UIColor clearColor];
        circle.clipsToBounds = YES;
        circle.layer.borderWidth = 1.5f;
        circle.layer.borderColor = color;
        circle.layer.cornerRadius = kCircleSize / 2.0f;
        circle.translatesAutoresizingMaskIntoConstraints = NO;
        [self.circles addObject:circle];
    }
}

@implementation VMPinInput

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)inputColor maxSymbols:(NSInteger)maxSymbols {
    if (self = [super initWithFrame:frame]) {
        self.maxSymbols = maxSymbols;
        self.inputColor = (inputColor ? inputColor : [UIColor colorWithHex:kDefaultColor]);
        initialize(self);
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.maxSymbols = kMaxSymbolsDefault;
        self.inputColor = [UIColor colorWithHex:kDefaultColor];
        initialize(self);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        initialize(self);
    }
    return self;
}

- (void)layoutSubviews {
    for (UIView *circle in self.circles) {
        [self addSubview:circle];
    }

    if (!_constraintsInstalled) {
        [self installConstraints];
        _constraintsInstalled = YES;
    }

    [super layoutSubviews];
}

- (void)installConstraints {
    if ([self.circles count]) {

        for (UIView *circle in self.circles) {
            [circle addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[circle(size)]"
                                                                           options:(NSLayoutFormatOptions)0
                                                                           metrics:@{ @"size": @(kCircleSize) }
                                                                             views:NSDictionaryOfVariableBindings(circle)
            ]];
            [circle addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[circle(size)]"
                                                                           options:(NSLayoutFormatOptions)0
                                                                           metrics:@{ @"size": @(kCircleSize) }
                                                                             views:NSDictionaryOfVariableBindings(circle)
            ]];
        }

        BOOL isEven = (self.maxSymbols % 2 == 0);

        NSInteger midIdx = (self.maxSymbols - 1) / 2;
        UIView *middleCircle = self.circles[(NSUInteger)midIdx];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:middleCircle
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:(isEven ? (-kCircleOffset - kCircleOffset) / 2 : 0.0f)]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:middleCircle
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0]];

        UIView *relativeCircle = middleCircle;
        for (NSInteger idx = midIdx - 1; idx >= 0; idx--) {

            UIView *leftCircle = self.circles[(NSUInteger)idx];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:leftCircle
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:relativeCircle
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:-kCircleOffset - kCircleOffset]];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:leftCircle
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:relativeCircle
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0]];

            relativeCircle = leftCircle;
        }

        relativeCircle = middleCircle;
        for (NSInteger idx = midIdx + 1; idx < self.maxSymbols; idx++) {

            UIView *rightCircle = self.circles[(NSUInteger)idx];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:rightCircle
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:relativeCircle
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:kCircleOffset + kCircleOffset]];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:rightCircle
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:relativeCircle
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0]];

            relativeCircle = rightCircle;
        }
    }
}

- (void)pushSymbol:(NSString *)string {
    NSAssert(string.length == 1, @"Only 1 character stings allowed");

    if (!self.blocked && (self.string.length < self.maxSymbols)) {
        UIView *circle = self.circles[self.string.length];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            circle.backgroundColor = self.inputColor;
        }];

        self.string = [self.string stringByAppendingString:string];
    }
}

- (NSString *)popSymbol {
    if (!self.blocked && self.string.length) {
        NSString *result = [self.string substringFromIndex:(self.string.length - 1)];

        UIView *circle = self.circles[self.string.length - 1];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            circle.backgroundColor = [UIColor clearColor];
        }];

        self.string = [self.string substringToIndex:(self.string.length - 1)];
        return result;
    }
    return nil;
}

- (void)reset {
    self.blocked = NO;
    self.string = @"";
    for (UIView *circle in self.circles) {
        circle.backgroundColor = [UIColor clearColor];
    }
}

- (void)setBlockedState:(BOOL)blocked {
    if (self.blocked != blocked) {
        self.blocked = blocked;
    }
}

@end
