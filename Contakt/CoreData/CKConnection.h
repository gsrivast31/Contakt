//
//  CKConnection.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 29/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CKContact;

@interface CKConnection : NSManagedObject

@property (nonatomic) BOOL share;
@property (nonatomic) int16_t type;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * profileUrl;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) CKContact *contact;

@end
