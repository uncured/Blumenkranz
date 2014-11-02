#ifndef Blumenkranz_VMInjection_h
#define Blumenkranz_VMInjection_h

#define DEFAULT_CONTEXT_INITIALIZER @"initWithContext:"
#define IS_SINGLETONE_METHOD_NAME @"vm_isContextSingletone"
#define CONTEXT_NAME_METHOD_NAME @"vm_contextName"

#define SINGLETONE \
+ (BOOL)vm_isContextSingletone { \
    return YES; \
}

#define NOT_SINGLETONE \
+ (BOOL)vm_isContextSingletone { \
    return NO; \
}

#define BIND_NAME(name) \
+ (NSString *)vm_contextName { \
    return name; \
}

#define UNBIND_NAME \
+ (NSString *)vm_contextName { \
    return nil; \
}

#define INJECTION_BEGIN(context_class) \
- (instancetype)initWithContext:(context_class *)context { \
    if (self = [super init]) {

#define INJECT(property, identifier) \
        { \
            if (identifier) { \
                [self setValue:[context provide:(identifier)] forKey:(property)]; \
            } else { \
                [self setValue:[context provide:[[self class] classOfProperty:(property)]] forKey:(property)]; \
            } \
            if ([self conformsToProtocol:@protocol(VMContextInjecting)]) { \
                [self performSelector:@selector(propertyInjected:) withObject:property]; \
            } \
        }

#define INJECTION_END \
        if ([self conformsToProtocol:@protocol(VMContextInjecting)]) { \
            [self performSelector:@selector(objectInitialized)]; \
        } \
    } \
    return self; \
}

#endif
