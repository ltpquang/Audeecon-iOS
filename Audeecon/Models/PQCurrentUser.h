//
//  PQCurrentUser.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/7/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Realm/Realm.h>

@interface PQCurrentUser : RLMObject
<# Add properties here to define the model #>
@end

// This protocol enables typed collections. i.e.:
// RLMArray<PQCurrentUser>
RLM_ARRAY_TYPE(PQCurrentUser)
