//
//  PQGlobalContainer.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/5/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PQGlobalContainer : NSObject
// to store sticker pack bought by current user
//@property (nonatomic, strong) NSArray *stickerPacks;

@property (nonatomic, strong) NSOperationQueue *stickerPackDownloadQueue;
@property (nonatomic, strong) NSOperationQueue *avatarDownloadQueue;
@end
