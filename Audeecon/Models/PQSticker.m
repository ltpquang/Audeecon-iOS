//
//  PQSticker.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/3/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQSticker.h"

@implementation PQSticker



- (id)initWithStickerId:(NSString *)stickerId
                 andUri:(NSString *)uri {
    if (self = [super init]) {
        _stickerId = stickerId;
        _uri = uri;
    }
    return self;
}

- (UIImage *)thumbnailImage {
    if (_thumbnailImage == nil) {
        _thumbnailImage = [UIImage imageWithData:_thumbnailData];
    }
    return _thumbnailImage;
}


// Specify default values for properties

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"stickerId":@"",
             @"uri":@"",
             @"thumbnailData":[NSData new]};
}

// Specify properties to ignore (Realm won't persist these)

+ (NSArray *)ignoredProperties
{
    return @[@"thumbnailImage"];
}

+ (NSString *)primaryKey {
    return @"stickerId";
}

@end
