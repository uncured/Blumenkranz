#import <XCTest/XCTest.h>
#import "NSObject+VMExtension.h"

#pragma mark Mock objects
@interface MockBaseObject : NSObject
@property (strong) id general;
@property (strong) id<NSObject> generalWithProtocol;
@property (strong) NSString *string;
@property (weak) NSNumber *number;
@property (copy) void (^callback)();
@property (assign) NSInteger integer;
@end

@implementation MockBaseObject
@end

#pragma mark Actual test class
@interface ObjectTests : XCTestCase

@end

@implementation ObjectTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testAnnotation {
    NSObject *object = [[NSObject alloc] init];

    id number = @(3);
    object.annotation = number;
    XCTAssertTrue([object.annotation isEqual:number], @"NSObject should be annotated with %@.", number);

    id string = @"random string";
    object.annotation = string;
    XCTAssertTrue([object.annotation isEqual:string], @"NSObject should be annotated with '%@'.", string);

    id anotherObject = [NSArray array];
    object.annotation = anotherObject;
    XCTAssertTrue([object.annotation isEqual:anotherObject], @"NSObject should be annotated with %@.", [anotherObject description]);

    object.annotation = nil;
    XCTAssertNil(object.annotation, @"NSObject should be annotated with nil.");
}

- (void)testSingletone {
    NSObject *object = [NSObject singletone];
    NSObject *anotherObject = [NSObject singletone];

    XCTAssertTrue(object == anotherObject, @"NSObject singletone should keep the same memory address.");
}

- (void)testPropertyClass {
    XCTAssertNil([MockBaseObject classOfProperty:@"general"], @"MockBaseObject @general property class should be invalidated.");
    XCTAssertNil([MockBaseObject classOfProperty:@"generalWithProtocol"], @"MockBaseObject @generalWithProtocol property class should be invalidated.");
    XCTAssertTrue([[MockBaseObject classOfProperty:@"string"] isEqual:[NSString class]], @"MockBaseObject @string property class should be NSString.");
    XCTAssertTrue([[MockBaseObject classOfProperty:@"number"] isEqual:[NSNumber class]], @"MockBaseObject @number property class should be NSNumber.");
    XCTAssertTrue([[MockBaseObject classOfProperty:@"callback"] isEqual:NSClassFromString(@"NSBlock")], @"MockBaseObject @string property class should be NSBlock.");
    XCTAssertNil([MockBaseObject classOfProperty:@"integer"], @"MockBaseObject @integer property class should be invalidated.");
    XCTAssertNil([MockBaseObject classOfProperty:@"someInvalidPropertyName"], @"MockBaseObject non-existing @someInvalidPropertyName property class should be invalidated.");
}

- (void)testCanBeCopied {
    NSNumber *successCopyTarget = @(1);
    XCTAssertTrue(vmObjectCanBeCopied(successCopyTarget), @"NSNumber should be copiable object.");

    NSObject *failCopyTarget = [[NSObject alloc] init];
    XCTAssertFalse(vmObjectCanBeCopied(failCopyTarget), @"NSObject should not be copiable object.");

    void (^successCopyBlockTarget)() = ^(){
        NSLog(@"Simple block");
    };
    XCTAssertTrue(vmObjectCanBeCopied(successCopyBlockTarget), @"NSBlock should be copiable object.");
}

- (void)testCanBeCopiedMutably {
    NSNumber *failCopyTargetOne = @(1);
    XCTAssertFalse(vmObjectCanBeCopiedMutably(failCopyTargetOne), @"NSNumber should not be mutably copiable object.");
    
    NSObject *failCopyTargetTwo = [[NSObject alloc] init];
    XCTAssertFalse(vmObjectCanBeCopiedMutably(failCopyTargetTwo), @"NSObject should not be mutably copiable object.");
    
    void (^failCopyBlockTarget)() = ^(){
        NSLog(@"Simple block");
    };
    XCTAssertFalse(vmObjectCanBeCopiedMutably(failCopyBlockTarget), @"NSBlock should not be mutably copiable object.");
    
    NSArray *successCopyTargetOne = @[ @(1), @"2" ];
    XCTAssertTrue(vmObjectCanBeCopiedMutably(successCopyTargetOne), @"NSArray should be mutably copiable object.");
    
    NSString *successCopyTargetTwo = @"Immutable string";
    XCTAssertTrue(vmObjectCanBeCopiedMutably(successCopyTargetTwo), @"NSString should be mutably copiable object.");
}

@end
