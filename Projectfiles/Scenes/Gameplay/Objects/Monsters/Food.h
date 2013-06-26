//
//  Monster.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/18/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "CCSprite.h"

@interface Monster : CCSprite

@property (nonatomic, assign) BOOL visible;

- (id)initWithMonsterPicture;
- (void)spawn;
- (void)gotCollected;

@end