@protocol VMActiveModelManipulating <NSObject>

- (void)save:(VMErrorsBlock)errorCallback;

- (void)remove:(VMErrorsBlock)errorCallback;

- (void)update:(VMErrorsBlock)errorCallback;

- (void)read:(NSDictionary *)parameters callback:(VMErrorsBlock)errorCallback;

- (BOOL)validate:(VMErrorsBlock)errorCallback;

@end
