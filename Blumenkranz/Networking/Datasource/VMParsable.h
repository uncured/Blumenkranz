@protocol VMParsable <NSObject>

+ (instancetype)objectWithParsedData:(NSDictionary *)data;

- (instancetype)initWithParsedData:(NSDictionary *)data;

@optional
- (void)mergeParsedData:(NSDictionary *)data;

@end
