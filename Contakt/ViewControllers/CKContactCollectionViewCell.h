//
//  CKContactCollectionViewCell.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 17/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKContact.h"

@interface CKContactCollectionViewCell : UICollectionViewCell

-(void)configureCellForContact:(CKContact*)contact;

@end
