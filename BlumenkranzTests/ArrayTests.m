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

- (void)testDeepCopy {
    NSMutableArray *mutableArray = [NSMutableArray array];
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    NSArray *arrayOne = @[ @(1), @"2", [[NSObject alloc] init] ];

    NSArray *arrayResultOne = [arrayOne deepImmutableCopy];
    XCTAssertTrue([arrayResultOne class] == [arrayOne class], @"Result of deepImmutableCopy should be NSArray.");
    XCTAssertEqual([arrayResultOne count], [arrayOne count], @"Result of deepImmutableCopy should be equal sized to original.");

    NSArray *arrayResultTwo = [arrayOne deepMutableCopy];
    XCTAssertTrue([arrayResultTwo class] == [mutableArray class], @"Result of deepMutableCopy should be NSArray.");
    XCTAssertEqual([arrayResultTwo count], [arrayOne count], @"Result of deepMutableCopy should be equal sized to original.");

    BOOL successOne;
    NSError *errorOne;
    NSArray *arrayResultThree = [arrayOne deepImmutableClone:&successOne error:&errorOne];
    XCTAssertFalse(successOne, @"Array with non-copy objects should fail.");
    XCTAssertTrue([arrayResultThree class] == [arrayOne class], @"Result of deepImmutableClone should be NSArray.");
    XCTAssertEqual([arrayResultThree count], [arrayOne count], @"Result of deepImmutableClone should be equal sized to original.");

    NSArray *arrayResultFour = [arrayOne deepMutableClone:&successOne error:&errorOne];
    XCTAssertFalse(successOne, @"Array with non-copy objects should fail.");
    XCTAssertTrue([arrayResultFour class] == [mutableArray class], @"Result of deepMutableClone should be NSMutableArray.");
    XCTAssertEqual([arrayResultFour count], [arrayOne count], @"Result of deepMutableClone should be equal sized to original.");

    NSArray *arrayTwo = @[ @"1", @"2", @"3" ];
    BOOL successTwo;
    NSError *errorTwo;
    NSArray *arrayResultFive = [arrayTwo deepImmutableClone:&successTwo error:&errorTwo];
    XCTAssertTrue(successTwo, @"Array without non-copy objects should succeed.");
    XCTAssertTrue([arrayResultFive class] == [arrayTwo class], @"Result of deepImmutableClone should be NSArray.");
    XCTAssertEqual([arrayResultFive count], [arrayTwo count], @"Result of deepImmutableClone should be equal sized to original.");

    NSArray *arrayResultSix = [arrayTwo deepMutableClone:&successTwo error:&errorTwo];
    XCTAssertTrue(successTwo, @"Array without non-copy objects should succeed.");
    XCTAssertTrue([arrayResultSix class] == [mutableArray class], @"Result of deepMutableClone should be NSMutableArray.");
    XCTAssertEqual([arrayResultSix count], [arrayTwo count], @"Result of deepMutableClone should be equal sized to original.");

    NSArray *arrayThree = @[ @[ @"1", @"2" ], @{ @"test1": @"YES" }, @[ @{ @"test2": @"NO" } ] ];
    NSArray *arrayResultSeven = [arrayThree deepImmutableCopy];
    XCTAssertEqualObjects(arrayResultSeven, arrayThree, @"Target and result should be equal.");

    NSArray *arrayResultEight = [arrayThree deepMutableCopy];
    XCTAssertTrue([arrayResultEight[0] class] == [mutableArray class], @"[0] should be NSMutableArray.");
    XCTAssertTrue([arrayResultEight[1] class] == [mutableDictionary class], @"[1] should be NSMutableDictionary.");
    XCTAssertTrue([arrayResultEight[2] class] == [mutableArray class], @"[2] should be NSMutableArray.");
    XCTAssertTrue([arrayResultEight[2][0] class] == [mutableDictionary class], @"[2,0] should be NSMutableDictionary.");
}

@end
