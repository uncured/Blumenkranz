@protocol VMParsable;

@protocol VMDatasourceStoring <NSObject>

- (NSUInteger)count;

- (id<VMParsable>)objectAtIndex:(NSUInteger)idx;

@end
