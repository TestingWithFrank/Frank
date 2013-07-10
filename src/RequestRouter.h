#import <Foundation/Foundation.h>

#import "HTTPResponse.h"
#import "RoutingEntry.h"

@class RoutingHTTPConnection;

@protocol Route

- (NSObject<HTTPResponse> *) handleRequestForPath: (NSArray *)path withConnection:(RoutingHTTPConnection *)connection;
- (BOOL) canHandlePostForPath: (NSArray *)path;

@end



@interface RequestRouter : NSObject {
	NSMutableArray *_routes; // deprecated
    NSMutableArray *_routingTable; // The new hotness. RoutingEntry instances
}

+ (RequestRouter *)singleton;

- (void) registerRoute: (id<Route>) route;
- (void) registerRoutingEntry:(id<RoutingEntry>)routingEntry;
- (void) registerRouteForPath:(NSString *)path
            supportingMethods:(NSArray *)methods
                    createdBy:(HandlerCreator)handlerClass;

- (NSObject<HTTPResponse> *) handleRequestForPath:(NSString *)path
                                           method:(NSString *)method
                                       connection:(RoutingHTTPConnection *)connection;

- (NSObject<HTTPResponse> *) handleRequestForPath:(NSString *)path
                                   withConnection:(RoutingHTTPConnection *)connection;

- (BOOL) canHandlePostForPath:(NSString *)path;

@end
