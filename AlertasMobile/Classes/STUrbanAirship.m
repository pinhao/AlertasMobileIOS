//
//  STUrbanAirship.m
//  AlertasMobile
//
//  Created by Pedro on 13/12/11.
//  Copyright (c) 2011 System Tech LDA. All rights reserved.
//

#import "STUrbanAirship.h"

NSString * const STUrbanAirshipURL = @"https://go.urbanairship.com/";

@implementation STUrbanAirship

+ (STUrbanAirship *)sharedUrbanAirship {
    static STUrbanAirship *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:STUrbanAirshipURL]];
        [_sharedClient setParameterEncoding:AFJSONParameterEncoding];
        [[NSNotificationCenter defaultCenter] addObserver:_sharedClient 
                                                 selector:@selector(defaultsChanged:)  
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    });
    
    return _sharedClient;     
}

-(void)registerForRemoteNotification {
    didRegister = NO;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {    
    didRegister = YES;
        
    NSString *devTokenString = [self parseDeviceToken:[devToken description]];
    NSString *urlString = [NSString stringWithFormat:@"api/device_tokens/%@", devTokenString];
    
    UIDevice *dev = [UIDevice currentDevice];
    NSString *alias = [NSString stringWithFormat:@"%@-%@-%@-%@", dev.name, dev.model, dev.systemVersion, [devTokenString substringToIndex:5]];
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithObject:alias forKey:@"alias"];
    BOOL silence = [[NSUserDefaults standardUserDefaults] boolForKey:@"STSilence"];
    if ( silence ) {
        NSString *startOfSilence = [[NSUserDefaults standardUserDefaults] stringForKey:@"STStartOfSilence"];
        NSString *endOfSilence = [[NSUserDefaults standardUserDefaults] stringForKey:@"STEndOfSilence"];
        NSString *timeZone = [[NSTimeZone systemTimeZone] name];
        NSDictionary *silenceTimeInterval = [NSDictionary dictionaryWithObjectsAndKeys:startOfSilence, @"start", endOfSilence, @"end", nil];
        [payload setObject:silenceTimeInterval forKey:@"quiettime"];
        [payload setValue:timeZone forKey:@"tz"];
    }
    
    NSMutableURLRequest *request = [self requestWithMethod:@"PUT" path:urlString parameters:payload];
    [request setValue:UA_APP_AUTH forHTTPHeaderField:@"Authorization"];
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id object){
        if ([operation hasAcceptableStatusCode]) {
            DLog(@"Device register request OK");
            didRegister = YES;
        } else {
            DLog(@"Device register request FAILED [Error]: (%@ %@) %@", 
                  [operation.request HTTPMethod], 
                  [[operation.request URL] relativePath], 
                  operation.error);
            didRegister = NO;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Device register request FAILED [Error]: (%@ %@) %@", 
              [operation.request HTTPMethod], 
              [[operation.request URL] relativePath], 
              operation.error);
        didRegister = NO;
    }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    didRegister = NO;
    DLog(@"didFailToRegisterForRemoteNotificationsWithError:%@", error);
}

-(void)applicationWillEnterForeground {
    if ( !didRegister )
        [self registerForRemoteNotification];
}

- (NSString*)parseDeviceToken:(NSString*)tokenStr {
    return [[[tokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""] 
             stringByReplacingOccurrencesOfString:@">" withString:@""]
            stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (void)defaultsChanged:(NSNotification *)notification {
    [self registerForRemoteNotification];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
