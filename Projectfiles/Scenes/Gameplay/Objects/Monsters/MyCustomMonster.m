//
//  MyCustomMonster.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/18/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "MyCustomMonster.h"
#import "GameMechanics.h"

@implementation MyCustomMonster

- (id)initWithMonsterPicture
{
    self = [super initWithFile:@"basicbarrell.png"];

    if (self)
    {
        [self scheduleUpdate];
    }

    return self;
}

- (void)spawn
{
    self.position = CGPointMake(250, 50);
	
	// Finally set yourself to be visible, this also flag the enemy as "in use"
	self.visible = YES;
}

- (void)gotHit
{
    // mark as unvisible and move off screen
    self.visible = FALSE;
    self.position = ccp(-MAX_INT, 0);
    [[GameMechanics sharedGameMechanics] game].enemiesKilled += 1;
    [[GameMechanics sharedGameMechanics] game].score += 1;
}

- (void)update:(ccTime)delta
{
    // apply background scroll speed
    float backgroundScrollSpeedX = [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX];
    float xSpeed = 1.1 * backgroundScrollSpeedX;
    
    // move the monster until it leaves the left edge of the screen
    if (self.position.x > (self.contentSize.width * (-1)))
    {
        self.position = ccp(self.position.x - (xSpeed*delta), self.position.y);
    }
}

@end
