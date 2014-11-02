#import "VMTypes.h"

@protocol VMModelValidating <NSObject>

- (BOOL)validate:(VMErrorsBlock)errorCallback;

@end
