//
//  HttpRequestContext.h
//  Frank
//
//  Created by Pete Hodgson on 7/7/13.
//
//

#import <Foundation/Foundation.h>

@class HTTPConnection;
@class RoutingHTTPConnection;
@class HTTPMessage;
@class HTTPFileResponse;
@class HTTPDataResponse;

@interface HTTPRequestContext : NSObject

- (id)initWithConnection:(RoutingHTTPConnection*)connection
          pathComponents:(NSArray *)pathComponents;

- (HTTPConnection *)connection;
- (BOOL) isMethod:(NSString *)method;
- (NSArray *)pathComponents;
- (NSDictionary *)queryParams;

- (NSString *)bodyAsString;
- (NSDictionary *)bodyAsJsonDict;


- (HTTPFileResponse *) fileResponseForPath:(NSString *)path;
- (HTTPDataResponse *) responseWithStringBody:(NSString *)body;
- (HTTPDataResponse *) responseWithJsonBody:(id)json;
- (HTTPDataResponse *) successResponseWithoutResults;
- (HTTPDataResponse *) successResponseWithResults:(NSArray *)results;
- (HTTPDataResponse *) errorResponseWithReason:(NSString *)reason andDetails:(NSString *)details;

@end
