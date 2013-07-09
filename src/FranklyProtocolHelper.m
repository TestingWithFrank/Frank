//
//  Created by pete on 5/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FranklyProtocolHelper.h"

#import "JSON.h"


@implementation FranklyProtocolHelper

+ (NSDictionary *)errorResponseWithReason:(NSString *)reason andDetails:(NSString *)details{
    return @{@"outcome":@"ERROR",@"reason":reason,@"details":details};
}
+ (NSString *)generateErrorResponseWithReason:(NSString *)reason andDetails:(NSString *)details{
	return TO_JSON([self errorResponseWithReason:reason andDetails:details]);
}


+ (NSDictionary *)successResponseWithoutResults{
    return @{@"outcome":@"SUCCESS"};
}
+ (NSString *)generateSuccessResponseWithoutResults{
	return TO_JSON([self successResponseWithoutResults]);
}

+ (NSString *)generateSuccessResponseWithResults:(NSArray *)results{
	NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"SUCCESS", @"outcome",
							  results, @"results",
							  nil];
	return TO_JSON(response);
}

@end