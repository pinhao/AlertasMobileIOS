//
//  STBVCanasApi.h
//  AlertasMobile
//
//  Created by Pedro on 26/10/11.
//  Copyright (c) 2011 System Tech LDA. All rights reserved.
//

#import "AFHTTPClient.h"

extern NSString * const STBVCAnasApiBaseURL;

@interface STBVCanasApi : AFHTTPClient
+ (STBVCanasApi *)sharedClient;
@end
