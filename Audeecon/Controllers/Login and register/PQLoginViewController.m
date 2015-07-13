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

@interface PQLoginViewController ()
@property BOOL keyboardIsShown;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *mainLogo;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *registerView;
@property (strong, nonatomic) IBOutlet UIView *loginView;
// Login view
@property (weak, nonatomic) IBOutlet PQTextField *loginUsernameTextField;
@property (weak, nonatomic) IBOutlet PQTextField *loginPasswordTextField;
// Register view
@property (weak, nonatomic) IBOutlet PQTextField *registerUsernameTextField;
@property (weak, nonatomic) IBOutlet PQTextField *registerPasswordTextField;
@property (weak, nonatomic) IBOutlet PQTextField *registerConfirmPasswordTextField;


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
    
    [self.loginView setFrame:CGRectMake(0.0, 0.0, scrollSize.width, scrollSize.height)];
    [self.registerView setFrame:CGRectMake(scrollSize.width, 0.0, scrollSize.width, scrollSize.height)];
    
    self.mainScrollView.contentSize = CGSizeMake(scrollSize.width * 2.0, scrollSize.height);
    
    [self.mainScrollView addSubview:self.loginView];
    [self.mainScrollView addSubview:self.registerView];
    
    [self.view addSubview:self.mainScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupView];
    self.loginUsernameTextField.text = @"gaulois";
    self.loginPasswordTextField.text = @"123123";
}

- (IBAction)logMeInButtonTUI:(id)sender {
    NSLog(@"Clicked");
    //return;
    NSString *userName = [PQHostnameFactory nicknameWithHostName:self.loginUsernameTextField.text];
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setObject:self.loginPasswordTextField.text forKey:@"userPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[self appDelegate] connect];
}

- (IBAction)registerButtonTUI:(id)sender {
    // Bring up register view
    CGRect frame = self.mainScrollView.frame;
    frame.origin.x = frame.size.width;
    frame.origin.y = 0.0;
    [self.mainScrollView scrollRectToVisible:frame animated:YES];
}

- (IBAction)signMeUpButtonTUI:(id)sender {
}
- (IBAction)loginButtonTUI:(id)sender {
    //Bring up login view
    CGRect frame = self.mainScrollView.frame;
    frame.origin.x = 0.0;
    frame.origin.y = 0.0;
    [self.mainScrollView scrollRectToVisible:frame animated:YES];
}
#pragma mark - Stream connect delegate
- (void)xmppStreamDidConnect {
    [[self appDelegate] authenticateUsingPassword];
}

- (void)xmppStreamConnectDidTimeOut {
    
}

#pragma mark - Login delegates
- (void)loginDidAuthenticate {
    [[[self appDelegate] window] setRootViewController:[self.storyboard instantiateInitialViewController]];
}

- (void)loginDidNotAuthenticate:(DDXMLElement *)error {
    
}

#pragma mark - Keyboard handler
- (void)keyboardWillHide:(NSNotification *)n
{
    //NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    //CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
//    // resize the scrollview
//    CGRect viewFrame = self.mainScrollView.frame;
//    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
//    viewFrame.origin.y = 0;
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [self.mainScrollView setFrame:viewFrame];
//    [UIView commitAnimations];
//    
//    self.keyboardIsShown = NO;
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
