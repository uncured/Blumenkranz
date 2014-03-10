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

@end
