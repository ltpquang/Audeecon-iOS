//
//  PQTextField.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/12/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQTextField.h"

@implementation PQTextField

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.leftInset = 0.0;
        self.rightInset = 0.0;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.leftInset = 0.0;
        self.rightInset = 0.0;
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0.0, self.leftInset, 0.0, self.rightInset))];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0.0, self.leftInset, 0.0, self.rightInset))];
}

@end
