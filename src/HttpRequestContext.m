//
//  HttpRequestContext.m
//  Frank
//
//  Created by Pete Hodgson on 7/7/13.
//
//

#import "HTTPRequestContext.h"

#import "HTTPMessage.h"
#import "HTTPFileResponse.h"
#import "RoutingHTTPConnection.h"

@interface HTTPRequestContext(){
    RoutingHTTPConnection *_connection;
    NSArray *_pathComponents;
}

@end

@implementation HTTPRequestContext

- (id)initWithConnection:(RoutingHTTPConnection*)connection
          pathComponents:(NSArray *)pathComponents
{
    self = [super init];
    if (self) {
        _connection = [connection retain];
        _pathComponents = [pathComponents retain];
    }
    return self;
}

- (void)dealloc
{
    [_connection release];
    [_pathComponents release];
    [super dealloc];
}

- (BOOL) isMethod:(NSString *)method{
    return( NSOrderedSame == [method compare:_connection.request.method options:NSCaseInsensitiveSearch] );
}

- (HTTPConnection *)connection{
    return _connection;
}

- (NSArray *)pathComponents{
    return _pathComponents;
}

- (NSString *)bodyAsString{
    // UTF8 might be a bogus assumption, but it's unlikely to fail.
    return [[[NSString alloc] initWithData:_connection.request.body encoding:NSUTF8StringEncoding] autorelease];
}

- (HTTPFileResponse *) fileResponseForPath:(NSString *)path{
    return [[HTTPFileResponse alloc] initWithFilePath:path forConnection:_connection];
}

@end
