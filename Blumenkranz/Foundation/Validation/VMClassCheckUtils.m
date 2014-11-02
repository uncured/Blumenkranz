#import "VMClassCheckUtils.h"
#import <objc/runtime.h>

BOOL vmIsClass(id validationObject) {
    return class_isMetaClass(object_getClass(validationObject));
}

BOOL vmIsClassName(NSString *validationObject) {
    return ( NSClassFromString(validationObject) != nil );
}

BOOL vmIsProtocol(id validationObject) {
    return [@"Protocol" isEqualToString:NSStringFromClass([validationObject class])];
}

BOOL vmIsProtocolName(NSString *validationObject) {
    return ( NSProtocolFromString(validationObject) != nil );
}