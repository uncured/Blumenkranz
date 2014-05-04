#import "VMModelValidating.h"
#import "CTBlockDescription.h"
#import "VMActiveModelValidation.h"

typedef NS_ENUM(uint8_t, VMValidationErrorCode) {
    VMValidationErrorCodeUnknown,
    
    VMValidationErrorCodeAccepts,
    VMValidationErrorCodeExcludes,
    VMValidationErrorCodeValidateWith,
    VMValidationErrorCodeLength,
    VMValidationErrorCodeLengthRange,
    VMValidationErrorCodeFormat,
    VMValidationErrorCodeRequired,
    VMValidationErrorCodeNull,
    VMValidationErrorCodeInRange,
    VMValidationErrorCodeLess,
    VMValidationErrorCodeGreater,
    VMValidationErrorCodeOdd,
    VMValidationErrorCodeEven,
    VMValidationErrorCodeBlock,
    VMValidationErrorCodeEach,
    
    VMValidationErrorCodeCount
};

extern NSString * const VMValidationErrorDomain;
extern NSString * const VMValidationErrorTargetProperty;

@interface VMValidatableModel : NSObject <VMModelValidating>

@end
