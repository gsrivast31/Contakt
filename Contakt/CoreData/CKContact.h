//
//  CKContact.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 17/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CKConnection;

@interface CKContact : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSSet *connections;
@end

@interface CKContact (CoreDataGeneratedAccessors)

- (void)addConnectionsObject:(CKConnection *)value;
- (void)removeConnectionsObject:(CKConnection *)value;
- (void)addConnections:(NSSet *)values;
- (void)removeConnections:(NSSet *)values;

@end
