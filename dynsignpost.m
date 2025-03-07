//
//  dynsignpost.m
//  dynamic-signpost
//
//  Created by Ethan Arbuckle on 3/6/25.
//

#import "dynsignpost.h"

os_log_t get_signpost_log(void) {
    static os_log_t signpost_log = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        signpost_log = os_log_create("com.objc.dynasignpost", "signposts");
    });
    
    return signpost_log;
}

