//
//  VersionRoute.h
//  Frank
//
//  Created by Pete Hodgson on 7/8/13.
//
//

#import "RoutingEntry.h"

@interface VersionRoute : NSObject<HTTPRequestHandler>

- (id)initWithVersion:(NSString *)version;
@end
