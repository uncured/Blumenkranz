#import <XCTest/XCTest.h>
#import "VMActiveModel.h"

#pragma mark Mock objects
@interface MockInnerActiveModel : VMActiveModel
@property (strong) NSNumber *numberProperty;
@property (strong) NSString *stringProperty;
@end

@implementation MockInnerActiveModel

VALIDATION_BEGIN
VALIDATE_ACCEPTS(@"numberProperty", (@[ @(0), @(100) ]), @"Number not 0 nor 100.")
VALIDATE_EXCLUDES(@"stringProperty", (@[ @"", @"123" ]), @"String not valid.")
VALIDATE_LENGTH_RANGE(@"stringProperty", 4, 10, @"String length range incorrect")
VALIDATION_END

@end

@interface MockActiveModel : VMActiveModel
@property (strong) NSNumber *numberProperty;
@property (strong) NSString *stringProperty;
@property (strong) MockInnerActiveModel *recursiveProperty;
@end

@implementation MockActiveModel

VALIDATION_BEGIN
VALIDATE_ACCEPTS(@"numberProperty", (@[ @(0), @(100) ]), @"Number not 0 nor 100.")
VALIDATE_EXCLUDES(@"stringProperty", (@[ @"", @"123" ]), @"String not valid.")
VALIDATE_WITH(@"recursiveProperty", @"Recursive property not valid")
VALIDATE_LENGTH(@"stringProperty", 4, @"String length incorrect")
VALIDATE_FORMAT(@"stringProperty", @"T.{2}T", @"String format incorrect")
VALIDATE_FORMAT(@"numberProperty", @"\\d", @"Number format incorrect")
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
    self.model.recursiveProperty = [[MockInnerActiveModel alloc] init];
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

- (void)testValidateLength {
    self.model.stringProperty = @"TEST";
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 'TEST' value length.");
    
    self.model.stringProperty = @"";
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify '' value length.");
    
    self.model.stringProperty = @"123TEST112312323123";
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify '123TEST112312323123' value length.");
}

- (void)testValidateLengthRange {
    self.model.recursiveProperty.stringProperty = @"TEST";
    XCTAssertTrue([self.model.recursiveProperty validate:nil], @"Test model should qualify 'TEST' value length.");
    
    self.model.recursiveProperty.stringProperty = @"TEST123";
    XCTAssertTrue([self.model.recursiveProperty validate:nil], @"Test model should qualify 'TEST123' value length.");
    
    self.model.recursiveProperty.stringProperty = @"TEST123123";
    XCTAssertTrue([self.model.recursiveProperty validate:nil], @"Test model should qualify 'TEST123123' value length.");
    
    self.model.recursiveProperty.stringProperty = @"";
    XCTAssertFalse([self.model.recursiveProperty validate:nil], @"Test model shouldn't qualify '' value length.");
    
    self.model.recursiveProperty.stringProperty = @"123TEST112312323123";
    XCTAssertFalse([self.model.recursiveProperty validate:nil], @"Test model shouldn't qualify '123TEST112312323123' value length.");
}

- (void)testValidateFormatString {
    self.model.stringProperty = @"TEST";
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 'TEST' value format.");
    
    self.model.stringProperty = @"TSET";
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 'TSET' value format.");
    
    self.model.stringProperty = @"TSES";
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 'TSES' value format.");
}

- (void)testValidateFormatNumber {
    self.model.numberProperty = @(0);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify '0' value format.");
    
    self.model.numberProperty = @(100);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify '100' value format.");
}

- (void)testValidateRequired {

}

- (void)testValidateNull {
    
}

- (void)testValidateInRange {
    
}

- (void)testValidateLess {
    
}

- (void)testValidateLessOrEqual {
    
}

- (void)testValidateGreater {
    
}

- (void)testValidateGreaterOrEqual {
    
}

- (void)testValidateOdd {
    
}

- (void)testValidateEven {
    
}

- (void)testValidateBlock {
    
}

- (void)testValidateEach {
    
}

@end
