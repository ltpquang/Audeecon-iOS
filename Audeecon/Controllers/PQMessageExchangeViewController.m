//
//  PQMessageExchangeViewController.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 4/1/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQMessageExchangeViewController.h"
#import "AppDelegate.h"
#import "XMPPFramework.h"
#import "PQMessage.h"
#import "PQMessageCollectionViewCell.h"
#import "PQStickerKeyboardView.h"
#import "PQSticker.h"
#import "PQStickerPack.h"
#import "PQRequestingService.h"
#import "PQCurrentUser.h"

@interface PQMessageExchangeViewController ()
@property (nonatomic, strong) XMPPUserCoreDataStorageObject *partner;
@property (strong, nonatomic) NSMutableArray *messages;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) PQStickerKeyboardView *keyboardView;
@property (nonatomic, strong) PQAudioPlayerAndRecorder *audioRecorderAndPlayer;
@property (nonatomic, strong) PQSticker *selectedSticker;
@property (nonatomic, strong) PQStickerPack *selectedPack;
@property (nonatomic, strong) PQMessageCollectionViewCell *playingCell;
@property (nonatomic, strong) PQRequestingService *requestingService;
@end

@implementation PQMessageExchangeViewController
#pragma mark - App utilities
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}

#pragma mark - Controller delegates
- (void)configUsingPartner:(XMPPUserCoreDataStorageObject *)partner {
    _partner = partner;
}

- (PQStickerKeyboardView *)keyboardView {
    if (_keyboardView == nil) {
        _keyboardView = [[[NSBundle mainBundle] loadNibNamed:@"StickerKeyboardView" owner:nil options:nil] lastObject];
    }
    return _keyboardView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self appDelegate] setMessageExchangeDelegate:self];
    
    [self configCollectionView];
    _messages = [NSMutableArray new];
    _audioRecorderAndPlayer = [[PQAudioPlayerAndRecorder alloc] initWithDelegate:self];
    _requestingService = [PQRequestingService new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self tapGestureHandler];
}

- (void)configCollectionView {
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    _flowLayout.minimumInteritemSpacing = 1000.0;
    
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler)];
    tapgesture.numberOfTapsRequired = 2;
    
    [_collectionView addGestureRecognizer:tapgesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Handle gesture
- (void)tapGestureHandler {
    NSLog(@"Double tap");
    [self.view addSubview:self.keyboardView];
    [self.keyboardView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.keyboardView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.keyboardView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.keyboardView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.keyboardView configKeyboardWithStickerPacks:[[[[self appDelegate] currentUser] ownedStickerPack] valueForKey:@"self"]
                                         delegate:self];

}



#pragma mark - Message exchange delegates
- (void)didReceiveMessage:(PQMessage *)message {
    [_messages addObject:message];
    [_collectionView reloadData];
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1
                                                                inSection:0]
                            atScrollPosition:UICollectionViewScrollPositionBottom
                                    animated:YES];
}

- (void)reloadStickers {
    [self.keyboardView reloadKeyboardUsingPacks:[[[[self appDelegate] currentUser] ownedStickerPack] valueForKey:@"self"]];
}

#pragma mark - Collection view datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _messages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PQMessageCollectionViewCell *cell = (PQMessageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MessageCell" forIndexPath:indexPath];
    [cell configCellUsingMessage:[_messages objectAtIndex:indexPath.row]
                        delegate:self];
    return cell;
}

#pragma mark - Keyboard delegate
- (void)didStartHoldingOnSticker:(PQSticker *)sticker
                   ofStickerPack:(PQStickerPack *)pack {
    NSLog(@"Start holding on sticker %@ of pack %@", sticker.stickerId, pack.packId);
    [_audioRecorderAndPlayer startRecording];
}

- (void)didStopHoldingOnSticker:(PQSticker *)sticker
                  ofStickerPack:(PQStickerPack *)pack {
    NSLog(@"Stop- holding on sticker %@ of pack %@", sticker.stickerId, pack.packId);
    
    NSString *from = [[[self xmppStream] myJID] user];
    NSString *to = [[[self partner] jid] user];
    NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
    
    NSDictionary *infoDict = @{@"from":from,
                               @"to":to,
                               @"timestamp":timestamp};
    
    _selectedPack = pack;
    _selectedSticker = sticker;
    
    [_audioRecorderAndPlayer stopRecordingAndSaveFileWithInfo:infoDict];
    
}

- (void)didChangeLayout {
    CGPoint offsets = self.collectionView.contentOffset;
    UIEdgeInsets insets = self.collectionView.contentInset;
    [self.collectionView setContentInset:UIEdgeInsetsMake(insets.top, insets.left, self.keyboardView.frame.size.height, insets.right)];
    
    [self.collectionView setContentOffset:CGPointMake(offsets.x, offsets.y - insets.bottom + self.collectionView.contentInset.bottom) animated:YES];
}

#pragma mark - Audio recorder delegate
- (void)didFinishRecordingAndSaveToFileAtUrl:(NSURL *)savedFile {
    PQMessage *message = [[PQMessage alloc] initWithSender:[[[self xmppStream] myJID] user]
                                             andStickerUri:_selectedSticker.thumbnailUri
                                        andOfflineAudioUri:[savedFile path]];
    
    [message uploadAudioWithCompletion:^(BOOL succeeded, NSError *error) {
        [[self xmppStream] sendElement:[message xmlElementSendTo:[_partner jidStr]]];
        
        [_messages addObject:message];
        
        NSLog(@"%@", message.offlineAudioUri);
        NSLog(@"%@", message.onlineAudioUri);
        [_collectionView reloadData];
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1
                                                                    inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionBottom
                                        animated:YES];
    }];
    
    
}

- (void)didFinishPlaying {
    if (_playingCell) {
        [_playingCell reshowPlayButton];
    }
    _playingCell = nil;
}

#pragma mark - Message cell delegate
- (void)didReceiveRequestToPlayCell:(PQMessageCollectionViewCell *)cell {
    [self didFinishPlaying];
    _playingCell = cell;
    NSIndexPath *path = [_collectionView indexPathForCell:_playingCell];
    PQMessage *message = [_messages objectAtIndex:path.row];
    [message downloadAudioUsingRequestingService:_requestingService
                                        complete:^(NSURL *offlineFile) {
                                            [_audioRecorderAndPlayer playAudioFileAtUrl:offlineFile];
                                        }];
    
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
