#import <XCTest/XCTest.h>
#import "NSDictionary+VMExtension.h"
#import "NSMutableDictionary+VMExtension.h"

@interface DictionaryTests : XCTestCase

@end

@implementation DictionaryTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testMerge {
    NSDictionary *dictionaryOne = @{ @"a": @(1), @"b": @(2), @"c": @{ @"c1": @(YES), @"c2": @(YES) } };
    NSDictionary *dictionaryTwo = @{ @"d": @(1), @"e": @(2), @"c": @{ @"c2": @(NO), @"c3":@(1) }, @"b": @(3) };

    NSDictionary *mergeResult = @{ @"a": @(1), @"b": @(3), @"c": @{ @"c2": @(NO), @"c3":@(1) } };
    XCTAssertEqualObjects([NSDictionary dictionaryByMerge:dictionaryOne with:dictionaryTwo type:VMDictionaryMergeExistingKeysReplace error:nil], mergeResult, @"Static 'replace' merge should be equal to given result.");
    XCTAssertEqualObjects([dictionaryOne dictionaryByMerge:dictionaryTwo type:VMDictionaryMergeExistingKeysReplace error:nil], mergeResult, @"'Replace' merge should be equal to given result.");

    mergeResult = @{ @"a": @(1), @"b": @(2), @"c": @{ @"c1": @(YES), @"c2": @(YES) }, @"d": @(1), @"e": @(2) };
    XCTAssertEqualObjects([NSDictionary dictionaryByMerge:dictionaryOne with:dictionaryTwo type:VMDictionaryMergeNewKeys error:nil], mergeResult, @"Static 'new keys' merge should be equal to given result.");
    XCTAssertEqualObjects([dictionaryOne dictionaryByMerge:dictionaryTwo type:VMDictionaryMergeNewKeys error:nil], mergeResult, @"'New keys' merge should be equal to given result.");

    mergeResult = @{ @"a": @(1), @"b": @(3), @"c": @{ @"c1": @(YES), @"c2": @(NO) } };
    XCTAssertEqualObjects([NSDictionary dictionaryByMerge:dictionaryOne with:dictionaryTwo type:VMDictionaryMergeExistingKeysReplace | VMDictionaryMergeExistingKeysJoin error:nil], mergeResult, @"Static 'join/replace' merge should be equal to given result.");
    XCTAssertEqualObjects([dictionaryOne dictionaryByMerge:dictionaryTwo type:VMDictionaryMergeExistingKeysReplace | VMDictionaryMergeExistingKeysJoin error:nil], mergeResult, @"'Join/replace' merge should be equal to given result.");

    NSDictionary *dictionaryThree = @{ @"d": @(1), @"e": @(2), @"c": @{ @"c2": @(NO), @"c3":@(1) } };
    mergeResult = @{ @"a": @(1), @"b": @(2), @"c": @{ @"c1": @(YES), @"c2": @(YES), @"c3":@(1) }, @"d": @(1), @"e": @(2) };
    XCTAssertEqualObjects([NSDictionary dictionaryByMerge:dictionaryOne with:dictionaryThree type:VMDictionaryMergeNewKeys | VMDictionaryMergeExistingKeysJoin error:nil], mergeResult, @"Static 'new keys/replace' merge should be equal to given result.");
    XCTAssertEqualObjects([dictionaryOne dictionaryByMerge:dictionaryThree type:VMDictionaryMergeNewKeys | VMDictionaryMergeExistingKeysJoin error:nil], mergeResult, @"'New keys/replace' merge should be equal to given result.");
}

@end
