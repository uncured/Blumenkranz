#import "VMPinButton.h"
#import "UIColor+VMExtension.h"

static const CGFloat kAnimationDuration = 0.15f;
static NSString * const kDefaultColor = @"#464646";

@interface VMPinButton ()
@property (nonatomic, strong) UILabel *mainTitleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIView *selectedView;
@end

static void initialize(VMPinButton *self) {
    self.selectedView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.05f];
    self.selectedView.alpha = 0.0f;
    self.selectedView.translatesAutoresizingMaskIntoConstraints = YES;
    self.selectedView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:self.selectedView];

    self.iconView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.iconView.backgroundColor = [UIColor clearColor];
    self.iconView.translatesAutoresizingMaskIntoConstraints = YES;
    self.iconView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.iconView.contentMode = UIViewContentModeCenter;
    [self addSubview:self.iconView];

    self.mainTitleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.mainTitleLabel.backgroundColor = [UIColor clearColor];
    self.mainTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:32.0f];
    self.mainTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.mainTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:self.mainTitleLabel];

    UILabel *mainLabel = self.mainTitleLabel;
    [mainLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[mainLabel(40)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(mainLabel)
    ]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[mainLabel]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(mainLabel)
    ]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mainLabel]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(mainLabel)
    ]];

    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.subtitleLabel.backgroundColor = [UIColor clearColor];
    self.subtitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:9.0f];
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.subtitleLabel];

    UILabel *subtitleLabel = self.subtitleLabel;
    [subtitleLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[subtitleLabel(20)]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(subtitleLabel)
    ]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[subtitleLabel]-7-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(subtitleLabel)
    ]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[subtitleLabel]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(subtitleLabel)
    ]];

    self.clipsToBounds = YES;
}

@implementation VMPinButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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

#pragma mark Lifecycle
- (void)layoutSubviews {
    [super layoutSubviews];

    [self prepareApperance];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    [self prepareApperance];
}

#pragma mark Layout
- (void)prepareApperance {
    static UIColor *defaultColor = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        defaultColor = [UIColor colorWithHex:kDefaultColor];
    });

    self.layer.borderColor = (self.borderColor ? [self.borderColor CGColor] : [defaultColor CGColor]);
    self.layer.borderWidth = (self.borderDisabled ? 0.0f : 1.5f);
    self.layer.cornerRadius = self.frame.size.height / 2.0f;

    self.mainTitleLabel.textColor = (self.titleColor ? self.titleColor : defaultColor);
    self.mainTitleLabel.highlightedTextColor = self.mainTitleLabel.textColor;
    self.subtitleLabel.textColor = self.mainTitleLabel.textColor;
    self.subtitleLabel.highlightedTextColor = self.mainTitleLabel.textColor;

    self.layer.borderColor = (self.borderColor ? [self.borderColor CGColor] : [[UIColor colorWithHex:kDefaultColor] CGColor]);

    if (self.titleText) {
        self.mainTitleLabel.text = self.titleText;
        self.accessibilityIdentifier = self.titleText;
    }

    if (self.subtitleText) {
        self.subtitleLabel.text = self.subtitleText;
    }

    if (self.image) {
        self.iconView.image = self.image;
    }
}

#pragma mark Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    __typeof__(self) __weak weakSelf = self;
    [UIView animateWithDuration:kAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.selectedView.alpha = 1.0f;
        [weakSelf setHighlighted:YES];
    } completion:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    __typeof__(self) __weak weakSelf = self;
    [UIView animateWithDuration:kAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         weakSelf.selectedView.alpha = 0.0f;
                         [weakSelf setHighlighted:NO];
                     } completion:nil];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    self.mainTitleLabel.highlighted = highlighted;
    self.subtitleLabel.highlighted = highlighted;
}

@end
