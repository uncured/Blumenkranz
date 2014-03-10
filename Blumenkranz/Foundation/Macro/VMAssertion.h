#import <objc/runtime.h>

#ifndef Blumenkranz_VMAssertion_h
#define Blumenkranz_VMAssertion_h

/*
 * Annotates class or instance method as abstract
 */
#define VMAbstract \
    id selfObject = nil; \
    if (class_isMetaClass(object_getClass(self))) { \
        selfObject = self; \
    } else { \
        selfObject = [self class]; \
    } \
    NSAssert(NO, @"%@ method %@ implementation is abstract.", NSStringFromClass(selfObject), NSStringFromSelector(_cmd));

/*
 * Annotates class or instance method as abstract if current class evaluates to given
 */
#define VMAbstractCheck(Class) \
    if ([Class isEqualToString:NSStringFromClass([self class])]) { \
        id selfObject = nil; \
        if (class_isMetaClass(object_getClass(self))) { \
            selfObject = self; \
        } else { \
            selfObject = [self class]; \
        } \
        NSAssert(NO, @"%@ method %@ implementation is abstract.", NSStringFromClass(selfObject), NSStringFromSelector(_cmd)); \
    }

/*
 * Annotates restricted point of class or instance method
 */
#define VMRestricted \
    id selfObject = nil; \
    if (class_isMetaClass(object_getClass(self))) { \
        selfObject = self; \
    } else { \
        selfObject = [self class]; \
    } \
    NSAssert(NO, @"[%@ %@] reached restricted point.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

/*
 * Check for NSString type of given argument
 */
#define VMString(object) \
    if (![object isKindOfClass:[NSString class]]) { \
        NSAssert(NO, @"[%@] is not a string in method %@.", object, NSStringFromSelector(_cmd)); \
    }

/*
 * Check for NSArray type of given argument
 */
#define VMArray(object) \
    if (![object isKindOfClass:[NSArray class]]) { \
        NSAssert(NO, @"[%@] is not an array in method %@.", object, NSStringFromSelector(_cmd)); \
    }

/*
 * Check for NSDictionary type of given argument
 */
#define VMDictionary(object) \
    if (![object isKindOfClass:[NSDictionary class]]) { \
        NSAssert(NO, @"[%@] is not a dictionary in method %@.", object, NSStringFromSelector(_cmd)); \
    }

/*
 * Check given argument for certain class
 */
#define VMCheckClass(object, class) \
    if (!(class && [object isKindOfClass:class])) { \
        NSAssert(NO, @"[%@] is not an instance of class [%@] in method %@.", object, class, NSStringFromSelector(_cmd)); \
    }

/*
 * Check for existing of object
 */
#define VMExist(object) \
    if (!object) { \
        NSAssert(NO, @"Object doesn't exist in method %@.", NSStringFromSelector(_cmd)); \
    }

#endif