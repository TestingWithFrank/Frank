//
//  RoutingEntry.h
//  Frank
//
//  Created by Pete Hodgson on 7/7/13.
//
//

#import <Foundation/Foundation.h>

#import "HTTPResponse.h"

@class HTTPRequestContext;

@protocol HTTPRequestHandler
@required
-(NSObject<HTTPResponse> *) handleRequest:(HTTPRequestContext *)context;
@end

typedef NSObject<HTTPRequestHandler> *(^HandlerCreator)();

@interface RoutingEntry : NSObject

- (id)initForPath:(NSString *)path
supportingMethods:(NSArray *)methods
   createdBy:(HandlerCreator)handlerCreator;

- (BOOL)handlesPath:(NSArray *)pathComponents;
- (BOOL)supportsMethod:(NSString *)method;
- (NSObject<HTTPRequestHandler> *)newHandler;


@end
