//
//  BasicRoute.h
//  Frank
//
//  Created by Pete Hodgson on 7/8/13.
//
//

#import <Foundation/Foundation.h>
#import "RoutingEntry.h"

@class HTTPDataResponse;

@interface BasicRoute : NSObject<HTTPRequestHandler>{
    HTTPRequestContext *_context;
}

- (id)initWithContext:(HTTPRequestContext *)context;

- (HTTPDataResponse *)responseWithJsonBody:(id)json;
- (HTTPDataResponse *)responseWithStringBody:(NSString *)body;
@end
