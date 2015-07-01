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

@interface PQLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    _usernameTextField.text = @"gaulois";
    _passwordTextField.text = @"123123";
}

- (IBAction)loginButtonTUI:(id)sender {
    NSLog(@"Clicked");
    //return;
    NSString *userName = [PQHostnameFactory nicknameWithHostName:self.usernameTextField.text];
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text forKey:@"userPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[self appDelegate] connect];
}

- (IBAction)registerButtonTUI:(id)sender {
    UIViewController *registerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterView"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:registerVC];
    [[[self appDelegate] window] setRootViewController:navController];
}

#pragma mark - Stream connect delegate
- (void)xmppStreamDidConnect {
    [[self appDelegate] authenticateUsingPassword];
}

- (void)xmppStreamConnectDidTimeOut {
    
}

#pragma mark - Login delegates
- (void)loginDidAuthenticate {
    //[self dismissViewControllerAnimated:YES completion:nil];
    [[[self appDelegate] window] setRootViewController:[self.storyboard instantiateInitialViewController]];
}

- (void)loginDidNotAuthenticate:(DDXMLElement *)error {
    
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
