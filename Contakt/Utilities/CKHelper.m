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

+ (NSString*)encodeString:(NSString*)string {
    if (![CKHelper isStringValid:string])
        string = @"";
    NSString* encodedString = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData* encodedData = [encodedString dataUsingEncoding:NSUTF8StringEncoding];
    return [encodedData base64EncodedStringWithOptions:0];
}

+ (NSString*)decodeString:(NSString*)string {
    NSData* decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
    NSString* decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return [decodedString stringByRemovingPercentEncoding];
}

+ (NSString*)serialize:(CKContact*)contact {
    NSDictionary* dict = [CKHelper connectionDictionary:contact];
    NSArray* strings = [[NSArray alloc] initWithObjects:
                        [self encodeString:kAppUniqueId],
                        [self encodeString:contact.guid],
                        [self encodeString:[dict objectForKey:kNameString]],
                        [self encodeString:[(CKConnection*)[dict objectForKey:kEmailString] value]],
                        [self encodeString:[(CKConnection*)[dict objectForKey:kPhoneString] value]],
                        [self encodeString:[(CKConnection*)[dict objectForKey:kFacebookString] value]],
                        [self encodeString:[(CKConnection*)[dict objectForKey:kFacebookString] profileUrl]],
                        [self encodeString:[(CKConnection*)[dict objectForKey:kTwitterString] value]],
                        [self encodeString:[(CKConnection*)[dict objectForKey:kTwitterString] profileUrl]],
                        [self encodeString:[(CKConnection*)[dict objectForKey:kLinkedInString] value]],
                        [self encodeString:[(CKConnection*)[dict objectForKey:kLinkedInString] profileUrl]],
                        nil];
    return [strings componentsJoinedByString:@"|"];
}

+ (CKContact*)deserialize:(NSString *)string {
    NSArray* strings = [string componentsSeparatedByString:@"|"];

    if ([strings count] != 11) {
        return nil;
    }
    
    BOOL isContakt = [[self decodeString:[strings objectAtIndex:0]] isEqualToString:kAppUniqueId] ;
    if (isContakt == FALSE) {
        return nil;
    }
    
    CKCoreDataStack *coreDataStack = [CKCoreDataStack defaultStack];
    CKContact *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"CKContact" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    newContact.guid = [self decodeString:[strings objectAtIndex:1]];
    newContact.name = [self decodeString:[strings objectAtIndex:2]];

    CKConnection *emailConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    emailConnection.type = CKEmailType;
    emailConnection.value = [self decodeString:[strings objectAtIndex:3]];
    emailConnection.share = YES;
    
    CKConnection *phoneConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    phoneConnection.type = CKPhoneType;
    phoneConnection.value = [self decodeString:[strings objectAtIndex:4]];
    phoneConnection.share = YES;

    CKConnection *fbConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    fbConnection.type = CKFacebookType;
    fbConnection.share = YES;
    fbConnection.value = [self decodeString:[strings objectAtIndex:5]];
    fbConnection.profileUrl = [self decodeString:[strings objectAtIndex:6]];
    
    CKConnection *twitterConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    twitterConnection.type = CKTwitterType;
    twitterConnection.share = YES;
    twitterConnection.value = [self decodeString:[strings objectAtIndex:7]];
    twitterConnection.profileUrl = [self decodeString:[strings objectAtIndex:8]];
    
    CKConnection *linkedInConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    linkedInConnection.type = CKLinkedInType;
    linkedInConnection.share = YES;
    linkedInConnection.value = [self decodeString:[strings objectAtIndex:9]];
    linkedInConnection.profileUrl = [self decodeString:[strings objectAtIndex:10]];
    
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
