#ifndef Blumenkranz_VMActiveModelValidation_h
#define Blumenkranz_VMActiveModelValidation_h

#define ACTIVE_MODEL_VALIDATION_METHOD_NAME @"vm_validate:"

#define VALIDATION_BEGIN \
- (BOOL)vm_validate:(VMErrorsBlock)errorCallback { \
    NSMutableArray *errors = [NSMutableArray array];

#define VALIDATION_END \
    dispatch_async(dispatch_get_main_queue(), ^{ \
        if (errorCallback) { \
            errorCallback([NSArray arrayWithArray:errors]); \
        } \
    }); \
    return [errors count] == 0; \
}

#define VALIDATE_ACCEPTS(property, accepts, message) \
    NSAssert([property isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([accepts isKindOfClass:[NSArray class]], @"ACCEPTS validation param of %@ must be an instance of NSArray in %@ method %@", property, NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([message isKindOfClass:[NSString class]], @"MESSAGE validation param must be an instance of NSString in %@ method %@", property, NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    if (![accepts containsObject:[self valueForKey:property]]) { \
        [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeAccepts userInfo:@{ \
            NSLocalizedDescriptionKey : message, \
            VMValidationErrorTargetProperty : property \
        }]]; \
    }

#define VALIDATE_EXCLUDES(property, excludes, message) \
    NSAssert([property isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([excludes isKindOfClass:[NSArray class]], @"EXCLUDES validation param of %@ must be an instance of NSArray in %@ method %@", property, NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([message isKindOfClass:[NSString class]], @"MESSAGE validation param must be an instance of NSString in %@ method %@", property, NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    if ([excludes containsObject:[self valueForKey:property]]) { \
        [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeExcludes userInfo:@{ \
            NSLocalizedDescriptionKey : message, \
            VMValidationErrorTargetProperty : property \
        }]]; \
    }

#define VALIDATE_WITH(property, message) \
    NSAssert([property isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([message isKindOfClass:[NSString class]], @"MESSAGE validation param must be an instance of NSString in %@ method %@", property, NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    if ([[self valueForKey:property] conformsToProtocol:@protocol(VMActiveModelManipulating)]) { \
        if (![(id<VMActiveModelManipulating>)[self valueForKey:property] validate:nil]) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeValidateWith userInfo:@{ \
                NSLocalizedDescriptionKey : message, \
                VMValidationErrorTargetProperty : property \
            }]]; \
        } \
    }

#endif