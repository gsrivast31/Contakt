//
//  CKIntroViewController.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 02/02/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKIntroViewController.h"
#import "CKIntroSignupViewController1.h"

@interface CKIntroViewController () <SRFSurfboardDelegate>

@end

@implementation CKIntroViewController

- (id)init {
    NSString* introsPath = [[NSBundle mainBundle] pathForResource:@"intros" ofType:@"json"];
    self = [super initWithPathToConfiguration:introsPath];
    self.delegate = self;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundColor = [UIColor colorFromHexCode:@"282F3B"];
    self.tintColor = [UIColor turquoiseColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark SRFSurfboardDelegate 

- (void)surfboard:(SRFSurfboardViewController *)surfboard didShowPanelAtIndex:(NSInteger)index {
    
}

- (void)surfboard:(SRFSurfboardViewController *)surfboard didTapButtonAtIndexPath:(NSIndexPath *)indexPath {
    CKIntroSignupViewController1* vc = (CKIntroSignupViewController1*)[CKHelper viewControllerWithId:@"introSignupController"];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
