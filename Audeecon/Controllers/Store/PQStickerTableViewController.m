//
//  PQStickerTableViewController.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/4/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerTableViewController.h"
#import "PQRequestingService.h"
#import "PQStickerPackTableViewCell.h"
#import "PQStickerPack.h"
#import "AppDelegate.h"
#import "PQCurrentUser.h"

@interface PQStickerTableViewController ()
// Data
@property BOOL forOnlineStore;
@property (strong, nonatomic) NSArray *stickerPacks;
@property (strong, nonatomic) PQRequestingService *requestingService;


@end

@implementation PQStickerTableViewController
- (void)configForOnlineStore:(BOOL)forOnlineStore {
    _forOnlineStore = forOnlineStore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupUI];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_stickerPacks.count != 0) return;
    [self start];
}

- (void)start {
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl.frame.size.height) animated:YES];
    [self refresh];
}

#pragma mark - App utilities
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Setup data
- (void)setupData {
    _stickerPacks = [NSArray new];
    _requestingService = [PQRequestingService new];
}

#pragma mark - Setup UI

- (void)setupRefreshControl {
    self.refreshControl = [UIRefreshControl new];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)setupUI {
    self.title = @"Stickers";
    [self setupRefreshControl];
    [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
}

#pragma mark - Refresh control delegate
- (void)refresh {
    NSString *username = self.forOnlineStore ? @"" : [[[self appDelegate] currentUser] username];
    if (self.forOnlineStore) {
        [self.requestingService getAllStickerPacksForUser:username
                                                  success:^(NSArray *result) {
                                                      //
                                                      [[self appDelegate] globalContainer].stickerPacks = result;
                                                      self.stickerPacks = [self updateStickerPacksArray:[result mutableCopy]
                                                                                 usingStickerPacksArray:[[[self appDelegate] globalContainer] stickerPacks]];
                                                      [self.tableView reloadData];
                                                      [self.refreshControl endRefreshing];
                                                  }
                                                  failure:^(NSError *error) {
                                                      //
                                                      [self.refreshControl endRefreshing];
                                                  }];
    }
    else {
        self.stickerPacks = [[[self appDelegate] globalContainer] stickerPacks];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }
}
#pragma mark - Utilities
- (NSArray *)updateStickerPacksArray:(NSMutableArray *)packs
              usingStickerPacksArray:(NSArray *)ownedPacks {
    NSMutableDictionary *idsAndPacks = [NSMutableDictionary new];
    for (PQStickerPack *pack in ownedPacks) {
        idsAndPacks[pack.packId] = pack;
    }
    NSArray *keyArray = [idsAndPacks allKeys];
    for (int i = 0; i < packs.count; ++i) {
        PQStickerPack *pack = packs[i];
        if ([keyArray containsObject:pack.packId]) {
            [packs replaceObjectAtIndex:i withObject:idsAndPacks[pack.packId]];
        }
    }
    return packs;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stickerPacks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PQStickerPackTableViewCell *cell = (PQStickerPackTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"StickerPackCell" forIndexPath:indexPath];
    
    NSArray *stickers = self.stickerPacks;
    
    [cell configCellUsingStickerPack:(PQStickerPack *)[stickers objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)computePackDescriptionHeightWithText:(NSString *)description {
    
    CGRect bound = [description boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width - 28, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]}
                                             context:nil];
    return bound.size.height;// + 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *stickers = self.stickerPacks;
    CGFloat descriptionHeight = [self computePackDescriptionHeightWithText:[[stickers objectAtIndex:indexPath.row] packDescription]];
    return descriptionHeight + 88;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSArray *stickers = _isSearching ? _searchResultStickerPacks : _stickerPacks;
//    _selectedPack = [stickers objectAtIndex:indexPath.row];
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    [self performSegueWithIdentifier:@"GoToStickerPackSegue" sender:self];
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
