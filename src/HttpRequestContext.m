//
//  HttpRequestContext.m
//  Frank
//
//  Created by Pete Hodgson on 7/7/13.
//
//

#import "HTTPRequestContext.h"

#import "HTTPMessage.h"

@interface HTTPRequestContext(){
    HTTPMessage *_request;
}

@end

@implementation HTTPRequestContext

- (id)initWithRequest:(HTTPMessage *)request
{
    self = [super init];
    if (self) {
        _request = [request retain];
    }
    return self;
}

- (void)dealloc
{
    [_request release];
    [super dealloc];
}

- (BOOL) isMethod:(NSString *)method{
    return( NSOrderedSame == [method compare:_request.method options:NSCaseInsensitiveSearch] );
}

- (NSString *)bodyAsString{
    // UTF8 might be a bogus assumption, but it's unlikely to fail.
    return [[[NSString alloc] initWithData:_request.body encoding:NSUTF8StringEncoding] autorelease];
}

@end
