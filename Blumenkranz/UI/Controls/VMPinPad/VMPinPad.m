#import "VMPinPad.h"
#import "VMPinButton.h"
#include <AudioToolbox/AudioToolbox.h>

static const CGFloat kButtonDimensionSize = 70.0f;
static const CGFloat kButtonOffsetX = 20.0f;
static const CGFloat kButtonOffsetY = 15.0f;
static const NSUInteger kTouchIdButtonIdx = 9;
static const NSUInteger kBackspaceButtonIdx = 11;
static const uint32_t kSystemKeyboardTockSoundID = 1104;

@interface VMPinPad () {
    BOOL _constraintsInstalled;
}
@property (nonatomic, strong) NSMutableArray *buttons;
@end

static void initialize(VMPinPad *self) {
    NSArray *titles = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"", @"0", @""];
    NSArray *subtitles = @[@"", @"ABC", @"DEF", @"GHI", @"JKL", @"MNO", @"PQRS", @"TUV", @"WXYZ", @"", @"", @""];

    self.buttons = [NSMutableArray array];

    for (NSUInteger idx = 0; idx < [titles count]; idx++) {
        VMPinButton *button = [[VMPinButton alloc] initWithFrame:CGRectMake(0, 0, kButtonDimensionSize, kButtonDimensionSize)];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.titleText = titles[idx];
        button.subtitleText = subtitles[idx];
        [self.buttons addObject:button];

        if (idx == kTouchIdButtonIdx) {
            [button addTarget:self action:@selector(touchidButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
            button.borderDisabled = YES;
        } else if (idx == kBackspaceButtonIdx) {
            [button addTarget:self action:@selector(backspaceButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
            button.borderDisabled = YES;
        } else {
            [button addTarget:self action:@selector(numberButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

@implementation VMPinPad

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

#pragma mark IBActions
- (IBAction)numberButtonTaped:(id)sender {
    AudioServicesPlaySystemSound(kSystemKeyboardTockSoundID);
    if (self.didPressNumberButton) {
        self.didPressNumberButton(sender, self);
    }
}

- (IBAction)touchidButtonTaped:(id)sender {
    AudioServicesPlaySystemSound(kSystemKeyboardTockSoundID);
    if (self.didPressTouchIdButton) {
        self.didPressTouchIdButton(sender, self);
    }
}

- (IBAction)backspaceButtonTaped:(id)sender {
    AudioServicesPlaySystemSound(kSystemKeyboardTockSoundID);
    if (self.didPressBackspaceButton) {
        self.didPressBackspaceButton(sender, self);
    }
}

#pragma mark Lifecycle
- (void)layoutSubviews {
    for (VMPinButton *button in self.buttons) {
        [self addSubview:button];
    }

    if (!_constraintsInstalled) {
        [self installConstraints];
        _constraintsInstalled = YES;
    }

    VMPinButton *buttonTouchId = self.buttons[kTouchIdButtonIdx];
    if (self.touchIdIcon) {
        buttonTouchId.image = self.touchIdIcon;
    } else {
        buttonTouchId.hidden = YES;
    }

    VMPinButton *buttonBackspace = self.buttons[kBackspaceButtonIdx];
    if (self.backspaceIcon) {
        buttonBackspace.image = self.backspaceIcon;
    } else {
        buttonBackspace.hidden = YES;
    }

    [super layoutSubviews];
}

- (void)installConstraints {
    for (VMPinButton *button in self.buttons) {
        [button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(size)]"
                                                                       options:(NSLayoutFormatOptions)0
                                                                       metrics:@{ @"size": @(kButtonDimensionSize) }
                                                                         views:NSDictionaryOfVariableBindings(button)
        ]];
        [button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(size)]"
                                                                       options:(NSLayoutFormatOptions)0
                                                                       metrics:@{ @"size": @(kButtonDimensionSize) }
                                                                         views:NSDictionaryOfVariableBindings(button)
        ]];
    }

    // 2nd row layout
    VMPinButton *button5 = self.buttons[4];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button5
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:button5
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:((-kButtonDimensionSize - kButtonOffsetY) / 2.0f)]];

    VMPinButton *button4 = self.buttons[3];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button4
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button5
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:button4
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button5
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:(-kButtonDimensionSize - kButtonOffsetX)]];

    VMPinButton *button6 = self.buttons[5];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button6
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button5
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:button6
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button5
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:(kButtonDimensionSize + kButtonOffsetX)]];

    // 1st row layout
    VMPinButton *button2 = self.buttons[1];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button2
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button5
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:(-kButtonDimensionSize - kButtonOffsetY)]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:button2
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button5
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];

    VMPinButton *button1 = self.buttons[0];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button1
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button2
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:button1
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button2
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:(-kButtonDimensionSize - kButtonOffsetX)]];

    VMPinButton *button3 = self.buttons[2];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button3
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button2
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:button3
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button2
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:(kButtonDimensionSize + kButtonOffsetX)]];

    // 3rd row layout
    VMPinButton *button8 = self.buttons[7];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button8
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button5
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:(kButtonDimensionSize + kButtonOffsetY)]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:button8
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button5
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];

    VMPinButton *button7 = self.buttons[6];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button7
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button8
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:button7
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button8
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:(-kButtonDimensionSize - kButtonOffsetX)]];

    VMPinButton *button9 = self.buttons[8];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button9
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button8
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:button9
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button8
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:(kButtonDimensionSize + kButtonOffsetX)]];

    // 4th row layout
    VMPinButton *button0 = self.buttons[10];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button0
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button8
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:(kButtonDimensionSize + kButtonOffsetY)]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:button0
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button8
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];

    VMPinButton *buttonTouchId = self.buttons[9];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonTouchId
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button0
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonTouchId
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button0
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:(-kButtonDimensionSize - kButtonOffsetX)]];

    VMPinButton *buttonBackspace = self.buttons[11];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonBackspace
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button0
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonBackspace
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button0
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:(kButtonDimensionSize + kButtonOffsetX)]];
}

@end
