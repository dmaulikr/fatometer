//
//  Coins.h
//  Fat
//
//  Created by Shalin Shah on 7/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "CCSprite.h"
#import "GameplayLayer.h"

@interface Coins :  CCSprite

// defines a hit zone, which is smaller as the sprite, only if this hit zone is hit the knight is injured
@property (nonatomic, assign) CGRect hitZone;

// velocity in pixels per second
@property (nonatomic, assign) CGPoint velocity;

@property (nonatomic, assign) NSInteger hitPoints;


- (id)initWithCoins;
- (void)spawn;

@end

