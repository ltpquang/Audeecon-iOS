//
//  PQStickerKeyboardView.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/21/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerKeyboardView.h"
#import "PQKeyboardPackCollectionViewCell.h"
#import "PQStickerKeyboardCollectionViewController.h"

#import "PQRequestingService.h"
#import "PQStickerPack.h"
#import "PQSticker.h"

@interface PQStickerKeyboardView()
@property (weak, nonatomic) IBOutlet UICollectionView *packsCollectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *stickersScrollView;

@property (strong, nonatomic) NSArray *packs;
@property (strong, nonatomic) NSMutableArray *keyboardCollectionViews;

@property (strong, nonatomic) PQStickerPack *selectedPack;
@property (strong, nonatomic) PQSticker *selectedSticker;
@end

@implementation PQStickerKeyboardView

#pragma mark - Keyboard actions
- (void)configKeyboardWithStickerPacks:(NSArray *)packs
                              delegate:(id<PQStickerKeyboardDelegate>)delegate {
    // config pack collection view
    _packsCollectionView.delegate = self;
    _packsCollectionView.dataSource = self;
    _packsCollectionView.tag = 0;
    [_packsCollectionView registerNib:[PQKeyboardPackCollectionViewCell nib]
           forCellWithReuseIdentifier:[PQKeyboardPackCollectionViewCell reuseIdentifier]];
    
    //config data
    _packs = packs;
    _delegate = delegate;
    
    // config scroll view
    [_stickersScrollView setDelegate:self];
    CGSize scrollSize = self.stickersScrollView.frame.size;
    self.stickersScrollView.contentSize = CGSizeMake(scrollSize.width * (CGFloat)packs.count, scrollSize.height);
    
    _keyboardCollectionViews = [NSMutableArray new];
    for (int i = 0; i < packs.count; ++i) {
        CGRect frame = self.stickersScrollView.bounds;
        frame.origin.x = frame.size.width * (CGFloat)i;
        frame.origin.y = 0.0;
        PQStickerKeyboardCollectionViewController *keyboard = [[PQStickerKeyboardCollectionViewController alloc]
                                                               initWithStickerPack:[packs objectAtIndex:i]
                                                               andFrame:frame
                                                               delegate:delegate];
        [_keyboardCollectionViews addObject:keyboard];
        [self.stickersScrollView addSubview:keyboard.view];
    }
    

    
    
    
    [self.packsCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                           animated:YES
                                     scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self collectionView:self.packsCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)reloadKeyboardUsingPacks:(NSArray *)packs {
    _packs = packs;
    //[_packsCollectionView reloadData];
    [self configKeyboardWithStickerPacks:packs delegate:self.delegate];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat width = scrollView.frame.size.width;
    NSInteger index = floor((scrollView.contentOffset.x - width / 2) / width) + 1;
    [self.packsCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                           animated:NO
                                     scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

#pragma mark - Collection view delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _packs.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 0) { //pack
        PQStickerPack *pack = [_packs objectAtIndex:indexPath.row];
        _selectedPack = pack;
        if (![pack needToBeUpdated]) {
            CGRect frame = self.stickersScrollView.frame;
            frame.origin.x = frame.size.width * indexPath.row;
            frame.origin.y = 0;
            [self.stickersScrollView scrollRectToVisible:frame animated:YES];
        }
        else {
            [pack downloadDataAndStickersUsingOperationQueue:[NSOperationQueue mainQueue]];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PQStickerPack *pack = [_packs objectAtIndex:indexPath.row];
    PQKeyboardPackCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PQKeyboardPackCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    
    [cell configCellUsingStickerPack:pack];
    return cell;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
