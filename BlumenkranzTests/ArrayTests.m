#import <XCTest/XCTest.h>
#import "NSArray+VMExtension.h"
#import "NSMutableArray+VMExtension.h"

@interface ArrayTests : XCTestCase

@end

@implementation ArrayTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testMerge {
    NSArray *arrayOne = @[@"a", @"b", @"c", @"d", @"123"];
    NSArray *arrayTwo = @[@"a", @"f", @"123", @"c"];

    NSArray *mergeResult = @[@"a", @"b", @"c", @"d", @"123", @"f"];
    XCTAssertEqualObjects([NSArray arrayByMerge:arrayOne with:arrayTwo type:VMArrayMergeNone error:nil], mergeResult, @"Static array merge result should be equal to given.");
    XCTAssertEqualObjects([arrayOne arrayByMerge:arrayTwo type:VMArrayMergeNone error:nil], mergeResult, @"Immutable array merge result should be equal to given.");
    XCTAssertEqualObjects([NSArray arrayByMerge:arrayOne with:arrayTwo type:VMArrayMergeCopy error:nil], mergeResult, @"Static array merge result should be equal to given.");
    XCTAssertEqualObjects([arrayOne arrayByMerge:arrayTwo type:VMArrayMergeCopy error:nil], mergeResult, @"Immutable array merge result should be equal to given.");

    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:arrayOne];
    BOOL result = [mutableArray merge:arrayTwo type:VMArrayMergeNone error:nil];
    XCTAssertTrue(result, @"Mutable array merge result should be executed properly.");
    XCTAssertTrue([mutableArray isEqualToArray:mergeResult], @"Mutable array merge result should be equal to given.");

    NSMutableArray *mutableArrayTwo = [NSMutableArray arrayWithArray:arrayOne];
    result = [mutableArrayTwo merge:arrayTwo type:VMArrayMergeCopy error:nil];
    XCTAssertTrue(result, @"Mutable array merge result should be executed properly.");
    XCTAssertTrue([mutableArrayTwo isEqualToArray:mergeResult], @"Mutable array merge result should be equal to given.");

    NSArray *failArray = @[@"a", @"f", @"123", [[NSObject alloc] init]];
    XCTAssertNil([NSArray arrayByMerge:arrayOne with:failArray type:VMArrayMergeCopy error:nil], @"Static array merge result should invalidate.");
    XCTAssertNil([arrayOne arrayByMerge:failArray type:VMArrayMergeCopy error:nil], @"Immutable array merge result should invalidate.");

    NSMutableArray *failMutableArray = [NSMutableArray arrayWithArray:arrayTwo];
    NSMutableArray *failMutableArrayCopy = [NSMutableArray arrayWithArray:arrayTwo];
    BOOL failResult = [failMutableArray merge:failArray type:VMArrayMergeCopy error:nil];
    XCTAssertFalse(failResult, @"Mutable array merge result should not be executed properly.");
    XCTAssertTrue([failMutableArray isEqualToArray:failMutableArrayCopy], @"Mutable array merge result should be equal to self.");
}

- (void)testIntersect {
    NSArray *arrayOne = @[@"a", @"b", @"c", @"d", @"123"];
    NSArray *arrayTwo = @[@"a", @"f", @"123", @"c"];
    NSSet *resultSet = [NSSet setWithObjects:@"a", @"c", @"123", nil];

    XCTAssertEqualObjects([arrayOne intersection:arrayTwo], resultSet, @"Arrays intersection should be equal to given.");
}

- (void)testExclude {
    NSArray *arrayOne = @[@"a", @"b", @"c", @"d", @"123"];
    NSArray *arrayTwo = @[@"a", @"f", @"123", @"c"];
    NSSet *resultSet = [NSSet setWithObjects:@"b", @"d", nil];

    XCTAssertEqualObjects([arrayOne exclusion:arrayTwo], resultSet, @"Arrays exclusion should be equal to given.");
}

@end
