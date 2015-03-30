//
//  CKProfileViewController.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 20/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKProfileViewController.h"
#import "CKProfileEditViewController.h"
#import "CKProfileViewCell.h"
#import "CKConnectionViewCell.h"

#import "CKCoreDataStack.h"
#import "CKMediaController.h"
#import "CKContact.h"
#import "CKConnection.h"
#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"
#import "SVWebViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>

@interface CKProfileViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) CKContact *contact;
@property (nonatomic, strong) UIImageView *qrImageView;

@end

static NSString * const reuseIdentifier1 = @"profileViewCell";
static NSString * const reuseIdentifier2 = @"connectionViewCell";

@implementation CKProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconListMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    [self.navigationItem setLeftBarButtonItem:menuBarButtonItem animated:NO];
    
    [self loadProfile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kUserSettingsChangedNotification object:nil];
    self.view.backgroundColor = [UIColor colorFromHexCode:@"343C4A"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
}

- (void)loadProfile {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileString]) {
        NSManagedObjectContext *moc = [[CKCoreDataStack defaultStack] managedObjectContext];
        if(moc) {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"CKContact" inManagedObjectContext:moc];
            [request setEntity:entity];
            [request setResultType:NSManagedObjectResultType];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid == %@", [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileString]];
            [request setPredicate:predicate];
            
            // Execute the fetch.
            NSError *error = nil;
            NSArray *objects = [moc executeFetchRequest:request error:&error];
            if (objects != nil && [objects count] > 0) {
               self.contact = [objects objectAtIndex:0];
            }
        }
    }
}

- (void)refresh {
    [self loadProfile];
    [self.tableView reloadData];
}

- (void)showQRCode:(UIGestureRecognizer*)gesture {
    TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:self.qrImageView.image];
    viewController.transitioningDelegate = self;
    viewController.title = self.contact.name;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)openLink:(id)sender {
    CKButton* button = (CKButton*)sender;
    if ([CKHelper isStringValid:button.nativeLink] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:button.nativeLink]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:button.nativeLink]];
    } else {
        SVWebViewController* vc = [[SVWebViewController alloc] initWithAddress:button.remoteLink];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 160.0f;
    } else {
        return 370.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        CKProfileViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier1 forIndexPath:indexPath];
        [cell configureCellWithContact:self.contact];
        self.qrImageView = cell.qrImageView;
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showQRCode:)];
        [cell.qrImageView addGestureRecognizer:gesture];
        return cell;
    } else {
        CKConnectionViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier2 forIndexPath:indexPath];
        [cell configureCellWithContact:self.contact];
        [cell.fbButton addTarget:self action:@selector(openLink:) forControlEvents:UIControlEventTouchUpInside];
        [cell.twitterButton addTarget:self action:@selector(openLink:) forControlEvents:UIControlEventTouchUpInside];
        [cell.linkedinButton addTarget:self action:@selector(openLink:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    return nil;
}

#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"edit"]) {
        UINavigationController* navVC = (UINavigationController*)segue.destinationViewController;
        CKProfileEditViewController* vc = (CKProfileEditViewController*)navVC.topViewController;
        vc.contact = self.contact;
    }
}

#pragma mark UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.qrImageView];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.qrImageView];
    }
    return nil;
}

@end
