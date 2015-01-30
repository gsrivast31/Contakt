//
//  CKHelper.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 19/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKContact;

@interface CKHelper : NSObject

+ (NSString*)generateUniqueGuid;
+ (NSString*)serialize:(CKContact*)contact;
+ (CKContact*)deserialize:(NSString*)string;
+ (UIViewController*)viewControllerWithId:(NSString*)string;
+ (BOOL)isStringValid:(NSString*)string;
+ (NSDictionary*)connectionDictionary:(CKContact*)contact;

@end
