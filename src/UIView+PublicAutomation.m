//
//  UIView+PublicAutomation.m
//  Frank
//
//  Created by Pete Hodgson on 10/15/11.
//  Copyright (c) 2011 ThoughtWorks. All rights reserved.
//

#import "LoadableCategory.h"
#import "CGGeometry-KIFAdditions.h"
#import "UIApplication-KIFAdditions.h"
#import "UITouch-KIFAdditions.h"
#import "UIView-KIFAdditions.h"
MAKE_CATEGORIES_LOADABLE(UIView_PublicAutomation)

@interface UIView ()

- (UIEvent*) _eventWithTouch: (UITouch*) touch;

@end

NSString * formatCGPointVal(NSValue *val) {
    CGPoint p = [val CGPointValue];
    return [NSString stringWithFormat:@"[%.2f, %.2f]", p.x, p.y];
}

@implementation UIView(PublicAutomation)

#pragma mark - Utils

- (CGPoint)FEX_centerPoint {
    return CGPointMake(0.5 * self.bounds.size.width, 0.5 * self.bounds.size.height);
}

- (CGPoint)FEX_pointFromX:(NSNumber*)x andY:(NSNumber*)y {
    if (CGFLOAT_IS_DOUBLE) {
		return CGPointMake([x doubleValue], [y doubleValue]);
	}
	else {
        return CGPointMake([x floatValue], [y floatValue]);
    }
}

#pragma mark - Test touch

- (BOOL)FEX_isPointInWindow:(CGPoint)point {
    CGPoint pointInWindowCoords = [self.window convertPoint:point fromView:self];
    
    return (CGRectContainsPoint(self.window.bounds, pointInWindowCoords));
}

- (BOOL)FEX_isPointInDirectViewHierarchy:(CGPoint)point touchRecipient:(UIView**)touchRecipient {
    CGPoint pointInWindowCoords = [self.window convertPoint:point fromView:self];
    
    UIView* touchedView = [self.window hitTest:pointInWindowCoords withEvent:nil];
    
    if (touchRecipient) {
        *touchRecipient = touchedView;
    }
    
    if ([touchedView isDescendantOfView:self]) {
        return YES;
    }
    else if ([self isDescendantOfView:touchedView]) {
        /* the following code implements the same functionality as `hitTest:withEvent:`
         but it doesn't ignore views with disabled user interactions */
        
        BOOL canContinue;
        
        do {
            canContinue = NO;
            
            CGPoint testedPoint = [self.window convertPoint:pointInWindowCoords toView:touchedView];
            NSArray* subviews = [[touchedView.subviews copy] autorelease];
            
            for (NSUInteger i = subviews.count; i > 0; i--) {
                UIView* subview = [subviews objectAtIndex:(i - 1)];
                
                if (subview.alpha < 0.01 || subview.hidden) {
                    continue;
                }
                
                CGPoint testedPointInSubviewCoords = [subview convertPoint:testedPoint fromView:touchedView];
                
                if ([subview pointInside:testedPointInSubviewCoords withEvent:nil]) {
                    if (subview == self) {
                        return YES;
                    }
                    else {
                        touchedView = subview;
                        canContinue = YES;
                        break;
                    }
                }
            }
        } while (canContinue);
    }
    
    return NO;
}

