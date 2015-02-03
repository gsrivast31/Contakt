//
//  CKCircleMenu.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 20/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKCircleMenu.h"
#import "CKMediaController.h"
#import "CKContact.h"

@interface CKCircleMenu()
{
    NSInteger buttonCount_;
    CGRect    buttonOriginFrame_;
    CKContact* contact_;
    BOOL shouldRecoverToNormalStatusWhenViewWillAppear_;
}

@property (nonatomic, copy) CKContact *contact;

- (void)_toggle:(id)sender;
- (void)_close:(NSNotification *)notification;
- (void)_updateButtonsLayoutWithTriangleHypotenuse:(CGFloat)triangleHypotenuse;
- (void)_setButtonWithTag:(NSInteger)buttonTag origin:(CGPoint)origin;

@end

static CGFloat menuSize_, buttonSize_, centerButtonSize_;
static CGFloat defaultTriangleHypotenuse_, minBounceOfTriangleHypotenuse_, maxBounceOfTriangleHypotenuse_, maxTriangleHypotenuse_;

@implementation CKCircleMenu

@synthesize menu           = menu_;
@synthesize centerButton   = centerButton_;
@synthesize titleLabel     = titleLabel_;
@synthesize isOpening      = isOpening_;
@synthesize isInProcessing = isInProcessing_;
@synthesize isClosed       = isClosed_;
@synthesize contact        = contact_;
@synthesize delegate       = delegate_;

- (void)dealloc {
    // Release subvies & remove notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Designated initializer
- (instancetype)initWithMenuSize:(CGFloat)menuSize
                      buttonSize:(CGFloat)buttonSize
                centerButtonSize:(CGFloat)centerButtonSize
                         contact:(CKContact *)contact
                        delegate:(id<CKConnectionViewDelegate>)delegate {
    if (self = [self init]) {
        buttonCount_                     = 5;
        menuSize_                        = menuSize;
        buttonSize_                      = buttonSize;
        centerButtonSize_                = centerButtonSize;
        contact_                         = contact;
        delegate_                        = delegate;
        
        // Default value for triangle hypotenuse
        defaultTriangleHypotenuse_     = (menuSize - buttonSize) * .5f;
        minBounceOfTriangleHypotenuse_ = defaultTriangleHypotenuse_ - 12.f;
        maxBounceOfTriangleHypotenuse_ = defaultTriangleHypotenuse_ + 12.f;
        maxTriangleHypotenuse_         = kKYCircleMenuViewHeight * .5f;
        
        // Buttons' origin frame
        CGFloat originX = (menuSize_ - centerButtonSize_) * .5f;
        buttonOriginFrame_ = (CGRect){{originX, originX}, {centerButtonSize_, centerButtonSize_}};
    }
    return self;
}

// Secondary initializer
- (id)init {
    if (self = [super init]) {
        isInProcessing_ = NO;
        isOpening_      = NO;
        isClosed_       = YES;
        shouldRecoverToNormalStatusWhenViewWillAppear_ = NO;
        self.frame = CGRectMake(0.f, 0.f, kKYCircleMenuViewWidth, kKYCircleMenuViewHeight);
    }
    return self;
}

#pragma mark - View lifecycle

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Constants
    CGFloat viewHeight = CGRectGetHeight(self.frame);
    CGFloat viewWidth  = CGRectGetWidth(self.frame);
    
    // Center Menu View
    CGRect centerMenuFrame = CGRectMake((viewWidth - menuSize_) * .5f, (viewHeight - menuSize_) * .5f, menuSize_, menuSize_);
    menu_ = [[UIView alloc] initWithFrame:centerMenuFrame];
    [menu_ setAlpha:0.f];
    [self addSubview:menu_];
    
    [self addMenuOptions];
    [self addCenterButton];
    [self addTitle];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self performSelector:@selector(open) withObject:nil afterDelay:.15f];
}

