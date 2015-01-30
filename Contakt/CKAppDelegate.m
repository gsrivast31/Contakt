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
    
    [Parse setApplicationId:@"Fp36xotAPA1RjmsiX34lRB9R4lDAMCAB8E723ZFr"
                  clientKey:@"8rS44z220bQD4apwnVAnOmUzakgbgvH6WWNIP1yQ"];
    
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    NSString *currentProfile = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileString];
    if ([CKHelper isStringValid:currentProfile]) {
        [self.window setRootViewController:[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"rootController"]];
    } else {
        [self.window setRootViewController:[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"introSignupController"]];
    }
    
    // Let UAAppReviewManager know our application has launched
    [UAAppReviewManager showPromptIfNecessary];

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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

@end
