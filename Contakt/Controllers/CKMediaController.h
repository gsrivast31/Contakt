//
//  CKMediaController.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 17/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CKMediaController : NSObject

+ (id)sharedInstance;

// Logic
- (void)saveImage:(UIImage *)image
     withFilename:(NSString *)filename
          success:(void (^)(void))successCallback
          failure:(void (^)(NSError *))failureCallback;
- (void)deleteImageWithFilename:(NSString *)filename
                        success:(void (^)(void))successCallback
                        failure:(void (^)(NSError *))failureCallback;
- (UIImage *)imageWithFilename:(NSString *)filename;
- (void)imageWithFilenameAsync:(NSString *)filename
                       success:(void (^)(UIImage *))successCallback
                       failure:(void (^)(void))failureCallback;

// Helpers
- (UIImage *)resizeImage:(UIImage *)image
                  toSize:(CGSize)newSize;
+ (BOOL)canStoreMedia;

@end
