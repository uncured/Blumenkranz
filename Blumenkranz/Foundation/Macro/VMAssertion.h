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
    NSAssert([object isKindOfClass:[NSString class]], @"[%@] is not a string in method %@.", object, NSStringFromSelector(_cmd)); \

/*
 * Check for NSNumber type of given argument
 */
#define VMNumber(object) \
    NSAssert([object isKindOfClass:[NSNumber class]], @"[%@] is not a number in method %@.", object, NSStringFromSelector(_cmd)); \

/*
 * Check for NSArray type of given argument
 */
#define VMArray(object) \
    NSAssert([object isKindOfClass:[NSArray class]], @"[%@] is not an array in method %@.", object, NSStringFromSelector(_cmd)); \

/*
 * Check for NSDictionary type of given argument
 */
#define VMDictionary(object) \
    NSAssert([object isKindOfClass:[NSDictionary class]], @"[%@] is not a dictionary in method %@.", object, NSStringFromSelector(_cmd)); \

/*
 * Check for existing of property
 */
#define VMProperty(object) \
    NSAssert([self respondsToSelector:NSSelectorFromString(object)], @"[%@] is not a property in method %@.", object, NSStringFromSelector(_cmd)); \

/*
 * Check given argument for certain class
 */
#define VMCheckClass(object, objectClass) \
    NSAssert((objectClass && [object isKindOfClass:objectClass]), @"[%@] is not an instance of class [%@] in method %@.", object, objectClass, NSStringFromSelector(_cmd)); \

/*
 * Check for existing of object
 */
#define VMExist(object) \
    NSAssert(object, @"Object doesn't exist in method %@.", NSStringFromSelector(_cmd)); \

/*
 * Check for non-existing of object
 */
#define VMNotExist(object) \
    NSAssert(!object, @"Object exists in method %@.", NSStringFromSelector(_cmd)); \

/*
 * Check array to contain only given type of objects
 */
#define VMArrayOfGenericType(array, objectClass) \
    for (id arrayObject in array) { \
        NSAssert([arrayObject isKindOfClass:objectClass], @"Object [%@] is not of type %@ in method %@.", arrayObject, objectClass, NSStringFromSelector(_cmd)); \
    }

/*
 * Check objects to be equal
 */
#define VMEqual(leftObject, rightObject) \
    NSAssert([leftObject isEqual:rightObject], @"Object [%@] is not equal to [%@] in method %@.", leftObject, rightObject, NSStringFromSelector(_cmd)); \

/*
 * Check objects not to be equal
 */
#define VMNotEqual(leftObject, rightObject) \
    NSAssert(![leftObject isEqual:rightObject], @"Object [%@] is equal to [%@] in method %@.", leftObject, rightObject, NSStringFromSelector(_cmd)); \

/*
 * Check object to be positive
 */
#define VMPositive(object) \
    NSAssert(object >= 0, @"Object [%@] is not positive in method %@.", object, NSStringFromSelector(_cmd)); \


/*
 * Check object to be negative
 */
#define VMNegative(object) \
    NSAssert(object < 0, @"Object [%@] is not negative in method %@.", object, NSStringFromSelector(_cmd)); \


#endif