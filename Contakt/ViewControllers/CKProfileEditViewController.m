//
//  CKProfileTableViewController.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 17/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKProfileEditViewController.h"
#import "CKProfileTableViewCell.h"
#import "CKProfileConnectionTableViewCell.h"
#import "CKSourceController.h"

#import "FlatUIKit.h"
#import "NSString+Icons.h"
#import "CKSourceBase.h"

#import "CKCodeGenerator.h"
#import "CKCoreDataStack.h"
#import "CKFacebookSource.h"
#import "CKTwitterSource.h"
#import "CKLinkedInSource.h"
#import "CKContact.h"
#import "CKConnection.h"

#import "CHTumblrMenuView.h"
#import "CKMediaController.h"
#import "MGSwipeButton.h"

@interface CKProfileEditViewController () <CKSourceLoginDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, MGSwipeTableCellDelegate>
{
    NSString *name;
    NSString *email;
    NSString *phone;
    NSString *imagePath;
    
    BOOL connectMail;
    BOOL connectPhone;
    BOOL connectFB;
    BOOL connectTwitter;
    BOOL connectLinkedIn;

    NSDictionary* facebookDict;
    NSDictionary* twitterDict;
    NSDictionary* linkedinDict;
    
    BOOL anyChanges;
}

@property (nonatomic, strong) UIImageView* imageView;

@end

@implementation CKProfileEditViewController

static NSString * const reuseIdentifier1 = @"profileCell";
static NSString * const reuseIdentifier2 = @"connectionCell";

@synthesize imageView;
@synthesize contact;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 205.0f)];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 50.0;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 3.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        UILabel* changeUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 18)];
        changeUserLabel.text = @"Tap to change profile photo";
        changeUserLabel.font = [UIFont flatFontOfSize:12];
        changeUserLabel.backgroundColor = [UIColor clearColor];
        changeUserLabel.textColor = [UIColor whiteColor];
        changeUserLabel.userInteractionEnabled = YES;
        [changeUserLabel sizeToFit];
        changeUserLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeUser:)];
        [changeUserLabel addGestureRecognizer:tapGesture];
        
        [view addSubview:imageView];
        [view addSubview:changeUserLabel];
        view.backgroundColor = [UIColor colorFromHexCode:@"282F3B"];
        view;
    });
    
    self.view.backgroundColor = [UIColor colorFromHexCode:@"343C4A"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconSave"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(saveProfile:)];

    anyChanges = FALSE;
    
    [self loadProfile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadProfile {
    name = contact.name;
    imagePath = contact.imagePath;
    
    NSDictionary* dict = [CKHelper connectionDictionary:contact];
    CKConnection* mailConn = (CKConnection*)[dict objectForKey:kEmailString];
    CKConnection* phoneConn = (CKConnection*)[dict objectForKey:kPhoneString];
    CKConnection* fbConn = (CKConnection*)[dict objectForKey:kFacebookString];
    NSLog(@"%@", fbConn.value);
    CKConnection* twitterConn = (CKConnection*)[dict objectForKey:kTwitterString];
    CKConnection* linkedinConn = (CKConnection*)[dict objectForKey:kLinkedInString];

    email = [mailConn value];
    connectMail = [mailConn share];
    phone = [phoneConn value];
    connectPhone = [phoneConn share];

    facebookDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [fbConn value], kProfileId,
                    [fbConn email], kProfileEmail,
                    [fbConn imageUrl], kProfileImageUrl,
                    [fbConn name], kProfileName,
                    [fbConn profileUrl], kProfileUrl,
                    nil];
    connectFB = [fbConn share];
    
    twitterDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [twitterConn value], kProfileId,
                    [twitterConn email], kProfileEmail,
                    [twitterConn imageUrl], kProfileImageUrl,
                    [twitterConn name], kProfileName,
                    [twitterConn profileUrl], kProfileUrl,
                    nil];
    connectTwitter = [twitterConn share];

    linkedinDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [linkedinConn value], kProfileId,
                    [linkedinConn email], kProfileEmail,
                    [linkedinConn imageUrl], kProfileImageUrl,
                    [linkedinConn name], kProfileName,
                    [linkedinConn profileUrl], kProfileUrl,
                    nil];
    connectLinkedIn = [linkedinConn share];


    [self loadProfileImage];
}

