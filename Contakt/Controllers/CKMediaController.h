//
//  CKMediaController.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 17/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

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
                       failure:(void (^)(NSError *))failureCallback;
- (void)imageFromURL:(NSDictionary*)photo
             success:(void (^)(UIImage *))successCallback
              failure:(void (^)(NSError *))failureCallback;

- (void)imageFromParse:(NSString*)user
               success:(void (^)(UIImage*))successCallback
               failure:(void (^)(NSError*))failureCallback;

- (void)saveToParse:(UIImage*)image
            forUser:(NSString*)user
            success:(void (^)(void))successCallback
            failure:(void (^)(NSError*))failureCallback;

// Helpers
- (UIImage *)resizeImage:(UIImage *)image
                  toSize:(CGSize)newSize;
+ (BOOL)canStoreMedia;

@end
