//
//  CKRootViewController.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 19/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKRootViewController.h"
#import "CKSideMenuViewController.h"

@interface CKRootViewController ()

@end

@implementation CKRootViewController

- (void)awakeFromNib {
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.contentViewShadowColor = [UIColor blackColor];
    self.contentViewShadowOffset = CGSizeMake(0, 0);
    self.contentViewShadowOpacity = 0.6;
    self.contentViewShadowRadius = 12;
    self.contentViewShadowEnabled = YES;
    
    self.contentViewController = [CKHelper viewControllerWithId:@"contentController"];
    self.leftMenuViewController = [[CKSideMenuViewController alloc] init];
    self.rightMenuViewController = nil;
    self.delegate = self;
}

#pragma mark -
#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController {
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController {
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController {
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController {
}

@end
