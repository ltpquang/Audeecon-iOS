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
#import "AppDelegate.h"
#import "PQCurrentUser.h"
#import "PQNotificationNameFactory.h"

@interface PQStickerKeyboardView()
// Top hairline
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topHairlineHeight;   //
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topHairlineLeft;     //
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topHairlineTop;      //
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topHairlineRight;    //
// Scroll view
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewLeft;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewRight;
// Middle hairline
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *middleHairlineHeight;    //
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *middleHairlineTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *middleHairlineRight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *middleHairlineLeft;      //
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *middleHairlineBottom;      //
// Left hairline
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftHairlineHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftHairlineWidth;   //
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftHairlineBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftHairlineTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftHairlineLeft;    //
// Store button
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *storeButtonHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *storeButtonWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *storeButtonRight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *storeButtonCenterY;
// Right hairline
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightHairlineEqualWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightHairlineCenterY;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightHairlineEqualHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightHairlineRight;
// Switch
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *switchCenterY;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *switchLeft;      //
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *switchWidth;     //
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *switchHeight;    //
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *switchTop;
// Collection view
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewRight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewLeft;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewBottom;



@property (strong, nonatomic) IBOutlet UICollectionView *packsCollectionView;
@property (strong, nonatomic) IBOutlet UIScrollView *stickersScrollView;

@property (strong, nonatomic) IBOutlet UISwitch *modeSwitch;
@property (strong, nonatomic) IBOutlet UIView *topHorizontalHairline;
@property (strong, nonatomic) IBOutlet UIView *middleHorizontalHairline;
@property (strong, nonatomic) IBOutlet UIView *leftVerticalHairline;
@property (strong, nonatomic) IBOutlet UIView *rightVerticalHairline;

@property (strong, nonatomic) IBOutlet UIImageView *mainRecommendationImageView;
@property (strong, nonatomic) IBOutlet UIImageView *upComingRecommendationImageView;

@property (strong, nonatomic) IBOutlet UIButton *storeButton;
// Data
@property (strong, nonatomic) NSArray *packs;
@property (strong, nonatomic) NSMutableArray *keyboardCollectionViews;

@property (strong, nonatomic) PQStickerPack *selectedPack;
@property (strong, nonatomic) PQSticker *selectedSticker;
@end

@implementation PQStickerKeyboardView
#pragma mark - App utilities
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (NSArray *)ownedStickerPacks {
    return [[[[self appDelegate] currentUser] ownedStickerPack] valueForKey:@"self"];
}

#pragma mark - Keyboard actions
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configKeyboard {
    // config pack collection view
    _packsCollectionView.delegate = self;
    _packsCollectionView.dataSource = self;
    _packsCollectionView.scrollsToTop = NO;
    [_packsCollectionView registerNib:[PQKeyboardPackCollectionViewCell nib]
           forCellWithReuseIdentifier:[PQKeyboardPackCollectionViewCell reuseIdentifier]];
    
    [_stickersScrollView setDelegate:self];
    [_stickersScrollView setScrollsToTop:NO];
    
    [self updateStickerPacks];
    
    [self updateLayoutForNormalLayout];
   // [self updateLayoutForAutoRecommendationLayout];
    [self setupLongPressRecognizerForMainRecommendationImageView];
    [self registerForNotification];
}

- (void)updateStickerPacks {
    //config data
    self.packs = [self ownedStickerPacks];
    
    [self.stickersScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // config scroll view
    CGSize scrollSize = self.stickersScrollView.frame.size;
    self.stickersScrollView.contentSize = CGSizeMake(scrollSize.width * (CGFloat)self.packs.count, scrollSize.height);
    
    self.keyboardCollectionViews = [NSMutableArray new];
    for (int i = 0; i < self.packs.count; ++i) {
        CGRect frame = self.stickersScrollView.bounds;
        frame.origin.x = frame.size.width * (CGFloat)i;
        frame.origin.y = 0.0;
        if ([[(PQStickerPack *)self.packs[i] thumbnailData] length] != 0) {
            PQStickerKeyboardCollectionViewController *keyboard = [[PQStickerKeyboardCollectionViewController alloc]
                                                                   initWithStickerPack:self.packs[i]
                                                                   andFrame:frame];
            
            [self.keyboardCollectionViews addObject:keyboard];
            [self.stickersScrollView addSubview:keyboard.view];
        }
        else {
            UIView *dummy = [[UIView alloc] initWithFrame:frame];
            [self.stickersScrollView addSubview:dummy];
        }
    }
    [self.packsCollectionView reloadData];
    [self updateKeyboardDelegates:self.delegate];
}

- (void)setDelegate:(id<PQStickerKeyboardDelegate>)delegate {
    _delegate = delegate;
    [self updateKeyboardDelegates:delegate];
}

- (void)updateKeyboardDelegates:(id<PQStickerKeyboardDelegate>)delegate {
    for (PQStickerKeyboardCollectionViewController *keyboard in self.keyboardCollectionViews) {
        [keyboard setStickerKeyboardDelegate:delegate];
    }
}

- (void)registerForNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(packDownloadCompleteHandler:)
                                                 name:[PQNotificationNameFactory stickerPackCompletedDownloading]
                                               object:nil];
}

- (void)packDownloadCompleteHandler:(NSNotification *)noti {
    [self updateStickerPacks];
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


- (void)addToSuperview:(UIView *)superview {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [superview addSubview:self];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:superview
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:superview
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:superview
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self finishUpdateConstraints];
}

