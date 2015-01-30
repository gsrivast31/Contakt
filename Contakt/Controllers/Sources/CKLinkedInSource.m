//
//  CKLinkedInSource.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 18/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKLinkedInSource.h"

#import "CKAppDelegate.h"
#import "CKProfileEditViewController.h"
#import "SimpleAuth.h"

#import "CMDQueryStringSerialization.h"

@interface CKLinkedInSource()
@end

@implementation CKLinkedInSource

@synthesize sourceName;
@synthesize supportsFollow;
@synthesize supportsLogin;

- (id) init {
    if (self = [super init]) {
        sourceName = kLinkedInString;
        supportsLogin = YES;
        supportsFollow = YES;
        
        SimpleAuth.configuration[@"linkedin-web"] = @{@"client_id" : LINKEDIN_API_KEY,
                                                      @"client_secret" : LINKEDIN_API_SECRET,
                                                      @"field_selectors" : @[@"id", @"formatted-name", @"email-address", @"site-standard-profile-request", @"public-profile-url", @"picture-url"],
                                                      SimpleAuthRedirectURIKey : LINKEDIN_CALLBACK_URL};
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
    
    [SimpleAuth authorize:@"linkedin-web" completion:^(id responseObject, NSError *error) {
        if (!error && responseObject) {
            NSDictionary* response = (NSDictionary*)responseObject;
            NSString* token = response[@"credentials"][@"token"];
            //NSString* url = response[@"raw_info"][@"siteStandardProfileRequest"][@"url"];
            NSString* publicUrl = response[@"raw_info"][@"publicProfileUrl"];
            NSString* profileId = response[@"raw_info"][@"id"];
            NSString* email = response[@"raw_info"][@"emailAddress"];
            NSString* name = response[@"raw_info"][@"formattedName"];
            NSString* imageUrl = response[@"raw_info"][@"pictureUrl"];
            
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  name, kProfileName,
                                  email, kProfileEmail,
                                  publicUrl, kProfileUrl,
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

- (NSDictionary*)getJSONDictionary:(NSDictionary*)info {
    NSString* pathString = [NSString stringWithFormat:@"/people/email=%@",[info valueForKey:@"email"]];
    NSString* firstName = [info valueForKey:@"firstName"];
    NSString* lastName = [info valueForKey:@"lastName"];
    NSString* subject = [info valueForKey:@"subject"];
    NSString* body = [info valueForKey:@"body"];

    NSDictionary* dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"connect-type", @"friend", nil];
    NSDictionary* dict2 = [NSDictionary dictionaryWithObjectsAndKeys:dict1, @"invitation-request", nil];

    NSDictionary* dict3 = [NSDictionary dictionaryWithObjectsAndKeys:
                           pathString, @"_path",
                           firstName, @"first-name",
                           lastName, @"last-name",
                           nil];
    NSDictionary* dict4 = [NSDictionary dictionaryWithObjectsAndKeys:dict3, @"person", nil];
    NSArray* array = @[dict4];
    NSDictionary* dict5 = [NSDictionary dictionaryWithObject:array forKey:@"values"];
    
    NSDictionary* jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              subject, @"subject",
                              body, @"body",
                              dict2 , @"item-content",
                              dict5, @"recipients",
                              nil];

    return jsonDict;
}

- (void)followUser:(NSString *)userName requestDelegate:(id<CKSourceFollowDelegate>)delegate userInfo:(NSDictionary *)info {
    NSDictionary *parameters = @{@"oauth2_access_token" : [self loadAccessToken], @"format" : @"json"};
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.linkedin.com/v1/people/~/mailbox?%@", [CMDQueryStringSerialization queryStringWithDictionary:parameters]];

    NSError *error = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:[self getJSONDictionary:info] options:(NSJSONWritingPrettyPrinted) error:&error];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: data];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate didFinishFollow:data withError:error andUserInfo:nil];
            });
    }];
    
    [task resume];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:kLinkedInToken];
}

- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kLinkedInToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
