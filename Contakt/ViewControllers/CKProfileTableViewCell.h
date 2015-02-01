//
//  CKProfileTableViewCell.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 17/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

@interface CKProfileTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet FUITextField *valueTextField;

-(void)configureCellWithIcon:(NSString*)iconName title:(NSString*)titleText placeHolder:(NSString*)defaultValue;

@end
