#import "VMTypes.h"

@protocol VMActiveModelManipulating <NSObject>

- (void)save:(VMErrorsBlock)errorCallback;

- (void)remove:(VMErrorsBlock)errorCallback;

- (void)update:(VMErrorsBlock)errorCallback;

- (void)read:(NSDictionary *)parameters callback:(VMErrorsBlock)errorCallback;

@end
