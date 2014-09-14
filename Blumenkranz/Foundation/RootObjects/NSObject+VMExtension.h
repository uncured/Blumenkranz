@interface NSObject (VMExtension)
@property(nonatomic, strong) id annotation;

+ (instancetype)singletone;

+ (Class)classOfProperty:(NSString *)propertyName;

+ (id)methodDescriptionForClass:(Class)class;

+ (id)ivarDescriptionForClass:(Class)class;

@end
