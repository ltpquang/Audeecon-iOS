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
#import "PQMessageTableViewCell.h"

@interface PQMessageExchangeViewController ()
@property (strong, nonatomic) NSMutableArray *messages;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self appDelegate] setMessageExchangeDelegate:self];
    _messages = [NSMutableArray new];
    _mainTableView.contentInset = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendButtonTUI:(id)sender {
    NSString *messageStr = self.messageField.text;
    
    if([messageStr length] > 0) {
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:@"test01@les-macbook-pro.local"];
        [message addChild:body];
        
        [self.xmppStream sendElement:message];
        
        self.messageField.text = @"";
        
        
        [_messages addObject:messageStr];
        [_mainTableView reloadData];
        
    }
    
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:_messages.count-1
                                                   inSection:0];
    
    [_mainTableView scrollToRowAtIndexPath:topIndexPath
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
}

- (NSString *) getCurrentTime {
    
    NSDate *nowUTC = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:nowUTC];
    
}


#pragma mark - Table View delegates
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PQMessageTableViewCell *cell = (PQMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    [cell configCellUsingMessage:[_messages objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messages.count;
}



#pragma mark - Message Exchange delegates
- (void)didReceiveMessage:(NSDictionary *)messageContent {
    [_messages addObject:[messageContent valueForKey:@"msg"]];
    [_mainTableView reloadData];
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
