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

#import "FlatUIKit.h"

@interface CKIntroSignupViewController2 () <CKSourceLoginDelegate>
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
    
    self.optionLabel.text = @"Select networks to share";
    self.optionLabel.font = [UIFont italicFlatFontOfSize:16.0f];
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
    CKCoreDataStack *coreDataStack = [CKCoreDataStack defaultStack];
    CKContact *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"CKContact" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    newContact.name = _name;
    newContact.imagePath = nil;
    newContact.guid = [CKHelper generateUniqueGuid];
    newContact.connections = [self connections];
    [coreDataStack saveContext];
    
    [[NSUserDefaults standardUserDefaults] setValue:newContact.guid forKey:kCurrentProfileString];
    
    //[self.navigationController pushViewController:[CKHelper viewControllerWithId:@"rootController"] animated:YES];
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
    fbConnection.email = facebookDict[kProfileEmail];
    fbConnection.name = facebookDict[kProfileName];
    
    CKConnection *twitterConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    twitterConnection.type = CKTwitterType;
    twitterConnection.share = connectTwitter;
    twitterConnection.value = twitterDict[kProfileId];
    twitterConnection.profileUrl = twitterDict[kProfileUrl];
    twitterConnection.imageUrl = twitterDict[kProfileImageUrl];
    twitterConnection.email = twitterDict[kProfileEmail];
    twitterConnection.name = twitterDict[kProfileName];
    
    CKConnection *linkedInConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    linkedInConnection.type = CKLinkedInType;
    linkedInConnection.share = connectLinkedIn;
    linkedInConnection.value = linkedinDict[kProfileId];
    linkedInConnection.profileUrl = linkedinDict[kProfileUrl];
    linkedInConnection.imageUrl = linkedinDict[kProfileImageUrl];
    linkedInConnection.email = linkedinDict[kProfileEmail];
    linkedInConnection.name = linkedinDict[kProfileName];
    
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
        [self setBorderWidth:0.0f forButton:self.fbButton];
    } else if ([source isKindOfClass:[CKTwitterSource class]]) {
        connectTwitter = FALSE;
        [self setBorderWidth:0.0f forButton:self.twitterButton];
    } else if ([source isKindOfClass:[CKLinkedInSource class]]) {
        connectLinkedIn = FALSE;
        [self setBorderWidth:.0f forButton:self.linkedinButton];
    }
}

- (void)didLogout:(CKSourceBase *)source {
    if ([source isKindOfClass:[CKFacebookSource class]]) {
        connectFB = FALSE;
        [self setBorderWidth:0.0f forButton:self.fbButton];
    } else if ([source isKindOfClass:[CKTwitterSource class]]) {
        connectTwitter = FALSE;
        [self setBorderWidth:0.0f forButton:self.twitterButton];
    } else if ([source isKindOfClass:[CKLinkedInSource class]]) {
        connectLinkedIn = FALSE;
        [self setBorderWidth:0.0f forButton:self.linkedinButton];
    }
}

@end
