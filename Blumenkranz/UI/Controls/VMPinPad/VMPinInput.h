@interface VMPinInput : UIView
@property (nonatomic, strong, readonly) NSString *string;
@property (nonatomic, assign, readonly, getter=isBlocked) BOOL blocked;

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)inputColor maxSymbols:(NSInteger)maxSymbols;

- (void)pushSymbol:(NSString *)string;

- (NSString *)popSymbol;

- (void)reset;

- (void)setBlockedState:(BOOL)blocked;

@end
