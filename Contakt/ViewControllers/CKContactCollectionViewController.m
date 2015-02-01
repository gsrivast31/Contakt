//
//  CKContactCollectionViewController.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 17/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKContactCollectionViewController.h"
#import "CKQRCodeReaderViewController.h"
#import "KRLCollectionViewGridLayout.h"

#import "CKContactCollectionViewCell.h"
#import "CKConnectionView.h"
#import "CKCoreDataStack.h"
#import "CKAppDelegate.h"
#import "CKConnection.h"
#import <MessageUI/MessageUI.h>
#import "SVWebViewController.h"

@interface CKContactCollectionViewController () <NSFetchedResultsControllerDelegate, CKQRCodeReaderDelegate, UISearchBarDelegate, CKConnectionViewDelegate, MFMailComposeViewControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
{
    UISearchController* searchController;
    UIView* searchView;
    
    NSArray *searchResults;
}

@property(nonatomic, strong) NSFetchedResultsController* fetchedResultsController;

@end

@implementation CKContactCollectionViewController

static NSString * const reuseIdentifier = @"contactCell";

- (KRLCollectionViewGridLayout *)layout {
    return (id)self.collectionView.collectionViewLayout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    self.layout.numberOfItemsPerLine = floor(width/106.0f);
    self.layout.aspectRatio = 1;
    self.layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.layout.interitemSpacing = 10;
    self.layout.lineSpacing = 10;

    [self prepareSearchBar];
    self.collectionView.contentInset = UIEdgeInsetsMake(searchController.searchBar.frame.size.height, 5, 0, 5);
    self.collectionView.contentOffset = CGPointMake(0, -searchController.searchBar.frame.size.height);

    [self.fetchedResultsController performFetch:nil];
    
    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconListMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    [self.navigationItem setLeftBarButtonItem:menuBarButtonItem animated:NO];
    
    self.collectionView.backgroundColor = [UIColor colorFromHexCode:@"282F3B"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareSearchBar{
    if (!searchView) {
        CGFloat searchBarBoundsY = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        searchView = [[UIView alloc] initWithFrame:CGRectMake(0, searchBarBoundsY, [UIScreen mainScreen].bounds.size.width, 44)];
        searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        searchController.searchResultsUpdater = self;
        [searchController.searchBar sizeToFit];
        [searchView addSubview:searchController.searchBar];
        searchController.dimsBackgroundDuringPresentation = NO;
        searchController.delegate = self;
        searchController.searchBar.delegate = self;
        self.definesPresentationContext = YES;

        [self.view addSubview:searchView];
    }
    
    searchController.searchBar.tintColor = [UIColor colorFromHexCode:@"282F3B"];
    searchController.searchBar.barTintColor = [UIColor colorFromHexCode:@"282F3B"];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:[UIColor colorFromHexCode:@"343C4A"]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor turquoiseColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary
                                                                                                  dictionaryWithObjectsAndKeys:
                                                                                                  [UIColor turquoiseColor],
                                                                                                  NSForegroundColorAttributeName,
                                                                                                  nil]
                                                                                        forState:UIControlStateNormal];

}

- (void)performSearchWithText:(NSString *)searchText {
    NSString *regex = [NSString stringWithFormat:@".*?%@.*?", [searchText lowercaseString]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name MATCHES[cd] %@", regex];
    
    if(predicate) {
        NSMutableArray *newResults = [NSMutableArray array];
        if(self.fetchedResultsController && [[self.fetchedResultsController fetchedObjects] count]) {
            for(id<NSFetchedResultsSectionInfo> section in [self.fetchedResultsController sections]) {
                NSArray *matchingObjects = [[section objects] filteredArrayUsingPredicate:predicate];
                if(matchingObjects && [matchingObjects count]) {
                    [newResults addObject:matchingObjects];
                }
            }
            
            searchResults = newResults;
            return;
        }
    }
    
    searchResults = nil;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchController setActive:NO];
}

#pragma mark - UISearchControllerDelegate

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchViewController {
    [self performSearchWithText:searchViewController.searchBar.text];
    [self.collectionView reloadData];
}

#pragma mark CKQRCodeReaderDelegate

- (void)didReadQRCode:(NSString *)string {
    CKContact* contact = [CKHelper deserialize:string];
    NSLog(@"%@", contact.guid);
    [[CKCoreDataStack defaultStack] saveContext];
    
    [self.collectionView reloadData];
}

#pragma mark

