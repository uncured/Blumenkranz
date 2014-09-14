#import "VMContext.h"
#import "VMContextProviding.h"
#import "VMClassCheckUtils.h"
#import "VMContextBindingManager.h"
#import "VMSingletone.h"
#import "VMInjection.h"

@interface VMContext ()
@property (nonatomic, strong) VMContextBindingManager *bindingManager;
@property (nonatomic, strong) NSMutableDictionary *objectStorage;
@property (nonatomic, strong) NSMutableDictionary *providersStorage;
@property (nonatomic, strong) NSMutableDictionary *providerBlocksStorage;

- (id)vm_storeOnProvide:(id)providedObject;

@end

@implementation VMContext

+ (VMContext *)context {
    VMStoreAndReturn( [[self alloc] init] );
}

+ (SEL)defaultInitializer {
    return NSSelectorFromString(DEFAULT_CONTEXT_INITIALIZER);
}

- (instancetype)init {
    if (self = [super init]) {
        self.bindingManager = [[VMContextBindingManager alloc] init];
        self.objectStorage = [NSMutableDictionary dictionary];
        self.providersStorage = [NSMutableDictionary dictionary];
        self.providerBlocksStorage = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)bindProviderBlock:(VMObjectProvidingBlock)providerBlock for:(id)objectClassifier {
    VMExist(providerBlock);
    VMExist(objectClassifier);
    
    id key = [self keyFor:objectClassifier];
    if (key) {
        VMNotExist(self.providersStorage[key]);
        self.providerBlocksStorage[key] = [providerBlock copy];
    }
}

- (void)bindProvider:(id<VMContextProviding>)provider for:(id)objectClassifier {
    VMExist(provider);
    VMExist(objectClassifier);
    
    id key = [self keyFor:objectClassifier];
    if (key) {
        VMNotExist(self.providerBlocksStorage[key]);
        self.providersStorage[key] = provider;
    }
}

- (void)bindDefaultInitializer:(SEL)initializer withParameteres:(NSArray *)parameters for:(Class)objectClassifier {
    VMExist(initializer);
    VMExist(objectClassifier);
    NSAssert([objectClassifier respondsToSelector:initializer], @"Can't bind %@ initializer to %@ class.", NSStringFromSelector(initializer), NSStringFromClass(objectClassifier));
    
    NSArray *parametersCopy = [parameters copy];
    
    [self bindProviderBlock:^id(){
        
        NSInvocation *initInvocation = [NSInvocation invocationWithMethodSignature:[objectClassifier methodSignatureForSelector:initializer]];
        [initInvocation setSelector:initializer];
        [initInvocation setTarget:[objectClassifier alloc]];

        NSUInteger offset = 2;
        NSUInteger count = [parameters count];
        for (NSUInteger idx = 0; idx < count; idx++) {
            id initArgument = parametersCopy[idx];
            [initInvocation setArgument:&initArgument atIndex:(idx + offset)];
        }
        
        [initInvocation invoke];
        id result = nil;
        [initInvocation getReturnValue:&result];
        return result;
        
    } for:objectClassifier];
}

- (void)unbindProvider:(id)objectClassifier {
    VMExist(objectClassifier);
    
    id key = [self keyFor:objectClassifier];
    if (key) {
        [self.providersStorage removeObjectForKey:key];
        [self.providerBlocksStorage removeObjectForKey:key];
    }
}

- (void)registerSingletone:(id)object withName:(NSString *)name {
    VMExist(object);
    VMExist(name);
    VMNotExist(self.objectStorage[name]);
    
    [self.bindingManager bind:name to:[object class]];
    
    self.objectStorage[name] = object;
}

- (void)resetContext {
    self.objectStorage = [NSMutableDictionary dictionary];
    self.providersStorage = [NSMutableDictionary dictionary];
    self.providerBlocksStorage = [NSMutableDictionary dictionary];
    [self.bindingManager unbindAll];
}

#pragma mark VMContextProviding interface
- (id)provide:(id)objectClassifier {
    VMExist(objectClassifier);
    
    id key = [self keyFor:objectClassifier];
    if (key) {
        id singletoneObject = self.objectStorage[key];
        if (singletoneObject) {
            return singletoneObject;
        }
        
        id binding = [self.bindingManager bindTarget:objectClassifier];
        if (binding) {
            return [self provide:binding];
        }
        
        id<VMContextProviding> provider = self.providersStorage[key];
        if (provider) {
            return [self vm_storeOnProvide:[provider provide:objectClassifier]];
        }
        
        VMObjectProvidingBlock providerBlock = self.providerBlocksStorage[key];
        if (providerBlock) {
            return [self vm_storeOnProvide:providerBlock()];
        }
        
        if (vmIsClass(objectClassifier)) {
            SEL initSelector = [[self class] defaultInitializer];
            if ([objectClassifier respondsToSelector:initSelector]) {
                
                NSInvocation *initInvocation = [NSInvocation invocationWithMethodSignature:[objectClassifier methodSignatureForSelector:initSelector]];
                [initInvocation setSelector:initSelector];
                [initInvocation setTarget:[objectClassifier alloc]];
                id selfRef = self;
                [initInvocation setArgument:&selfRef atIndex:2];
                [initInvocation invoke];
                id result = nil;
                [initInvocation getReturnValue:&result];
                return [self vm_storeOnProvide:result];
                
            } else {
                return [self vm_storeOnProvide:[[objectClassifier alloc] init]];
            }
        }
    }
    
    VMLog(@"WARNING: Context cannot provide anything for %@ key", objectClassifier);
    
    return nil;
}

- (id)vm_storeOnProvide:(id)providedObject {
    if (IS_SIGNLETONE(providedObject)) {
        
        [self registerSingletone:providedObject withName:BINDED_NAME(providedObject)];
        
    } else if (IS_NAMED(providedObject)) {
        
        id bindedName = BINDED_NAME(providedObject);
        if (![self.bindingManager bindTarget:bindedName]) {
            [self.bindingManager bind:BINDED_NAME(providedObject) to:[providedObject class]];
        }
        
    }
    return providedObject;
}

#pragma mark VMKeyProviding interface
- (id)keyFor:(id)keyBase {
    if (vmIsClass(keyBase)) {
        if (IS_NAMED(keyBase)) {
            return BINDED_NAME(keyBase);
        } else {
            return NSStringFromClass(keyBase);
        }
    } else if (vmIsProtocol(keyBase)) {
        return NSStringFromProtocol(keyBase);
    } else if ([keyBase isKindOfClass:[NSString class]]) {
        return keyBase;
    }
    
    VMLog(@"WARNING: Cannot create key");
    
    return nil;
}

#pragma mark VMContextBindingManager forwarding
- (void)bind:(id)source to:(id)target {
    [self.bindingManager bind:source to:target];
}

- (void)unbind:(id)source {
    [self.bindingManager unbind:source];
}

@end
