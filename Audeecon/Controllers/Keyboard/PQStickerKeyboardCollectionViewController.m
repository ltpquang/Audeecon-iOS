//
//  PQStickerKeyboardCollectionViewController.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/9/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerKeyboardCollectionViewController.h"
#import "PQSticker.h"
#import "PQStickerPack.h"

@interface PQStickerKeyboardCollectionViewController ()
@property (nonatomic, strong) PQStickerPack *pack;
@property (nonatomic, strong) NSArray *stickers;
@property (nonatomic, weak) id<PQStickerKeyboardDelegate> stickerKeyboardDelegate;
@end

@implementation PQStickerKeyboardCollectionViewController

- (id)initWithStickerPack:(PQStickerPack *)pack
                 andFrame:(CGRect)frame
                 delegate:(id<PQStickerKeyboardDelegate>) stickerKeyboardDelegate {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:[PQKeyboardStickerCollectionViewCell cellSize]];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumLineSpacing:5.0];
    [flowLayout setMinimumInteritemSpacing:0.0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0, 4, 0, 4)];
    
    if (self = [super initWithCollectionViewLayout:flowLayout]) {
        _pack = pack;
        _stickers = [pack.stickers valueForKey:@"self"];
        _stickerKeyboardDelegate = stickerKeyboardDelegate;

        [self.view setFrame:frame];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    [self.collectionView setShowsVerticalScrollIndicator:NO];
    [self.collectionView registerNib:[PQKeyboardStickerCollectionViewCell nib]
          forCellWithReuseIdentifier:[PQKeyboardStickerCollectionViewCell reuseIdentifier]];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.stickers.count;
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PQSticker *sticker = [_stickers objectAtIndex:indexPath.row];
    PQKeyboardStickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PQKeyboardStickerCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    [cell configCellUsingSticker:sticker
                        delegate:self];
    return cell;
}

#pragma mark - PQ Keyboard Sticker Cell Delegate
- (void)didStartHoldingOnCell:(UICollectionViewCell *)cell
                  withGesture:(UIGestureRecognizer *)gesture {
    NSIndexPath *path = [self.collectionView indexPathForCell:cell];
    [self.stickerKeyboardDelegate didStartHoldingOnSticker:[self.stickers objectAtIndex:path.row]
                                               withGesture:gesture];
}

- (void)didStopHoldingOnCell:(UICollectionViewCell *)cell
                 withGesture:(UIGestureRecognizer *)gesture {
    NSIndexPath *path = [self.collectionView indexPathForCell:cell];
    [self.stickerKeyboardDelegate didStopHoldingOnSticker:[self.stickers objectAtIndex:path.row]
                                              withGesture:gesture];
}



#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
