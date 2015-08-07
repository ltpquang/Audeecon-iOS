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
#import "PQStickerKeyboardView.h"
#import "PQSticker.h"
#import "PQStickerPack.h"
#import "PQRequestingService.h"
#import "PQCurrentUser.h"
#import "PQOtherUser.h"
#import "PQMessagingCenter.h"
#import "SCSiriWaveformView.h"
#import "PQNotificationNameFactory.h"
#import "PQRecordingOverlayView.h"
#import "PQPlayingOverlayView.h"
#import "PQStoreViewController.h"
#import "PQStickerRecommender.h"

@interface PQMessageExchangeViewController ()
@property (nonatomic, strong) PQOtherUser *partner;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) PQStickerKeyboardView *keyboardView;
@property (nonatomic, strong) PQAudioPlayerAndRecorder *audioRecorderAndPlayer;
@property (nonatomic, strong) PQSticker *selectedSticker;
@property (nonatomic, strong) PQMessageTableViewCell *playingCell;
@property (nonatomic, strong) PQRequestingService *requestingService;
@property (nonatomic, strong) PQMessagingCenter *messagingCenter;
@property (nonatomic, strong) PQRecordingOverlayView *recordingOverlay;
@property (nonatomic, strong) PQPlayingOverlayView *playingOverlay;
@property (nonatomic, strong) PQStickerRecommender *stickerRecommender;
@end

@implementation PQMessageExchangeViewController
#pragma mark - App utilities
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}

- (PQRecordingOverlayView *)recordingOverlay {
    if (_recordingOverlay == nil) {
        _recordingOverlay = [[[NSBundle mainBundle] loadNibNamed:@"RecordingOverlayView" owner:nil options:nil] lastObject];
        [_recordingOverlay setFrame:[self OverlayFrame]];
        [_recordingOverlay configUsingAudioRecorder:self.audioRecorderAndPlayer.recorder];
    }
    return _recordingOverlay;
}

- (PQPlayingOverlayView *)playingOverlay {
    if (_playingOverlay == nil) {
        _playingOverlay = [[[NSBundle mainBundle] loadNibNamed:@"PlayingOverlayView" owner:nil options:nil] lastObject];
        [_playingOverlay setFrame:[self OverlayFrame]];
        [_playingOverlay configRunLoop];
    }
    return _playingOverlay;
}

- (CGRect)OverlayFrame {
    CGRect frame = self.view.bounds;
    CGFloat navBarHeight = self.navigationController.navigationBar.bounds.size.height;
    CGRect newRect = CGRectMake(frame.origin.x, navBarHeight, frame.size.width, frame.size.height - navBarHeight - self.keyboardView.frame.size.height);
    return newRect;
}


#pragma mark - Controller delegates
- (void)configUsingPartner:(PQOtherUser *)partner {
    _partner = partner;
    self.title = partner.nickname;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.messagingCenter = [[self appDelegate] messagingCenter];
    self.keyboardView = [[self appDelegate] keyboardView];
    [self.keyboardView setDelegate:self];
    
    self.audioRecorderAndPlayer = [[PQAudioPlayerAndRecorder alloc] initWithDelegate:self];
    self.requestingService = [PQRequestingService new];
    
    self.stickerRecommender = [[self appDelegate] stickerRecommender];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addKeyboard];
    [self registerNotifications];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.keyboardView removeFromSuperview];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notifications
- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotificationHandler:)
                                                 name:[PQNotificationNameFactory messageCompletedReceivingFromJIDString:self.partner.jidString]
                                               object:nil];
}

- (void)receiveNotificationHandler:(NSNotification *)noti {
    [self.tableView reloadData];
    NSInteger messCount = [self.messagingCenter messageCountWithPartnerJIDString:self.partner.jidString];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messCount-1
                                                              inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
}


#pragma mark - Table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [self.messagingCenter messageCountWithPartnerJIDString:self.partner.jidString];
    //NSLog(@"%i", count);
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PQMessage *message = [self.messagingCenter messageAtIndexPath:indexPath
                                             withPartnerJIDString:self.partner.jidString];
    NSString *reuseId = message.isOutgoing ? @"OutgoingMessageCell" : @"IncomingMessageCell";
    
    PQMessageTableViewCell *cell = (PQMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseId
                                                                                             forIndexPath:indexPath];
    
    [cell configCellUsingMessage:message
                         andUser:(message.isOutgoing?[[self appDelegate] currentUser]:self.partner)
                        delegate:self];
    return cell;
}

