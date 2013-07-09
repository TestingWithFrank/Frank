//
//  DeviceRoute.m
//  Frank
//
//  Created by Pete Hodgson on 7/7/13.
//
//

#import "DeviceRoute.h"

#import "JSON.h"
#import "HTTPDataResponse.h"

@implementation DeviceRoute

-(NSObject<HTTPResponse> *) handleRequest:(HTTPRequestContext *)context{
    NSString* device = nil;
    
#if TARGET_OS_IPHONE
    switch ([[UIDevice currentDevice] userInterfaceIdiom]) {
        case UIUserInterfaceIdiomPhone:
            device = @"iphone";
            break;
            
        case UIUserInterfaceIdiomPad:
            device = @"ipad";
            break;
            
        default:
            device = @"unknown";
            break;
    }
#else
    device = @"mac";
#endif
    
    return [self responseWithJsonBody:@{@"device":device}];
}

@end