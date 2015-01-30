//
//  CKProfileConnectionTableViewCell.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 18/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKProfileConnectionTableViewCell.h"
#import "CKSourceController.h"
#import "CKSourceBase.h"

@interface CKProfileConnectionTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;

@end

@implementation CKProfileConnectionTableViewCell

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

-(void)configureSwitch:(NSString*)key {
    self.stateSwitch.onColor = [UIColor turquoiseColor];
    self.stateSwitch.offColor = [UIColor cloudsColor];
    self.stateSwitch.onBackgroundColor = [UIColor midnightBlueColor];
    self.stateSwitch.offBackgroundColor = [UIColor silverColor];
    self.stateSwitch.offLabel.font = [UIFont boldFlatFontOfSize:14];
    self.stateSwitch.onLabel.font = [UIFont boldFlatFontOfSize:14];
}

-(void)configureCellWithIcon:(NSString*)iconName key:(NSString*)key {
    self.controlView.backgroundColor = [UIColor colorFromHexCode:@"282F3B"];
    self.iconLabel.backgroundColor = [UIColor colorFromHexCode:@"282F3B"];
    
    [self configureIcon:iconName];
    [self configureTitle:[key uppercaseString]];
    [self configureSwitch:key];
}

@end