- (void)loadProfileImage {
    if (imagePath) {
        [[CKMediaController sharedInstance] imageWithFilenameAsync:imagePath success:^(UIImage *image) {
            imageView.image = image;
        } failure:^{
            imageView.image = [UIImage imageNamed:@"defaultProfile"];
        }];
    } else {
        imageView.image = [UIImage imageNamed:@"defaultProfile"];
    }
}

- (void)changeUser:(UIGestureRecognizer*)gesture {
    CHTumblrMenuView *menuView = [[CHTumblrMenuView alloc] init];
    
    [menuView addMenuItemWithTitle:@"Gallery" andIcon:[UIImage imageNamed:@"camera"] andSelectedBlock:^{
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }];
    
    [menuView addMenuItemWithTitle:@"Camera" andIcon:[UIImage imageNamed:@"camera"] andSelectedBlock:^{
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            controller.delegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
    }];
    
    [menuView addMenuItemWithTitle:@"Facebook" andIcon:[UIImage imageNamed:@"facebook"] andSelectedBlock:^{
    }];
    [menuView addMenuItemWithTitle:@"Twitter" andIcon:[UIImage imageNamed:@"twitter"] andSelectedBlock:^{
    }];
    [menuView addMenuItemWithTitle:@"LinkedIn" andIcon:[UIImage imageNamed:@"linkedin"] andSelectedBlock:^{
    }];
    [menuView show];
}

- (void)dismissSelf {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)save {
    if (contact != nil) {
        [self updateContact];
    } else {
        [self addContact];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserSettingsChangedNotification object:nil];
}

- (void)cancel:(id)sender {
    if (anyChanges) {
        [self save];
    }
    [self dismissSelf];
}

- (void)saveProfile:(id)sender {
    [self save];
    [self dismissSelf];
}

- (NSSet*)connections {
    CKConnection *fbConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    fbConnection.type = CKFacebookType;
    fbConnection.share = connectFB;
    fbConnection.value = facebookDict[kProfileId];
    fbConnection.profileUrl = facebookDict[kProfileUrl];
    fbConnection.imageUrl = facebookDict[kProfileImageUrl];
    fbConnection.email = facebookDict[kProfileEmail];
    fbConnection.name = facebookDict[kProfileName];
    
    CKConnection *twitterConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    twitterConnection.type = CKTwitterType;
    twitterConnection.share = connectTwitter;
    twitterConnection.value = twitterDict[kProfileId];
    twitterConnection.profileUrl = twitterDict[kProfileUrl];
    twitterConnection.imageUrl = twitterDict[kProfileImageUrl];
    twitterConnection.email = twitterDict[kProfileEmail];
    twitterConnection.name = twitterDict[kProfileName];
    
    CKConnection *linkedInConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    linkedInConnection.type = CKLinkedInType;
    linkedInConnection.share = connectLinkedIn;
    linkedInConnection.value = linkedinDict[kProfileId];
    linkedInConnection.profileUrl = linkedinDict[kProfileUrl];
    linkedInConnection.imageUrl = linkedinDict[kProfileImageUrl];
    linkedInConnection.email = linkedinDict[kProfileEmail];
    linkedInConnection.name = linkedinDict[kProfileName];
    
    CKConnection *emailConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    emailConnection.type = CKEmailType;
    emailConnection.share = connectMail;
    emailConnection.value = email;
    
    CKConnection *phoneConnection = [NSEntityDescription insertNewObjectForEntityForName:@"CKConnection" inManagedObjectContext:[CKCoreDataStack defaultStack].managedObjectContext];
    phoneConnection.type = CKPhoneType;
    phoneConnection.share = connectPhone;
    phoneConnection.value = phone;
    
    return [[NSSet alloc] initWithObjects:emailConnection, phoneConnection, fbConnection, twitterConnection, linkedInConnection, nil];
}

- (void)addContact {
    CKCoreDataStack *coreDataStack = [CKCoreDataStack defaultStack];
    CKContact *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"CKContact" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    newContact.name = name;
    newContact.imagePath = imagePath;
    newContact.guid = [CKHelper generateUniqueGuid];
    newContact.connections = [self connections];
    [coreDataStack saveContext];
    
    [[NSUserDefaults standardUserDefaults] setValue:newContact.guid forKey:kCurrentProfileString];
}

