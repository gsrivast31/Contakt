//
//  SRFSurfboardPanel.m
//  Surfboard
//
//  Created by Moshe on 8/12/14.
//  Copyright (c) 2014 Moshe Berman. All rights reserved.
//

#import "SRFSurfboardPanelCell.h"

/**
 *  A class extension for SRFSurfboardPanelCell
 */

@interface SRFSurfboardPanelCell ()

@end

@implementation SRFSurfboardPanelCell

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    self = [super awakeAfterUsingCoder:aDecoder];
    
    if (self)
    {   
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)prepareForReuse
{
    
    //  Set the title text.
    self.textView.text = self.panel.text;
    
    //  Add the image, tinted
    self.imageView.image = self.panel.image;
    
    if (self.imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate)
    {
        self.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.imageView.layer.borderWidth = 3.0f;
        self.imageView.layer.cornerRadius = 20.0f;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.clipsToBounds = YES;
        
    }
    else
    {
        self.imageView.layer.borderWidth = 0.0;
    }
    
    //  Apply the title
    [self.actionButton setTitle:self.panel.buttonTitle forState:UIControlStateNormal];
    
    //  Hide the button on panels with no title.
    self.actionButton.hidden = (self.panel.buttonTitle == nil);
}

- (void)setPanel:(SRFSurfboardPanel *)panel
{
    _panel = panel;
    
    [self prepareForReuse];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    self.actionButton.layer.cornerRadius = 5.0f;
    self.actionButton.backgroundColor = [[UIColor turquoiseColor] colorWithAlphaComponent:0.2];
    
    self.textView.textColor = self.tintColor;
    
    [self.actionButton setTitleColor:self.tintColor forState:UIControlStateNormal];
    
    /**
     *  Debug borders
     */
    
//    self.contentView.layer.borderColor = [UIColor redColor].CGColor;
//    self.contentView.layer.borderWidth = 2.0f;
}

@end
