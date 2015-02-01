//
//  CKConnectionViewCell.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 20/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKButton.h"

@class CKContact;

@interface CKConnectionViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet CKButton *fbButton;
@property (weak, nonatomic) IBOutlet CKButton *twitterButton;
@property (weak, nonatomic) IBOutlet CKButton *linkedinButton;

- (void)configureCellWithContact:(CKContact*)contact;
@end