- (void)addMenuOptions {
    [self.menu addSubview:[self buttonWithTag:CKEmailType withImageName:@"mail_circle"]];
    [self.menu addSubview:[self buttonWithTag:CKPhoneType withImageName:@"phone_circle"]];
    [self.menu addSubview:[self buttonWithTag:CKFacebookType withImageName:@"facebook_circle"]];
    [self.menu addSubview:[self buttonWithTag:CKTwitterType withImageName:@"twitter_circle"]];
    [self.menu addSubview:[self buttonWithTag:CKLinkedInType withImageName:@"linkedin_circle"]];
}

- (UIButton*)buttonWithTag:(NSInteger)tag withImageName:(NSString*)imageName {
    UIButton * button = [[UIButton alloc] initWithFrame:buttonOriginFrame_];
    [button setOpaque:NO];
    [button setTag:tag - 1];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(runButtonActions:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)addCenterButton {
    CGRect mainButtonFrame = CGRectMake((CGRectGetWidth(self.frame) - centerButtonSize_) * .5f,
                                        (CGRectGetHeight(self.frame) - centerButtonSize_) * .5f,
                                        centerButtonSize_, centerButtonSize_);
    centerButton_ = [[UIButton alloc] initWithFrame:mainButtonFrame];
    centerButton_.layer.masksToBounds = YES;
    centerButton_.layer.cornerRadius = CGRectGetWidth(centerButton_.frame) / 2.0f;
    centerButton_.layer.borderColor = [UIColor whiteColor].CGColor;
    centerButton_.layer.borderWidth = 3.0f;
    centerButton_.layer.rasterizationScale = [UIScreen mainScreen].scale;
    centerButton_.layer.shouldRasterize = YES;
    centerButton_.clipsToBounds = YES;
    
    [[CKMediaController sharedInstance] imageFromParse:contact_.guid success:^(UIImage *image) {
        [centerButton_ setImage:image forState:UIControlStateNormal];
    } failure:^(NSError *error) {
        [centerButton_ setImage:[UIImage imageNamed:@"defaultProfile"] forState:UIControlStateNormal];
    }];

    [centerButton_ addTarget:self action:@selector(_toggle:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:centerButton_];
}

- (void)addTitle {
    CGRect titleFrame = CGRectMake(10.0f, self.menu.frame.origin.y + self.menu.frame.size.height + 30.0f, self.frame.size.width - 20.0f, 30.0f);
    titleLabel_ = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel_.text = contact_.name;
    titleLabel_.textAlignment = NSTextAlignmentCenter;
    titleLabel_.font = [UIFont flatFontOfSize:25.0f];
    titleLabel_.textColor = [UIColor whiteColor];
    [self addSubview:titleLabel_];
}

#pragma mark - Publich Button Action

- (void)runButtonActions:(id)sender {
    shouldRecoverToNormalStatusWhenViewWillAppear_ = YES;
    NSInteger tag = [sender tag] + 1;
    [delegate_ didTapButton:tag forContact:contact_];
}

// Open center menu view
- (void)open {
    if (isOpening_) return;
    
    isInProcessing_ = YES;
    // Show buttons with animation
    [UIView animateWithDuration:.3f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.menu setAlpha:1.f];
                         // Compute buttons' frame and set for them, based on |buttonCount|
                         [self _updateButtonsLayoutWithTriangleHypotenuse:maxBounceOfTriangleHypotenuse_];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:.1f
                                               delay:0.f
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              [self _updateButtonsLayoutWithTriangleHypotenuse:defaultTriangleHypotenuse_];
                                          }
                                          completion:^(BOOL finished) {
                                              isOpening_ = YES;
                                              isClosed_ = NO;
                                              isInProcessing_ = NO;
                                          }];
                     }];
}

// Recover to normal status
- (void)recoverToNormalStatus {
    [self _updateButtonsLayoutWithTriangleHypotenuse:maxTriangleHypotenuse_];
    [UIView animateWithDuration:.3f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Show buttons & slide in to center
                         [self.menu setAlpha:1.f];
                         [self _updateButtonsLayoutWithTriangleHypotenuse:minBounceOfTriangleHypotenuse_];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:.1f
                                               delay:0.f
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              [self _updateButtonsLayoutWithTriangleHypotenuse:defaultTriangleHypotenuse_];
                                          }
                                          completion:nil];
                     }];
}

