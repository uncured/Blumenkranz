#import <XCTest/XCTest.h>
#import "VMActiveModel.h"

#pragma mark Mock objects
@interface MockActiveModel : VMActiveModel
@property (strong) NSNumber *numberProperty;
@property (strong) NSString *stringProperty;
@property (strong) MockActiveModel *recursiveProperty;
@end

@implementation MockActiveModel

VALIDATION_BEGIN
VALIDATE_ACCEPTS(@"numberProperty", (@[ @(0), @(100) ]), @"Number not 0 nor 100.")
VALIDATE_EXCLUDES(@"stringProperty", (@[ @"", @"123" ]), @"String not valid.")
VALIDATE_WITH(@"recursiveProperty", @"Recursive property not valid")
VALIDATION_END

@end

#pragma mark Actual test class
/*
 * Here we go testing!
 */
@interface ActiveModelTests : XCTestCase
@property (strong) MockActiveModel *model;
@end

@implementation ActiveModelTests

- (void)setUp {
    [super setUp];
    
    self.model = [[MockActiveModel alloc] init];
    self.model.stringProperty = @"TEST";
    self.model.numberProperty = @(0);
    self.model.recursiveProperty = [[MockActiveModel alloc] init];
    self.model.recursiveProperty.stringProperty = @"TEST";
    self.model.recursiveProperty.numberProperty = @(0);
}

- (void)tearDown {
    [super tearDown];
    
    self.model = nil;
}

- (void)testValidateAccepts {
    self.model.numberProperty = @(0);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 0 value.");
    
    self.model.numberProperty = @(1);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 1 value.");
}

- (void)testValidateExcludes {
    self.model.stringProperty = @"TEST";
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 'TEST' value.");
    
    self.model.stringProperty = @"";
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify '' value.");
}

- (void)testValidateWith {
    self.model.recursiveProperty.numberProperty = @(0);
    XCTAssertTrue([self.model validate:nil], @"Test model's recursiveProperty should qualify 0 value.");
    
    self.model.recursiveProperty.numberProperty = @(1);
    XCTAssertFalse([self.model validate:nil], @"Test model's recursiveProperty shouldn't qualify 1 value.");
    
    self.model.recursiveProperty = nil;
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify nil recursive property.");
}

@end
