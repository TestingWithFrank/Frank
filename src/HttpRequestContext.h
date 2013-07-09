//
//  HttpRequestContext.h
//  Frank
//
//  Created by Pete Hodgson on 7/7/13.
//
//

#import <Foundation/Foundation.h>

@class HTTPMessage;

@interface HTTPRequestContext : NSObject

- (id)initWithRequest:(HTTPMessage *)request;

- (BOOL) isMethod:(NSString *)method;
- (NSString *)bodyAsString;
@end
