//
//  dynsignpost_tests.m
//  dynsignpost-tests
//
//  Created by Ethan Arbuckle on 3/6/25.
//

#import <XCTest/XCTest.h>
#import "dynsignpost.h"

@interface dynsignpost_tests : XCTestCase
@end

@implementation dynsignpost_tests

- (void)setUp {
    [super setUp];
    SignpostTestUtils_PurgeMessages();
}

- (void)testHardcodedSignpostBeginEnd {
    // Given a signpost begin/end pair with hardcoded names
    // When the signposts are emitted
    SIGNPOST_BEGIN("TestBegin");
    SIGNPOST_END("TestEnd");

    // Then two signposts are captured
    NSArray<NSString *> *captured = SignpostTestUtils_CapturedMessages();
    XCTAssertEqual(captured.count, 2, @"Should have 2 signposts (begin + end).");
    
    // And the captured messages contain the hardcoded names
    XCTAssertTrue([captured[0] containsString:@"TestBegin"], @"First signpost should contain 'TestBegin'.");
    XCTAssertTrue([captured[1] containsString:@"TestEnd"], @"Second signpost should contain 'TestEnd'.");
}

- (void)testBlockSignpostDynamicName {
    // Given a dynamic string (not known at compile time)
    NSString *signpostName = [@"Dynamic" stringByAppendingString:@"Signpost"];
    
    // When a block is executed with a signpost,
    // And the dynamic string is used as the signpost name
    EXECUTE_WITH_SIGNPOST(signpostName.UTF8String, ^{
      NSLog(@"Signpost block");
    });
    
    // Then two signposts should be captured
    NSArray<NSString *> *captured = SignpostTestUtils_CapturedMessages();
    XCTAssertEqual(captured.count, 2, @"Should have 2 signposts for block (begin + end).");
    
    // And both captured messages should contain the dynamic string
    XCTAssertTrue([captured[0] containsString:@"DynamicSignpost"], @"Should contain 'DynamicSignpost' in the first message.");
    XCTAssertTrue([captured[1] containsString:@"DynamicSignpost"], @"Should contain 'DynamicSignpost' in the second message.");
}

- (void)testHardcodedSignPostNames {
    // Given a signpost log
    os_log_t log = get_signpost_log();
    os_signpost_id_t spid = os_signpost_id_generate(log);
    
    // And the name used for os_signpost begin/end calls is known at compile time
    #define BEGIN_NAME "BeginName"
    #define END_NAME "EndName"

    // When two signposts are emitted using the static string names
    dyn_os_signpost_interval_begin(log, spid, BEGIN_NAME, "Value: %d", 100);
    dyn_os_signpost_interval_end(log, spid, END_NAME, "Another: %@", @"HelloSignpost");

    // Then two signposts should be captured
    NSArray<NSString *> *captured = SignpostTestUtils_CapturedMessages();
    XCTAssertEqual(captured.count, 2, @"Expected 2 messages for begin and end.");
    
    // And the first item's name includes "BeginName"
    NSString *first = captured[0];
    XCTAssertTrue([first containsString:@BEGIN_NAME], @"Should contain 'BeginName'.");

    // And the second item's name includes "EndName"
    NSString *second = captured[1];
    XCTAssertTrue([second containsString:@END_NAME], @"Should contain 'EndName'.");
}

@end
