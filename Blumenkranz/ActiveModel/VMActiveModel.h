#import "VMActiveModelManipulating.h"
#import "VMActiveModelValidation.h"

typedef NS_ENUM(uint8_t, VMValidationErrorCode) {
    VMValidationErrorCodeUnknown,
    
    VMValidationErrorCodeAccepts,
    VMValidationErrorCodeExcludes,
    VMValidationErrorCodeValidateWith,
    
    VMValidationErrorCodeCount
};

extern NSString * const VMValidationErrorDomain;
extern NSString * const VMValidationErrorTargetProperty;

@interface VMActiveModel : NSObject <VMActiveModelManipulating>

@end
