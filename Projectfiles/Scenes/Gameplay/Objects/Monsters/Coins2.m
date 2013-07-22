//
//  Coins2.m
//  Fat
//
//  Created by Shalin Shah on 7/17/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Coins2.h"
#import "GameMechanics.h"
#import "GameplayLayer.h"
#import "Store.h"

@implementation Coins2

- (id)initWithMonsterPicture
{
    self = [super initWithFile:@"bubble.png"];
    if (self)
    {
        CGRect screenRect = [[CCDirector sharedDirector] screenRect];
        CGSize spriteSize = [self contentSize];
        posX =  screenRect.size.width + spriteSize.width * 0.5f;
        posY = 170;
        self.initialHitPoints = 1;
        self.animationFrames = [NSMutableArray array];
        [self scheduleUpdate];
        inAppCurrencyDisplayNode.score = [Store availableAmountInAppCurrency];
    }
    coinValue = 3;
    return self;
}
- (void)spawn
{
    self.position = CGPointMake(posX, posY);
    self.visible = YES;
}
- (void)gotCollected {
    self.visible = FALSE;
    self.position = ccp(-MAX_INT, 0);
    [Store addInAppCurrency:coinValue];
}

@end