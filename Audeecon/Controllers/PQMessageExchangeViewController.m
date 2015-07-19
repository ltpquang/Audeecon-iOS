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
#import "PQMessageTableViewCell.h"
#import "PQStickerKeyboardView.h"
#import "PQSticker.h"
#import "PQStickerPack.h"
#import "PQRequestingService.h"
#import "PQCurrentUser.h"
#import "PQOtherUser.h"
#import "PQMessagingCenter.h"
#import "SCSiriWaveformView.h"
#import "PQRecordingOverlayView.h"

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
        CGRect frame = self.view.bounds;
        CGRect newRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - self.keyboardView.frame.size.height);
        [_recordingOverlay setFrame:newRect];
        [_recordingOverlay configUsingAudioRecorder:self.audioRecorderAndPlayer.recorder];
    }
    return _recordingOverlay;
}


#pragma mark - Controller delegates
- (void)configUsingPartner:(PQOtherUser *)partner {
    _partner = partner;
    _messagingCenter = [[self appDelegate] messagingCenter];
    self.title = partner.username;
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
    
    [self configTableView];
    self.audioRecorderAndPlayer = [[PQAudioPlayerAndRecorder alloc] initWithDelegate:self];
    self.requestingService = [PQRequestingService new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self tapGestureHandler];
    [self registerNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configTableView {
    
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler)];
    tapgesture.numberOfTapsRequired = 2;
    
    [self.tableView addGestureRecognizer:tapgesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notifications
- (void)registerNotifications {
    NSString *receiveNotiName = [@"Received:" stringByAppendingString:self.partner.jidString];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotificationHandler:)
                                                 name:receiveNotiName
                                               object:nil];
}

- (void)receiveNotificationHandler:(NSNotification *)noti {
    [self.tableView reloadData];
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
- (void)reloadStickers {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.keyboardView reloadKeyboardUsingPacks:[[[[self appDelegate] currentUser] ownedStickerPack] valueForKey:@"self"]];
    });
}

#pragma mark - Table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messagingCenter messageCountWithPartnerJIDString:self.partner.jidString];
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
    NSString *to = self.partner.jidString;
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
}

- (void)didChangeLayout {
    CGPoint offsets = self.tableView.contentOffset;
    UIEdgeInsets insets = self.tableView.contentInset;
    [self.tableView setContentInset:UIEdgeInsetsMake(insets.top, insets.left, self.keyboardView.frame.size.height + 8.0, insets.right)];
    
    [self.tableView setContentOffset:CGPointMake(offsets.x, offsets.y - insets.bottom + self.tableView.contentInset.bottom) animated:YES];
    
    
    CGRect frame = self.view.bounds;
    CGRect newRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - self.keyboardView.frame.size.height);
    [self.recordingOverlay setFrame:newRect];
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
}

#pragma mark - Message cell delegate
- (void)didReceiveRequestToPlayCell:(PQMessageTableViewCell *)cell {
    [self didFinishPlaying];
    self.playingCell = cell;
    NSIndexPath *path = [self.tableView indexPathForCell:self.playingCell];
    PQMessage *message = [self.messagingCenter messageAtIndexPath:path withPartnerJIDString:self.partner.jidString];
    [message downloadAudioUsingRequestingService:self.requestingService
                                        complete:^(NSURL *offlineFile) {
                                            [self.audioRecorderAndPlayer playAudioFileAtUrl:offlineFile];
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
