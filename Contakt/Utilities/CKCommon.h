//
//  CKCommon.h
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 18/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#ifndef Contakt_CKCommon_h
#define Contakt_CKCommon_h

NS_ENUM(int16_t, CKDetailType)
{
    CKNameType = 1,
    CKEmailType = 2,
    CKPhoneType = 3
};
        
NS_ENUM(int16_t, CKSourceType)
{
    CKFacebookType = 4,
    CKTwitterType = 5,
    CKLinkedInType = 6,
};

NS_ENUM(int16_t, CKImageType)
{
    CKImageLocal = 1,
    CKImageFacebook = 2,
    CKImageTwitter = 3,
    CKImageLinkedIn = 4,
    CKImageNone = 5
};

static NSString* const kAppUniqueId = @"com.memoir.contaktme";
static NSString* const APP_NAME = @"ContaktMe";
static NSString* const APP_ID = @"963590012";
static NSString* const APP_URL = @"https://itunes.apple.com/app/id/id963590012";

static NSString* const kNameString = @"Name";
static NSString* const kEmailString = @"Email";
static NSString* const kPhoneString = @"Phone";
static NSString* const kFacebookString = @"Facebook";
static NSString* const kTwitterString = @"Twitter";
static NSString* const kLinkedInString = @"LinkedIn";

static NSString* const kCurrentProfileString = @"KCurrentProfile";
static NSString* const kUserSettingsChangedNotification = @"kUserSettingsChangedNotification";

static NSString* const kTwitterToken = @"KTwitterToken";
static NSString* const kFacebookToken = @"kFacebookToken";
static NSString* const kLinkedInToken = @"kLinkedInToken";

static NSString* const kProfileId = @"profileId";
static NSString* const kProfileUrl = @"profileUrl";
static NSString* const kProfileImageUrl = @"profileImageUrl";
static NSString* const kProfileEmail = @"profileEmail";
static NSString* const kProfileName = @"profileName";

#endif