- (IBAction)addContact:(id)sender {
    CKQRCodeReaderViewController* vc = [[CKQRCodeReaderViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(searchController.isActive == NO) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
    } else {
        return [[searchResults objectAtIndex:section] count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CKContactCollectionViewCell *cell = (CKContactCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    CKContact* contact = nil;
    if (searchController.isActive == NO) {
        contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        NSArray *section = [searchResults objectAtIndex:indexPath.section];
        contact = (CKContact *)[section objectAtIndex:indexPath.row];
    }

    [cell configureCellForContact:contact];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if(searchController.isActive == NO) {
        return [[self.fetchedResultsController sections] count];
    } else {
        return [searchResults count];
    }
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CKContact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [CKConnectionView presentInView:self.view withContact:contact withDelegate:self];
}

#pragma mark NSFetchedResultsControllerDelegate

- (NSFetchRequest *)entryListFetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CKContact"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    return fetchRequest;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    CKCoreDataStack *coreDataStack = [CKCoreDataStack defaultStack];
    NSFetchRequest *fetchRequest = [self entryListFetchRequest];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:coreDataStack.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
            
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];
            
        } else {
            
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in _objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
}

/*#pragma mark - observer
- (void)addObservers{
    [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}
- (void)removeObservers{
    [self.collectionView removeObserver:self forKeyPath:@"contentOffset" context:Nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UICollectionView *)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"] && object == self.collectionView ) {
        
        self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x,
                                          (-1* object.contentOffset.y)-self.searchBar.frame.size.height,
                                          self.searchBar.frame.size.width,
                                          self.searchBar.frame.size.height);
    }
}*/

#pragma mark CKConnectionViewDelegate

- (void)didTapButton:(NSInteger)type forContact:(CKContact *)contact {
    NSDictionary* dict = [CKHelper connectionDictionary:contact];

    if (type == CKEmailType) {
        NSString *email = [(CKConnection*)[dict objectForKey:kEmailString] value];
        if([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
            [mailController setMailComposeDelegate:self];
            [mailController setModalPresentationStyle:UIModalPresentationFormSheet];
            [mailController setToRecipients:@[email]];
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
    } else if (type == CKPhoneType) {
        NSString *phone = [(CKConnection*)[dict objectForKey:kPhoneString] value];
        if ([CKHelper isStringValid:phone]) {
            NSString* phoneNumber = [@"tel://" stringByAppendingString:phone];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        }
    } else if (type == CKFacebookType) {
        NSString* fbId = [(CKConnection*)[dict objectForKey:kFacebookString] value];
        NSURL* fbURL = [NSURL URLWithString:[@"fb://profile/" stringByAppendingString:fbId]];
        if ([CKHelper isStringValid:fbId] && [[UIApplication sharedApplication] canOpenURL:fbURL]) {
            [[UIApplication sharedApplication] openURL:fbURL];
        } else {
            NSString* fbProfile = [(CKConnection*)[dict objectForKey:kFacebookString] profileUrl];
            if ([CKHelper isStringValid:fbProfile]) {
                SVWebViewController* vc = [[SVWebViewController alloc] initWithAddress:fbProfile];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    } else if (type == CKTwitterType) {
        NSString* twitterId = [(CKConnection*)[dict objectForKey:kTwitterString] value];
        NSURL* twitterURL = [NSURL URLWithString:[@"twitter://user?id=" stringByAppendingString:twitterId]];
        if ([CKHelper isStringValid:twitterId] && [[UIApplication sharedApplication] canOpenURL:twitterURL]) {
            [[UIApplication sharedApplication] openURL:twitterURL];
        } else {
            NSString* twitterProfile = [(CKConnection*)[dict objectForKey:kTwitterString] profileUrl];
            if ([CKHelper isStringValid:twitterProfile]) {
                SVWebViewController* vc = [[SVWebViewController alloc] initWithAddress:twitterProfile];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    } else if (type == CKPhoneType) {
        NSString* linkedinId = [(CKConnection*)[dict objectForKey:kLinkedInString] value];
        NSURL* linkedInURL = [NSURL URLWithString:[@"linkedin://#profile/" stringByAppendingString:linkedinId]];
        if ([CKHelper isStringValid:linkedinId] && [[UIApplication sharedApplication] canOpenURL:linkedInURL]) {
            [[UIApplication sharedApplication] openURL:linkedInURL];
        } else {
            NSString* linkedinProfile = [(CKConnection*)[dict objectForKey:kLinkedInString] profileUrl];
            if ([CKHelper isStringValid:linkedinProfile]) {
                SVWebViewController* vc = [[SVWebViewController alloc] initWithAddress:linkedinProfile];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
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
