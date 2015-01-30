//
//  CKProfileTableViewCell.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 17/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKProfileTableViewCell.h"

@interface CKProfileTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CKProfileTableViewCell

-(void)configureIcon:(NSString*)iconName {
    self.iconLabel.font = [UIFont iconFontWithSize:16];
    self.iconLabel.textAlignment = NSTextAlignmentCenter;
    self.iconLabel.text = iconName;
    self.iconLabel.textColor = [UIColor turquoiseColor];
}

-(void)configureTitle:(NSString*)title {
    self.titleLabel.font = [UIFont flatFontOfSize:12.0f];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.text = title;
    self.titleLabel.textColor = [UIColor turquoiseColor];
}

-(void)configureCellWithIcon:(NSString*)iconName title:(NSString*)titleText placeHolder:(NSString*)defaultValue {
    self.controlView.backgroundColor = [UIColor colorFromHexCode:@"282F3B"];
    self.iconLabel.backgroundColor = [UIColor colorFromHexCode:@"282F3B"];
    
    [self configureIcon:iconName];
    [self configureTitle:titleText];
    
    self.valueTextField.placeholder = defaultValue;
    self.valueTextField.textColor = [UIColor alizarinColor];
    self.valueTextField.textFieldColor = [UIColor clearColor];
}

@end
