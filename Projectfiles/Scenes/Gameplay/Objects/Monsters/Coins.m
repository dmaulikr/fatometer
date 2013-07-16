//
//  Coins.m
//  Fat
//
//  Created by Shalin Shah on 7/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Coins.h"
#import "GameMechanics.h"
#import "GameplayLayer.h"
#import "Store.h"

@implementation Coins

- (id)initWithMonsterPicture
{
    self = [super initWithFile:@"bubble.png"];
    
    if (self)
    {
        self.initialHitPoints = 1;
        self.animationFrames = [NSMutableArray array];
        [self scheduleUpdate];
        inAppCurrencyDisplayNode.score = [Store availableAmountInAppCurrency];
        
    }
    return self;
    
    fromNumber = 4;
    toNumber = 14;
    coinValue = (arc4random()%(toNumber-fromNumber+1))+fromNumber;
}


- (void)gotCollected {
    self.visible = FALSE;
    self.position = ccp(-MAX_INT, 0);
    [Store addInAppCurrency:coinValue];
}
@end
