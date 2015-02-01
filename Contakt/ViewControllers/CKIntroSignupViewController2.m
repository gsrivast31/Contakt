//
//  CKIntroSignupViewController2.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 27/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKIntroSignupViewController2.h"
#import "CKRootViewController.h"
#import "CKCoreDataStack.h"
#import "CKContact.h"
#import "CKConnection.h"

#import "CKSourceBase.h"
#import "CKFacebookSource.h"
#import "CKTwitterSource.h"
#import "CKLinkedInSource.h"

#import "CKSourceController.h"

#import "CAGradientLayer+CKGradients.h"
#import "MBProgressHUD.h"
#import "NSString+Icons.h"

@interface CKIntroSignupViewController2 () <CKSourceLoginDelegate, MBProgressHUDDelegate>
{
    NSString* _name;
    NSString* _email;
    NSString* _phone;
    
    BOOL connectEmail;
    BOOL connectPhone;
    BOOL connectFB;
    BOOL connectTwitter;
    BOOL connectLinkedIn;
    
    NSDictionary* facebookDict;
    NSDictionary* twitterDict;
    NSDictionary* linkedinDict;
    
    MBProgressHUD* notificationView;
}

@property (weak, nonatomic) IBOutlet UILabel *optionLabel;
@property (weak, nonatomic) IBOutlet FUIButton *emailButton;
@property (weak, nonatomic) IBOutlet FUIButton *phoneButton;
@property (weak, nonatomic) IBOutlet FUIButton *fbButton;
@property (weak, nonatomic) IBOutlet FUIButton *twitterButton;
@property (weak, nonatomic) IBOutlet FUIButton *linkedinButton;
@property (weak, nonatomic) IBOutlet FUIButton *submitButton;

@end

