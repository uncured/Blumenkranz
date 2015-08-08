#import "VMDatasourceLoading.h"
#import "VMDatasourceStoring.h"

extern const NSInteger VMDatasourceNetworkErrorCode;

@interface VMDatasource : NSObject<VMDatasourceLoading, VMDatasourceStoring>
@end

@interface VMDatasource (Override)

- (void)setupResponseHandler;

- (NSArray *)parseResponse:(NSData *)response;

@end
