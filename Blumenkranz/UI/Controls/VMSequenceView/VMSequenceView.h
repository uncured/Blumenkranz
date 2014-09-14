extern NSString * const VMSequenceViewErrorDomain;

@interface VMSequenceView : UIView
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, copy) UIColor *barTintColor;

- (BOOL)setSequence:(NSArray *)sequence animated:(BOOL)animated error:(NSError **)error;

@end