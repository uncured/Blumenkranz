#import "VMDatasource.h"
#import "VMDataParsing.h"

const NSInteger VMDatasourceNetworkErrorCode = 404;

@interface VMDatasource ()
@property(nonatomic, copy) NSURL *url;
@property(nonatomic, strong) id<VMDataParsing> parser;
@property(nonatomic, strong) NSURLSessionDataTask *networkTask;
@property(nonatomic, copy) void (^responseHandler)(NSData *data, NSURLResponse *response, NSError *error);
@property(nonatomic, strong) NSArray *data;
@property(nonatomic, strong) NSRecursiveLock *dataLock;
@end

@implementation VMDatasource
@synthesize observer;

- (instancetype)initWithURL:(NSURL *)url parser:(id<VMDataParsing>)parser {
    NSAssert(url, @"URL should be provided for Datasource object.");
    NSAssert(parser, @"Data parser should be provided for Datasource object.");
    
    if (self = [super init]) {
        self.url = url;
        self.parser = parser;
        self.dataLock = [[NSRecursiveLock alloc] init];
        [self setupResponseHandler];
    }
    return self;
}

- (void)start {
    @synchronized(self.url) {
        [self stop:YES];
        self.networkTask = [[NSURLSession sharedSession] dataTaskWithURL:self.url completionHandler:self.responseHandler];
    }
    [self.networkTask resume];
}

- (void)stop:(BOOL)clearTaskOnStop {
    if (clearTaskOnStop) {
        [self.networkTask cancel];
        self.networkTask = nil;
    } else {
        [self.networkTask suspend];
    }
}

- (void)setupResponseHandler {
    __typeof__(self) __weak weakSelf = self;
    self.responseHandler = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (weakSelf.observer) {
            NSArray *datasourceData = nil;
            NSError *datasourceError = nil;
            if (error) {
                datasourceError = error;
            } else if ([response isKindOfClass:[NSHTTPURLResponse class]] && ([(NSHTTPURLResponse *)response statusCode] != 200)) {
                datasourceError = [NSError errorWithDomain:NSStringFromClass([weakSelf class]) code:VMDatasourceNetworkErrorCode userInfo:nil];
            } else {
                datasourceData = [weakSelf parseResponse:data];
            }
            weakSelf.observer(weakSelf, datasourceData, datasourceError);
        }
    };
}

- (NSArray *)parseResponse:(NSData *)response {
    [self.dataLock lock];
    self.data = [self.parser parse:response];
    [self.dataLock unlock];
    return self.data;
}

- (NSUInteger)count {
    [self.dataLock lock];
    NSUInteger count = [self.data count];
    [self.dataLock unlock];
    return count;
}

- (id<VMParsable>)objectAtIndex:(NSUInteger)idx {
    [self.dataLock lock];
    id<VMParsable> object = [self.data objectAtIndex:idx];
    [self.dataLock unlock];
    return object;
}

@end
