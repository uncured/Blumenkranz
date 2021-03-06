#import "VMContextProviding.h"
#import "VMKeyProviding.h"
#import "VMTypes.h"

@interface VMContext : NSObject <VMContextProviding, VMKeyProviding>

+ (VMContext *)context;

+ (SEL)defaultInitializer;

- (void)bindProviderBlock:(VMObjectProvidingBlock)providerBlock for:(id)objectClassifier;

- (void)bindProvider:(id<VMContextProviding>)provider for:(id)objectClassifier;

- (void)bindDefaultInitializer:(SEL)initializer withParameteres:(NSArray *)parameters for:(Class)objectClassifier;

- (void)unbindProviderFor:(id)objectClassifier;

- (void)registerSingletone:(id)object withName:(NSString *)name;

- (void)resetContext;

@end

@interface VMContext (VMContextBindingManagerForwarding)

- (void)bind:(id)source to:(id)target;

- (void)unbind:(id)source;

@end
