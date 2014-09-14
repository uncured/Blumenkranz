typedef NS_ENUM(uint8_t, VMDictionaryMergeType) {
    VMDictionaryMergeNone = 0,
    VMDictionaryMergeNewKeys = 1,
    VMDictionaryMergeExistingKeysReplace = 1 << 1,
    VMDictionaryMergeExistingKeysJoin = 1 << 2,
    VMDictionaryMergeCopy = 1 << 3
};

extern const NSInteger NSDictionaryObjectCannotBeCopiedErrorCode;
extern const NSInteger NSDictionaryObjectCannotBeMergedErrorCode;
extern NSString * const NSDictionaryVMExtensionDomain;

@interface NSDictionary (VMExtension)

+ (NSDictionary *)dictionaryByMerge:(NSDictionary *)target with:(NSDictionary *)source type:(VMDictionaryMergeType)type error:(NSError **)error;

- (NSDictionary *)dictionaryByMerge:(NSDictionary *)dictionary type:(VMDictionaryMergeType)type error:(NSError **)error;

@end