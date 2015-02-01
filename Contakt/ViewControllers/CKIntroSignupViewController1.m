//
//  CKIntroSignupViewController1.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 27/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKIntroSignupViewController1.h"
#import "CKIntroSignupViewController2.h"
#import "NSString+Icons.h"
#import "CKTextField.h"
#import "CAGradientLayer+CKGradients.h"

@interface CKIntroSignupViewController1 ()

@property (weak, nonatomic) IBOutlet CKTextField *nameTextField;
@property (weak, nonatomic) IBOutlet CKTextField *emailTextField;
@property (weak, nonatomic) IBOutlet CKTextField *phoneTextField;
@property (weak, nonatomic) IBOutlet FUIButton *continueButton;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;

@end

@implementation CKIntroSignupViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        [self setEdgesForExtendedLayout:UIRectEdgeTop];
    
    self.nameTextField.placeholder = @"Name";
    
    self.emailTextField.placeholder = @"Email";
    
    self.phoneTextField.placeholder = @"(+1)-2223334444";
    
    [self.nameTextField setRequired:YES];
    [self.emailTextField setRequired:YES];
    [self.phoneTextField setRequired:NO];
    
    [self setupStyling:self.nameTextField];
    [self setupStyling:self.emailTextField];
    [self setupStyling:self.phoneTextField];
    
    self.continueButton.buttonColor = [UIColor turquoiseColor];
    self.continueButton.shadowColor = [UIColor greenSeaColor];
    self.continueButton.shadowHeight = 3.0f;
    self.continueButton.cornerRadius = 6.0f;
    self.continueButton.titleLabel.font = [UIFont iconFontWithSize:16];
    [self.continueButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.continueButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    self.captionLabel.text = @"FILL YOUR DETAILS";
    self.captionLabel.font = [UIFont flatFontOfSize:21.0f];
    self.captionLabel.textColor = [UIColor midnightBlueColor];
    
    [self.continueButton setTitle:[NSString stringWithFormat:@"CONTINUE %@", [NSString iconStringForEnum:FUIArrowRight]] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableDisableButton) name:UITextFieldTextDidChangeNotification object:self.nameTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableDisableButton) name:UITextFieldTextDidChangeNotification object:self.emailTextField];
    
    [self enableDisableButton];
    
    CAGradientLayer *backgroundLayer = [CAGradientLayer sideGradientLayer];
    backgroundLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:backgroundLayer atIndex:0];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.nameTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.emailTextField];
}

- (void)setupStyling:(FUITextField*)textField {
    [textField setTextFieldColor:[UIColor cloudsColor]];
    [textField setBorderColor:[UIColor asbestosColor]];
    [textField setCornerRadius:4];
    [textField setFont:[UIFont flatFontOfSize:14]];
    [textField setTextColor:[UIColor midnightBlueColor]];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (![self validateInputInView:self.view]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid information please review and try again!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CKIntroSignupViewController2* vc = (CKIntroSignupViewController2*)segue.destinationViewController;
    [vc setUserWithName:self.nameTextField.text withEmail:self.emailTextField.text withPhone:self.phoneTextField.text];
}

- (void)enableDisableButton {
    if ([CKHelper isStringValid:self.nameTextField.text] && [CKHelper isStringValid:self.emailTextField.text]) {
        self.continueButton.enabled = YES;
    } else {
        self.continueButton.enabled = NO;
    }
}

- (BOOL)validateInputInView:(UIView*)view {
    for(UIView *subView in view.subviews){
        if ([subView isKindOfClass:[UIScrollView class]])
            return [self validateInputInView:subView];
        
        if ([subView isKindOfClass:[CKTextField class]]){
            if (![(CKTextField*)subView validate]){
                return NO;
            }
        }
    }
    
    return YES;
}

@end
