//
//  CKContactCollectionViewCell.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 17/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKContactCollectionViewCell.h"
#import "CKMediaController.h"

#define kBorderWidth 2.0

@interface CKContactCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation CKContactCollectionViewCell

- (void)setProfileImage:(UIImage*)image {
    self.profileImageView.contentMode = UIViewContentModeCenter;
    if (!CGRectContainsRect(self.profileImageView.bounds, CGRectMake(CGRectZero.origin.x, CGRectZero.origin.y, image.size.width, image.size.height))) {
        self.profileImageView.contentMode = UIViewContentModeScaleToFill;
    }
    self.profileImageView.image = image;
}

- (void) configureCellForContact:(CKContact *)contact {
    __weak typeof(self) weakSelf = self;
    [[CKMediaController sharedInstance] imageFromParse:contact.guid success:^(UIImage *image) {
        __strong typeof(weakSelf) strongSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image)
                [strongSelf setProfileImage:image];
            else
                [strongSelf setProfileImage:[UIImage imageNamed:@"defaultProfile"]];
        });
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = self;
        [strongSelf setProfileImage:[UIImage imageNamed:@"defaultProfile"]];
    }];
    
    if (contact.name) {
        self.nameLabel.text = [[contact.name componentsSeparatedByString:@" "] objectAtIndex:0];
        self.nameLabel.font = [UIFont flatFontOfSize:12.0f];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor turquoiseColor];
    }

    self.profileImageView.alpha = 0.5f;
    
    
    self.layer.borderColor = [[UIColor colorWithRed:0.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f] CGColor];
    self.layer.borderWidth = 2.0f;
    self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2.0f;
    self.layer.masksToBounds = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.shouldRasterize = YES;
    self.clipsToBounds = YES;
    
    self.backgroundColor = [UIColor colorFromHexCode:@"343C4A"];
}

@end
