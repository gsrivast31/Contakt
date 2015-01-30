//
//  CKSourceController.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 18/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKSourceBase;

@interface CKSourceController : NSObject

@property (nonatomic, retain) NSMutableDictionary* sources;

+ (CKSourceController*)sharedInstance;
- (void)addSource:(CKSourceBase*)source forKey:(NSString*)key;
- (CKSourceBase*)sourceForKey:(NSString*)key;

@end
