//
//  CKContactCollectionViewCell.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 17/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKContactCollectionViewCell.h"
#import "CKMediaController.h"

#import "FlatUIKit.h"

#define kBorderWidth 2.0

@interface CKContactCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation CKContactCollectionViewCell

- (void)addBorder {
    CALayer *borderLayer = [CALayer layer];
    CGRect borderFrame = CGRectMake(-kBorderWidth, -kBorderWidth, self.frame.size.width + 2*kBorderWidth, self.frame.size.height + 2*kBorderWidth);
    
    [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [borderLayer setFrame:borderFrame];
    [borderLayer setBorderWidth:kBorderWidth];
    [borderLayer setBorderColor:[[UIColor colorWithRed:0.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f] CGColor]];
    [self.layer addSublayer:borderLayer];
}

-(void)changeShape {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2.0f;
}

- (void) configureCellForContact:(CKContact *)contact {
    if (contact.imagePath) {
        __weak typeof(self) weakSelf = self;
        [[CKMediaController sharedInstance] imageWithFilenameAsync:contact.imagePath success:^(UIImage *image) {
            __strong typeof(weakSelf) strongSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image)
                    strongSelf.profileImageView.image = image;
                else
                    strongSelf.profileImageView.image = [UIImage imageNamed:@"defaultProfile"];
            });
        } failure:^{
             __strong typeof(weakSelf) strongSelf = self;
            strongSelf.profileImageView.image = [UIImage imageNamed:@"defaultProfile"];
        }];
    } else {
        self.profileImageView.image = [UIImage imageNamed:@"defaultProfile"];
        
    }
    
    if (contact.name) {
        self.nameLabel.text = [[contact.name componentsSeparatedByString:@" "] objectAtIndex:0];
        self.nameLabel.font = [UIFont flatFontOfSize:12.0f];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor turquoiseColor];
    }

    self.profileImageView.alpha = 0.5f;
    [self addBorder];
    [self changeShape];
    
    self.backgroundColor = [UIColor colorFromHexCode:@"343C4A"];
}

@end
