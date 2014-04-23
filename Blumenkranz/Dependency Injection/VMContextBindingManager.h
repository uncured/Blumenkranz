#import "VMKeyProviding.h"

@interface VMContextBindingManager : NSObject <VMKeyProviding>

- (void)bind:(id)source to:(id)target;

- (void)unbind:(id)source;

- (void)unbindAll;

- (id)bindTarget:(id)source;

@end
