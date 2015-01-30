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
#import "FlatUIKit.h"

@interface CKContactCollectionViewController () <NSFetchedResultsControllerDelegate, CKQRCodeReaderDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
{
    UISearchController* searchController;
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
    
    // Register cell classes
    //[self.collectionView registerClass:[CKContactCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    
    self.layout.numberOfItemsPerLine = floor(width/106.0f);
    self.layout.aspectRatio = 1;
    self.layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.layout.interitemSpacing = 10;
    self.layout.lineSpacing = 10;
    
    [self.fetchedResultsController performFetch:nil];
    
    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconListMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    [self.navigationItem setLeftBarButtonItem:menuBarButtonItem animated:NO];
    
    self.collectionView.backgroundColor = [UIColor colorFromHexCode:@"282F3B"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark CKQRCodeReaderDelegate

- (void)didReadQRCode:(NSString *)string {
    CKContact* contact = [CKHelper deserialize:string];
    contact.guid = [CKHelper generateUniqueGuid];
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CKContactCollectionViewCell *cell = (CKContactCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    CKContact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [cell configureCellForContact:contact];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CKContact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //CKFullContactViewController* vc = (CKFullContactViewController*)[CKHelper viewControllerWithId:@"fullContactViewController"];
    //vc.contact = contact;
    //[self presentViewController:vc animated:YES completion:nil];
    CKAppDelegate *delegate = (CKAppDelegate*)[[UIApplication sharedApplication] delegate];
    //CKContactView* contactView = [CKContactView presentInView:delegate.window.rootViewController.view withContact:contact];
    CKConnectionView* view = [CKConnectionView presentInView:delegate.window.rootViewController.view withContact:contact];
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

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchController setActive:NO];
}

#pragma mark - UISearchControllerDelegate

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchViewController {
    //[self performSearchWithText:searchViewController.searchBar.text];
    [self.collectionView reloadData];
}


@end
