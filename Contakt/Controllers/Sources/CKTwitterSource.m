//
//  CKTwitterSource.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 18/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKTwitterSource.h"

#import "CKAppDelegate.h"
#import "CKProfileEditViewController.h"
#import "CKRootViewController.h"

#import "SimpleAuth.h"

@interface CKTwitterSource()


@end

@implementation CKTwitterSource

@synthesize sourceName;
@synthesize supportsFollow;
@synthesize supportsLogin;

@synthesize loginDelegate;
@synthesize followDelegate;

- (id) init {
    if (self = [super init]) {
        sourceName = kTwitterString;
        supportsLogin = YES;
        supportsFollow = YES;

        SimpleAuth.configuration[@"twitter-web"] = @{@"consumer_key" : TWITTER_API_KEY,
                                                      @"consumer_secret" : TWITTER_API_SECRET,
                                                      SimpleAuthRedirectURIKey : TWITTER_CALLBACK_URL};
        
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
    
    [SimpleAuth authorize:@"twitter-web" completion:^(id responseObject, NSError *error) {
        if (!error && responseObject) {
            NSDictionary* response = (NSDictionary*)responseObject;
            NSString* token = response[@"credentials"][@"token"];
            NSString* url = response[@"info"][@"urls"][@"Twitter"];
            NSNumber* uid = (NSNumber*)response[@"uid"];
            NSString* profileId = [uid stringValue];
            NSString* email = @"";
            NSString* name = response[@"info"][@"name"];
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
/*    followDelegate = delegate;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            [[FHSTwitterEngine sharedEngine] followUser:userName isID:YES];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                @autoreleasepool {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                }
            });
        }
    });*/
}

#pragma mark FHSTwitterEngineAccessTokenDelegate

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:kTwitterToken];
}

- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:kTwitterToken];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

@end
