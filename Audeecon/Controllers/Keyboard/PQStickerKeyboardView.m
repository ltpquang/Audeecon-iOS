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
@property (strong, nonatomic) IBOutlet UICollectionView *packsCollectionView;
@property (strong, nonatomic) IBOutlet UIScrollView *stickersScrollView;

@property (strong, nonatomic) IBOutlet UISwitch *modeSwitch;
@property (strong, nonatomic) IBOutlet UIView *topHorizontalHairline;
@property (strong, nonatomic) IBOutlet UIView *middleHorizontalHairline;
@property (strong, nonatomic) IBOutlet UIView *middleVerticalHairline;

@property (strong, nonatomic) IBOutlet UIImageView *mainRecommendationImageView;
@property (strong, nonatomic) IBOutlet UIImageView *upComingRecommendationImageView;

// Data
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
    
    
    
    
    if ([[(PQStickerPack *)packs[0] thumbnailData] length] != 0) {
        [self.packsCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                               animated:YES
                                         scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
    
    [self updateLayoutForNormalLayout];
    //[self updateLayoutForAutoRecommendationLayout];
    
}

- (void)reloadKeyboardUsingPacks:(NSArray *)packs {
    _packs = packs;
    [self configKeyboardWithStickerPacks:packs delegate:self.delegate];
    [self.packsCollectionView reloadData];
    
    [self.packsCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                           animated:YES
                                     scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (void)removeAllConstraints {
    NSArray *views = @[self.packsCollectionView,
                       self.stickersScrollView,
                       self.modeSwitch,
                       self.topHorizontalHairline,
                       self.middleHorizontalHairline,
                       self.middleVerticalHairline,
                       self.mainRecommendationImageView,
                       self.upComingRecommendationImageView];
    for (UIView *view in views) {
        [view removeConstraints:view.constraints];
        [view removeFromSuperview];
    }
    [self removeConstraints:self.constraints];
}

- (void)updateLayoutForAutoRecommendationLayout {
    [self removeAllConstraints];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self addSubview:self.mainRecommendationImageView];
    [self addSubview:self.upComingRecommendationImageView];
    
    [self addSubview:self.modeSwitch];
    [self addSubview:self.topHorizontalHairline];
    [self addSubview:self.middleHorizontalHairline];
    [self addSubview:self.middleVerticalHairline];
    
    [self setConstraintsForAutoRecommendationLayout];
    
    [self finishUpdateConstraints];
    
    
    self.upComingRecommendationImageView.image = [(PQStickerPack *)self.packs[0] thumbnailImage];
    self.mainRecommendationImageView.image = [(PQStickerPack *)self.packs[1] thumbnailImage];
}

- (void)updateLayoutForNormalLayout {
    [self removeAllConstraints];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self addSubview:self.packsCollectionView];
    [self addSubview:self.stickersScrollView];
    
    [self addSubview:self.modeSwitch];
    [self addSubview:self.topHorizontalHairline];
    [self addSubview:self.middleHorizontalHairline];
    [self addSubview:self.middleVerticalHairline];
    
    [self setConstraintsForNormalLayout];
    
    [self finishUpdateConstraints];
}

- (void)setConstraintsForAutoRecommendationLayout {
    
    CGFloat switchWidth = 51.0; //self.modeSwitch.frame.size.width;
    CGFloat switchHeight = 31.0; //self.modeSwitch.frame.size.height;
    // Switch leading
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.modeSwitch
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                                 constant:2.0]];
    // Switch bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.modeSwitch
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                      constant:2.0]];
    // Switch width
    [self.modeSwitch addConstraint:[NSLayoutConstraint constraintWithItem:self.modeSwitch
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0
                                                                 constant:switchWidth]];
    // Switch height
    [self.modeSwitch addConstraint:[NSLayoutConstraint constraintWithItem:self.modeSwitch
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0
                                                                 constant:switchHeight]];
    // Middle horizontal hairline height
    [self.middleHorizontalHairline addConstraint:[NSLayoutConstraint constraintWithItem:self.middleHorizontalHairline
                                                                              attribute:NSLayoutAttributeHeight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:nil
                                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                                             multiplier:1.0
                                                                               constant:1.0]];
    // Middle horizontal hairline width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.middleHorizontalHairline
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:switchWidth]];
    // Middle horizontal hairline left
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.middleHorizontalHairline
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:2.0]];
    // Middle horizontal hairline bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.middleHorizontalHairline
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:switchHeight + 4.0]];
    // Middle vertical hairline width
    [self.middleVerticalHairline addConstraint:[NSLayoutConstraint constraintWithItem:self.middleVerticalHairline
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0
                                                                             constant:1.0]];
    // Middle vertical hairline bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.middleVerticalHairline
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // Middle vertical hairline left
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.middleVerticalHairline
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.middleHorizontalHairline
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0
                                                      constant:2.0]];
    // Middle vertical hairline height
    [self.middleVerticalHairline addConstraint:[NSLayoutConstraint constraintWithItem:self.middleVerticalHairline
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:switchWidth]];
    // Up coming recommendation image view height
    [self.upComingRecommendationImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.upComingRecommendationImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:0.0
                                                      constant:switchHeight]];
    // Up coming recommendation image view width
    [self.upComingRecommendationImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.upComingRecommendationImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:0.0
                                                      constant:switchHeight]];
    // Up comming recommendation image view horizontal center
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.upComingRecommendationImageView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.middleHorizontalHairline
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    // Up coming recommendation image view bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.middleHorizontalHairline
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.upComingRecommendationImageView
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0
                                                                             constant:2.0]];
    
    // Top horizontal hairline height
    [self.topHorizontalHairline addConstraint:[NSLayoutConstraint constraintWithItem:self.topHorizontalHairline
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:1.0]];
    // Top horizontal hairline left
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topHorizontalHairline
                                                                           attribute:NSLayoutAttributeLeading
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeLeading
                                                                          multiplier:1.0
                                                                            constant:0.0]];
    // Top horizontal hairline top
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topHorizontalHairline
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1.0
                                                                            constant:0.0]];
    // Top horizontal hairline right
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topHorizontalHairline
                                                                           attribute:NSLayoutAttributeTrailing
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeTrailing
                                                                          multiplier:1.0
                                                                            constant:0.0]];
    // Top horizontal hairline bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.upComingRecommendationImageView
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.topHorizontalHairline
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1.0
                                                                            constant:2.0]];
    // Main recommendation image width
    [self.mainRecommendationImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.mainRecommendationImageView
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.mainRecommendationImageView
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                multiplier:1.0
                                                                                  constant:0.0]];
    // Main recommendatioin image top
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mainRecommendationImageView
                                                                                 attribute:NSLayoutAttributeTop
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.topHorizontalHairline
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0
                                                                                  constant:2.0]];
    // Main recommendatioin image bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.mainRecommendationImageView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:2.0]];
    // Main recommendatioin image horizontal center
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mainRecommendationImageView
                                                                                 attribute:NSLayoutAttributeCenterX
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self
                                                                                 attribute:NSLayoutAttributeCenterX
                                                                                multiplier:1.0
                                                                                  constant:0.0]];
}