@implementation CKIntroSignupViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor cloudsColor];
    
    connectEmail = connectPhone = connectFB = connectLinkedIn = connectTwitter = FALSE;
    
    self.optionLabel.text = @"SELECT NETWORKS TO SHARE";
    self.optionLabel.font = [UIFont flatFontOfSize:21.0f];
    self.optionLabel.textColor = [UIColor midnightBlueColor];
    
    self.submitButton.buttonColor = [UIColor turquoiseColor];
    self.submitButton.shadowColor = [UIColor greenSeaColor];
    self.submitButton.shadowHeight = 3.0f;
    self.submitButton.cornerRadius = 6.0f;
    self.submitButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.submitButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    [self.submitButton setTitle:@"CREATE PROFILE" forState:UIControlStateNormal];
    
    [self.emailButton addTarget:self action:@selector(emailTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.phoneButton addTarget:self action:@selector(phoneTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.fbButton addTarget:self action:@selector(fbTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.twitterButton addTarget:self action:@selector(twitterTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.linkedinButton addTarget:self action:@selector(linkedinTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.submitButton addTarget:self action:@selector(saveProfile:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addBorder:self.emailButton];
    [self addBorder:self.phoneButton];
    [self addBorder:self.fbButton];
    [self addBorder:self.twitterButton];
    [self addBorder:self.linkedinButton];
    
    CAGradientLayer *backgroundLayer = [CAGradientLayer sideGradientLayer];
    backgroundLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:backgroundLayer atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUserWithName:(NSString*)name withEmail:(NSString*)email withPhone:(NSString*)phone {
    _name = name;
    _email = email;
    _phone = phone;
}

- (void)setBorderWidth:(CGFloat)width forButton:(FUIButton*)button {
    button.layer.borderWidth = width;
}

- (void)addBorder:(FUIButton*)button {
    button.layer.masksToBounds = YES;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    [self setBorderWidth:0.0f forButton:button];
    button.layer.rasterizationScale = [UIScreen mainScreen].scale;
    button.layer.shouldRasterize = YES;
    button.clipsToBounds = YES;
}

- (void)emailTapped:(id)sender {
    connectEmail = !connectEmail;
    [self setBorderWidth:connectEmail?5.0f:0.0f forButton:self.emailButton];
}

- (void)phoneTapped:(id)sender {
    connectPhone = !connectPhone;
    [self setBorderWidth:connectPhone?5.0f:0.0f forButton:self.phoneButton];
}

- (void)fbTapped:(id)sender {
    CKSourceBase* source = [[CKSourceController sharedInstance] sourceForKey:kFacebookString];
    if ([source isLoggedIn]) {
        connectFB = !connectFB;
        [self setBorderWidth:connectFB?5.0f:0.0f forButton:self.fbButton];
    } else {
        [source login:self];
    }
}

- (void)twitterTapped:(id)sender {
    CKSourceBase* source = [[CKSourceController sharedInstance] sourceForKey:kTwitterString];
    if ([source isLoggedIn]) {
        connectTwitter = !connectTwitter;
        [self setBorderWidth:connectTwitter?5.0f:0.0f forButton:self.twitterButton];
    } else {
        [source login:self];
    }
}

- (void)linkedinTapped:(id)sender {
    CKSourceBase* source = [[CKSourceController sharedInstance] sourceForKey:kLinkedInString];
    if ([source isLoggedIn]) {
        connectLinkedIn = !connectLinkedIn;
        [self setBorderWidth:connectLinkedIn?5.0f:0.0f forButton:self.linkedinButton];
    } else {
        [source login:self];
    }
}

- (void)saveProfile:(id)sender {
    /*CKCoreDataStack *coreDataStack = [CKCoreDataStack defaultStack];
    CKContact *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"CKContact" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    newContact.name = _name;
    newContact.guid = [CKHelper generateUniqueGuid];
    newContact.connections = [self connections];
    [coreDataStack saveContext];
    
    [[NSUserDefaults standardUserDefaults] setValue:newContact.guid forKey:kCurrentProfileString];
    
    //[self.navigationController pushViewController:[CKHelper viewControllerWithId:@"rootController"] animated:YES];*/
    CKRootViewController* vc = (CKRootViewController*)[CKHelper viewControllerWithId:@"rootController"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:nil];
    
}

- (NSSet*)connections {
    CKConnection *fbConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    fbConnection.type = CKFacebookType;
    fbConnection.share = connectFB;
    fbConnection.value = facebookDict[kProfileId];
    fbConnection.profileUrl = facebookDict[kProfileUrl];
    fbConnection.imageUrl = facebookDict[kProfileImageUrl];
    
    CKConnection *twitterConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    twitterConnection.type = CKTwitterType;
    twitterConnection.share = connectTwitter;
    twitterConnection.value = twitterDict[kProfileId];
    twitterConnection.profileUrl = twitterDict[kProfileUrl];
    twitterConnection.imageUrl = twitterDict[kProfileImageUrl];
    
    CKConnection *linkedInConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    linkedInConnection.type = CKLinkedInType;
    linkedInConnection.share = connectLinkedIn;
    linkedInConnection.value = linkedinDict[kProfileId];
    linkedInConnection.profileUrl = linkedinDict[kProfileUrl];
    linkedInConnection.imageUrl = linkedinDict[kProfileImageUrl];
    
    CKConnection *emailConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    emailConnection.type = CKEmailType;
    emailConnection.share = connectEmail;
    emailConnection.value = _email;
    
    CKConnection *phoneConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    phoneConnection.type = CKPhoneType;
    phoneConnection.share = connectPhone;
    phoneConnection.value = _phone;
    
    return [[NSSet alloc] initWithObjects:emailConnection, phoneConnection, fbConnection, twitterConnection, linkedInConnection, nil];
}

#pragma mark CKSourceLoginDelegate

- (void)didLogin:(CKSourceBase *)source withUserInfo:(NSDictionary *)userInfo {
    if ([source isKindOfClass:[CKFacebookSource class]]) {
        connectFB = TRUE;
        facebookDict = userInfo;
        [self setBorderWidth:5.0f forButton:self.fbButton];
    } else if ([source isKindOfClass:[CKTwitterSource class]]) {
        connectTwitter = TRUE;
        twitterDict = userInfo;
        [self setBorderWidth:5.0f forButton:self.twitterButton];
    } else if ([source isKindOfClass:[CKLinkedInSource class]]) {
        connectLinkedIn = TRUE;
        linkedinDict = userInfo;
        [self setBorderWidth:5.0f forButton:self.linkedinButton];
    }
}

- (void)didNotLogin:(CKSourceBase *)source {
    if ([source isKindOfClass:[CKFacebookSource class]]) {
        connectFB = FALSE;
        [self showNotification:@"Failed to login in Facebook" isError:YES];
        [self setBorderWidth:0.0f forButton:self.fbButton];
    } else if ([source isKindOfClass:[CKTwitterSource class]]) {
        connectTwitter = FALSE;
        [self showNotification:@"Failed to login in Twitter" isError:YES];
        [self setBorderWidth:0.0f forButton:self.twitterButton];
    } else if ([source isKindOfClass:[CKLinkedInSource class]]) {
        connectLinkedIn = FALSE;
        [self showNotification:@"Failed to login in LinkedIn" isError:YES];
        [self setBorderWidth:.0f forButton:self.linkedinButton];
    }
}

- (void)didLogout:(CKSourceBase *)source {
    if ([source isKindOfClass:[CKFacebookSource class]]) {
        connectFB = FALSE;
        [self showNotification:@"Logged out of Facebook" isError:NO];
        [self setBorderWidth:0.0f forButton:self.fbButton];
    } else if ([source isKindOfClass:[CKTwitterSource class]]) {
        connectTwitter = FALSE;
        [self showNotification:@"Logged out of Twitter" isError:NO];
        [self setBorderWidth:0.0f forButton:self.twitterButton];
    } else if ([source isKindOfClass:[CKLinkedInSource class]]) {
        connectLinkedIn = FALSE;
        [self showNotification:@"Logged out of LinkedIn" isError:NO];
        [self setBorderWidth:0.0f forButton:self.linkedinButton];
    }
}

#pragma mark
- (void)showNotification:(NSString*)text isError:(BOOL)isError {
    notificationView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:notificationView];
    
    UILabel* label = [[UILabel alloc] init];
    label.font = [UIFont iconFontWithSize:16];
    
    if (isError) {
        label.text = [NSString iconStringForEnum:FUICrossCircle];
    } else {
        label.text = [NSString iconStringForEnum:FUICheckCircle];
    }
    
    notificationView.customView = label;
    
    // Set custom view mode
    notificationView.mode = MBProgressHUDModeCustomView;
    
    notificationView.delegate = self;
    notificationView.labelText = text;
    
    [notificationView show:YES];
    [notificationView hide:YES afterDelay:3];
}

#pragma mark MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [notificationView removeFromSuperview];
}


@end
