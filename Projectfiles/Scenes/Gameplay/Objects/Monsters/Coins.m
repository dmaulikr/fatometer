//
//  Coins.m
//  Fat
//
//  Created by Shalin Shah on 7/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Coins.h"
#import "GameMechanics.h"

@implementation Coins

- (void)dealloc
{
    /*
     When our object is removed, we need to unregister from all notifications.
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithCoins{
    
    if (self)
    {
        [self scheduleUpdate];
    }
    return self;
}

- (void)update:(ccTime)delta
{
    // apply background scroll speed
    float backgroundScrollSpeedX = [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX];
    float xSpeed = 1.6 * backgroundScrollSpeedX;

    // move the monster until it leaves the left edge of the screen
    if (self.position.x > (self.contentSize.width * (-1)))
    {
        self.position = ccp(self.position.x - (xSpeed*delta), self.position.y);
    }
}

- (void)gamePaused
{
    [self pauseSchedulerAndActions];
}

- (void)gameResumed
{
    [self resumeSchedulerAndActions];
}

@end
