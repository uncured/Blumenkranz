#import "VMSequenceView.h"

NSString * const VMSequenceViewErrorDomain = @"ru.visualmyth.blumenkranz.VMSequenceView";
static const NSTimeInterval VMSequenceViewAnimationDuration = .3f;

@interface VMSequenceView () {
    BOOL _animated;
}
@property (nonatomic, copy) NSArray *sequence;
@end

@implementation VMSequenceView

- (void)setup {
    self.transform = CGAffineTransformMakeRotation((CGFloat)M_PI);
    self.barTintColor = [UIColor blueColor];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    self.barTintColor = nil;
    self.sequence = nil;
}

- (BOOL)setSequence:(NSArray *)sequence animated:(BOOL)animated error:(NSError **)error {
    VMArrayOfGenericType(sequence, [NSNumber class])
    
    if (!self.maxValue) {
        NSNumber *maxValue = @(0);
        for (NSNumber *sequenceObject in sequence) {
            if ([sequenceObject compare:maxValue] == NSOrderedDescending) {
                maxValue = sequenceObject;
            }
        }
        self.maxValue = [maxValue floatValue];
    }
    
    self.sequence = sequence;
    _animated = animated;
    
    [self setNeedsLayout];
    
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSUInteger barNumberToDisplay = [self.sequence count];
    
    if (barNumberToDisplay) {
        CGFloat barWidth = self.frame.size.width / barNumberToDisplay;
        NSUInteger barNumberDisplayed = [self.layer.sublayers count];
        
        if (barNumberToDisplay < barNumberDisplayed) {
            
            for (NSUInteger idx = 0; idx < (barNumberDisplayed - barNumberToDisplay); idx++) {
                [[self.layer.sublayers objectAtIndex:idx] removeFromSuperlayer];
            }
            
        } else if (barNumberToDisplay > barNumberDisplayed) {
            
            for (NSUInteger idx = 0; idx < (barNumberToDisplay - barNumberDisplayed); idx++) {
                CALayer *layer = [CALayer layer];
                layer.backgroundColor = self.barTintColor.CGColor;
                [self.layer addSublayer:layer];
            }
            
        }
        
        for (NSUInteger idx = 0; idx < barNumberToDisplay; idx++) {
            CALayer *layer = [self.layer.sublayers objectAtIndex:idx];
            layer.frame = CGRectMake(
                                     barWidth * idx,
                                     0,
                                     barWidth,
                                     layer.frame.size.height);
        }
        
        for (NSUInteger idx = 0; idx < barNumberToDisplay; idx++) {
            CALayer *layer = [self.layer.sublayers objectAtIndex:barNumberToDisplay - idx - 1];
            CGFloat sequenceItem = [[self.sequence objectAtIndex:idx] floatValue];
            
            CGRect layerFrame = layer.frame;
            layerFrame.size.height = self.frame.size.height / self.maxValue * sequenceItem;
            
            if (_animated) {
                
                [UIView animateWithDuration:VMSequenceViewAnimationDuration animations:^{
                    layer.frame = layerFrame;
                }];
                
            } else {
                
                layer.frame = layerFrame;
                
            }
            
        }
    }
    
    _animated = NO;
}

@end