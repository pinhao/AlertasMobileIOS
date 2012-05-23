//
//  STBVCanasApi.m
//  AlertasMobile
//
//  Created by Pedro on 26/10/11.
//  Copyright (c) 2011 System Tech LDA. All rights reserved.
//

#import "STBVCanasApi.h"
#import "AFJSONRequestOperation.h"

NSString * const STBVCAnasApiBaseURL = @"http://bvcanas.com/api/";

@implementation STBVCanasApi

+ (STBVCanasApi *)sharedClient {
    static STBVCanasApi *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:STBVCAnasApiBaseURL]];
    });
    
    return _sharedClient;  
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];

    [self setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
}

@end
