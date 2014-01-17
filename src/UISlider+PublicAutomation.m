//
// UISLider+PublicAutomation.m
//
// Created by Alvaro Barbeira on 27/3/13
//
#import "LoadableCategory.h"
#import "CGGeometry-KIFAdditions.h"
#import "UIApplication-KIFAdditions.h"

@interface UIView ()

- (BOOL) FEX_dragFromPoint: (CGPoint) startPoint
                   toPoint: (CGPoint) destPoint
                  duration: (CGFloat) duration
                     delay: (BOOL)    delay;

@end

MAKE_CATEGORIES_LOADABLE(UISlider_PublicAutomation)

#define UI_SLIDER_TIME_STEP 0.1

@implementation UISlider(PublicAutomation)

- (BOOL) FEX_dragThumbToValue: (double) value withDuration: (NSTimeInterval) duration
{
    CGRect  bounds    = [self bounds];
    CGRect  trackRect = [self trackRectForBounds: bounds];
    CGRect  startRect = [self thumbRectForBounds: bounds trackRect: trackRect value: [self value]];
    
    CGPoint startPoint = CGPointCenteredInRect(startRect);
    CGPoint destPoint  = CGPointMake(bounds.size.width * value / [self maximumValue], 1.0);
    
    startPoint = [self convertPoint: startPoint toView: nil];
    destPoint  = [self convertPoint: destPoint  toView: nil];
    
    return [self FEX_dragFromPoint: startPoint toPoint: destPoint duration: duration delay: NO];
}

- (BOOL) FEX_dragThumbToValue:(double) value {
    return [self FEX_dragThumbToValue: value withDuration: UI_SLIDER_TIME_STEP];
}

@end