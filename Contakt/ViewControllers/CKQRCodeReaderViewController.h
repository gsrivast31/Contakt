//
//  CKQRCodeReaderViewController.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 17/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

@protocol CKQRCodeReaderDelegate<NSObject>

- (void)didReadQRCode:(NSString*)string;

@end

@interface CKQRCodeReaderViewController : UIViewController

@property (nonatomic, assign) id<CKQRCodeReaderDelegate> delegate;

@end
