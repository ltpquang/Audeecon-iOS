//
//  PQStoreViewController.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/4/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStoreViewController.h"
#import "PQStickerTableViewController.h"
#import "AppDelegate.h"
#import "PQStickerPackDownloadOperation.h"
#import "PQStickerPack.h"
#import "PQSticker.h"
#import "PQRequestingService.h"

@interface PQStoreViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) NSArray *stickerTableViewControllers;
@property (strong, nonatomic) UIViewController *activeViewController;
@end

@implementation PQStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"did load");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"did appear");
    [self segmentedControlValueChanged:self.segmentedControl];
}


- (NSArray *)stickerTableViewControllers {
    if (_stickerTableViewControllers == nil) {
        PQStickerTableViewController *allStickers = [self.storyboard instantiateViewControllerWithIdentifier:@"StickerTableView"];
        [allStickers configForOnlineStore:YES];
        PQStickerTableViewController *yoursStickers = [self.storyboard instantiateViewControllerWithIdentifier:@"StickerTableView"];
        [yoursStickers configForOnlineStore:NO];
        
        _stickerTableViewControllers = @[allStickers, yoursStickers];
    }
    return _stickerTableViewControllers;
}

- (IBAction)closeButtonTUI:(id)sender {
    //
//    NSArray *packs = [[[self appDelegate] globalContainer] stickerPacks];
//    NSOperationQueue *queue = [[[self appDelegate] globalContainer] stickerPackDownloadQueue];
//    //PQRequestingService *requestingService = [PQRequestingService new];
//    PQStickerPack *pack = [packs objectAtIndex:0];
//    
//    [pack downloadDataAndStickersUsingOperationQueue:queue];
//    
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender {
    
    [self.activeViewController removeFromParentViewController];
    [self.activeViewController.view removeFromSuperview];
    
    self.activeViewController = self.stickerTableViewControllers[self.segmentedControl.selectedSegmentIndex];
    
    [self addChildViewController:self.activeViewController];
    [self.view addSubview:self.activeViewController.view];
    
}

#pragma mark - App utilities
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
