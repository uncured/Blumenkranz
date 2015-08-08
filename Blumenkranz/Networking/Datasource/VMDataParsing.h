@protocol VMParsable;

@protocol VMDataParsing <NSObject>

- (Class<VMParsable>)parserObjectType;

- (NSArray *)parse:(NSData *)data;

@end
