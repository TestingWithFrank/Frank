//
//  OrientationRoute.m
//  Frank
//
//  Created by Pete Hodgson on 7/8/13.
//
//

#import "OrientationRoute.h"

#import <PublicAutomation/UIAutomationBridge.h>

#import "HttpRequestContext.h"

@implementation OrientationRoute

- (NSDictionary *)representOrientation:(NSString *)orientation withDetailedOrientation:(NSString *)detailedOrientation{
    return @{@"orientation":orientation, @"detailed_description":detailedOrientation};
}

- (NSDictionary *)getOrientationRepresentationViaStatusBar{
    switch([[UIApplication sharedApplication] statusBarOrientation]){
		case UIInterfaceOrientationLandscapeLeft:
            return [self representOrientation:@"landscape" withDetailedOrientation:@"landscape_left"];
		case UIInterfaceOrientationLandscapeRight:
            return [self representOrientation:@"landscape" withDetailedOrientation:@"landscape_right"];
		case UIInterfaceOrientationPortrait:
            return [self representOrientation:@"portrait" withDetailedOrientation:@"portrait"];
		case UIInterfaceOrientationPortraitUpsideDown:
            return [self representOrientation:@"portrait" withDetailedOrientation:@"portrait_upside_down"];
        default:
            NSLog(@"Device orientation via status bar is unknown");
            return nil;
    }
}

- (NSDictionary *)getOrientationRepresentationViaDevice{
    switch ( [UIDevice currentDevice].orientation ) {
		case UIDeviceOrientationLandscapeRight:
            return [self representOrientation:@"landscape" withDetailedOrientation:@"landscape_right"];
		case UIDeviceOrientationLandscapeLeft:
            return [self representOrientation:@"landscape" withDetailedOrientation:@"landscape_left"];
		case UIDeviceOrientationPortrait:
            return [self representOrientation:@"portrait" withDetailedOrientation:@"portrait"];
		case UIDeviceOrientationPortraitUpsideDown:
            return [self representOrientation:@"portrait" withDetailedOrientation:@"portrait_upside_down"];
        case UIDeviceOrientationFaceUp:
            NSLog(@"Device orientation is face up");
            return nil;
        case UIDeviceOrientationFaceDown:
            NSLog(@"Device orientation is face down");
            return nil;
        default:
            NSLog(@"Device orientation via device is unknown");
            return nil;
	}
}

- (HTTPDataResponse *)handleGet{
   	NSDictionary *orientationDescription = [self getOrientationRepresentationViaDevice];
    if( !orientationDescription )
        orientationDescription = [self getOrientationRepresentationViaStatusBar];
	
    return [self responseWithJsonBody:orientationDescription];
}

- (HTTPDataResponse *)handlePost:(NSString *)requestBody{
    requestBody = [requestBody lowercaseString];
    
    UIDeviceOrientation requestedOrientation = UIDeviceOrientationUnknown;
    if( [requestBody isEqualToString:@"landscape_right"] ){
        requestedOrientation = UIDeviceOrientationLandscapeRight;
    }else if( [requestBody isEqualToString:@"landscape_left"] ){
        requestedOrientation = UIDeviceOrientationLandscapeLeft;
    }else if( [requestBody isEqualToString:@"portrait"] ){
        requestedOrientation = UIDeviceOrientationPortrait;
    }else if( [requestBody isEqualToString:@"portrait_upside_down"] ){
        requestedOrientation = UIDeviceOrientationPortraitUpsideDown;
    }
    
    if( requestedOrientation == UIDeviceOrientationUnknown){
        return [self errorResponseWithReason:@"unrecognized orientation"
                                  andDetails:[NSString stringWithFormat:@"orientation '%@' is invalid. Use 'landscape_right','landscape_left','portrait', or 'portrait_upside_down'", requestBody]];
    }
    
    [UIAutomationBridge setOrientation:requestedOrientation];
    
    return [self successResponseWithoutResults];
}

-(NSObject<HTTPResponse> *) handleRequest:(HTTPRequestContext *)context{
    if( [context isMethod:@"GET"] ){
        return [self handleGet];
        
    }else if( [context isMethod:@"POST"] ){
        return [self handlePost:context.bodyAsString];
    }else{
        return nil;
    }
}



@end
