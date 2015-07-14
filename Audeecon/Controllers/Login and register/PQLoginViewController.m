//
//  PQLoginViewController.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 3/20/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQLoginViewController.h"
#import "AppDelegate.h"
#import "PQHostnameFactory.h"
#import "PQTextField.h"
#import "XMPPvCardTemp.h"
#import <DBCameraContainerViewController.h>
#import <DBCameraView.h>
#import <AWSS3.h>
#import <AWSCore.h>
#import "PQUrlService.h"
#import "PQFilePathFactory.h"
#import "PQRequestingService.h"
#import "UIImage+Resize.h"


@interface PQLoginViewController ()
@property BOOL keyboardIsShown;
@property BOOL onRegisterSection;
@property BOOL needUpdateInfo;
@property NSString *nickname;
@property NSString *username;
@property BOOL defaultAvatarChanged;
@property BOOL viewLoaded;

@property MBProgressHUD *hud;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *mainLogo;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *registerView;
@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UIView *updateInfoView;
// Login view
@property (weak, nonatomic) IBOutlet PQTextField *loginUsernameTextField;
@property (weak, nonatomic) IBOutlet PQTextField *loginPasswordTextField;
// Register view
@property (weak, nonatomic) IBOutlet PQTextField *registerFullnameTextField;
@property (weak, nonatomic) IBOutlet PQTextField *registerUsernameTextField;
@property (weak, nonatomic) IBOutlet PQTextField *registerPasswordTextField;
@property (weak, nonatomic) IBOutlet PQTextField *registerConfirmPasswordTextField;

@property (weak, nonatomic) IBOutlet UIImageView *updateInfoAvatarImageView;

@end

@implementation PQLoginViewController


#pragma mark - App utilities
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - View controller delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self appDelegate] setStreamConnectDelegate:self];
    [[self appDelegate] setLoginDelegate:self];
    [[self appDelegate] setRegisterDelegate:self];
    [[self appDelegate] setVCardModuleDelegate:self];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    self.keyboardIsShown = NO;
}

- (void)setupView {
//    CGRect frame = CGRectMake(0.0, 145.0, self.view.frame.size.width, self.view.frame.size.width);
//    self.mainScrollView = [[UIScrollView alloc] initWithFrame:frame];
    CGSize scrollSize = self.mainScrollView.frame.size;
    
    self.loginView = [[[NSBundle mainBundle] loadNibNamed:@"LoginView" owner:self options:nil] lastObject];
    self.registerView = [[[NSBundle mainBundle] loadNibNamed:@"RegisterView" owner:self options:nil] lastObject];
    self.updateInfoView = [[[NSBundle mainBundle] loadNibNamed:@"UpdateInfoView" owner:self options:nil] lastObject];
    self.updateInfoAvatarImageView.layer.cornerRadius = self.updateInfoAvatarImageView.bounds.size.width/2;
    self.updateInfoAvatarImageView.layer.masksToBounds = YES;
    self.updateInfoAvatarImageView.layer.borderWidth = 1.0;
    self.updateInfoAvatarImageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveInfoImageTapGestureHandler:)];
    tap.numberOfTapsRequired = 1;
    [self.updateInfoAvatarImageView addGestureRecognizer:tap];
    
    [self.loginView setFrame:CGRectMake(0.0, 0.0, scrollSize.width, scrollSize.height)];
    [self.registerView setFrame:CGRectMake(scrollSize.width, 0.0, scrollSize.width, scrollSize.height)];
    [self.updateInfoView setFrame:CGRectMake(scrollSize.width * 2.0, 0.0, scrollSize.width, scrollSize.height)];
    
    self.mainScrollView.contentSize = CGSizeMake(scrollSize.width * 3.0, scrollSize.height);
    
    [self.mainScrollView addSubview:self.loginView];
    [self.mainScrollView addSubview:self.registerView];
    [self.mainScrollView addSubview:self.updateInfoView];
    
    [self.view addSubview:self.mainScrollView];
    self.viewLoaded = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.viewLoaded) {
        [self setupView];
        self.loginUsernameTextField.text = @"gaulois";
        self.loginPasswordTextField.text = @"123123";
        
//        self.registerFullnameTextField.text = @"Lê Thái Phúc Quang";
//        self.registerUsernameTextField.text = @"regtest";
//        self.registerPasswordTextField.text = @"123123";
//        self.registerConfirmPasswordTextField.text = @"123123";
    }
}