- (BOOL)FEX_canTouchPoint:(CGPoint)point force:(BOOL)force raiseExceptions:(BOOL)raiseExceptions {
    NSString* errorTitle = @"Touch failed";
    
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        NSString* errorMessage = @"Application is ignoring interaction events";
        
        NSLog(@"%@ - %@", errorTitle, errorMessage);        
        
        if (raiseExceptions) {
            [NSException raise:errorTitle format:@"%@", errorMessage];
        }
        
        return NO;
    }
    
    if (![self FEX_isPointInWindow:point]) {
        NSString* errorMessage = @"Touch point is outside window bounds";
        
        NSLog(@"%@ - %@", errorTitle, errorMessage);
        
        if (raiseExceptions) {
            [NSException raise:errorTitle format:@"%@", errorMessage];
        }
        
        return NO;
    }
    
    UIView* touchedView = nil;
    
    if (!force && ![self FEX_isPointInDirectViewHierarchy:point touchRecipient:&touchedView]) {
        NSString* touchedViewDescriptor = nil;
        
        if (touchedView != nil) {
            touchedViewDescriptor = [NSString stringWithFormat:@"%p#%@", touchedView, NSStringFromClass([touchedView class])];
        }
        
        NSString* errorMessage = [NSString stringWithFormat:
                                  @"View not touched because it would not be the recipient of the touch event - consider FEX_forcedTouch instead (touch recipient: %@)",
                                  touchedViewDescriptor];
        
        NSLog(@"%@ - %@", errorTitle, errorMessage);
        
        if (raiseExceptions) {
            [NSException raise:errorTitle format:@"%@", errorMessage];
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL)FEX_canTouch {
    return [self FEX_canTouchPoint:[self FEX_centerPoint] force:NO raiseExceptions:NO];
}

- (BOOL)FEX_canTouchPointX:(NSNumber*)x y:(NSNumber*)y {
    CGPoint point = [self FEX_pointFromX:x andY:y];
    
    return [self FEX_canTouchPoint:point force:NO raiseExceptions:NO];
}

#pragma mark - Touch

- (BOOL)FEX_touchPoint:(CGPoint)point {
    if (![self FEX_canTouchPoint:point force:NO raiseExceptions:YES]) {
        return NO;
    }
    
    [self tapAtPoint: point];
    return YES;
}

- (BOOL)touch {
    return [self FEX_touchPoint:[self FEX_centerPoint]];
}

- (BOOL)FEX_forcedTouch {
    CGPoint point = [self FEX_centerPoint];
    
    if (![self FEX_canTouchPoint:point force:YES raiseExceptions:YES]) {
        return NO;
    }
    
    [self tapAtPoint: point];
    
    return YES;
}

- (BOOL)touchx:(NSNumber *)x y:(NSNumber *)y {
    CGPoint point = [self FEX_pointFromX:x andY:y];
    
	return [self FEX_touchPoint:point];
}


- (BOOL)FEX_forcedTouchx:(NSNumber *)x y:(NSNumber *)y {
    CGPoint point = [self FEX_pointFromX:x andY:y];
    
    if (![self FEX_canTouchPoint:point force:YES raiseExceptions:NO]) {
        return NO;
    }
    
    [self tapAtPoint: point];
    
    return YES;
}


//Modled on UIAutomation
#pragma mark - Touch Gestures

//Double Tap
- (BOOL)doubleTapPoint:(CGPoint)point {
    if (![self FEX_canTouchPoint:point force:NO raiseExceptions:YES]) {
        return NO;
    }
	
    [self tapAtPoint: point];
    [self tapAtPoint: point];
	return YES;
}

- (BOOL)doubleTap {
    return [self doubleTapPoint:[self FEX_centerPoint]];
}

- (BOOL)doubleTapx:(NSNumber *)x y:(NSNumber *)y {
    CGPoint point = [self FEX_pointFromX:x andY:y];
    
    return [self doubleTapPoint:point];
}

////Tap With Options
//- (BOOL)tapWithOptions:(NSDictionary *)options pointIfInsideWindow:(CGPoint)point {
//	
//}
//
//- (BOOL)tapWithOptions:(NSDictionary *)options {
//	
//}
//
//- (BOOL)tapWithOptions:(NSDictionary *)options x:(NSNumber *)x y:(NSNumber *)y {
//	
//}

//Touch and hold
- (BOOL)touchAndHold:(NSTimeInterval)duration point:(CGPoint)point {
    if (![self FEX_canTouchPoint:point force:NO raiseExceptions:YES]) {
        return NO;
    }
	
    [self longPressAtPoint: point duration: duration];
	return YES;
}

- (BOOL)touchAndHold:(CGFloat)duration {
    return [self touchAndHold:duration point:[self FEX_centerPoint]];
}

- (BOOL)touchAndHold:(CGFloat)duration x:(NSNumber *)x y:(NSNumber *)y {
    CGPoint point = [self FEX_pointFromX:x andY:y];
    
    return [self touchAndHold:duration point:point];
}

////Two finger tap
//- (BOOL)twofingerTapPointIfInsideWindow:(CGPoint)point {
//	
//}
//
//- (BOOL)twofingerTap {
//	
//}
//
//- (BOOL)twofingerTapx:(NSNumber *)x y:(NSNumber *)y {
//	
//}

#pragma mark - Swipe Gestures
//TODO
//-(void)swipeInDirection:(NSString *)dir by:(int)pixels {

// THESE MAGIC NUMBERS ARE IMPORTANT. From experimentation it appears that too big or too small a ration leads to
// gestures not being recognized as such by the system. For example setting the big ratio to 0.4 leads to
// swipe-to-delete not working on UITableViewCells.
// Also note that we always include at least a small component in each axes because in the past totally 'right-angled'
//swipes weren't detected properly. But we were using a different approach to touch simulation then,
//so this might now be unnecessary.
#define BIG_RATIO (0.3)
#define BIG_RATIO_IOS7 (0.4)
#define SMALL_RATIO (0.05)
#define SWIPE_DURATION (0.1)

//returns what portion of the view to swipe along in the x and y axes.
+ (CGSize) swipeRatiosForDirection: (NSString*) direction
{
    CGFloat bigRatio = BIG_RATIO;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        bigRatio = BIG_RATIO_IOS7;
    }
    
    if ([direction isEqualToString: @"left"])
    {
        return CGSizeMake(-bigRatio, SMALL_RATIO);
    }
    else if ([direction isEqualToString: @"right"])
    {
        return CGSizeMake(bigRatio, SMALL_RATIO);
    }
    else if ([direction isEqualToString: @"up"])
    {
        return CGSizeMake(SMALL_RATIO, -bigRatio);
    }
    else if ([direction isEqualToString: @"down"])
    {
        return CGSizeMake(SMALL_RATIO, bigRatio);
    }
    else
    {
        [NSException raise: @"invalid swipe direction" format: @"swipe direction '%@' is invalid", direction];
        return CGSizeZero;
    }
}

