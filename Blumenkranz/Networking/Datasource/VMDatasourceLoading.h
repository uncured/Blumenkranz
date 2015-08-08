@protocol VMDataParsing;
@protocol VMDatasourceLoading;

typedef void (^VMDatasourceUpdateBlock)(id<VMDatasourceLoading> sender, NSArray *data, NSError *error);

@protocol VMDatasourceLoading <NSObject>
@property(nonatomic, copy) VMDatasourceUpdateBlock observer;

- (instancetype)initWithURL:(NSURL *)url parser:(id<VMDataParsing>)parser;

- (void)start;

- (void)stop:(BOOL)clearTaskOnStop;

@end
