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
#import "NSString+Icons.h"
#import "CKCodeGenerator.h"

@interface CKProfileViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation CKProfileViewCell

- (void)setProfileImage:(UIImage*)image {
    self.profileImageView.contentMode = UIViewContentModeCenter;
    if (!CGRectContainsRect(self.profileImageView.bounds, CGRectMake(CGRectZero.origin.x, CGRectZero.origin.y, image.size.width, image.size.height))) {
        self.profileImageView.contentMode = UIViewContentModeScaleToFill;
    }
    self.profileImageView.image = image;
}

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
    
    [[CKMediaController sharedInstance] imageFromParse:contact.guid success:^(UIImage *image) {
        [self setProfileImage:image];
    } failure:^(NSError* error){
        [self setProfileImage:[UIImage imageNamed:@"defaultProfile"]];
        NSLog(@"%@", [error localizedDescription]);
    }];
    
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
