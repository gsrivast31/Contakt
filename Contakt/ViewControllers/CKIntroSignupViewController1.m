//
//  CKIntroSignupViewController1.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 27/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKIntroSignupViewController1.h"
#import "CKIntroSignupViewController2.h"
#import "FlatUIKit.h"
#import "NSString+Icons.h"

@interface CKIntroSignupViewController1 () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet FUITextField *nameTextField;
@property (weak, nonatomic) IBOutlet FUITextField *emailTextField;
@property (weak, nonatomic) IBOutlet FUITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet FUIButton *continueButton;

@end

@implementation CKIntroSignupViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameTextField.placeholder = @"Name";
    self.nameTextField.delegate = self;
    
    self.emailTextField.placeholder = @"Email";
    self.emailTextField.delegate = self;
    
    self.phoneTextField.placeholder = @"(+1)-2223334444";
    self.phoneTextField.delegate = self;
    
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
    
    [self.continueButton setTitle:[NSString stringWithFormat:@"CONTINUE %@", [NSString iconStringForEnum:FUIArrowRight]] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableDisableButton) name:UITextFieldTextDidChangeNotification object:self.nameTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableDisableButton) name:UITextFieldTextDidChangeNotification object:self.emailTextField];
    
    [self enableDisableButton];
    self.navigationController.navigationBar.translucent = YES;

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

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
