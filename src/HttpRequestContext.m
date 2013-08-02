//
//  HttpRequestContext.m
//  Frank
//
//  Created by Pete Hodgson on 7/7/13.
//
//

#import "HTTPRequestContext.h"

#import "AnyJSON.h"

#import "HTTPMessage.h"
#import "HTTPFileResponse.h"
#import "HTTPDataResponse.h"
#import "RoutingHTTPConnection.h"
#import "FranklyProtocolHelper.h"

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

- (NSDictionary *)bodyAsJsonDict{
    return AnyJSONDecode(_connection.request.body, nil);
}

- (HTTPFileResponse *) fileResponseForPath:(NSString *)path{
    return [[HTTPFileResponse alloc] initWithFilePath:path forConnection:_connection];
}

-(HTTPDataResponse *)responseWithStringBody:(NSString *)body{
    NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
    return [[[HTTPDataResponse alloc] initWithData:data] autorelease];
}

-(HTTPDataResponse *)responseWithJsonBody:(id)json{
    NSData *data = AnyJSONEncode(json, nil);
    return [[[HTTPDataResponse alloc] initWithData:data] autorelease];
}

-(HTTPDataResponse *)successResponseWithoutResults{
    return [self responseWithJsonBody:[FranklyProtocolHelper successResponseWithoutResults]];
}

-(HTTPDataResponse *)errorResponseWithReason:(NSString *)reason andDetails:(NSString *)details{
    return [self responseWithJsonBody:[FranklyProtocolHelper errorResponseWithReason:reason andDetails:details]];
}

@end
