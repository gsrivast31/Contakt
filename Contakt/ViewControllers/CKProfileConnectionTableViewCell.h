//
//  CKProfileConnectionTableViewCell.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 18/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "MGSwipeTableCell.h"

@interface CKProfileConnectionTableViewCell : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet FUISwitch *stateSwitch;

-(void)configureCellWithIcon:(NSString*)iconName key:(NSString*)key;

@end
