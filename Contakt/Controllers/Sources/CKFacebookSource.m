//
//  CKFacebookSource.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 18/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKFacebookSource.h"
#import "SimpleAuth.h"

@implementation CKFacebookSource

@synthesize sourceName;
@synthesize supportsFollow;
@synthesize supportsLogin;

- (id) init {
    if (self = [super init]) {
        sourceName = kFacebookString;
        supportsLogin = YES;
        supportsFollow = YES;
        
        SimpleAuth.configuration[@"facebook-web"] = @{@"app_id" : FACEBOOK_API_KEY,
                                                  @"app_secret" : FACEBOOK_API_SECRET};
        
    }
    return self;
}

- (NSString*) sourceDescription {
    if (![self isLoggedIn]) {
        return @"Please sign in";
    }
    return nil;
}

- (BOOL)isLoggedIn {
    return ([self loadAccessToken] != nil);
}

- (void)login:(id<CKSourceLoginDelegate>)delegate {
    if ([self isLoggedIn]) {
        return;
    }
    
    [SimpleAuth authorize:@"facebook-web" completion:^(id responseObject, NSError *error) {
        if (!error && responseObject) {
            NSDictionary* response = (NSDictionary*)responseObject;
            NSString* token = response[@"credentials"][@"token"];
            NSString* profileId = response[@"uid"];
            NSString* name = response[@"info"][@"name"];
            NSString* url = response[@"info"][@"urls"][@"Facebook"];
            NSString* email = response[@"info"][@"email"];
            NSString* imageUrl = response[@"info"][@"image"];
            
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  name, kProfileName,
                                  email, kProfileEmail,
                                  url, kProfileUrl,
                                  profileId, kProfileId,
                                  imageUrl, kProfileImageUrl,
                                  nil];
            
            [self storeAccessToken:token];
            [delegate didLogin:self withUserInfo:dict];
        } else {
            [delegate didNotLogin:self];
        }
    }];
}

- (void)logout:(id<CKSourceLoginDelegate>)delegate {
    [self storeAccessToken:nil];
    [delegate didLogout:self];
}

- (void)followUser:(NSString *)userName requestDelegate:(id<CKSourceFollowDelegate>)delegate userInfo:(NSDictionary *)info {
    
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:kFacebookToken];
}

- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kFacebookToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
