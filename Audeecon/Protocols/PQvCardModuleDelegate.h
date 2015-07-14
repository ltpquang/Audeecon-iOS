//
//  PQvCardModuleDelegate.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/13/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"

@protocol PQvCardModuleDelegate <NSObject>
- (void)vCardModuleDidUpdateMyvCard;
- (void)vCardModuleDidNotUpdateMyvCard:(DDXMLElement *)error;
@end
