//
//  PQLoginViewController.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 3/20/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQLoginViewController.h"
#import "AppDelegate.h"

@interface PQLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation PQLoginViewController

#pragma mark - View controller delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    NSString *server = @"les-macbook-pro.local";
    //NSString *server = @"ec2-52-74-63-154.ap-southeast-1.compute.amazonaws.com";
    NSString *userName = [NSString stringWithFormat:@"%@@%@", self.usernameTextField.text,server];
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text forKey:@"userPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[self appDelegate] connect];
    //[self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - App utilities
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Login delegates
- (void)loginDidConnect {
    
}

- (void)loginDidConnectTimeout {

}

- (void)loginDidAuthenticate {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
