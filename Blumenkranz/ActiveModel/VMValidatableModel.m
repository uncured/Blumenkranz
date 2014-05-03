#import "VMValidatableModel.h"

NSString * const VMValidationErrorDomain = @"ru.visualmyth.blumenkranz.VMValidatableModel";
NSString * const VMValidationErrorTargetProperty = @"validation_target_property";

@implementation VMValidatableModel

- (BOOL)validate:(VMErrorsBlock)errorCallback {
    BOOL result = NO;
    
    SEL innerValidationSelector = NSSelectorFromString(ACTIVE_MODEL_VALIDATION_METHOD_NAME);
    if (innerValidationSelector && [self respondsToSelector:innerValidationSelector]) {
        
        NSInvocation *validationInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:innerValidationSelector]];
        [validationInvocation setSelector:innerValidationSelector];
        [validationInvocation setTarget:self];
        [validationInvocation setArgument:&errorCallback atIndex:2];
        [validationInvocation invoke];
        [validationInvocation getReturnValue:&result];
        
    } else {
        
        if (errorCallback) {
            errorCallback(nil);
        }
        result = YES;
        
    }
    
    return result;
}

//- (void)g {
//    NSString *property = @"";
//    NSString *format = @"";
//    NSString *message = @"";
//    NSMutableArray *errors = [NSMutableArray array];
//    
//    NSAssert([(property) isKindOfClass:[NSString class]] && [self respondsToSelector:NSSelectorFromString(property)], @"PROPERTY validation param must be a name of property in %@ method %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
//    NSAssert([(message) isKindOfClass:[NSString class]], @"MESSAGE validation param must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
//    NSAssert([(format) isKindOfClass:[NSString class]], @"FORMAT validation param must be an instance of NSString in %@ method %@", (property), NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
//    { \
//        id value = [self valueForKey:(property)]; \
//        if ([value respondsToSelector:NSSelectorFromString(@"stringValue")]) { \
//            value = [value stringValue]; \
//        } else if (![value isKindOfClass:[NSString class]]) { \
//            value = nil; \
//        } \
//        if (value && ![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", (format)] evaluateWithObject:(value)]) { \
//            [errors addObject:[NSError errorWithDomain:VMValidationErrorDomain code:VMValidationErrorCodeLengthRange userInfo:@{ \
//                NSLocalizedDescriptionKey : (message), \
//                VMValidationErrorTargetProperty : (property) \
//            }]]; \
//        } \
//    }
//    
//}


@end
