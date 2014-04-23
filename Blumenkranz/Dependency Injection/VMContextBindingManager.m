#import "VMContextBindingManager.h"
#import "VMValidation.h"

@interface VMContextBindingManager ()
@property (nonatomic, strong) NSMutableDictionary *bindings;
@end

@implementation VMContextBindingManager

- (instancetype)init {
    if (self = [super init]) {
        self.bindings = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)bind:(id)source to:(id)target {
    VMExist(source);
    VMExist(target);
    VMNotEqual(source, target);
    
    id existingTarget = [self bindTarget:source];
    VMNotExist(existingTarget);
    
    id key = [self keyFor:source];
    if (key) {
        self.bindings[key] = target;
    }
}

- (void)unbind:(id)source {
    VMExist(source);

    id target = [self bindTarget:source];
    if (target) {
        id key = [self keyFor:source];
        if (key) {
            [self.bindings removeObjectForKey:key];
        }
    }
    
    if (!target) {
        VMLog(@"WARNING: No binding for %@. Can't unbind.", source);
    }
}

- (void)unbindAll {
    self.bindings = [NSMutableDictionary dictionary];
}

- (id)bindTarget:(id)source {
    VMExist(source);
    
    id key = [self keyFor:source];
    if (key) {
        return self.bindings[key];
    }
    return nil;
}

#pragma mark VMKeyProviding interface
- (id)keyFor:(id)keyBase {
    if (vmIsClass(keyBase)) {
        return NSStringFromClass(keyBase);
    } else if (vmIsProtocol(keyBase)) {
        return NSStringFromProtocol(keyBase);
    } else if ([keyBase isKindOfClass:[NSString class]]) {
        return keyBase;
    }
    
    VMLog(@"WARNING: Cannot create key");
    
    return nil;
}

@end
