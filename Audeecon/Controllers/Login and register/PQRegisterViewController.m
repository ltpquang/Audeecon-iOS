//
//  PQRegisterViewController.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/10/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQRegisterViewController.h"
#import "AppDelegate.h"

@interface PQRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@end

@implementation PQRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self appDelegate] setRegisterDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - App utilities
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (IBAction)registerButton_TUI:(id)sender {
    
}

- (IBAction)loginButton_TUI:(id)sender {
    UIViewController *registerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:registerVC];
    [[[self appDelegate] window] setRootViewController:navController];
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