- (void)setConstraintsForNormalLayout {
    
    CGFloat switchWidth = 51.0; //self.modeSwitch.frame.size.width;
    CGFloat switchHeight = 31.0; //self.modeSwitch.frame.size.height;
    // Switch leading
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.modeSwitch
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                                 constant:2.0]];
    // Switch bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.modeSwitch
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:2.0]];
    // Switch width
    [self.modeSwitch addConstraint:[NSLayoutConstraint constraintWithItem:self.modeSwitch
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0
                                                                 constant:switchWidth]];
    // Switch height
    [self.modeSwitch addConstraint:[NSLayoutConstraint constraintWithItem:self.modeSwitch
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0
                                                                 constant:switchHeight]];
    // Middle horizontal hairline height
    [self.middleHorizontalHairline addConstraint:[NSLayoutConstraint constraintWithItem:self.middleHorizontalHairline
                                                                              attribute:NSLayoutAttributeHeight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:nil
                                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                                             multiplier:1.0
                                                                               constant:1.0]];
    // Middle horizontal hairline right
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                              attribute:NSLayoutAttributeTrailing
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.middleHorizontalHairline
                                                                              attribute:NSLayoutAttributeTrailing
                                                                             multiplier:1.0
                                                                               constant:2.0]];
    // Middle horizontal hairline left
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.middleHorizontalHairline
                                                                              attribute:NSLayoutAttributeLeading
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeLeading
                                                                             multiplier:1.0
                                                                               constant:2.0]];
    // Middle horizontal hairline bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.modeSwitch
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.middleHorizontalHairline
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1.0
                                                                               constant:2.0]];
    // Middle vertical hairline width
    [self.middleVerticalHairline addConstraint:[NSLayoutConstraint constraintWithItem:self.middleVerticalHairline
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0
                                                                             constant:1.0]];
    // Middle vertical hairline bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.middleVerticalHairline
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0
                                                                             constant:2.0]];
    
    // Middle vertical hairline left
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.middleVerticalHairline
                                                                            attribute:NSLayoutAttributeLeading
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeLeading
                                                                           multiplier:1.0
                                                                             constant:switchWidth + 4.0]];
    // Middle vertical hairline top
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.middleVerticalHairline
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.middleHorizontalHairline
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0
                                                                             constant:2.0]];
    // Pack collection view left
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.packsCollectionView
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.middleVerticalHairline
                                                                         attribute:NSLayoutAttributeTrailing
                                                                        multiplier:1.0
                                                                          constant:2.0]];
    // Pack collection view top
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.packsCollectionView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.middleHorizontalHairline
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0
                                                                          constant:0.0]];
    // Pack collection view right
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeTrailing
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.packsCollectionView
                                                                         attribute:NSLayoutAttributeTrailing
                                                                        multiplier:1.0
                                                                          constant:2.0]];
    // Pack collection view bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.packsCollectionView
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0
                                                                          constant:0.0]];
    // Sticker scroll view left
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.stickersScrollView
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeLeading
                                                                       multiplier:1.0
                                                                         constant:2.0]];
    // Sticker scroll view right
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.stickersScrollView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1.0
                                                                         constant:2.0]];
    // Sticker scroll view bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.middleHorizontalHairline
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.stickersScrollView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:2.0]];
    // Sticker scroll view height
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.stickersScrollView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.modeSwitch
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:6.0
                                                                         constant:0.0]];
    // Top horizontal hairline height
    [self.topHorizontalHairline addConstraint:[NSLayoutConstraint constraintWithItem:self.topHorizontalHairline
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:1.0]];
    // Top horizontal hairline left
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topHorizontalHairline
                                                                           attribute:NSLayoutAttributeLeading
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeLeading
                                                                          multiplier:1.0
                                                                            constant:0.0]];
    // Top horizontal hairline top
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topHorizontalHairline
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1.0
                                                                            constant:0.0]];
    // Top horizontal hairline right
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                           attribute:NSLayoutAttributeTrailing
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.topHorizontalHairline
                                                                           attribute:NSLayoutAttributeTrailing
                                                                          multiplier:1.0
                                                                            constant:0.0]];
    // Top horizontal hairline bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.stickersScrollView
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.topHorizontalHairline
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1.0
                                                                            constant:2.0]];
}

- (void)finishUpdateConstraints {
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self.delegate didChangeLayout];
}

- (IBAction)modeSwitchValueChanged:(UISwitch *)sender {
    
    if ([sender isOn]) {
        [self updateLayoutForAutoRecommendationLayout];
    }
    else {
        [self updateLayoutForNormalLayout];
    }
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
    PQStickerPack *pack = [self.packs objectAtIndex:indexPath.row];
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
