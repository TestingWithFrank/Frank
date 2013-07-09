//
//  BasicRoute.m
//  Frank
//
//  Created by Pete Hodgson on 7/8/13.
//
//

#import "BasicRoute.h"

#import "AnyJSON.h"
#import "FranklyProtocolHelper.h"

@implementation BasicRoute

-(NSObject<HTTPResponse> *) handleRequest:(HTTPRequestContext *)context {
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

-(HTTPDataResponse *)successResponseWithoutResults{
    return [self responseWithJsonBody:[FranklyProtocolHelper successResponseWithoutResults]];
}

-(HTTPDataResponse *)errorResponseWithReason:(NSString *)reason andDetails:(NSString *)details{
    return [self responseWithJsonBody:[FranklyProtocolHelper errorResponseWithReason:reason andDetails:details]];
}
@end
