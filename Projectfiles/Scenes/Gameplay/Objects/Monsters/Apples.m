//
//  Apples.m
//  Fat
//
//  Created by Shalin Shah on 7/9/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Apples.h"
#import "GameMechanics.h"

@implementation Apples

- (id)initWithMonsterPicture
{
    self = [super initWithFile:@"apple.png"];
    
    if (self)
    {
        self.animationFrames = [NSMutableArray array];
        //Create an animation from the set of frames you created earlier
        CCAnimation *running = [CCAnimation animationWithSpriteFrames: self.animationFrames delay:0.7f];
        //Create an action with the animation that can then be assigned to a sprite
        self.run = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:running]];        
        // run the animation
        [self runAction:self.run];
        
        [self scheduleUpdate];
    }
    return self;
}


- (void)spawn
{
    // Select a spawn location just outside the right side of the screen, and 
	CGRect screenRect = [[CCDirector sharedDirector] screenRect];
	CGSize spriteSize = [self contentSize];
	float xPos = screenRect.size.width + spriteSize.width * 0.5f;
	float yPos = screenRect.size.height / 12 *9;
	self.position = CGPointMake(xPos, yPos);
    
	// Finally set yourself to be visible, this also flag the enemy as "in use"
	self.visible = YES;
    
    
}

- (void)gotCollected
{
    
    CCParticleSystem* system = [CCParticleSystemQuad particleWithFile:@"fx-explosion.plist"];
    // Set some parameters that can't be set in Particle Designer
    system.positionType = kCCPositionTypeFree;
    system.autoRemoveOnFinish = YES;
    system.position = self.position;
    [[[GameMechanics sharedGameMechanics] gameScene] addChild:system];
    
    // mark as unvisible and move off screen
    self.visible = FALSE;
    self.position = ccp(-MAX_INT, 0);
    [[GameMechanics sharedGameMechanics] game].fatness = [[GameMechanics sharedGameMechanics] game].fatness -= 8;
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

@end
