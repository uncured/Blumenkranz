#import <XCTest/XCTest.h>
#import "VMActiveModel.h"
#import "VMAssertion.h"

#pragma mark Mock objects
@interface MockActiveModel : VMActiveModel
@property (strong) NSNumber *acceptsNumberProperty;
@property (strong) NSString *acceptsStringProperty;
@property (strong) NSNumber *excludeNumberProperty;
@property (strong) NSString *excludeStringProperty;
@property (strong) NSNumber *lengthNumberProperty;
@property (strong) NSString *lengthStringProperty;
@property (strong) NSNumber *lengthRangeNumberProperty;
@property (strong) NSString *lengthRangeStringProperty;
@property (strong) NSNumber *formatNumberProperty;
@property (strong) NSString *formatStringProperty;
@property (strong) NSString *requiredStringProperty;
@property (strong) NSNumber *nonRequiredNumberProperty;
@property (strong) NSNumber *inRangeNumberProperty;
@property (strong) NSNumber *lessNumberProperty;
@property (strong) NSNumber *greaterNumberProperty;
@property (strong) NSNumber *oddNumberProperty;
@property (strong) NSNumber *evenNumberProperty;
@property (strong) NSNumber *blockNumberProperty;
@property (strong) NSArray *eachStringsProperty;
@property (strong) MockActiveModel *recursiveProperty;
@end

@implementation MockActiveModel

VALIDATION_BEGIN
VALIDATE_ACCEPTS(@"acceptsNumberProperty", (@[ @(0), @(100) ]), @"Number not 0 nor 100.")
VALIDATE_ACCEPTS(@"acceptsStringProperty", (@[ @"101", @"TEST" ]), @"String not '101' nor 'TEST'.")
VALIDATE_EXCLUDES(@"excludeNumberProperty", (@[ @(1), @(101) ]), @"Number is 1 or 101.")
VALIDATE_EXCLUDES(@"excludeStringProperty", (@[ @"", @"123" ]), @"String is empty or '123'.")
VALIDATE_WITH(@"recursiveProperty", @"Recursive property not valid")
VALIDATE_LENGTH(@"lengthNumberProperty", 4, @"Number length incorrect")
VALIDATE_LENGTH(@"lengthStringProperty", 4, @"String length incorrect")
VALIDATE_LENGTH_RANGE(@"lengthRangeNumberProperty", 3, 10, @"Number length range incorrect")
VALIDATE_LENGTH_RANGE(@"lengthRangeStringProperty", 3, 10, @"String length range incorrect")
VALIDATE_FORMAT(@"formatNumberProperty", @"\\d", @"Number format incorrect")
VALIDATE_FORMAT(@"formatStringProperty", @"T.{2}T", @"String format incorrect")
VALIDATE_REQUIRED(@"requiredStringProperty", @"String is required")
VALIDATE_NULL(@"nonRequiredNumberProperty", @"Number is deprecated")
VALIDATE_IN_RANGE(@"inRangeNumberProperty", 1, 13, @"Number not in range")
VALIDATE_LESS(@"lessNumberProperty", 13, @"Number greater or equal 13")
VALIDATE_GREATER(@"greaterNumberProperty", 13, @"Number less or equal 13")
VALIDATE_ODD(@"oddNumberProperty", @"Number is not odd")
VALIDATE_EVEN(@"evenNumberProperty", @"Number is not even")
VALIDATE_BLOCK(@"blockNumberProperty", (^BOOL(id object){ return [object integerValue] > 0; }), @"Number is not greater than 0")
VALIDATE_EACH(@"eachStringsProperty", (^BOOL(id object){ return ![object isEqualToString:@"fuck"]; }), @"Strings contain F**k word. Nah-ah!")
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
    
    [self reset];
}

- (void)tearDown {
    [super tearDown];
    
    self.model = nil;
}

