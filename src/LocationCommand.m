//
//  LocationCommand.m
//  Frank
//
//  Created by Micke Lisinge on 10/30/12.
//
//

#import <objc/runtime.h>

#import "LocationCommand.h"

#import "FranklyProtocolHelper.h"
#import "JSON.h"

@interface NSObject ()
- (id)initWithLatitude: (double) latitude longitude: (double) longitude;

- (id) location;

- (void) locationManager: (id) locationManager didUpdateLocations: (NSArray*) locations;
- (void) locationManager: (id) locationManager didUpdateToLocation: (id) newLocation fromLocation: (id) oldLocation;
@end

static LocationCommand*     FEX_staticLocationCommand = nil;
static id                   FEX_overridenLocation     = nil;
static NSMutableDictionary* FEX_locationDelegates     = nil;
static NSMutableDictionary* FEX_updatingManagers      = nil;

@implementation LocationCommand

- (id) init
{
    if (self = [super init])
    {
        FEX_staticLocationCommand = self;
    }
    
    return self;
}

- (NSString *)handlePost:(NSString *)requestBody{
    NSDictionary *requestCommand = FROM_JSON(requestBody);
    
    if( ![requestCommand objectForKey:@"latitude"] && ![requestCommand objectForKey:@"longitude"]){
        return [FranklyProtocolHelper generateErrorResponseWithReason:@"nil location"
                                                           andDetails:[NSString stringWithFormat:@"you have to provide both longitude and latitude"]];
    }
    
    CGPoint locationAsPoint = CGPointMake([[requestCommand objectForKey:@"latitude"] floatValue],[[requestCommand objectForKey:@"longitude"] floatValue]);
    
    NSLog(@"simulating location of %f,%f",locationAsPoint.x, locationAsPoint.y);
    
    FEX_overridenLocation = [[NSClassFromString(@"CLLocation") alloc] initWithLatitude: locationAsPoint.x
                                                                             longitude: locationAsPoint.y];
    
    for (id locationManagerDescription in FEX_locationDelegates)
    {
        id locationManager =[FEX_updatingManagers objectForKey: locationManagerDescription];
        if (locationManager != nil)
        {
            id delegate = [FEX_locationDelegates objectForKey: [locationManager description]];
            if ([delegate respondsToSelector: @selector(locationManager:didUpdateLocations:)])
            {
                [delegate locationManager: locationManager
                       didUpdateLocations: [NSArray arrayWithObject: [((NSObject*) locationManager) location]]];
            }
            
            if ([delegate respondsToSelector: @selector(locationManager:didUpdateToLocation:fromLocation:)])
            {
                [delegate locationManager: locationManager
                      didUpdateToLocation: [((NSObject*) locationManager) location]
                             fromLocation: [((NSObject*) locationManager) location]];
            }
        }
    }
    
    return [FranklyProtocolHelper generateSuccessResponseWithoutResults];
}

- (NSString *)handleCommandWithRequestBody:(NSString *)requestBody {
    if( !requestBody || [requestBody isEqualToString:@""] )
        return [FranklyProtocolHelper generateErrorResponseWithReason:@"get not supported"
                                                          andDetails:[NSString stringWithFormat:@"this interface does not support getting the location"]];
    else
        return [self handlePost:requestBody];
}

- (id) FEX_location
{
    id returnValue = nil;
    
    if (FEX_overridenLocation != nil)
    {
        returnValue = FEX_overridenLocation;
    }
    else
    {
        returnValue = [self FEX_location];
    }
    
    return returnValue;
}

- (void) FEX_setDelegate: (id) delegate
{
    [FEX_locationDelegates setObject: delegate forKey: [self description]];
    [self FEX_setDelegate: FEX_staticLocationCommand];
}

- (void) FEX_startUpdatingLocation
{
    [FEX_updatingManagers setObject: self forKey: [self description]];
    [self FEX_startUpdatingLocation];
}

- (void) FEX_stopUpdatingLocation
{
    [FEX_updatingManagers removeObjectForKey: [self description]];
    [self FEX_stopUpdatingLocation];
}

- (void) FEX_dealloc
{
    [FEX_locationDelegates removeObjectForKey: [self description]];
    [FEX_updatingManagers  removeObjectForKey: [self description]];
    
    [self FEX_dealloc];
}

+ (void) insertMethod: (SEL) newSelector andSwapWithMethod: (SEL) origSelector
{
    Class locationManagerClass = NSClassFromString(@"CLLocationManager");
    
    if (locationManagerClass != nil)
    {
        Method origMethod = class_getInstanceMethod(locationManagerClass, origSelector);
        Method newMethod  = class_getInstanceMethod(self, newSelector);
        IMP    newIMP     = method_getImplementation(newMethod);
        
        if (class_addMethod(locationManagerClass, newSelector, newIMP, method_getTypeEncoding(newMethod)))
        {
            newMethod = class_getInstanceMethod(locationManagerClass, newSelector);
            
            if (origMethod != NULL && newMethod != NULL)
            {
                method_exchangeImplementations(origMethod, newMethod);
            }
        }
    }
}

+ (void) load
{
    FEX_locationDelegates = [NSMutableDictionary new];
    FEX_updatingManagers  = [NSMutableDictionary new];
    
    [self insertMethod: @selector(FEX_setDelegate:)          andSwapWithMethod: @selector(setDelegate:)];
    [self insertMethod: @selector(FEX_dealloc)               andSwapWithMethod: @selector(dealloc)];
    [self insertMethod: @selector(FEX_startUpdatingLocation) andSwapWithMethod: @selector(startUpdatingLocation)];
    [self insertMethod: @selector(FEX_stopUpdatingLocation)  andSwapWithMethod: @selector(stopUpdatingLocation)];
    [self insertMethod: @selector(FEX_location)              andSwapWithMethod: @selector(location)];
}

- (void) locationManager: (id) locationManager didUpdateLocations: (NSArray*) locations
{
    if (locationManager != nil && [FEX_updatingManagers objectForKey: [locationManager description]] != nil)
    {
        id delegate = [FEX_locationDelegates objectForKey: [locationManager description]];
        if ([delegate respondsToSelector: @selector(locationManager:didUpdateLocations:)])
        {
            if (FEX_overridenLocation == nil)
            {
                [delegate locationManager: locationManager
                       didUpdateLocations: locations];
            }
            else
            {
                [delegate locationManager: locationManager
                       didUpdateLocations: [NSArray arrayWithObject: FEX_overridenLocation]];
            }
        }
    }
}

- (void) locationManager: (id) locationManager didUpdateToLocation: (id) newLocation fromLocation: (id) oldLocation
{
    if (locationManager != nil && [FEX_updatingManagers objectForKey: [locationManager description]] != nil)
    {
        id delegate = [FEX_locationDelegates objectForKey: [locationManager description]];
        if ([delegate respondsToSelector: @selector(locationManager:didUpdateToLocation:fromLocation:)])
        {
            if (FEX_overridenLocation == nil)
            {
                [delegate locationManager: locationManager
                      didUpdateToLocation: newLocation
                             fromLocation: oldLocation];
            }
            else
            {
                [delegate locationManager: locationManager
                      didUpdateToLocation: FEX_overridenLocation
                             fromLocation: FEX_overridenLocation];
            }
        }
    }
}

@end