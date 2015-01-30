//
//  CKConnectionView.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 20/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "FXBlurView.h"

@class CKContact;

@interface CKConnectionView : FXBlurView

@property (nonatomic, strong) CKContact* contact;

// Setup
+ (id)presentInView:(UIView *)parentView withContact:(CKContact*)ckContact;

@end
