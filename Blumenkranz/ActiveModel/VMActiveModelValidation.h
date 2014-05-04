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
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    if (![(accepts) containsObject:[self valueForKey:(property)]]) { \
        [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeAccepts userInfo:@{ \
            NSLocalizedDescriptionKey : (message), \
            VMValidationErrorTargetProperty : (property) \
        }]]; \
    }

#define VALIDATE_EXCLUDES(property, excludes, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(excludes) isKindOfClass:[NSArray class]], @"EXCLUDES validation param of %@ must be an instance of NSArray in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    if ([(excludes) containsObject:[self valueForKey:(property)]]) { \
        [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeExcludes userInfo:@{ \
            NSLocalizedDescriptionKey : (message), \
            VMValidationErrorTargetProperty : (property) \
        }]]; \
    }

#define VALIDATE_WITH(property, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
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
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
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
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
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
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(format) isKindOfClass:[NSString class]], @"FORMAT validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    { \
        id value = [self valueForKey:(property)]; \
        if ([value respondsToSelector:NSSelectorFromString(@"stringValue")]) { \
            value = [value stringValue]; \
        } else if (![value isKindOfClass:[NSString class]]) { \
            value = nil; \
        } \
        if (value && ![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", (format)] evaluateWithObject:(value)]) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeFormat userInfo:@{ \
                NSLocalizedDescriptionKey : (message), \
                VMValidationErrorTargetProperty : (property) \
            }]]; \
        } \
    }

#define VALIDATE_REQUIRED(property, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    { \
        id value = [self valueForKey:(property)]; \
        if (!value || [value isKindOfClass:[NSNull class]]) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeRequired userInfo:@{ \
                NSLocalizedDescriptionKey : (message), \
                VMValidationErrorTargetProperty : (property) \
            }]]; \
        } \
    }

#define VALIDATE_NULL(property, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    { \
        id value = [self valueForKey:(property)]; \
        if (value && ![value isKindOfClass:[NSNull class]]) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeNull userInfo:@{ \
                NSLocalizedDescriptionKey : (message), \
                VMValidationErrorTargetProperty : (property) \
            }]]; \
        } \
    }

#define VALIDATE_IN_RANGE(property, min, max, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    { \
        id value = [self valueForKey:(property)]; \
        NSAssert([value isKindOfClass:[NSNumber class]], @"PROPERTY validation param must be numeric object in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
        if (!value || ([value compare:@(min)] == NSOrderedAscending) || ([value compare:@(max)] == NSOrderedDescending)) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeInRange userInfo:@{ \
                NSLocalizedDescriptionKey : (message), \
                VMValidationErrorTargetProperty : (property) \
            }]]; \
        } \
    }

#define VALIDATE_LESS(property, max, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    { \
        id value = [self valueForKey:(property)]; \
        NSAssert([value isKindOfClass:[NSNumber class]], @"PROPERTY validation param must be numeric object in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
        if (!value || ([value compare:@(max)] != NSOrderedAscending)) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeLess userInfo:@{ \
                NSLocalizedDescriptionKey : (message), \
                VMValidationErrorTargetProperty : (property) \
            }]]; \
        } \
    }

#define VALIDATE_GREATER(property, min, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    { \
        id value = [self valueForKey:(property)]; \
        NSAssert([value isKindOfClass:[NSNumber class]], @"PROPERTY validation param must be numeric object in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
        if (!value || ([value compare:@(min)] != NSOrderedDescending)) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeGreater userInfo:@{ \
                NSLocalizedDescriptionKey : (message), \
                VMValidationErrorTargetProperty : (property) \
            }]]; \
        } \
    }

#define VALIDATE_ODD(property, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    { \
        id value = [self valueForKey:(property)]; \
        NSAssert([value isKindOfClass:[NSNumber class]], @"PROPERTY validation param must be numeric object in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
        if (!value || ([value longLongValue] % 2 == 0)) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeOdd userInfo:@{ \
                NSLocalizedDescriptionKey : (message), \
                VMValidationErrorTargetProperty : (property) \
            }]]; \
        } \
    }

#define VALIDATE_EVEN(property, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    { \
        id value = [self valueForKey:(property)]; \
        NSAssert([value isKindOfClass:[NSNumber class]], @"PROPERTY validation param must be numeric object in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
        if (!value || ([value longLongValue] % 2 == 1)) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeEven userInfo:@{ \
                NSLocalizedDescriptionKey : (message), \
                VMValidationErrorTargetProperty : (property) \
            }]]; \
        } \
    }

#define VALIDATE_BLOCK(property, block, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(block) isKindOfClass:NSClassFromString(@"NSBlock")], @"BLOCK validation param of %@ must be an instance of NSBlock in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    { \
        id value = [self valueForKey:(property)]; \
        NSMethodSignature *blockSignature = [[CTBlockDescription alloc] initWithBlock:block].blockSignature; \
        NSAssert(([blockSignature numberOfArguments] == 2) && (strcmp([blockSignature methodReturnType], "B") == 0) && (strcmp([blockSignature getArgumentTypeAtIndex:1], "@") == 0), @"BLOCK validation param of %@ must have ^BOOL(id) signature in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
        if (!((VMObjectValidationBlock)block)(value)) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeBlock userInfo:@{ \
                NSLocalizedDescriptionKey : (message), \
                VMValidationErrorTargetProperty : (property) \
            }]]; \
        } \
    }

#define VALIDATE_EACH(property, block, message) \
    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(block) isKindOfClass:NSClassFromString(@"NSBlock")], @"BLOCK validation param of %@ must be an instance of NSBlock in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param of %@ must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
    { \
        id value = [self valueForKey:(property)]; \
        NSAssert(!value || [value isKindOfClass:[NSArray class]], @"PROPERTY validation param of %@ must refer to an instance of NSArray or nil in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
        NSMethodSignature *blockSignature = [[CTBlockDescription alloc] initWithBlock:block].blockSignature; \
        NSAssert(([blockSignature numberOfArguments] == 2) && (strcmp([blockSignature methodReturnType], "B") == 0) && (strcmp([blockSignature getArgumentTypeAtIndex:1], "@") == 0), @"BLOCK validation param of %@ must have ^BOOL(id) signature in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
        BOOL eachValidationResult = YES; \
        for (id eachValidationObject in value) { \
            eachValidationResult = eachValidationResult && ((VMObjectValidationBlock)block)(eachValidationObject); \
        } \
        if (!eachValidationResult) { \
            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeEach userInfo:@{ \
                NSLocalizedDescriptionKey : (message), \
                VMValidationErrorTargetProperty : (property) \
            }]]; \
        } \
    }

#endif