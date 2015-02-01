//
//  CKCircleMenu.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 20/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKConnectionView.h"

#define kKYCircleMenuViewHeight CGRectGetHeight([UIScreen mainScreen].applicationFrame)
#define kKYCircleMenuViewWidth  CGRectGetWidth([UIScreen mainScreen].applicationFrame)
#define kKYCircleMenuNavigationBarHeight 44.f

@class CKContact;

@interface CKCircleMenu : UIView
{
    UIView   * menu_;
    UIButton * centerButton_;
    UILabel  * titleLabel_;
    BOOL       isOpening_;
    BOOL       isInProcessing_;
    BOOL       isClosed_;
}

@property (nonatomic, strong) UIView   * menu;
@property (nonatomic, strong) UIButton * centerButton;
@property (nonatomic, strong) UILabel  * titleLabel;
@property (nonatomic, assign) BOOL       isOpening;
@property (nonatomic, assign) BOOL       isInProcessing;
@property (nonatomic, assign) BOOL       isClosed;
@property (nonatomic, assign) id<CKConnectionViewDelegate> delegate;

- (instancetype)initWithMenuSize:(CGFloat)menuSize
                         buttonSize:(CGFloat)buttonSize
                   centerButtonSize:(CGFloat)centerButtonSize
                         contact:(CKContact*)contact
                        delegate:(id<CKConnectionViewDelegate>)delegate;

- (void)runButtonActions:(id)sender;
- (void)open;
- (void)close;
- (void)recoverToNormalStatus;
@end
