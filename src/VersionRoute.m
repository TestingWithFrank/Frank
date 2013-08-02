//
//  VersionRoute.m
//  Frank
//
//  Created by Pete Hodgson on 7/8/13.
//
//

#import "VersionRoute.h"
#import "HTTPDataResponse.h"
#import "HttpRequestContext.h"

@implementation VersionRoute {
    NSString *_version;
}

- (id)initWithVersion:(NSString *)version
{
    self = [super init];
    if (self) {
        _version = [version copy];
    }
    return self;
}

- (void)dealloc
{
    [_version release];
    [super dealloc];
}

-(NSObject<HTTPResponse> *) handleRequest:(HTTPRequestContext *)context{
    return [context responseWithJsonBody:@{@"version":_version}];
}

@end