- (void)reset {
    self.model = [[MockActiveModel alloc] init];
    self.model.acceptsNumberProperty = @(0);
    self.model.acceptsStringProperty = @"101";
    self.model.excludeNumberProperty = @(0);
    self.model.excludeStringProperty = @"101";
    self.model.lengthNumberProperty = @(1234);
    self.model.lengthStringProperty = @"1234";
    self.model.lengthRangeNumberProperty = @(1234);
    self.model.lengthRangeStringProperty = @"1234";
    self.model.formatNumberProperty = @(0);
    self.model.formatStringProperty = @"TEST";
    self.model.requiredStringProperty = @"TEST";
    self.model.nonRequiredNumberProperty = nil;
    self.model.inRangeNumberProperty = @(10);
    self.model.lessNumberProperty = @(10);
    self.model.greaterNumberProperty = @(15);
    self.model.oddNumberProperty = @(13);
    self.model.evenNumberProperty = @(10);
    self.model.blockNumberProperty = @(10);
    self.model.eachStringsProperty = @[ @"TEST", @"101" ];
    
    self.model.recursiveProperty = [[MockActiveModel alloc] init];
    self.model.recursiveProperty.acceptsNumberProperty = @(0);
    self.model.recursiveProperty.acceptsStringProperty = @"101";
    self.model.recursiveProperty.excludeNumberProperty = @(0);
    self.model.recursiveProperty.excludeStringProperty = @"101";
    self.model.recursiveProperty.lengthNumberProperty = @(1234);
    self.model.recursiveProperty.lengthStringProperty = @"1234";
    self.model.recursiveProperty.lengthRangeNumberProperty = @(1234);
    self.model.recursiveProperty.lengthRangeStringProperty = @"1234";
    self.model.recursiveProperty.formatNumberProperty = @(0);
    self.model.recursiveProperty.formatStringProperty = @"TEST";
    self.model.recursiveProperty.requiredStringProperty = @"TEST";
    self.model.recursiveProperty.nonRequiredNumberProperty = nil;
    self.model.recursiveProperty.inRangeNumberProperty = @(10);
    self.model.recursiveProperty.lessNumberProperty = @(10);
    self.model.recursiveProperty.greaterNumberProperty = @(15);
    self.model.recursiveProperty.oddNumberProperty = @(13);
    self.model.recursiveProperty.evenNumberProperty = @(10);
    self.model.recursiveProperty.blockNumberProperty = @(10);
    self.model.recursiveProperty.eachStringsProperty = @[ @"TEST", @"101" ];
}

- (void)testValidateAccepts {
    self.model.acceptsNumberProperty = @(0);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 0 value.");
    
    self.model.acceptsNumberProperty = @(1);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 1 value.");
    [self reset];
    
    self.model.acceptsStringProperty = @"101";
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify '101' value.");
    
    self.model.acceptsStringProperty = @"102";
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify '102' value.");
}

- (void)testValidateExcludes {
    self.model.excludeNumberProperty = @(2);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 2 value.");
    
    self.model.excludeNumberProperty = @(1);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 1 value.");
    [self reset];
    
    self.model.excludeStringProperty = @"TEST123123123123";
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 'TEST123123123123' value.");
    
    self.model.excludeStringProperty = @"";
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify '' value.");
}

- (void)testValidateWith {
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify default recursion value.");
    
    self.model.recursiveProperty.acceptsNumberProperty = @(12312);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify '12312' recursion value.");
}

- (void)testValidateLength {
    self.model.lengthNumberProperty = @(1);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 1 value.");
    
    self.model.lengthNumberProperty = @(1234);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 1234 value.");
    
    self.model.lengthNumberProperty = @(12345);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 12345 value.");
    [self reset];
    
    self.model.lengthStringProperty = @"1";
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify '1' value.");
    
    self.model.lengthStringProperty = @"1234";
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify '1234' value.");
    
    self.model.lengthStringProperty = @"12345";
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify '12345' value.");
}

