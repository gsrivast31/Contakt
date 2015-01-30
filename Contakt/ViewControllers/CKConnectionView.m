//
//  CKConnectionView.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 20/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKConnectionView.h"
#import "CKCircleMenu.h"
#import "CKContact.h"

@implementation CKConnectionView

@synthesize contact;

#pragma mark - Setup
+ (id)presentInView:(UIView *)parentView withContact:(CKContact*)ckContact {
    CKConnectionView *view = [[CKConnectionView alloc] initWithFrame:parentView.bounds withContact:ckContact];
    [parentView addSubview:view];
    
    return view;
}

- (id)initWithFrame:(CGRect)frame withContact:(CKContact*)ckContact {
    self = [super initWithFrame:frame];
    if (self) {
        self.contact = ckContact;
        self.tintColor = [UIColor clearColor];
        self.dynamic = NO;
        self.blurRadius = 10.0f;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self addGestureRecognizer:gesture];
        
        [self setupConnections];
    }
    return self;
}

- (void)setupConnections {
    CKCircleMenu* circleMenu = [[CKCircleMenu alloc] initWithMenuSize:280.0f
                                             buttonSize:64.0f
                                       centerButtonSize:120.0f
                                              titleName:self.contact.name
                                  centerButtonImageName:self.contact.imagePath];
    [self addSubview:circleMenu];

}

#pragma mark - Logic
- (void)dismiss {
    [self removeFromSuperview];
}

@end
