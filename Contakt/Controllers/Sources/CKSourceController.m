//
//  CKSourceController.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 18/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKSourceController.h"
#import "CKSourceBase.h"

@interface CKSourceController()

- (void)create;

@end

@implementation CKSourceController

@synthesize sources = _sources;

+ (CKSourceController*)sharedInstance {
    static CKSourceController *sInstance = nil;
    if ( sInstance == nil ) {
        sInstance = [[CKSourceController alloc] init];
        [sInstance create];
    }
    
    return sInstance;
}

- (void)create {
    _sources = [[NSMutableDictionary alloc] init];
}

- (void)addSource:(CKSourceBase *)source forKey:(NSString*)key {
    [_sources setObject:source forKey:key];
}

- (CKSourceBase*)sourceForKey:(NSString *)key {
    return [_sources objectForKey:key];
}

@end
