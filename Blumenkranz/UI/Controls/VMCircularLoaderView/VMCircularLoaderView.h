@interface VMCircularLoaderView : UIView
@property (nonatomic, assign, readonly) uint8_t value;

- (void)tick:(uint8_t)value;

- (void)reset;

@end
