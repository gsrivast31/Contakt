//
//  CKAppDelegate.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 17/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKAppDelegate.h"
#import "CKCoreDataStack.h"

#import "CKSourceController.h"
#import "CKFacebookSource.h"
#import "CKTwitterSource.h"
#import "CKLinkedInSource.h"

#import <UAAppReviewManager/UAAppReviewManager.h>
#import <Parse/Parse.h>

@interface CKAppDelegate ()

@end

@implementation CKAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UAAppReviewManager setAppID:APP_ID];
    [UAAppReviewManager setDaysUntilPrompt:2];
    [UAAppReviewManager setUsesUntilPrompt:5];
    [UAAppReviewManager setSignificantEventsUntilPrompt:-1];
    [UAAppReviewManager setDaysBeforeReminding:3];
    [UAAppReviewManager setReviewMessage:NSLocalizedString(@"If you find Contakt useful you can help support further development by leaving a review on the App Store. It'll only take a minute!", nil)];

    [self setupSources];
    
    [Parse setApplicationId:PARSE_API_ID
                  clientKey:PARSE_CLIENT_KEY];
    
    NSString *currentProfile = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileString];
    if (/*[CKHelper isStringValid:currentProfile]*/FALSE) {
        [self.window setRootViewController:[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"rootController"]];
    } else {
        [self.window setRootViewController:[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"introSignupController"]];
    }
    
    // Let UAAppReviewManager know our application has launched
    [UAAppReviewManager showPromptIfNecessary];
    [self setupStyling];

    return YES;
}

- (void)setupSources {
    CKFacebookSource* facebookSource = [[CKFacebookSource alloc] init];
    CKTwitterSource* twitterSource = [[CKTwitterSource alloc] init];
    CKLinkedInSource* linkedInSource = [[CKLinkedInSource alloc] init];
    
    [[CKSourceController sharedInstance] addSource:facebookSource forKey:kFacebookString];
    [[CKSourceController sharedInstance] addSource:twitterSource forKey:kTwitterString];
    [[CKSourceController sharedInstance] addSource:linkedInSource forKey:kLinkedInString];
}

- (void)setupStyling {
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorFromHexCode:@"F1F0F0"]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont flatFontOfSize:17.0f], NSForegroundColorAttributeName:[UIColor colorFromHexCode:@"282F3B"]}];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], [UIToolbar class], nil] setTintColor:[UIColor turquoiseColor]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[CKCoreDataStack defaultStack] saveContext];
}

@end
