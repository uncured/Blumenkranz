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
    if (property == NULL) {
        return nil;
    }
    NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
    NSArray *splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@","];
    if ([splitPropertyAttributes count] > 0){
        NSString *encodeType = splitPropertyAttributes[0];
        NSArray *splitEncodeType = [encodeType componentsSeparatedByString:@"\""];
        if ([splitEncodeType count] > 1) {
            NSString *className = splitEncodeType[1];
            if (![className hasPrefix:@"<"]) {
                propertyClass = NSClassFromString(className);
            }
        } else if ([splitEncodeType count] && [splitEncodeType[0] hasSuffix:@"?"]) {
            propertyClass = NSClassFromString(@"NSBlock");
        }
    }
    return propertyClass;
}

@end

BOOL vmObjectCanBeCopied(id target) {
    return [target respondsToSelector:@selector(copy)] && [target respondsToSelector:@selector(copyWithZone:)];
}

BOOL vmObjectCanBeCopiedMutably(id target) {
    return [target respondsToSelector:@selector(mutableCopy)] && [target respondsToSelector:NSSelectorFromString(@"mutableCopyWithZone:")];
}