- (void)scrollToIndex:(NSInteger)index {
    CGRect frame = self.mainScrollView.frame;
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0.0;
    [self.mainScrollView scrollRectToVisible:frame animated:YES];
}

- (IBAction)logMeInButtonTUI:(id)sender {
    self.username = self.loginUsernameTextField.text;
    NSString *userNameWithHost = [PQHostnameFactory nicknameWithHostName:self.username];
    [[NSUserDefaults standardUserDefaults] setObject:userNameWithHost forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setObject:self.loginPasswordTextField.text forKey:@"userPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[self appDelegate] connect];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.delegate = self;
    self.hud.labelText = @"Loging in...";
    self.hud.minSize = CGSizeMake(135.f, 135.f);
}

- (IBAction)registerButtonTUI:(id)sender {
    // Bring up register view
    [self scrollToIndex:1];
}

- (IBAction)signMeUpButtonTUI:(id)sender {
    [[self view] endEditing:YES];
    self.onRegisterSection = YES;
    self.username = self.registerUsernameTextField.text;
    self.nickname = self.registerFullnameTextField.text;
    NSString *userNameWithHost = [PQHostnameFactory nicknameWithHostName:self.username];
    [[NSUserDefaults standardUserDefaults] setObject:userNameWithHost forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setObject:self.registerPasswordTextField.text forKey:@"userPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[self appDelegate] connect];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.delegate = self;
    self.hud.labelText = @"Signing up...";
    self.hud.minSize = CGSizeMake(135.f, 135.f);
}

- (IBAction)loginButtonTUI:(id)sender {
    //Bring up login view
    [self scrollToIndex:0];
}

- (void)saveInfoImageTapGestureHandler:(UITapGestureRecognizer *)gesture {
    [self loadCamera];
}

- (IBAction)saveInfoButtonTUI:(id)sender {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.delegate = self;
    self.hud.minSize = CGSizeMake(135.f, 135.f);
    
    if (self.defaultAvatarChanged) {
        // Upload to server
        self.hud.labelText = @"Uploading...";
        self.hud.mode = MBProgressHUDModeAnnularDeterminate;
        [self performSelectorInBackground:@selector(uploadImage:) withObject:self.updateInfoAvatarImageView.image];
        //[self uploadImage:self.updateInfoAvatarImageView.image];
    }
    else {
        // Update info
        self.hud.labelText = @"Updating...";
        [self updatevCardUsingAvatarUrl:[PQUrlService urlToDefaultAvatar]];
    }
}
#pragma mark - Stream connect delegate
- (void)xmppStreamDidConnect {
    if (!self.onRegisterSection) {
        [[self appDelegate] authenticateUsingPassword];
    }
    else {
        [[self appDelegate] registerUsingPassword];
    }
}

- (void)xmppStreamConnectDidTimeOut {
    
}

#pragma mark - Login delegates
- (void)loginDidAuthenticate {
    if (!self.needUpdateInfo) {
        [[[self appDelegate] window] setRootViewController:[self.storyboard instantiateInitialViewController]];
        [self.hud hide:YES];
    }
    else {
        //Update info
        [self scrollToIndex:2];
        [self.hud hide:YES];
    }
}

- (void)loginDidNotAuthenticate:(DDXMLElement *)error {
    
}

#pragma mark - Register delegates
- (void)registerDidSuccess {
    [[[self appDelegate] xmppStream] disconnect];
    self.onRegisterSection = NO;
    self.needUpdateInfo = YES;
    [[self appDelegate] connect];
}

- (void)registerDidNotSuccess:(DDXMLElement *)error {
    
}

#pragma mark - vCard module delegates
- (void)vCardModuleDidUpdateMyvCard {
    // Update complete, register with server
    [self registerUserWithServer];
}

- (void)vCardModuleDidNotUpdateMyvCard:(DDXMLElement *)error {
    
}

- (void)registerUserWithServer {
    [[PQRequestingService new] registerWithServerForUser:self.username
                                                 success:^{
                                                     // Dismiss
                                                     [[[self appDelegate] window] setRootViewController:[self.storyboard instantiateInitialViewController]];
                                                     [self.hud hide:YES];
                                                 }
                                                 failure:^(NSError *error) {
                                                     NSLog(@"Register with server failed");
                                                 }];
}

#pragma mark - Camera
- (void)loadCamera
{
    DBCameraViewController *cameraController = [DBCameraViewController initWithDelegate:self];
    [cameraController setForceQuadCrop:YES];
    
    DBCameraContainerViewController *container = [[DBCameraContainerViewController alloc] initWithDelegate:self cameraSettingsBlock:^(DBCameraView *cameraView, id container) {
        //
        [cameraView.photoLibraryButton setHidden:NO];
        [cameraView.cameraButton setHidden:NO];
        [cameraView.flashButton setHidden:YES];
    }];
    [container setCameraViewController:cameraController];
    [container setFullScreenMode];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:container];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata {
    [cameraViewController restoreFullScreenMode];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    self.defaultAvatarChanged = YES;
    self.updateInfoAvatarImageView.image = image;
}

- (void)uploadImage:(UIImage *)image {
    NSURL *fileUrl = [PQFilePathFactory filePathInTemporaryDirectoryForAvatarImage];
    
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:fileUrl.path atomically:YES];
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *filepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"avatar.png"];

    NSString *onlineFileName = [self.username stringByAppendingString:@".jpeg"];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"audeecon-us/avatar";
    uploadRequest.key = onlineFileName;
    uploadRequest.body = fileUrl;
    uploadRequest.uploadProgress = ^(int64_t bytes, int64_t totalBytes, int64_t totalBytesExpected) {
        NSLog(@"%lld - %lld - %lld", bytes, totalBytes, totalBytesExpected);
        float progress = (float)(totalBytes * 100.0 / totalBytesExpected);
        NSLog(@"%f", progress);
        self.hud.progress = progress/100;
    };
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager S3TransferManagerForKey:@"defaulttransfermanager"];
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                       withBlock:^id(AWSTask *task) {
                                                           if (task.error != nil) {
                                                               //complete(NO, task.error);
                                                           }
                                                           else {
                                                               NSString *fileUrl = [PQUrlService urlToS3FileWithFileName:[@"avatar/" stringByAppendingString:onlineFileName]];
                                                               NSLog(@"%@", fileUrl);
                                                               [self updatevCardUsingAvatarUrl:fileUrl];
                                                               self.hud.mode = MBProgressHUDModeIndeterminate;
                                                               self.hud.labelText = @"Updating...";
                                                           }
                                                           return nil;
                                                       }];
}

