//
//  CKSourceBase.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 18/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKSourceBase;

@protocol CKSourceLoginDelegate<NSObject>

-(void)didLogin:(CKSourceBase*)source withUserInfo:(NSDictionary*)userInfo;
-(void)didNotLogin:(CKSourceBase*)source;
-(void)didLogout:(CKSourceBase*)source;

@end

@protocol CKSourceFollowDelegate<NSObject>

-(void)didFinishFollow:(id)result withError:(NSError*)error andUserInfo:(NSDictionary*)userInfo;

@end

@protocol CKSourceServicesDelegate <NSObject>

@optional

- (BOOL) isLoggedIn;
- (void) login:(id<CKSourceLoginDelegate>)delegate;
- (void) logout:(id<CKSourceLoginDelegate>)delegate;

- (void) followUser:(NSString*)userName
     requestDelegate:(id<CKSourceFollowDelegate>)delegate
            userInfo:(NSDictionary *)info;

@end

@interface CKSourceBase : NSObject <CKSourceServicesDelegate> 

@property (nonatomic, assign, readonly) NSString* sourceId;
@property (nonatomic, assign, readonly) NSString* sourceName;
@property (nonatomic, assign, readonly) NSString* sourceDescription;
@property (nonatomic) BOOL supportsLogin;
@property (nonatomic) BOOL supportsFollow;

@property (nonatomic, assign) id<CKSourceLoginDelegate> loginDelegate;
@property (nonatomic, assign) id<CKSourceFollowDelegate> followDelegate;

@end
