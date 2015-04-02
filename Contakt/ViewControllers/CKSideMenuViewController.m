//
//  CKSideMenuViewController.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 19/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKSideMenuViewController.h"
#import "CKContactCollectionViewController.h"
#import "UIViewController+RESideMenu.h"
#import "CAGradientLayer+CKGradients.h"

#import <MessageUI/MessageUI.h>
#import <UAAppReviewManager/UAAppReviewManager.h>
#import "NSString+Icons.h"

@interface CKSideMenuViewController () <MFMailComposeViewControllerDelegate>

@property (strong, readwrite, nonatomic) UITableView *tableView;

@end

@implementation CKSideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 54 * 5) / 2.0f, self.view.frame.size.width, 54 * 5) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView.scrollsToTop = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
    
    CAGradientLayer *backgroundLayer = [CAGradientLayer sideGradientLayer];
    backgroundLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:backgroundLayer atIndex:0];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[CKHelper viewControllerWithId:@"contactsViewController"]] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 1:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[CKHelper viewControllerWithId:@"profileViewController"]] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 2:
            if([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
                [mailController setMailComposeDelegate:self];
                [mailController setModalPresentationStyle:UIModalPresentationFormSheet];
                [mailController setSubject:@"ContaktMe Support"];
                [mailController setToRecipients:@[@"gaurav.sri87@gmail.com"]];
                [mailController setMessageBody:[NSString stringWithFormat:@"%@\n\n", NSLocalizedString(@"Here's my feedback:", @"A default message shown to users when contacting support for help")] isHTML:NO];
                if(mailController) {
                    [self presentViewController:mailController animated:YES completion:nil];
                }
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                    message:NSLocalizedString(@"This device hasn't been setup to send emails.", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }

            [self.sideMenuViewController hideMenuViewController];
            break;
        case 3:
            if([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
                [mailController setMailComposeDelegate:self];
                [mailController setModalPresentationStyle:UIModalPresentationFormSheet];
                [mailController setSubject:[NSString stringWithFormat:@"Checkout this:%@", APP_NAME]];
                
                NSString *body = [NSString stringWithFormat:@"Hey! I found this cool app <b><u><a href='%@'>%@</a></u></b>. Check it out.", APP_URL, APP_NAME];
                [mailController setMessageBody:body isHTML:YES];
                if(mailController) {
                    [self presentViewController:mailController animated:YES completion:nil];
                }
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                    message:NSLocalizedString(@"This device hasn't been setup to send emails.", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
            
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 4:
            [UAAppReviewManager rateApp];
            [self.sideMenuViewController hideMenuViewController];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont iconFontWithSize:18.0f];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.45f];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    NSArray *titles = @[@"Friends", @"Profile", @"Give Feedback", @"Tell a Friend", @"Rate Us"];
    NSArray *images = @[@"home", @"profile", @"mail", @"message", @"rate"];
    cell.textLabel.text = titles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    
    return cell;
}

#pragma mark - MFMailComposeViewDelegate methods
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    if (result == MFMailComposeResultSent) {
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
