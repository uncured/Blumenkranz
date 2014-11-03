@interface NSObject (VMExtension)
@property (nonatomic, strong) id annotation;

+ (instancetype)singletone;

+ (Class)classOfProperty:(NSString *)propertyName;

@end

BOOL vmObjectCanBeCopied(id target);

BOOL vmObjectCanBeCopiedMutably(id target);