#pragma mark - Add keyboard
- (void)addKeyboard {
    [self.keyboardView addToSuperview:self.view];
    NSInteger messCount = [self.messagingCenter messageCountWithPartnerJIDString:self.partner.jidString];
    if (messCount != 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messCount-1
                                                                  inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
    
}

#pragma mark - Keyboard delegate
- (void)didStartHoldingOnSticker:(PQSticker *)sticker
                     withGesture:(UIGestureRecognizer *)gesture {
    [self.recordingOverlay animatingUsingSticker:sticker];
    [self.audioRecorderAndPlayer startRecording];
    [self.view addSubview:self.recordingOverlay];
    NSLog(@"Start holding");
}

- (void)didStopHoldingOnSticker:(PQSticker *)sticker
                    withGesture:(UIGestureRecognizer *)gesture {
    NSLog(@"Stop holding");
    NSLog(@"%d", [self.recordingOverlay cancelViewContainGesture:gesture]);
    
    NSString *from = [[[self xmppStream] myJID] user];
    NSString *to = self.partner.username;
    NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
    NSNumber *isCanceled = [NSNumber numberWithBool:[self.recordingOverlay cancelViewContainGesture:gesture]];
    
    NSDictionary *infoDict = @{@"sticker":sticker,
                               @"from":from,
                               @"to":to,
                               @"timestamp":timestamp,
                               @"isCanceled":isCanceled};
    
    self.selectedSticker = sticker;
    
    [self.audioRecorderAndPlayer stopRecordingAndSaveFileWithInfo:infoDict];
    
    
    [self.recordingOverlay removeFromSuperview];
    [self.recordingOverlay stopAnimating];
    
    if (![isCanceled boolValue]) {
        [self.stickerRecommender updateRecommenderUsingSticker:sticker];
    }
}

- (void)didTapOnStoreButton {
    // Load up sticker store
    NSLog(@"Store button tap");
//    PQStoreViewController *storeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StoreViewController"];
//    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:storeVC];
//    [self presentViewController:navVC
//                       animated:YES
//                     completion:nil];
    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"StoreNavigationController"];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)keyboardDidChangeLayout {
    UIEdgeInsets insets = self.tableView.contentInset;
    [self.tableView setContentInset:UIEdgeInsetsMake(insets.top, insets.left, self.keyboardView.frame.size.height + 8.0, insets.right)];
    
    [self.recordingOverlay setFrame:[self OverlayFrame]];
    [self.playingOverlay setFrame:[self OverlayFrame]];
}

#pragma mark - Audio recorder delegate
- (void)didFinishRecordingAndSaveToFileAtUrl:(NSURL *)savedFile {
    
    PQMessage *message = [[PQMessage alloc] initWithSticker:self.selectedSticker
                                         andOfflineAudioUri:savedFile.path
                                              fromJIDString:[[[self xmppStream] myJID] bare]
                                                toJIDString:self.partner.jidString
                                                 isOutgoing:YES];
    
    [self.messagingCenter sendMessage:message];
    [self.tableView reloadData];
    NSInteger messCount = [self.messagingCenter messageCountWithPartnerJIDString:self.partner.jidString];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messCount-1
                                                                    inSection:0]
                                atScrollPosition:UITableViewScrollPositionBottom
                                        animated:YES];
}

- (void)didFinishPlaying {
    [self.playingOverlay stop];
}

#pragma mark - Table view cell delegate
- (void)didStartHoldingOnCell:(UITableViewCell *)cell {
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    PQMessage *message = [self.messagingCenter messageAtIndexPath:path
                                             withPartnerJIDString:self.partner.jidString];
    if (message.offlineAudioUri.length != 0) {
        [message markAsRead];
        [self.playingOverlay startPlayingUsingSticker:message
                            andAudioRecorderAndPlayer:self.audioRecorderAndPlayer
                                               onView:self.view];
    }
    
}

- (void)didStopHoldingOnCell:(UITableViewCell *)cell {
    [self.playingOverlay stop];
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