- (void)updateContact {
    contact.name = name;
    contact.imagePath = imagePath;
    contact.connections = [self connections];
    
    CKCoreDataStack *coreDataStack = [CKCoreDataStack defaultStack];
    [coreDataStack saveContext];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    imageView.image = image;
    
    NSString* guid = self.contact ? self.contact.guid : @"";
    NSString* fileName = [NSString stringWithFormat:@"%@_profile.jpg", guid];
    [[CKMediaController sharedInstance] saveImage:[[CKMediaController sharedInstance] resizeImage:image toSize:CGSizeMake(160.0, 160.0)] withFilename:fileName success:^{
        imagePath = fileName;
    } failure:^(NSError *error) {
        NSLog(@"Failed to save file : %@", [error localizedDescription]);
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 3) {
        CKProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier1 forIndexPath:indexPath];
        NSString* iconName = nil;
        NSString* title = nil;
        NSString* placeHolder = nil;

        if (indexPath.section == 0) {
            iconName = [NSString iconStringForEnum:FUIUser];
            title = @"NAME";
            placeHolder = @"E.g. John Smith";
            
            cell.valueTextField.tag = CKNameType;
            cell.valueTextField.keyboardType = UIKeyboardTypeNamePhonePad;
            cell.valueTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            cell.valueTextField.delegate = self;
            
            if (name && ![name isEqualToString:@""]) {
                cell.valueTextField.text = name;
            }
        } else if (indexPath.section == 1) {
            iconName = [NSString iconStringForEnum:FUIMail];
            title = @"EMAIL";
            placeHolder = @"E.g. abc@xyz.com";

            cell.valueTextField.tag = CKEmailType;
            cell.valueTextField.keyboardType = UIKeyboardTypeEmailAddress;
            cell.valueTextField.delegate = self;
            
            if (email && ![email isEqualToString:@""]) {
                cell.valueTextField.text = email;
            }
        } else if (indexPath.section == 2) {
            iconName = [NSString iconStringForEnum:FUIChat];
            title = @"SMS";
            placeHolder = @"E.g. +91-9999999999";

            cell.valueTextField.tag = CKPhoneType;
            cell.valueTextField.keyboardType = UIKeyboardTypePhonePad;
            cell.valueTextField.delegate = self;
            
            if (phone && ![phone isEqualToString:@""]) {
                cell.valueTextField.text = phone;
            }
        }
        [cell configureCellWithIcon:iconName title:title placeHolder:placeHolder];
        return cell;
    } else {
        CKProfileConnectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier2 forIndexPath:indexPath];
        NSString* iconName = nil;
        NSString* key = nil;
        
        if (indexPath.section == 3) {
            iconName = [NSString iconStringForEnum:FUIFacebook];
            key = kFacebookString;
            cell.stateSwitch.tag = CKFacebookType;
            cell.stateSwitch.on = connectFB;
        } else if (indexPath.section == 4) {
            iconName = [NSString iconStringForEnum:FUITwitter];
            key = kTwitterString;
            cell.stateSwitch.tag = CKTwitterType;
            cell.stateSwitch.on = connectTwitter;
        } else if (indexPath.section == 5) {
            iconName = [NSString iconStringForEnum:FUILinkedin];
            key = kLinkedInString;
            cell.stateSwitch.tag = CKLinkedInType;
            cell.stateSwitch.on = connectLinkedIn;
        }
        
        [cell configureCellWithIcon:iconName key:key];
        cell.delegate = self;
        [cell.stateSwitch addTarget:self action:@selector(performLoginAction:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    
    return nil;
}

#pragma mark Selectors

- (void)performLoginAction:(id)sender {
    FUISwitch* switchControl = (FUISwitch*)sender;
    
    CKSourceBase* source;
    if (switchControl.tag == CKFacebookType) {
        source = [[CKSourceController sharedInstance] sourceForKey:kFacebookString];
    } else if (switchControl.tag == CKTwitterType) {
        source = [[CKSourceController sharedInstance] sourceForKey:kTwitterString];
    } else if (switchControl.tag == CKLinkedInType) {
        source = [[CKSourceController sharedInstance] sourceForKey:kLinkedInString];
    }
    
    if ([source isLoggedIn]) {
        connectFB = !connectFB;
    } else {
        [source login:self];
    }
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 6.0f;
    }
    return 1.0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 3) {
        CKProfileTableViewCell* cell = (CKProfileTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.valueTextField becomeFirstResponder];
    } else {
        CKProfileConnectionTableViewCell* cell = (CKProfileConnectionTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.stateSwitch becomeFirstResponder];
    }
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == CKNameType) {
        name = textField.text;
    } else if (textField.tag == CKEmailType) {
        email = textField.text;
    } else if (textField.tag == CKPhoneType) {
        phone = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark CKSourceLoginDelegate

- (void)didLogin:(CKSourceBase *)source withUserInfo:(NSDictionary *)userInfo {
    if ([source isKindOfClass:[CKFacebookSource class]]) {
        connectFB = TRUE;
        facebookDict = userInfo;
    } else if ([source isKindOfClass:[CKTwitterSource class]]) {
        connectTwitter = TRUE;
        twitterDict = userInfo;
    } else if ([source isKindOfClass:[CKLinkedInSource class]]) {
        connectLinkedIn = TRUE;
        linkedinDict = userInfo;
    }
}

- (void)didNotLogin:(CKSourceBase *)source {
    if ([source isKindOfClass:[CKFacebookSource class]]) {
        connectFB = FALSE;
        facebookDict = nil;
    } else if ([source isKindOfClass:[CKTwitterSource class]]) {
        connectTwitter = FALSE;
        twitterDict = nil;
    } else if ([source isKindOfClass:[CKLinkedInSource class]]) {
        connectLinkedIn = FALSE;
        linkedinDict = nil;
    }
}

- (void)didLogout:(CKSourceBase *)source {
    if ([source isKindOfClass:[CKFacebookSource class]]) {
        connectFB = FALSE;
        facebookDict = nil;
    } else if ([source isKindOfClass:[CKTwitterSource class]]) {
        connectTwitter = FALSE;
        twitterDict = nil;
    } else if ([source isKindOfClass:[CKLinkedInSource class]]) {
        connectLinkedIn = FALSE;
        linkedinDict = nil;
    }
    anyChanges = TRUE;
}

#pragma mark MGSwipeTableCellDelegate

- (BOOL)swipeTableCell:(MGSwipeTableCell *)_cell canSwipe:(MGSwipeDirection)direction {
    CKProfileConnectionTableViewCell* cell = (CKProfileConnectionTableViewCell*)_cell;
    CKSourceBase* source = nil;
    if (cell.stateSwitch.tag == CKFacebookType) {
        source = [[CKSourceController sharedInstance] sourceForKey:kFacebookString];
    } else if (cell.stateSwitch.tag == CKTwitterType) {
        source = [[CKSourceController sharedInstance] sourceForKey:kTwitterString];
    } else if (cell.stateSwitch.tag == CKLinkedInType) {
        source = [[CKSourceController sharedInstance] sourceForKey:kLinkedInString];
    }
    
    if (source) {
        return [source isLoggedIn];
    }
    return NO;
}

-(void) swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState) state gestureIsActive:(BOOL) gestureIsActive {
    
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*)_cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        //sign out button
        CKProfileConnectionTableViewCell* cell = (CKProfileConnectionTableViewCell*)_cell;
        FUISwitch* switchControl = (FUISwitch*)cell.stateSwitch;
        
        CKSourceBase* source = nil;
        if (switchControl.tag == CKFacebookType) {
            source = [[CKSourceController sharedInstance] sourceForKey:kFacebookString];
        } else if (switchControl.tag == CKTwitterType) {
            source = [[CKSourceController sharedInstance] sourceForKey:kTwitterString];
        } else if (switchControl.tag == CKLinkedInType) {
            source = [[CKSourceController sharedInstance] sourceForKey:kLinkedInString];
        }
        
        if ([source isLoggedIn]) {
            [source logout:self];
        }
    }
    return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {
    return @[[MGSwipeButton buttonWithTitle:@"Sign Out" backgroundColor:[UIColor redColor]]];
}


@end
