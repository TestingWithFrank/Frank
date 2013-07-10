//
//  FixedRoutingEntry.m
//  Frank
//
//  Created by Pete Hodgson on 7/10/13.
//
//

#import "FixedRoutingEntry.h"

@interface FixedRoutingEntry() {
    NSString *_path;
    NSArray *_supportedMethods;
    HandlerCreator _handlerCreator;
}
@end

@implementation FixedRoutingEntry

- (id)initForPath:(NSString *)path
supportingMethods:(NSArray *)methods
        createdBy:(HandlerCreator)handlerCreator
{
    self = [super init];
    if (self) {
        // TODO: normalize path (e.g. strip trailing /)
        _path = [path copy];
        _supportedMethods = [methods retain];
        _handlerCreator = handlerCreator;
    }
    return self;
}

- (void)dealloc
{
    [_path release];
    [_supportedMethods release];
    
    [super dealloc];
}

- (BOOL)handlesPath:(NSArray *)pathComponents{
    NSString *incomingPath = [@"/" stringByAppendingString:[pathComponents componentsJoinedByString:@"/"]];
    return( NSOrderedSame == [incomingPath compare:_path options:NSCaseInsensitiveSearch] );
}

- (BOOL)supportsMethod:(NSString *)method{
    NSPredicate *containsMethod = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",method];
    return ([[_supportedMethods filteredArrayUsingPredicate:containsMethod] count] > 0);
}

- (NSObject<HTTPRequestHandler> *)newHandler
{
    return _handlerCreator();
}

@end
