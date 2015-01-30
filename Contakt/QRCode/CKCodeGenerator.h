//
//  CKCodeGenerator.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 17/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CKCodeGenerator : NSObject

+ (id)sharedInstance;
- (void)generateCode:(NSString*)string
             success:(void (^)(UIImage *))successCallback
             failure:(void (^)(NSError *))failureCallback;

@end
