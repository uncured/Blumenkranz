#import "VMValidatableModel.h"
#import "VMTypes.h"

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

@end
