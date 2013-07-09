//
//  BasicRoute.m
//  Frank
//
//  Created by Pete Hodgson on 7/8/13.
//
//

#import "BasicRoute.h"

#import "AnyJSON.h"
#import "HTTPDataResponse.h"

@implementation BasicRoute

- (id)initWithContext:(HTTPRequestContext *)context
{
    self = [super init];
    if (self) {
        _context = [context retain];
    }
    return self;
}

- (void)dealloc
{
    [_context release];
    [super dealloc];
}

-(NSObject<HTTPResponse> *) handleRequest {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(HTTPDataResponse *)responseWithStringBody:(NSString *)body{
    NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
    return [[[HTTPDataResponse alloc] initWithData:data] autorelease];
}

-(HTTPDataResponse *)responseWithJsonBody:(id)json{
    NSData *data = AnyJSONEncode(json, nil);
    return [[[HTTPDataResponse alloc] initWithData:data] autorelease];
}


@end