- (void)setupLongPressRecognizerForMainRecommendationImageView {
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                      action:@selector(longPressHandler:)];
    [longPressRecognizer setMinimumPressDuration:0.25];
    [self.mainRecommendationImageView addGestureRecognizer:longPressRecognizer];
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            //
            [self.delegate didStartHoldingOnSticker:nil withGesture:gesture];
            break;
        case UIGestureRecognizerStateEnded:
            //
            [self.delegate didStopHoldingOnSticker:nil withGesture:gesture];
            break;
        default:
            break;
    }
}

- (void)removeAllConstraints {
    NSArray *views = @[self.packsCollectionView,
                       self.stickersScrollView,
                       self.modeSwitch,
                       self.topHorizontalHairline,
                       self.middleHorizontalHairline,
                       self.leftVerticalHairline,
                       self.rightVerticalHairline,
                       self.mainRecommendationImageView,
                       self.upComingRecommendationImageView,
                       self.storeButton];
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
    [self addSubview:self.leftVerticalHairline];
    
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
    [self addSubview:self.rightVerticalHairline];
    [self addSubview:self.storeButton];
    
    [self addSubview:self.modeSwitch];
    [self addSubview:self.topHorizontalHairline];
    [self addSubview:self.middleHorizontalHairline];
    [self addSubview:self.leftVerticalHairline];
    
    [self setConstraintsForNormalLayout];
    
    [self finishUpdateConstraints];
}

- (void)setConstraintsForAutoRecommendationLayout {
    // Top hairline
    [self.topHorizontalHairline addConstraint:self.topHairlineHeight];
    [self addConstraint:self.topHairlineLeft];
    [self addConstraint:self.topHairlineRight];
    [self addConstraint:self.topHairlineTop];
    
    // Main recommendation image
    [self.mainRecommendationImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.mainRecommendationImageView
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:66.0]];
    [self.mainRecommendationImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.mainRecommendationImageView
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:66.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mainRecommendationImageView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.topHorizontalHairline
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:2.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.mainRecommendationImageView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:2.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.mainRecommendationImageView
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // Left hairline
    [self.leftVerticalHairline addConstraint:self.leftHairlineWidth];
    [self addConstraint:self.leftHairlineLeft];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftVerticalHairline
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.topHorizontalHairline
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:15.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.leftVerticalHairline
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // Middle hairline
    [self.middleHorizontalHairline addConstraint:self.middleHairlineHeight];
    [self addConstraint:self.middleHairlineBottom];
    [self addConstraint:self.middleHairlineLeft];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftVerticalHairline
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.middleHorizontalHairline
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0
                                                      constant:2.0]];
    
    // Switch
    [self.modeSwitch addConstraint:self.switchHeight];
    [self.modeSwitch addConstraint:self.switchWidth];
    [self addConstraint:self.switchLeft];
    [self addConstraint:self.switchTop];
    
    // Up coming recommendation
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.upComingRecommendationImageView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:2.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftVerticalHairline
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.upComingRecommendationImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0
                                                      constant:2.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.upComingRecommendationImageView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.topHorizontalHairline
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:1.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.middleHorizontalHairline
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.upComingRecommendationImageView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:1.0]];
}

- (void)setConstraintsForNormalLayout {
    [self.topHorizontalHairline addConstraint:self.topHairlineHeight];
    [self.stickersScrollView addConstraint:self.scrollViewHeight];
    [self.middleHorizontalHairline addConstraint:self.middleHairlineHeight];
    [self.leftVerticalHairline addConstraint:self.leftHairlineHeight];
    [self.leftVerticalHairline addConstraint:self.leftHairlineWidth];
    [self.storeButton addConstraint:self.storeButtonHeight];
    [self.storeButton addConstraint:self.storeButtonWidth];
    [self.modeSwitch addConstraint:self.switchWidth];
    [self.modeSwitch addConstraint:self.switchHeight];
    [self addConstraint:self.topHairlineLeft];
    [self addConstraint:self.topHairlineTop];
    [self addConstraint:self.topHairlineRight];
    [self addConstraint:self.scrollViewRight];
    [self addConstraint:self.scrollViewTop];
    [self addConstraint:self.scrollViewLeft];
    [self addConstraint:self.middleHairlineTop];
    [self addConstraint:self.middleHairlineRight];
    [self addConstraint:self.middleHairlineLeft];
    [self addConstraint:self.switchLeft];
    [self addConstraint:self.rightHairlineCenterY];
    [self addConstraint:self.leftHairlineBottom];
    [self addConstraint:self.switchCenterY];
    [self addConstraint:self.leftHairlineTop];
    [self addConstraint:self.rightHairlineEqualHeight];
    [self addConstraint:self.rightHairlineEqualWidth];
    [self addConstraint:self.leftHairlineLeft];
    [self addConstraint:self.storeButtonCenterY];
    [self addConstraint:self.collectionViewTop];
    [self addConstraint:self.collectionViewBottom];
    [self addConstraint:self.collectionViewLeft];
    [self addConstraint:self.collectionViewRight];
    [self addConstraint:self.storeButtonRight];
    [self addConstraint:self.rightHairlineRight];
}

- (void)finishUpdateConstraints {
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self.delegate keyboardDidChangeLayout];
}

- (IBAction)modeSwitchValueChanged:(UISwitch *)sender {
    
    if ([sender isOn]) {
        [self updateLayoutForAutoRecommendationLayout];
    }
    else {
        [self updateLayoutForNormalLayout];
    }
    
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
