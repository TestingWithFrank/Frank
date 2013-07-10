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

@interface HTTPRequestContext : NSObject

- (id)initWithConnection:(RoutingHTTPConnection*)connection
          pathComponents:(NSArray *)pathComponents;

- (HTTPConnection *)connection;
- (BOOL) isMethod:(NSString *)method;
- (NSString *)bodyAsString;
- (NSArray *)pathComponents;

- (HTTPFileResponse *) fileResponseForPath:(NSString *)path;
@end
