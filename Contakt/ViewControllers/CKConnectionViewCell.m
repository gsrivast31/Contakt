//
//  CKConnectionViewCell.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 20/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKConnectionViewCell.h"
#import "CKMediaController.h"
#import "NSString+Icons.h"
#import "CKContact.h"
#import "CKConnection.h"

@interface CKConnectionViewCell()

@property (weak, nonatomic) IBOutlet FUIButton *nameButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet FUIButton *emailButton;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet FUIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;


@end

@implementation CKConnectionViewCell

- (void)configureCellWithContact:(CKContact*)contact {
    NSDictionary* dict = [CKHelper connectionDictionary:contact];
    NSString *name = [dict objectForKey:kNameString];
    NSString *email = [(CKConnection*)[dict objectForKey:kEmailString] value];
    NSString *phone = [(CKConnection*)[dict objectForKey:kPhoneString] value];
    BOOL enableFB = [(CKConnection*)[dict objectForKey:kFacebookString] share];
    BOOL enableTwitter= [(CKConnection*)[dict objectForKey:kTwitterString] share];
    BOOL enableLinkedIn = [(CKConnection*)[dict objectForKey:kLinkedInString] share];
    NSString *facebookRemoteUrl = [(CKConnection*)[dict objectForKey:kFacebookString] profileUrl];
    NSString *twitterRemoteUrl = [(CKConnection*)[dict objectForKey:kTwitterString] profileUrl];
    NSString *linkedinRemoteUrl = [(CKConnection*)[dict objectForKey:kLinkedInString] profileUrl];
    NSString *facebookId = [(CKConnection*)[dict objectForKey:kFacebookString] value];
    NSString *twitterId = [(CKConnection*)[dict objectForKey:kTwitterString] value];
    NSString *linkedinId = [(CKConnection*)[dict objectForKey:kLinkedInString] value];
    NSString *facebookNativeURL = [CKHelper isStringValid:facebookId] ? [@"fb://profile/" stringByAppendingString:facebookId] : nil;
    NSString *twitterNativeURL = [CKHelper isStringValid:facebookId] ? [@"twitter://user?id=" stringByAppendingString:twitterId] : nil;
    NSString *linkedInNativeURL = [CKHelper isStringValid:facebookId] ? [@"linkedin://#profile/" stringByAppendingString:linkedinId] : nil;
                                                                   
    self.fbButton.titleLabel.font = [UIFont iconFontWithSize:16];
    self.fbButton.buttonColor = [UIColor colorFromHexCode:@"3b5998"];
    self.fbButton.shadowColor = [UIColor colorFromHexCode:@"3b5998"];
    self.fbButton.disabledColor = [UIColor grayColor];
    self.fbButton.disabledShadowColor = [UIColor grayColor];
    self.fbButton.shadowHeight = 3.0f;
    self.fbButton.cornerRadius = 6.0f;
    [self.fbButton setTitle:[NSString stringWithFormat:@"%@ Facebook", [NSString iconStringForEnum:FUIFacebook]] forState:UIControlStateNormal];
    [self.fbButton setRemoteLink:facebookRemoteUrl];
    [self.fbButton setNativeLink:facebookNativeURL];
    [self.fbButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.twitterButton.titleLabel.font = [UIFont iconFontWithSize:16];
    self.twitterButton.buttonColor = [UIColor colorFromHexCode:@"00aced"];
    self.twitterButton.shadowColor = [UIColor colorFromHexCode:@"00aced"];
    self.twitterButton.disabledColor = [UIColor grayColor];
    self.twitterButton.disabledShadowColor = [UIColor grayColor];
    self.twitterButton.shadowHeight = 3.0f;
    self.twitterButton.cornerRadius = 6.0f;
    [self.twitterButton setTitle:[NSString stringWithFormat:@"%@ Twitter", [NSString iconStringForEnum:FUITwitter]] forState:UIControlStateNormal];
    [self.twitterButton setRemoteLink:twitterRemoteUrl];
    [self.twitterButton setNativeLink:twitterNativeURL];
    [self.twitterButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];

    self.linkedinButton.titleLabel.font = [UIFont iconFontWithSize:16];
    self.linkedinButton.buttonColor = [UIColor colorFromHexCode:@"007bb6"];
    self.linkedinButton.shadowColor = [UIColor colorFromHexCode:@"007bb6"];
    self.linkedinButton.disabledColor = [UIColor grayColor];
    self.linkedinButton.disabledShadowColor = [UIColor grayColor];
    self.linkedinButton.shadowHeight = 3.0f;
    self.linkedinButton.cornerRadius = 6.0f;
    [self.linkedinButton setTitle:[NSString stringWithFormat:@"%@ LinkedIn", [NSString iconStringForEnum:FUILinkedin]] forState:UIControlStateNormal];
    [self.linkedinButton setRemoteLink:linkedinRemoteUrl];
    [self.linkedinButton setNativeLink:linkedInNativeURL];
    [self.linkedinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.nameButton.backgroundColor = self.emailButton.backgroundColor = self.phoneButton.backgroundColor = self.nameLabel.backgroundColor = self.emailLabel.backgroundColor = self.phoneLabel.backgroundColor = [UIColor colorFromHexCode:@"282F3B"];
    
    self.nameButton.titleLabel.font = [UIFont iconFontWithSize:16];
    [self.nameButton setTitle:[NSString iconStringForEnum:FUIUser] forState:UIControlStateNormal];
    [self.nameButton setTitleColor:[UIColor turquoiseColor] forState:UIControlStateNormal];
    [self.emailButton setTitle:[NSString iconStringForEnum:FUIMail] forState:UIControlStateNormal];
    self.emailButton.titleLabel.font = [UIFont iconFontWithSize:16];
    [self.emailButton setTitleColor:[UIColor turquoiseColor] forState:UIControlStateNormal];
    [self.phoneButton setTitle:[NSString iconStringForEnum:FUIChat] forState:UIControlStateNormal];
    [self.phoneButton setTitleColor:[UIColor turquoiseColor] forState:UIControlStateNormal];
    self.phoneButton.titleLabel.font = [UIFont iconFontWithSize:16];
    
    [self.nameLabel setTextColor:[UIColor turquoiseColor]];
    [self.emailLabel setTextColor:[UIColor turquoiseColor]];
    [self.phoneLabel setTextColor:[UIColor turquoiseColor]];
    
    if ([CKHelper isStringValid:name]) {
        [self.nameLabel setText:name];
        self.nameLabel.font = [UIFont flatFontOfSize:16];
    } else {
        [self.nameLabel setText:@"No name specified"];
        self.nameLabel.font = [UIFont italicFlatFontOfSize:14];
    }

    if ([CKHelper isStringValid:email]) {
        [self.emailLabel setText:email];
        self.emailLabel.font = [UIFont flatFontOfSize:16];
    } else {
        [self.emailLabel setText:@"No email specified"];
        self.emailLabel.font = [UIFont italicFlatFontOfSize:14];
    }

    if ([CKHelper isStringValid:phone]) {
        [self.phoneLabel setText:phone];
        self.phoneLabel.font = [UIFont flatFontOfSize:16];
    } else {
        [self.phoneLabel setText:@"No phone number specified"];
        self.phoneLabel.font = [UIFont italicFlatFontOfSize:14];
    }

    if (enableFB) {
        self.fbButton.enabled = YES;
        self.fbButton.userInteractionEnabled = YES;
    } else {
        self.fbButton.enabled = NO;
    }
    
    if (enableTwitter) {
        self.twitterButton.enabled = YES;
        self.twitterButton.userInteractionEnabled = YES;
    } else {
        self.twitterButton.enabled = NO;
    }

    if (enableLinkedIn) {
        self.linkedinButton.enabled = YES;
        self.linkedinButton.userInteractionEnabled = YES;
    } else {
        self.linkedinButton.enabled = NO;
    }

    self.backgroundColor = [UIColor colorFromHexCode:@"282F3B"];
}

@end