- (void)updatevCardUsingAvatarUrl:(NSString *)fileUrl {
    XMPPvCardTemp *myvCardTemp = [[[self appDelegate] xmppvCardTempModule] myvCardTemp];
    if (myvCardTemp == nil) {
        NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
        myvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
    }
    [myvCardTemp setNickname:self.nickname];
    [myvCardTemp setUrl:fileUrl];
    [[[self appDelegate] xmppvCardTempModule] updateMyvCardTemp:myvCardTemp];
}

#pragma mark - HUD delegates
- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [_hud removeFromSuperview];
    _hud = nil;
}

#pragma mark - Keyboard handler
- (void)keyboardWillHide:(NSNotification *)n
{
    self.logoTopConstraint.constant = 40.0;
    self.scrollViewTopConstraint.constant = 40.0;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
    
    self.keyboardIsShown = NO;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the `UIScrollView` if the keyboard is already shown.  This can happen if the user, after fixing editing a `UITextField`, scrolls the resized `UIScrollView` to another `UITextField` and attempts to edit the next `UITextField`.  If we were to resize the `UIScrollView` again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if (self.keyboardIsShown) {
        return;
    }
    
    self.logoTopConstraint.constant = 8.0;
    self.scrollViewTopConstraint.constant = 8.0;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
    
    self.keyboardIsShown = YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
