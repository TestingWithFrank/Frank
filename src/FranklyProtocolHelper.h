//
//  Created by pete on 5/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface FranklyProtocolHelper : NSObject
+ (NSDictionary *)errorResponseWithReason:(NSString *)reason andDetails:(NSString *)details;
+ (NSString *)generateErrorResponseWithReason:(NSString *)reason andDetails:(NSString *)details;

+ (NSDictionary *)successResponseWithoutResults;
+ (NSDictionary *)successResponseWithResults:(NSArray *)results;

+ (NSString *)generateSuccessResponseWithoutResults;
+ (NSString *)generateSuccessResponseWithResults:(NSArray *)results;


@end