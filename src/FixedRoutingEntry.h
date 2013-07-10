//
//  FixedRoutingEntry.h
//  Frank
//
//  Created by Pete Hodgson on 7/10/13.
//
//

#import "RoutingEntry.h"

@interface FixedRoutingEntry : NSObject<RoutingEntry>

- (id)initForPath:(NSString *)path
supportingMethods:(NSArray *)methods
        createdBy:(HandlerCreator)handlerCreator;

@end
