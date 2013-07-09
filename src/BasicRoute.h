//
//  BasicRoute.h
//  Frank
//
//  Created by Pete Hodgson on 7/8/13.
//
//

#import <Foundation/Foundation.h>
#import "RoutingEntry.h"

#import "HTTPDataResponse.h"


@interface BasicRoute : NSObject<HTTPRequestHandler>
- (HTTPDataResponse *)responseWithJsonBody:(id)json;
- (HTTPDataResponse *)responseWithStringBody:(NSString *)body;
- (HTTPDataResponse *)successResponseWithoutResults;
- (HTTPDataResponse *)errorResponseWithReason:(NSString *)reason andDetails:(NSString *)details;

@end
