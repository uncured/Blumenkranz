#import "NSObject+VMExtension.h"
#import <objc/runtime.h>

@implementation NSObject (VMExtension)

#pragma mark Singletone object
+ (instancetype)singletone {
    static dispatch_once_t predicate;
    static id sharedObject = nil;
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

#pragma mark Annotation property
- (void)setAnnotation:(id)vmDebugAnnotation {
    objc_setAssociatedObject(self, @selector(annotation), vmDebugAnnotation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)annotation {
    return objc_getAssociatedObject(self, @selector(annotation));
}

#pragma mark Properties introspection
+ (Class)classOfProperty:(NSString *)propertyName {
    Class propertyClass = nil;
    objc_property_t property = class_getProperty(self, [propertyName UTF8String]);
    NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
    NSArray *splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@","];
    if ([splitPropertyAttributes count] > 0){
        NSString *encodeType = splitPropertyAttributes[0];
        NSArray *splitEncodeType = [encodeType componentsSeparatedByString:@"\""];
        NSString *className = splitEncodeType[1];
        propertyClass = NSClassFromString(className);
    }
    return propertyClass;
}

#pragma mark Debug introspection
+ (id)methodDescriptionForClass:(Class)class {
    SEL selector = (class ? NSSelectorFromString(@"__methodDescriptionForClass:") : NSSelectorFromString(@"_methodDescription"));
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSObject instanceMethodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    if (class) {
        [invocation setArgument:&class atIndex:2];
    }
    [invocation invoke];
    NSString *result = nil;
    [invocation getReturnValue:&result];
    return result;
}

+ (id)ivarDescriptionForClass:(Class)class {
    SEL selector = (class ? NSSelectorFromString(@"__ivarDescriptionForClass:") : NSSelectorFromString(@"_ivarDescription"));
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSObject instanceMethodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    if (class) {
        [invocation setArgument:&class atIndex:2];
    }
    [invocation invoke];
    NSString *result = nil;
    [invocation getReturnValue:&result];
    return result;
}

@end
