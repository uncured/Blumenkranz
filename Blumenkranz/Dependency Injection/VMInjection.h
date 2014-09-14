#ifndef Blumenkranz_VMInjection_h
#define Blumenkranz_VMInjection_h

#define DEFAULT_CONTEXT_INITIALIZER @"initWithContext:"

#define IS_SIGNLETONE(object) [(object) respondsToSelector:NSSelectorFromString(@"vm_isContextSingletone")]

#define SINGLETONE \
- (BOOL)vm_isContextSingletone { \
    return YES; \
} \
+ (BOOL)vm_isContextSingletone { \
    return YES; \
}

#define IS_NAMED(object) [(object) respondsToSelector:NSSelectorFromString(@"vm_isContextName")]

#define BINDED_NAME(object) ([(object) respondsToSelector:NSSelectorFromString(@"vm_isContextName")] ? [(object) valueForKey:@"vm_isContextName"] : NSStringFromClass([(object) class]))

#define BIND_NAME(name) \
- (NSString *)vm_isContextName { \
    return name; \
} \
+ (NSString *)vm_isContextName { \
    return name; \
}

#define INJECTION_BEGIN(context_class) \
- (instancetype)initWithContext:(context_class *)context { \
    if (self = [super init]) {

#define INJECT(property, identifier) \
        { \
            if (identifier) { \
                [self setValue:[context provide:(identifier)] forKey:(property)]; \
            } else { \
                [self setValue:[context provide:[[self class] classOfProperty:property]] forKey:(property)]; \
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
