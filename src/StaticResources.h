//
//  StaticResources.h
//  Frank
//
//  Created by Pete Hodgson on 7/10/13.
//
//

#import "RoutingEntry.h"

@interface StaticResources : NSObject<RoutingEntry,HTTPRequestHandler>
- (id) initWithStaticResourceSubDir:(NSString *)resourceSubdir;
@end
