//
//  PQStickerKeyboardView.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/21/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerKeyboardView.h"
#import "PQKeyboardPackCollectionViewCell.h"

#import "PQRequestingService.h"
#import "PQStickerPack.h"
#import "PQSticker.h"

@interface PQStickerKeyboardView()
@property (weak, nonatomic) IBOutlet UICollectionView *packsCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *stickersCollectionView;

@property (strong, nonatomic) NSArray *packs;
@property (strong, nonatomic) NSArray *stickers;

@property (strong, nonatomic) PQRequestingService *requestingService;

@property (strong, nonatomic) PQStickerPack *selectedPack;
@property (strong, nonatomic) PQSticker *selectedSticker;
@end

@implementation PQStickerKeyboardView

#pragma mark - Keyboard actions
- (void)configKeyboardWithStickerPacks:(NSArray *)packs
                              delegate:(id<PQStickerKeyboardDelegate>)delegate {
    _packsCollectionView.delegate = self;
    _stickersCollectionView.delegate = self;
    
    _packsCollectionView.dataSource = self;
    _stickersCollectionView.dataSource = self;
    
    _packsCollectionView.tag = 0;
    _stickersCollectionView.tag = 1;
    
    
    [_packsCollectionView registerNib:[PQKeyboardPackCollectionViewCell nib]
           forCellWithReuseIdentifier:[PQKeyboardPackCollectionViewCell reuseIdentifier]];
    [_stickersCollectionView registerNib:[PQKeyboardStickerCollectionViewCell nib]
              forCellWithReuseIdentifier:[PQKeyboardStickerCollectionViewCell reuseIdentifier]];
    
    _packs = packs;
    _delegate = delegate;

    _requestingService = [[PQRequestingService alloc] init];
}

- (void)reloadKeyboardUsingPacks:(NSArray *)packs {
    _packs = packs;
    [_packsCollectionView reloadData];
}


#pragma mark - Collection view delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == 0) { //pack
        return _packs.count;
    }
    else {
        return _stickers.count;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 0) { //pack
        PQStickerPack *pack = [_packs objectAtIndex:indexPath.row];
        _selectedPack = pack;
        if (![pack needToBeUpdated]) {
            _stickers = [pack.stickers valueForKey:@"self"];
            [_stickersCollectionView reloadData];
        }
        else {
            [pack downloadDataAndStickersUsingOperationQueue:[NSOperationQueue mainQueue]];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 0) { //pack
        PQStickerPack *pack = [_packs objectAtIndex:indexPath.row];
        PQKeyboardPackCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PQKeyboardPackCollectionViewCell reuseIdentifier] forIndexPath:indexPath];

        [cell configCellUsingStickerPack:pack];
        return cell;
    }
    else {
        PQSticker *sticker = [_stickers objectAtIndex:indexPath.row];
        PQKeyboardStickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PQKeyboardStickerCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
        [cell configCellUsingSticker:sticker
                            delegate:self];
        return cell;
    }
    return nil;
}


#pragma mark - Keyboard sticker cell delegates
- (void)didStartHoldingOnCell:(UICollectionViewCell *)cell {
    NSIndexPath *path = [_stickersCollectionView indexPathForCell:cell];
    [_delegate didStartHoldingOnSticker:[_stickers objectAtIndex:path.row]
                          ofStickerPack:_selectedPack];
}

- (void)didStopHoldingOnCell:(UICollectionViewCell *)cell {
    NSIndexPath *path = [_stickersCollectionView indexPathForCell:cell];
    [_delegate didStopHoldingOnSticker:[_stickers objectAtIndex:path.row]
                         ofStickerPack:_selectedPack];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
