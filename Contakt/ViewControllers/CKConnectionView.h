//
//  CKConnectionView.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 20/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "FXBlurView.h"

@class CKContact;

@protocol CKConnectionViewDelegate<NSObject>

- (void)didTapButton:(NSInteger)type forContact:(CKContact*)contact;

@end

@interface CKConnectionView : FXBlurView

@property (nonatomic, strong) CKContact* contact;
@property (nonatomic, assign) id<CKConnectionViewDelegate> delegate;

// Setup
+ (id)presentInView:(UIView *)parentView withContact:(CKContact*)ckContact withDelegate:(id<CKConnectionViewDelegate>)delegate;

@end
