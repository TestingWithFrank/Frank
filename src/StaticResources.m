//
//  StaticResources.m
//  Frank
//
//  Created by Pete Hodgson on 7/10/13.
//
//

#import "StaticResources.h"

#import "HttpRequestContext.h"
#import "HTTPFileResponse.h"

extern BOOL frankLogEnabled;

@interface StaticResources(){
    NSString *_staticResourceDirectoryPath;
}
@end


@implementation StaticResources

- (id) initWithStaticResourceSubDir:(NSString *)resourceSubdir
{
	self = [super init];
	if (self != nil) {
		_staticResourceDirectoryPath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:resourceSubdir]retain];
	}
	return self;
}

- (void) dealloc
{
	[_staticResourceDirectoryPath release];
	[super dealloc];
}

- (BOOL)handlesPath:(NSArray *)pathComponents {
    return [self localFileExistsForResource:pathComponents];
}

- (BOOL)supportsMethod:(NSString *)method {
    return (NSOrderedSame == [@"GET" compare:method options:NSCaseInsensitiveSearch]);
}
- (NSObject<HTTPRequestHandler> *)newHandler{
    // I am my own request handler!
    return [self retain];
}

-(NSObject<HTTPResponse> *) handleRequest:(HTTPRequestContext *)context{
    if( [self localFileExistsForResource:context.pathComponents] )
    {
        return [context fileResponseForPath:[self localPathForResource:context.pathComponents]];
    }else{
        return nil;
    }
}

- (BOOL) localFileExistsForResource:(NSArray *)pathComponents{
    
    if(frankLogEnabled) {
        NSLog( @"Checking for static file at %@", [self localPathForResource:pathComponents]);
    }
	BOOL isDir = YES;
	return( [[NSFileManager defaultManager] fileExistsAtPath:[self localPathForResource:pathComponents] isDirectory:&isDir] && !isDir );
}

- (NSString *)localPathForResource:(NSArray *)pathComponents{
    return [_staticResourceDirectoryPath stringByAppendingPathComponent: [NSString pathWithComponents:pathComponents]];
}

@end
