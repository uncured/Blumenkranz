@protocol VMContextInjecting <NSObject>

- (void)propertyInjected:(NSString *)propertyName;

- (void)objectInitialized;

@end
