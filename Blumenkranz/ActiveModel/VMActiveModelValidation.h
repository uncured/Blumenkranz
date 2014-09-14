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

#define VALIDATION_ERROR(property, message, errorCode) \
        [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:(errorCode) userInfo:@{ \
            NSLocalizedDescriptionKey : (message), \
            VMValidationErrorTargetProperty : (property) \
        }]]; \

#define VALIDATE_ACCEPTS(property, accepts, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    VMArray((accepts)); \
    if (![(accepts) containsObject:[self valueForKey:(property)]]) { \
        VALIDATION_ERROR(property, message, VMValidationErrorCodeAccepts) \
    }

#define VALIDATE_EXCLUDES(property, excludes, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    VMArray((excludes)); \
    if ([(excludes) containsObject:[self valueForKey:(property)]]) { \
        VALIDATION_ERROR(property, message, VMValidationErrorCodeExcludes) \
    }

#define VALIDATE_WITH(property, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    if ([[self valueForKey:(property)] conformsToProtocol:@protocol(VMActiveModelManipulating)]) { \
        if (![(id<VMModelValidating>)[self valueForKey:(property)] validate:nil]) { \
            VALIDATION_ERROR(property, message, VMValidationErrorCodeValidateWith) \
        } \
    }

#define VALIDATE_LENGTH(property, propertyLength, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    { \
        id value = [self valueForKey:(property)]; \
        if ([value respondsToSelector:NSSelectorFromString(@"stringValue")]) { \
            value = [value stringValue]; \
        } else if (![value isKindOfClass:[NSString class]]) { \
            value = nil; \
        } \
        if (value && ([value length] != (propertyLength))) { \
            VALIDATION_ERROR(property, message, VMValidationErrorCodeLength) \
        } \
    }

#define VALIDATE_LENGTH_RANGE(property, min, max, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    { \
        id value = [self valueForKey:(property)]; \
        if ([value respondsToSelector:NSSelectorFromString(@"stringValue")]) { \
            value = [value stringValue]; \
        } else if (![value isKindOfClass:[NSString class]]) { \
            value = nil; \
        } \
        if (value && ([value length] < (min) || [value length] > (max))) { \
            VALIDATION_ERROR(property, message, VMValidationErrorCodeLengthRange) \
        } \
    }

#define VALIDATE_FORMAT(property, format, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    VMString((format)); \
    { \
        id value = [self valueForKey:(property)]; \
        if ([value respondsToSelector:NSSelectorFromString(@"stringValue")]) { \
            value = [value stringValue]; \
        } else if (![value isKindOfClass:[NSString class]]) { \
            value = nil; \
        } \
        if (value && ![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", (format)] evaluateWithObject:(value)]) { \
            VALIDATION_ERROR(property, message, VMValidationErrorCodeFormat) \
        } \
    }

#define VALIDATE_REQUIRED(property, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    { \
        id value = [self valueForKey:(property)]; \
        if (!value || [value isKindOfClass:[NSNull class]]) { \
            VALIDATION_ERROR(property, message, VMValidationErrorCodeRequired) \
        } \
    }

#define VALIDATE_NULL(property, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    { \
        id value = [self valueForKey:(property)]; \
        if (value && ![value isKindOfClass:[NSNull class]]) { \
            VALIDATION_ERROR(property, message, VMValidationErrorCodeNull) \
        } \
    }

#define VALIDATE_IN_RANGE(property, min, max, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    { \
        id value = [self valueForKey:(property)]; \
        VMNumber(value); \
        if (!value || ([value compare:@(min)] == NSOrderedAscending) || ([value compare:@(max)] == NSOrderedDescending)) { \
            VALIDATION_ERROR(property, message, VMValidationErrorCodeInRange) \
        } \
    }

#define VALIDATE_LESS(property, max, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    { \
        id value = [self valueForKey:(property)]; \
        VMNumber(value); \
        if (!value || ([value compare:@(max)] != NSOrderedAscending)) { \
            VALIDATION_ERROR(property, message, VMValidationErrorCodeLess) \
        } \
    }

#define VALIDATE_GREATER(property, min, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    { \
        id value = [self valueForKey:(property)]; \
        VMNumber(value); \
        if (!value || ([value compare:@(min)] != NSOrderedDescending)) { \
            VALIDATION_ERROR(property, message, VMValidationErrorCodeGreater) \
        } \
    }

#define VALIDATE_ODD(property, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    { \
        id value = [self valueForKey:(property)]; \
        VMNumber(value); \
        if (!value || ([value longLongValue] % 2 == 0)) { \
            VALIDATION_ERROR(property, message, VMValidationErrorCodeOdd) \
        } \
    }

#define VALIDATE_EVEN(property, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    { \
        id value = [self valueForKey:(property)]; \
        VMNumber(value); \
        if (!value || ([value longLongValue] % 2 == 1)) { \
            VALIDATION_ERROR(property, message, VMValidationErrorCodeEven) \
        } \
    }

#define VALIDATE_BLOCK(property, block, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    VMCheckClass((block), (NSClassFromString(@"NSBlock"))); \
    { \
        id value = [self valueForKey:(property)]; \
        NSMethodSignature *blockSignature = [[CTBlockDescription alloc] initWithBlock:(block)].blockSignature; \
NSLog(@"%@", blockSignature.description); \
        NSAssert(([blockSignature numberOfArguments] == 2) && (strcmp([blockSignature methodReturnType], @encode(BOOL)) == 0) && (strcmp([blockSignature getArgumentTypeAtIndex:1], "@") == 0), @"BLOCK validation param of %@ must have ^BOOL(id) signature in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
        if (!((VMObjectValidationBlock)(block))(value)) { \
            VALIDATION_ERROR(property, message, VMValidationErrorCodeBlock) \
        } \
    }

#define VALIDATE_EACH(property, block, message) \
    VMString((message)); \
    VMString((property)); \
    VMProperty((property)); \
    VMCheckClass((block), (NSClassFromString(@"NSBlock"))); \
    { \
        id value = [self valueForKey:(property)]; \
        NSAssert(!value || [value isKindOfClass:[NSArray class]], @"PROPERTY validation param must refer to an instance of NSArray or nil"); \
        NSMethodSignature *blockSignature = [[CTBlockDescription alloc] initWithBlock:(block)].blockSignature; \
        NSAssert(([blockSignature numberOfArguments] == 2) && (strcmp([blockSignature methodReturnType], @encode(BOOL)) == 0) && (strcmp([blockSignature getArgumentTypeAtIndex:1], "@") == 0), @"BLOCK validation param of %@ must have ^BOOL(id) signature in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
        BOOL eachValidationResult = YES; \
        for (id eachValidationObject in value) { \
            eachValidationResult = eachValidationResult && ((VMObjectValidationBlock)(block))(eachValidationObject); \
        } \
        if (!eachValidationResult) { \
            VALIDATION_ERROR(property, message, VMValidationErrorCodeEach) \
        } \
    }

#endif