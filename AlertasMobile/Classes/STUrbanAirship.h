//
//  STUrbanAirship.h
//  AlertasMobile
//
//  Created by Pedro on 13/12/11.
//  Copyright (c) 2011 System Tech LDA. All rights reserved.
//

#import "../UACredentials.h"
#import "AFNetworking.h"

@interface STUrbanAirship : AFHTTPClient {
    BOOL didRegister;
}

+ (STUrbanAirship *)sharedUrbanAirship;
- (void)registerForRemoteNotification;
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)applicationWillEnterForeground;
- (NSString*)parseDeviceToken:(NSString*)tokenStr;
@end
