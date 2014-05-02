#import "VMActiveModel.h"

NSString * const VMValidationErrorDomain = @"ru.visualmyth.blumenkranz.VMActiveModelValidation";
NSString * const VMValidationErrorTargetProperty = @"validation_target_property";

@implementation VMActiveModel

- (void)save:(VMErrorsBlock)errorCallback {
    // TODO: Write method
}

- (void)remove:(VMErrorsBlock)errorCallback {
    // TODO: Write method
}

- (void)update:(VMErrorsBlock)errorCallback {
    // TODO: Write method
}

- (void)read:(NSDictionary *)parameters callback:(VMErrorsBlock)errorCallback {
    // TODO: Write method
}

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

        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorCallback) {
                errorCallback(nil);
            }
        });
        result = YES;
        
    }

    return result;
}

@end
