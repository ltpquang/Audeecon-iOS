//
//  PQMessageTableViewCell.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 4/8/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQMessageTableViewCell.h"
@interface PQMessageTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation PQMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCellUsingMessage:(NSString *)message {
    _messageLabel.text = message;
}
@end
