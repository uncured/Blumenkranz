#import <XCTest/XCTest.h>
#import "VMContextInjecting.h"
#import "VMInjection.h"
#import "VMContext.h"
#import "NSObject+VMExtension.h"
#import "VMContextBindingManager.h"


#pragma mark Mock injectable objects

/*
 * Clean injection
 */
@interface SimpleInjectionMockObject : NSObject
@end

@implementation SimpleInjectionMockObject
@end

/*
 * Named injection
 */
@interface NamedInjectionMockObject : NSObject
@end

@implementation NamedInjectionMockObject

BIND_NAME(@"NamedObject")

@end

/*
 * Singletone injection
 */
@interface SingletoneInjectionMockObject : NSObject
@end

@implementation SingletoneInjectionMockObject

SINGLETONE

@end

/*
 * Named singletone injection
 */
@interface NamedSingletoneInjectionMockObject : NSObject
@end

@implementation NamedSingletoneInjectionMockObject

SINGLETONE
BIND_NAME(@"TestSingletone")

@end


#pragma mark Test Context
/*
 * Context exposure
 */
@interface VMContext ()
@property (nonatomic, strong) VMContextBindingManager *bindingManager;
@end

/*
 * Test context
 */
@interface InjectionTestContext : VMContext

@end

@implementation InjectionTestContext

@end


#pragma mark Actual test class
/*
 * Here we go testing!
 */
@interface InjectionTests : XCTestCase

@end

@implementation InjectionTests

- (void)setUp {
    [super setUp];
    
    [VMContext context];
}

- (void)tearDown {
    [super tearDown];
    
    [[VMContext context] resetContext];
}

- (void)testCleanInjection {
    id object = [[VMContext context] provide:[SimpleInjectionMockObject class]];
    
    XCTAssertNotNil(object, @"Nil provided by context");
    XCTAssertTrue([object isMemberOfClass:[SimpleInjectionMockObject class]], @"Object %@ is not of SimpleInjectionMockObject class.", object);
    
    id object2 = [[VMContext context] provide:[SimpleInjectionMockObject class]];

    XCTAssertNotNil(object2, @"Nil provided by context");
    XCTAssertTrue([object2 isMemberOfClass:[SimpleInjectionMockObject class]], @"Object %@ is not of SimpleInjectionMockObject class.", object2);
    
    XCTAssertFalse(object == object2, @"Objects %@ and %@ shouldn't be identical.", object, object2);
}

- (void)testNamedInjection {
    id object = [[VMContext context] provide:[NamedInjectionMockObject class]];
    
    XCTAssertNotNil(object, @"Nil provided by context");
    XCTAssertTrue([object isMemberOfClass:[NamedInjectionMockObject class]], @"Object %@ is not of NamedInjectionMockObject class.", object);
    
    id object2 = [[VMContext context] provide:[NamedInjectionMockObject class]];
    
    XCTAssertNotNil(object2, @"Nil provided by context");
    XCTAssertTrue([object2 isMemberOfClass:[NamedInjectionMockObject class]], @"Object %@ is not of NamedInjectionMockObject class.", object2);
    
    XCTAssertFalse(object == object2, @"Objects %@ and %@ shouldn't be identical.", object, object2);
    
    id name = [object vm_isContextName];
    XCTAssertEqualObjects(name, @"NamedObject", @"Named object has unpredicted name => %@", name);
    
    id binding = [[[VMContext context] bindingManager] bindTarget:name];
    XCTAssertEqualObjects(binding, [NamedInjectionMockObject class], @"Binding %@ is wrong.", binding);
}

- (void)testSingletoneInjection {
    id object = [[VMContext context] provide:[SingletoneInjectionMockObject class]];
    
    XCTAssertNotNil(object, @"Nil provided by context");
    XCTAssertTrue([object isMemberOfClass:[SingletoneInjectionMockObject class]], @"Object %@ is not of SingletoneInjectionMockObject class.", object);
    
    id object2 = [[VMContext context] provide:[SingletoneInjectionMockObject class]];
    
    XCTAssertNotNil(object2, @"Nil provided by context");
    XCTAssertTrue([object2 isMemberOfClass:[SingletoneInjectionMockObject class]], @"Object %@ is not of SingletoneInjectionMockObject class.", object2);
    
    XCTAssertTrue(object == object2, @"Objects %@ and %@ should be identical.", object, object2);
}

- (void)testNamedSingletoneInjection {
    id object = [[VMContext context] provide:[NamedSingletoneInjectionMockObject class]];
    
    XCTAssertNotNil(object, @"Nil provided by context");
    XCTAssertTrue([object isMemberOfClass:[NamedSingletoneInjectionMockObject class]], @"Object %@ is not of NamedSingletoneInjectionMockObject class.", object);
    
    id object2 = [[VMContext context] provide:[NamedSingletoneInjectionMockObject class]];
    
    XCTAssertNotNil(object2, @"Nil provided by context");
    XCTAssertTrue([object2 isMemberOfClass:[NamedSingletoneInjectionMockObject class]], @"Object %@ is not of NamedSingletoneInjectionMockObject class.", object2);
    
    XCTAssertTrue(object == object2, @"Objects %@ and %@ should be identical.", object, object2);
    
    id object3 = [[VMContext context] provide:@"TestSingletone"];
    
    XCTAssertNotNil(object3, @"Nil provided by context");
    XCTAssertTrue([object3 isMemberOfClass:[NamedSingletoneInjectionMockObject class]], @"Object %@ is not of NamedSingletoneInjectionMockObject class.", object3);
    
    XCTAssertTrue(object == object3, @"Objects %@ and %@ should be identical.", object, object3);
}

@end
