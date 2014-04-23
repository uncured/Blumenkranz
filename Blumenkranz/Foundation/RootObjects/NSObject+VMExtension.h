@interface NSObject (VMExtension)
@property(nonatomic, strong) id annotation;

+ (instancetype)singletone;

+ (Class)classOfProperty:(NSString *)propertyName;

@end
