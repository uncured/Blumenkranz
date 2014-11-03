typedef NS_ENUM(uint8_t, VMArrayMergeType) {
    VMArrayMergeNone = 0,
    VMArrayMergeCopy = 1
};

extern const NSInteger NSArrayObjectCannotBeCopiedErrorCode;
extern NSString * const NSArrayVMExtensionDomain;

@interface NSArray (VMExtension)

+ (NSArray *)arrayByMerge:(NSArray *)target with:(NSArray *)source type:(VMArrayMergeType)type error:(NSError **)error;

- (NSArray *)arrayByMerge:(NSArray *)array type:(VMArrayMergeType)type error:(NSError **)error;

- (NSSet *)intersection:(NSArray *)array;

- (NSSet *)exclusion:(NSArray *)array;

- (NSMutableArray *)deepMutableCopy;

- (NSArray *)deepImmutableCopy;

- (NSMutableArray *)deepMutableClone:(BOOL *)success error:(NSError **)error;

- (NSArray *)deepImmutableClone:(BOOL *)success error:(NSError **)error;

@end