- (BOOL) swipeInDirection: (NSString*) strDir
{
    
    CGPoint swipeStart = CGPointCenteredInRect([self accessibilityFrame]);
    CGSize ratios      = [[self class] swipeRatiosForDirection: strDir];
    CGSize viewSize    = [self bounds].size;
    CGPoint swipeEnd   = CGPointMake(swipeStart.x + (ratios.width  * viewSize.width),
                                     swipeStart.y + (ratios.height * viewSize.height));
    
    return [self FEX_dragToX: swipeEnd.x y: swipeEnd.y duration: SWIPE_DURATION];
}

#define NUM_POINTS_IN_DRAG 50
#define DRAG_TOUCH_DELAY 0.3

- (BOOL)FEX_dragWithInitialDelayToX:(CGFloat)x y:(CGFloat)y
{
    return [self FEX_dragToX: x y: y duration: DRAG_TOUCH_DELAY];
}

- (BOOL) FEX_dragToX: (CGFloat) x y: (CGFloat) y duration: (CGFloat) duration
{
    CGPoint startPoint   = CGPointCenteredInRect([self accessibilityFrame]);
    CGPoint displacement = CGPointMake(x - startPoint.x, y - startPoint.y);
    
    CGPoint *path = alloca(NUM_POINTS_IN_DRAG * sizeof(CGPoint));
    
    for (NSUInteger i = 0; i < NUM_POINTS_IN_DRAG; i++)
    {
        CGFloat progress = ((CGFloat)i)/(NUM_POINTS_IN_DRAG - 1);
        path[i] = CGPointMake(startPoint.x + (progress * displacement.x),
                              startPoint.y + (progress * displacement.y));
    }
    
    UITouch* touch = [[UITouch alloc] initAtPoint: [self FEX_centerPoint] inView: self];
    [touch setPhase:UITouchPhaseBegan];
    
    UIEvent* eventDown = [self _eventWithTouch: touch];
    [[UIApplication sharedApplication] sendEvent: eventDown];
    
    CFRunLoopRunInMode(UIApplicationCurrentRunMode, duration, false);
    
    for (NSInteger pointIndex = 1; pointIndex < NUM_POINTS_IN_DRAG; ++pointIndex)
    {
        [touch setLocationInWindow: path[pointIndex]];
        [touch setPhase: UITouchPhaseMoved];
        
        UIEvent *eventDrag = [self _eventWithTouch: touch];
        [[UIApplication sharedApplication] sendEvent: eventDrag];
        
        CFRunLoopRunInMode(UIApplicationCurrentRunMode, 0.01, false);
    }
    
    [touch setPhase: UITouchPhaseEnded];
    
    UIEvent* eventUp = [self _eventWithTouch: touch];
    [[UIApplication sharedApplication] sendEvent: eventUp];
    
    if (touch.view == self && [self canBecomeFirstResponder])
    {
        [self becomeFirstResponder];
    }
    
    while (UIApplicationCurrentRunMode != kCFRunLoopDefaultMode)
    {
        CFRunLoopRunInMode(UIApplicationCurrentRunMode, 0.1, false);
    }
    
    [touch release];
    
    return YES;
}

@end