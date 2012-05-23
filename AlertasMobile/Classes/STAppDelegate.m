//
//  STAppDelegate.m
//  AlertasMobile
//
//  Created by Pedro on 25/10/11.
//  Copyright (c) 2011 System Tech LDA. All rights reserved.
//

#import "STAppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "STUrbanAirship.h"
#import "STAlertasDataSource.h"
#import <AudioToolbox/AudioServices.h>


@implementation STAppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [self.window makeKeyAndVisible];
    
    NSURLCache *URLCache = [[[NSURLCache alloc] initWithMemoryCapacity:128 * 1024 diskCapacity:1024 * 1024 diskPath:nil] autorelease];
    [NSURLCache setSharedURLCache:URLCache];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:@"00:00", @"STStartOfSilence", @"00:00", @"STEndOfSilence", NO, @"STSilence", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    [[STUrbanAirship sharedUrbanAirship] registerForRemoteNotification];
        
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)notification {
    DLog(@"Received remote notification: %@", notification);
        
    if ([[notification allKeys] containsObject:@"aps"]) {
        NSDictionary *apsDict = [notification objectForKey:@"aps"];
        
        NSString *badgeNumber = [apsDict valueForKey:@"badge"];
        if (badgeNumber) {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[badgeNumber intValue]];
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        [[STAlertasDataSource sharedAlertasDataSource] reloadDataSourceWithTableViewController:nil];
    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[STUrbanAirship sharedUrbanAirship] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[STUrbanAirship sharedUrbanAirship] didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [[STUrbanAirship sharedUrbanAirship] applicationWillEnterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [[STAlertasDataSource sharedAlertasDataSource] reloadDataSourceWithTableViewController:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
