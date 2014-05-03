#ifndef Blumenkranz_VMActiveModelValidation_h
#define Blumenkranz_VMActiveModelValidation_h

#define ACTIVE_MODEL_VALIDATION_METHOD_NAME @"vm_validate:"

#define VALIDATION_BEGIN \
- (BOOL)vm_validate:(VMErrorsBlock)errorCallback { \
    NSMutableArray *errors = [NSMutableArray array];

#define VALIDATION_END \
    if (errorCallback) { \
        errorCallback([NSArray arrayWithArray:errors]); \
    } \
    return [errors count] == 0; \
}

#define VALIDATE_ACCEPTS(property, accepts, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(accepts) isKindOfClass:[NSArray class]], @"ACCEPTS validation param of %@ must be an instance of NSArray in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    if (![(accepts) containsObject:[self valueForKey:(property)]]) { \
        [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeAccepts userInfo:@{ \
            NSLocalizedDescriptionKey : (message), \
            VMValidationErrorTargetProperty : (property) \
        }]]; \
    }

#define VALIDATE_EXCLUDES(property, excludes, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(excludes) isKindOfClass:[NSArray class]], @"EXCLUDES validation param of %@ must be an instance of NSArray in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    if ([(excludes) containsObject:[self valueForKey:(property)]]) { \
        [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeExcludes userInfo:@{ \
            NSLocalizedDescriptionKey : (message), \
            VMValidationErrorTargetProperty : (property) \
        }]]; \
    }

#define VALIDATE_WITH(property, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    if ([[self valueForKey:(property)] conformsToProtocol:@protocol(VMActiveModelManipulating)]) { \
        if (![(id<VMModelValidating>)[self valueForKey:(property)] validate:nil]) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeValidateWith userInfo:@{ \
                NSLocalizedDescriptionKey : (message), \
                VMValidationErrorTargetProperty : (property) \
            }]]; \
        } \
    }

#define VALIDATE_LENGTH(property, propertyLength, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    { \
        id value = [self valueForKey:(property)]; \
        if ([value respondsToSelector:NSSelectorFromString(@"stringValue")]) { \
            value = [value stringValue]; \
        } else if (![value isKindOfClass:[NSString class]]) { \
            value = nil; \
        } \
        if (value && ([value length] != (propertyLength))) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeLength userInfo:@{ \
                NSLocalizedDescriptionKey : (message), \
                VMValidationErrorTargetProperty : (property) \
            }]]; \
        } \
    }

#define VALIDATE_LENGTH_RANGE(property, min, max, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    { \
        id value = [self valueForKey:(property)]; \
        if ([value respondsToSelector:NSSelectorFromString(@"stringValue")]) { \
            value = [value stringValue]; \
        } else if (![value isKindOfClass:[NSString class]]) { \
            value = nil; \
        } \
        if (value && ([value length] < (min) || [value length] > (max))) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeLengthRange userInfo:@{ \
                NSLocalizedDescriptionKey : (message), \
                VMValidationErrorTargetProperty : (property) \
            }]]; \
        } \
    }

#define VALIDATE_FORMAT(property, format, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(format) isKindOfClass:[NSString class]], @"FORMAT validation param must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    { \
        id value = [self valueForKey:(property)]; \
        if ([value respondsToSelector:NSSelectorFromString(@"stringValue")]) { \
            value = [value stringValue]; \
        } else if (![value isKindOfClass:[NSString class]]) { \
            value = nil; \
        } \
        if (value && ![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", (format)] evaluateWithObject:(value)]) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeLengthRange userInfo:@{ \
                NSLocalizedDescriptionKey : (message), \
                VMValidationErrorTargetProperty : (property) \
            }]]; \
        } \
    }

#define VALIDATE_REQUIRED(property, message)

#define VALIDATE_NULL(property, message)

#define VALIDATE_IN_RANGE(property, min, max, message)

#define VALIDATE_LESS(property, max, message)

#define VALIDATE_LESS_OR_EQUAL(property, max, message)

#define VALIDATE_GREATER(property, min, message)

#define VALIDATE_GREATER_OR_EQUAL(property, min, message)

#define VALIDATE_ODD(property, message)

#define VALIDATE_EVEN(property, message)

#define VALIDATE_BLOCK(property, block, message)

#define VALIDATE_EACH(property, block, message)

#endif