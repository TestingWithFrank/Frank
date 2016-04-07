//
//  FrankLoader.m
//  FrankFramework
//
//  Created by Pete Hodgson on 8/12/11.
//  Copyright 2011 ThoughtWorks. All rights reserved.
//

#import "FrankLoader.h"

#import "FrankServer.h"

#import <dlfcn.h>

#import "DDLog.h"
#import "DDTTYLogger.h"

#if !TARGET_OS_IPHONE
#import "AccessibilityCheckCommand.h"
#import "NSApplication+FrankAutomation.h"
#endif

BOOL frankLogEnabled = NO;

@implementation FrankLoader

+ (void)applicationDidBecomeActive:(NSNotification *)notification{
    static dispatch_once_t frankDidBecomeActiveToken;
#if TARGET_OS_IPHONE
    dispatch_once(&frankDidBecomeActiveToken, ^{
        FrankServer *server = [[FrankServer alloc] initWithDefaultBundle];
        [server startServer];
    });
#else
    dispatch_once(&frankDidBecomeActiveToken, ^{
        FrankServer *server = [[FrankServer alloc] initWithDefaultBundle];
        [server startServer];
        
        [[NSApplication sharedApplication] FEX_startTrackingMenus];
        
        [[NSNotificationCenter defaultCenter] removeObserver: [self class]
                                                        name: NSApplicationDidUpdateNotification
                                                      object: nil];
        
        [AccessibilityCheckCommand accessibilitySeemsToBeTurnedOn];
    });
#endif
}

+ (void)load{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    NSLog(@"Injecting Frank loader");
    
    NSAutoreleasePool *autoreleasePool = [[NSAutoreleasePool alloc] init];
    NSString *appSupportLocation = @"/System/Library/PrivateFrameworks/AppSupport.framework/AppSupport";
    
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *simulatorRoot = [environment objectForKey:@"IPHONE_SIMULATOR_ROOT"];
    if (simulatorRoot) {
        appSupportLocation = [simulatorRoot stringByAppendingString:appSupportLocation];
    }
    
    void *appSupportLibrary = dlopen([appSupportLocation fileSystemRepresentation], RTLD_LAZY);
    
    if(!appSupportLibrary) {
         NSLog(@"Unable to dlopen AppSupport. Cannot automatically enable accessibility.");
    }

    CFStringRef (*copySharedResourcesPreferencesDomainForDomain)(CFStringRef domain) = dlsym(appSupportLibrary, "CPCopySharedResourcesPreferencesDomainForDomain");
    
    if (copySharedResourcesPreferencesDomainForDomain) {
        CFStringRef accessibilityDomain = copySharedResourcesPreferencesDomainForDomain(CFSTR("com.apple.Accessibility"));
        
        if (accessibilityDomain) {
            CFPreferencesSetValue(CFSTR("ApplicationAccessibilityEnabled"), kCFBooleanTrue, accessibilityDomain, kCFPreferencesAnyUser, kCFPreferencesAnyHost);
            CFRelease(accessibilityDomain);
            NSLog(@"Successfully updated the ApplicationAccessibilityEnabled value.");
        }
        else {
            NSLog(@"Unable to copy accessibility preferences. Cannot automatically enable accessibility.");
        }
    }
    else {
        NSLog(@"Unable to dlsym CPCopySharedResourcesPreferencesDomainForDomain. Cannot automatically enable accessibility.");
    }

    NSString* accessibilitySettingsBundleLocation = @"/System/Library/PreferenceBundles/AccessibilitySettings.bundle/AccessibilitySettings";

    if (simulatorRoot) {
        accessibilitySettingsBundleLocation = [simulatorRoot stringByAppendingString:accessibilitySettingsBundleLocation];
    }

    const char *accessibilitySettingsBundlePath = [accessibilitySettingsBundleLocation fileSystemRepresentation];
    void* accessibilitySettingsBundle = dlopen(accessibilitySettingsBundlePath, RTLD_LAZY);

    if (accessibilitySettingsBundle) {
        Class axSettingsPrefControllerClass = NSClassFromString(@"AccessibilitySettingsController");
        id axSettingPrefController = [[axSettingsPrefControllerClass alloc] init];

        id initialAccessibilityInspectorSetting = [axSettingPrefController AXInspectorEnabled:nil];
        [axSettingPrefController setAXInspectorEnabled:@(YES) specifier:nil];

        NSLog(@"Successfully enabled the AXInspector.");
    }
    else {
        NSLog(@"Unable to dlopen AccessibilitySettings. Cannout automatically enable accessibility.");
    }

    [autoreleasePool drain];
    
#if TARGET_OS_IPHONE
    NSString *notificationName = @"UIApplicationDidBecomeActiveNotification";
#else
    NSString *notificationName = NSApplicationDidUpdateNotification;
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:[self class] 
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:notificationName
                                               object:nil];

#if TARGET_OS_IPHONE
    NSArray *iOSVersionComponents = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    int majorVersion = [[iOSVersionComponents objectAtIndex:0] intValue];

    if (majorVersion >= 9) 
    { 
        // iOS9 is installed. The UIApplicationDidBecomeActiveNotification may have been fired *before* 
        // this code is called.
        // See also:
        // http://stackoverflow.com/questions/31785878/ios-9-uiapplicationdidbecomeactivenotification-callback-not-called

        // Call applicationDidBecomeActive: after 0.5 second. 
        // Delay execution of my block for 10 seconds.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * USEC_PER_SEC), dispatch_get_main_queue(), ^{
            NSLog(@"Forcefully invoking applicationDidBecomeActive");
            [FrankLoader applicationDidBecomeActive:nil];
        });
    }
#endif
}

@end
