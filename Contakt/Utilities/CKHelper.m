//
//  CKHelper.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 19/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKHelper.h"
#import "CKContact.h"
#import "CKConnection.h"

#import "CKConnection.h"
#import "CKCoreDataStack.h"

@implementation CKHelper

+ (NSString*)generateUniqueGuid {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *str = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return str;
}

+ (NSString*)createEmptyIfNull:(NSString*)string {
    return string? string : @"";
}

+ (NSDictionary*)connectionDictionary:(CKContact*)contact {
    NSString* name = contact.name;
    CKConnection* emailConn;
    CKConnection* phoneConn;
    CKConnection* facebookConn;
    CKConnection* twitterConn;
    CKConnection* linkedInConn;
    
    NSSet* set = [NSSet setWithSet:contact.connections];
    for (CKConnection* item in set) {
        if (item.type == CKEmailType) {
            emailConn = item;
        } else if (item.type == CKPhoneType) {
            phoneConn = item;
        } else if (item.type == CKFacebookType) {
            facebookConn = item;
        } else if (item.type == CKTwitterType) {
            twitterConn = item;
        } else if (item.type == CKLinkedInType) {
            linkedInConn = item;
        }
    }
    
    name = [self createEmptyIfNull:name];

    return [NSDictionary dictionaryWithObjectsAndKeys:
            name, kNameString,
            emailConn, kEmailString,
            phoneConn, kPhoneString,
            facebookConn, kFacebookString,
            twitterConn, kTwitterString,
            linkedInConn, kLinkedInString,
            nil];
}

+ (NSString*)serialize:(CKContact*)contact {
    NSDictionary* dict = [CKHelper connectionDictionary:contact];
    NSArray* strings = [[NSArray alloc] initWithObjects:
                        [dict objectForKey:kNameString],
                        [(CKConnection*)[dict objectForKey:kEmailString] value],
                        [(CKConnection*)[dict objectForKey:kPhoneString] value],
                        [(CKConnection*)[dict objectForKey:kFacebookString] profileUrl],
                        [(CKConnection*)[dict objectForKey:kTwitterString] profileUrl],
                        [(CKConnection*)[dict objectForKey:kLinkedInString] profileUrl],
                        nil];
    return [strings componentsJoinedByString:@"|"];
}

+ (CKContact*)deserialize:(NSString *)string {
    NSArray* strings = [string componentsSeparatedByString:@"|"];
    
    CKCoreDataStack *coreDataStack = [CKCoreDataStack defaultStack];
    CKContact *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"CKContact" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    newContact.name = [strings objectAtIndex:0];

    CKConnection *emailConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    emailConnection.type = CKEmailType;
    emailConnection.value = [strings objectAtIndex:1];
    
    CKConnection *phoneConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    phoneConnection.type = CKPhoneType;
    phoneConnection.value = [strings objectAtIndex:2];

    CKConnection *fbConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    fbConnection.type = CKFacebookType;
    
    CKConnection *twitterConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    twitterConnection.type = CKTwitterType;
    
    CKConnection *linkedInConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    linkedInConnection.type = CKLinkedInType;
    
    newContact.connections = [[NSSet alloc] initWithObjects:emailConnection, phoneConnection, fbConnection, twitterConnection, linkedInConnection, nil];
    
    return newContact;
}

+ (UIViewController*)viewControllerWithId:(NSString*)string {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:string];
}

+ (BOOL)isStringValid:(NSString *)string {
    return string && ![string isEqualToString:@""];
}

@end
