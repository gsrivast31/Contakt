//
//  CKProfileViewCell.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 20/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKContact;

@interface CKProfileViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;

- (void)configureCellWithContact:(CKContact*)contact;

@end
