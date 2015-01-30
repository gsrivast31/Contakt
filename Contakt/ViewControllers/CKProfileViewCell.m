//
//  CKProfileViewCell.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 20/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKProfileViewCell.h"
#import "CKMediaController.h"

#import "CKConnection.h"
#import "CKContact.h"
#import "FlatUIKit.h"
#import "NSString+Icons.h"
#import "CKCodeGenerator.h"

@interface CKProfileViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation CKProfileViewCell

- (void)loadQRCode:(CKContact*)contact {
    if (contact != nil) {
        __weak typeof(self) weakSelf = self;
        NSString* string = [CKHelper serialize:contact];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [[CKCodeGenerator sharedInstance] generateCode:string success:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.qrImageView setImage:image];
                });
            } failure:^(NSError *error) {
                [strongSelf.qrImageView setImage:nil];
            }];
        });
    }
}

- (void)configureCellWithContact:(CKContact*)contact {
    [self loadQRCode:contact];
    
    if ([CKHelper isStringValid:contact.imagePath]) {
        [[CKMediaController sharedInstance] imageWithFilenameAsync:contact.imagePath success:^(UIImage *image) {
            self.profileImageView.image = image;
        } failure:^{
            self.profileImageView.image = [UIImage imageNamed:@"defaultProfile"];
        }];
    } else {
        self.profileImageView.image = [UIImage imageNamed:@"defaultProfile"];
    }
    
    self.profileImageView.backgroundColor = [UIColor clearColor];
    self.profileImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = 10.0;
    self.profileImageView.layer.borderColor = [UIColor colorFromHexCode:@"282F3B"].CGColor;
    self.profileImageView.layer.borderWidth = 2.0f;
    self.profileImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.profileImageView.layer.shouldRasterize = YES;
    self.profileImageView.clipsToBounds = YES;
    
    self.qrImageView.backgroundColor = [UIColor clearColor];
    self.qrImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.qrImageView.layer.masksToBounds = YES;
    self.qrImageView.layer.cornerRadius = 10.0;
    self.qrImageView.layer.borderColor = [UIColor colorFromHexCode:@"282F3B"].CGColor;
    self.qrImageView.layer.borderWidth = 2.0f;
    self.qrImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.qrImageView.layer.shouldRasterize = YES;
    self.qrImageView.clipsToBounds = YES;
    self.qrImageView.userInteractionEnabled = YES;

    self.backgroundColor = [UIColor clearColor];
}

@end