- (void)testValidateLengthRange {
    self.model.lengthRangeNumberProperty = @(1);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 1 value.");
    
    self.model.lengthRangeNumberProperty = @(123);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 123 value.");
    
    self.model.lengthRangeNumberProperty = @(12345);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 12345 value.");
    
    self.model.lengthRangeNumberProperty = @(1234567890);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 1234567890 value.");
    
    self.model.lengthRangeNumberProperty = @(12345678901);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 12345678901 value.");
    [self reset];
    
    self.model.lengthRangeStringProperty = @"1";
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify '1' value.");
    
    self.model.lengthRangeStringProperty = @"123";
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify '123' value.");
    
    self.model.lengthRangeStringProperty = @"12345";
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify '12345' value.");
    
    self.model.lengthRangeStringProperty = @"1234567890";
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify '1234567890' value.");
    
    self.model.lengthRangeStringProperty = @"12345678901";
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify '12345678901' value.");
}

- (void)testValidateFormat {
    self.model.formatNumberProperty = @(123);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 123 value.");
    
    self.model.formatNumberProperty = @(1);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 1 value.");
    
    self.model.formatNumberProperty = @(5);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 5 value.");
    [self reset];
    
    self.model.formatStringProperty = @"1";
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify '1' value.");
    
    self.model.formatStringProperty = @"TEST";
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 'TEST' value.");
    
    self.model.formatStringProperty = @"Td4T";
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 'Td4T' value.");
    
    self.model.formatStringProperty = @"TSETR";
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 'TSETR' value.");
}

- (void)testValidateRequired {
    self.model.requiredStringProperty = nil;
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify nil value.");
    
    self.model.requiredStringProperty = @"123TEST123";
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify '123TEST123' value.");
}

- (void)testValidateNull {
    self.model.nonRequiredNumberProperty = @(123);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 123 value.");
    
    self.model.nonRequiredNumberProperty = nil;
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify nil value.");
}

- (void)testValidateInRange {
    self.model.inRangeNumberProperty = @(0);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 0 value.");
    
    self.model.inRangeNumberProperty = @(1);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 1 value.");
    
    self.model.inRangeNumberProperty = @(10);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 10 value.");
    
    self.model.inRangeNumberProperty = @(13);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 13 value.");
    
    self.model.inRangeNumberProperty = @(15);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 15 value.");
}

- (void)testValidateLess {
    self.model.lessNumberProperty = @(1);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 1 value.");
    
    self.model.lessNumberProperty = @(12);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 12 value.");
    
    self.model.lessNumberProperty = @(13);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 13 value.");
    
    self.model.lessNumberProperty = @(15);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 15 value.");
}

- (void)testValidateGreater {
    self.model.greaterNumberProperty = @(15);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 15 value.");
    
    self.model.greaterNumberProperty = @(100);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 100 value.");
    
    self.model.greaterNumberProperty = @(13);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 13 value.");
    
    self.model.greaterNumberProperty = @(10);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 10 value.");
}

- (void)testValidateOdd {
    self.model.oddNumberProperty = @(15);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 15 value.");
    
    self.model.oddNumberProperty = @(101);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 101 value.");
    
    self.model.oddNumberProperty = @(12);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 12 value.");
    
    self.model.oddNumberProperty = @(64);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 64 value.");
}

- (void)testValidateEven {
    self.model.evenNumberProperty = @(15);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 15 value.");
    
    self.model.evenNumberProperty = @(101);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 101 value.");
    
    self.model.evenNumberProperty = @(12);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 12 value.");
    
    self.model.evenNumberProperty = @(64);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 64 value.");
}

- (void)testValidateBlock {
    self.model.blockNumberProperty = @(0);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify 0 value.");
    
    self.model.blockNumberProperty = @(-10);
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify -10 value.");
    
    self.model.blockNumberProperty = @(1);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 1 value.");
    
    self.model.blockNumberProperty = @(101);
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify 101 value.");
}

- (void)testValidateEach {
    self.model.eachStringsProperty = nil;
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify nil value.");
    
    self.model.eachStringsProperty = @[ @"", @"TEST", @"123123", @"FUK" ];
    XCTAssertTrue([self.model validate:nil], @"Test model should qualify @[ @'', @'TEST', @'123123', @'FUK' ] value.");
    
    self.model.eachStringsProperty = @[ @"", @"TEST", @"fuck" ];
    XCTAssertFalse([self.model validate:nil], @"Test model shouldn't qualify @[ @'', @'TEST', @'fuck' ] value.");
}

@end
