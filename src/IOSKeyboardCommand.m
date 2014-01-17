//
//  Created by pete on 5/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "FranklyProtocolHelper.h"
#import "IOSKeyboardCommand.h"
#import "JSON.h"
#import "KIFTypist.h"
#import "UIApplication-KIFAdditions.h"

@implementation IOSKeyboardCommand {

}

- (NSString *)generateKeyboardNotPresentErrorResponse {
    return [FranklyProtocolHelper generateErrorResponseWithReason:@"keyboard not present"
                                                       andDetails:@"The iOS keyboard is not currently present, so Frank can't use it so simulate typing. You might want to simulate a tap on the thing you want to type into first."];
}

- (NSString *)handleCommandWithRequestBody:(NSString *)requestBody {

    NSDictionary *requestCommand = FROM_JSON(requestBody);
	NSString *textToType = [requestCommand objectForKey:@"text_to_type"];

    if( ![[UIApplication sharedApplication] keyboardWindow]){
        return [self generateKeyboardNotPresentErrorResponse];
    }
    
    for (NSUInteger characterIndex = 0; characterIndex < [textToType length]; characterIndex++) {
        NSString *characterString = [textToType substringWithRange:NSMakeRange(characterIndex, 1)];
        [KIFTypist enterCharacter: characterString];
    }

	return [FranklyProtocolHelper generateSuccessResponseWithoutResults];
}

@end