- (void)close {
    [self _close:nil];
}

#pragma mark - Private Methods

// Toggle Circle Menu
- (void)_toggle:(id)sender {
    (isClosed_ ? [self open] : [self _close:nil]);
}

// Close menu to hide all buttons around
- (void)_close:(NSNotification *)notification {
    if (isClosed_)
        return;
    
    isInProcessing_ = YES;
    // Hide buttons with animation
    [UIView animateWithDuration:.3f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         for (UIButton * button in [self.menu subviews])
                             [button setFrame:buttonOriginFrame_];
                         [self.menu setAlpha:0.f];
                     }
                     completion:^(BOOL finished) {
                         isClosed_       = YES;
                         isOpening_      = NO;
                         isInProcessing_ = NO;
                     }];
}

// Update buttons' layout with the value of triangle hypotenuse that given
- (void)_updateButtonsLayoutWithTriangleHypotenuse:(CGFloat)triangleHypotenuse {
    //
    //  Triangle Values for Buttons' Position
    //
    //      /|      a: triangleA = c * cos(x)
    //   c / | b    b: triangleB = c * sin(x)
    //    /)x|      c: triangleHypotenuse
    //   -----      x: degree
    //     a
    //
    CGFloat centerBallMenuHalfSize = menuSize_         * .5f;
    CGFloat buttonRadius           = centerButtonSize_ * .5f;
    if (! triangleHypotenuse) triangleHypotenuse = defaultTriangleHypotenuse_; // Distance to Ball Center
    
    //
    //      o       o   o      o   o     o   o     o o o     o o o
    //     \|/       \|/        \|/       \|/       \|/       \|/
    //  1 --|--   2 --|--    3 --|--   4 --|--   5 --|--   6 --|--
    //     /|\       /|\        /|\       /|\       /|\       /|\
    //                           o       o   o     o   o     o o o
    //
    switch (buttonCount_) {
        case 1:
            [self _setButtonWithTag:1 origin:CGPointMake(centerBallMenuHalfSize - buttonRadius,
                                                         centerBallMenuHalfSize - triangleHypotenuse - buttonRadius)];
            break;
            
        case 2: {
            CGFloat degree    = M_PI / 4.0f; // = 45 * M_PI / 180
            CGFloat triangleB = triangleHypotenuse * sinf(degree);
            CGFloat negativeValue = centerBallMenuHalfSize - triangleB - buttonRadius;
            CGFloat positiveValue = centerBallMenuHalfSize + triangleB - buttonRadius;
            [self _setButtonWithTag:1 origin:CGPointMake(negativeValue, negativeValue)];
            [self _setButtonWithTag:2 origin:CGPointMake(positiveValue, negativeValue)];
            break;
        }
            
        case 3: {
            // = 360.0f / self.buttonCount * M_PI / 180.0f;
            // E.g: if |buttonCount_ = 6|, then |degree = 60.0f * M_PI / 180.0f|;
            // CGFloat degree = 2 * M_PI / self.buttonCount;
            //
            CGFloat degree    = M_PI / 3.0f; // = 60 * M_PI / 180
            CGFloat triangleA = triangleHypotenuse * cosf(degree);
            CGFloat triangleB = triangleHypotenuse * sinf(degree);
            [self _setButtonWithTag:1 origin:CGPointMake(centerBallMenuHalfSize - triangleB - buttonRadius,
                                                         centerBallMenuHalfSize - triangleA - buttonRadius)];
            [self _setButtonWithTag:2 origin:CGPointMake(centerBallMenuHalfSize + triangleB - buttonRadius,
                                                         centerBallMenuHalfSize - triangleA - buttonRadius)];
            [self _setButtonWithTag:3 origin:CGPointMake(centerBallMenuHalfSize - buttonRadius,
                                                         centerBallMenuHalfSize + triangleHypotenuse - buttonRadius)];
            break;
        }
            
        case 4: {
            CGFloat degree    = M_PI / 4.0f; // = 45 * M_PI / 180
            CGFloat triangleB = triangleHypotenuse * sinf(degree);
            CGFloat negativeValue = centerBallMenuHalfSize - triangleB - buttonRadius;
            CGFloat positiveValue = centerBallMenuHalfSize + triangleB - buttonRadius;
            [self _setButtonWithTag:1 origin:CGPointMake(negativeValue, negativeValue)];
            [self _setButtonWithTag:2 origin:CGPointMake(positiveValue, negativeValue)];
            [self _setButtonWithTag:3 origin:CGPointMake(negativeValue, positiveValue)];
            [self _setButtonWithTag:4 origin:CGPointMake(positiveValue, positiveValue)];
            break;
        }
            
        case 5: {
            CGFloat degree    = M_PI / 2.5f; // = 72 * M_PI / 180
            CGFloat triangleA = triangleHypotenuse * cosf(degree);
            CGFloat triangleB = triangleHypotenuse * sinf(degree);
            [self _setButtonWithTag:1 origin:CGPointMake(centerBallMenuHalfSize - triangleB - buttonRadius,
                                                         centerBallMenuHalfSize - triangleA - buttonRadius)];
            [self _setButtonWithTag:2 origin:CGPointMake(centerBallMenuHalfSize - buttonRadius,
                                                         centerBallMenuHalfSize - triangleHypotenuse - buttonRadius)];
            [self _setButtonWithTag:3 origin:CGPointMake(centerBallMenuHalfSize + triangleB - buttonRadius,
                                                         centerBallMenuHalfSize - triangleA - buttonRadius)];
            
            degree    = M_PI / 5.0f;  // = 36 * M_PI / 180
            triangleA = triangleHypotenuse * cosf(degree);
            triangleB = triangleHypotenuse * sinf(degree);
            [self _setButtonWithTag:4 origin:CGPointMake(centerBallMenuHalfSize - triangleB - buttonRadius,
                                                         centerBallMenuHalfSize + triangleA - buttonRadius)];
            [self _setButtonWithTag:5 origin:CGPointMake(centerBallMenuHalfSize + triangleB - buttonRadius,
                                                         centerBallMenuHalfSize + triangleA - buttonRadius)];
            break;
        }
            
        case 6: {
            CGFloat degree    = M_PI / 3.0f; // = 60 * M_PI / 180
            CGFloat triangleA = triangleHypotenuse * cosf(degree);
            CGFloat triangleB = triangleHypotenuse * sinf(degree);
            [self _setButtonWithTag:1 origin:CGPointMake(centerBallMenuHalfSize - triangleB - buttonRadius,
                                                         centerBallMenuHalfSize - triangleA - buttonRadius)];
            [self _setButtonWithTag:2 origin:CGPointMake(centerBallMenuHalfSize - buttonRadius,
                                                         centerBallMenuHalfSize - triangleHypotenuse - buttonRadius)];
            [self _setButtonWithTag:3 origin:CGPointMake(centerBallMenuHalfSize + triangleB - buttonRadius,
                                                         centerBallMenuHalfSize - triangleA - buttonRadius)];
            [self _setButtonWithTag:4 origin:CGPointMake(centerBallMenuHalfSize - triangleB - buttonRadius,
                                                         centerBallMenuHalfSize + triangleA - buttonRadius)];
            [self _setButtonWithTag:5 origin:CGPointMake(centerBallMenuHalfSize - buttonRadius,
                                                         centerBallMenuHalfSize + triangleHypotenuse - buttonRadius)];
            [self _setButtonWithTag:6 origin:CGPointMake(centerBallMenuHalfSize + triangleB - buttonRadius,
                                                         centerBallMenuHalfSize + triangleA - buttonRadius)];
            break;
        }
            
        default:
            break;
    }
}

// Set Frame for button with special tag
- (void)_setButtonWithTag:(NSInteger)buttonTag origin:(CGPoint)origin {
    UIButton * button = (UIButton *)[self.menu viewWithTag:buttonTag];
    [button setFrame:CGRectMake(origin.x, origin.y, centerButtonSize_, centerButtonSize_)];
    button = nil;
}

@end
