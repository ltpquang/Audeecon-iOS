//
//  PQRealmString.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/15/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Realm/Realm.h>

@interface PQRealmString : RLMObject
@property NSString *string;

- (id)initWithNSString:(NSString *)string;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<PQRealmString>
RLM_ARRAY_TYPE(PQRealmString)
