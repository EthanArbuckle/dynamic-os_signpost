//
//  dynsignpost_mock.m
//  dynsignpost-tests
//
//  Created by Ethan Arbuckle on 3/6/25.
//

#import <Foundation/Foundation.h>
#import <os/signpost.h>
#import <os/log.h>

#ifdef UNIT_TESTING_SIGNPOST

#import "dynsignpost.h"

static NSMutableArray<NSString *> *gCapturedSignpostMessages = nil;

void mock_signpost_emit(void *dso, os_log_t log, os_signpost_type_t type, os_signpost_id_t spid, const char *name, const char *format, uint8_t *buffer, uint32_t bufsize) {
    if (!gCapturedSignpostMessages) {
        gCapturedSignpostMessages = [[NSMutableArray alloc] init];
    }
    
    NSString *finalMessage = [[NSString alloc] initWithBytes:buffer length:bufsize encoding:NSUTF8StringEncoding];
    if (!finalMessage) {
        finalMessage = @"<no message>";
    }
    
    NSString *nameString = [[NSString alloc] initWithUTF8String:name];
    if (!nameString) {
        nameString = @"<no name>";
    }
    
    [gCapturedSignpostMessages addObject:[NSString stringWithFormat:@"[%@] %@", nameString, finalMessage]];
}

NSArray<NSString *> *SignpostTestUtils_CapturedMessages(void) {
    if (!gCapturedSignpostMessages) {
        return @[];
    }

    return [gCapturedSignpostMessages copy];
}

void SignpostTestUtils_PurgeMessages(void) {
    if (!gCapturedSignpostMessages) {
        gCapturedSignpostMessages = [[NSMutableArray alloc] init];
    }
    else {
        [gCapturedSignpostMessages removeAllObjects];
    }
}

#else // UNIT_TESTING_SIGNPOST == 0

void mock_signpost_emit(void *dso, os_log_t log, os_signpost_type_t type, os_signpost_id_t spid, const char *name, const char *format, uint8_t *buffer, uint32_t bufsize) {}

NSArray<NSString *> *SignpostTestUtils_CapturedMessages(void) {
    return @[];
}

void SignpostTestUtils_PurgeMessages(void) {}

#endif // UNIT_TESTING_SIGNPOST
