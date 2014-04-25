//
//  Strawberries.m
//  Fat
//
//  Created by Shalin Shah on 7/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Strawberries.h"
#import "GameMechanics.h"
#import "GameplayLayer.h"

@implementation Strawberries

- (id)initWithMonsterPicture
{
    self = [super initWithFile:@"strawberry.png"];
    
    if (self)
    {
        self.initialHitPoints = 1;
        self.animationFrames = [NSMutableArray array];
        [self scheduleUpdate];
    }
    
    return self;
}

- (void)spawn
{
	// Select a spawn location just outside the right side of the screen, with random y position
	CGRect screenRect = [[CCDirector sharedDirector] screenRect];
	CGSize spriteSize = [self contentSize];
	float xPos = screenRect.size.width + spriteSize.width * 0.5f;
    //	float yPos = CCRANDOM_0_1() * (0.25 * screenRect.size.height - spriteSize.height) + spriteSize.height * 0.5f;
//    int yPos = 0.21 * screenRect.size.height - spriteSize.height;
    int yPos2 = screenRect.size.height / 8 *4;;
//    int randomNumber = (arc4random()%(yPos2-yPos))+yPos;
	self.position = CGPointMake(xPos, yPos2);
    
    self.visible = YES;
	// reset health
	self.hitPoints = self.initialHitPoints;
}
- (void)gotCollected {
    
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
    [[GameMechanics sharedGameMechanics] game].foodsCollected = [[GameMechanics sharedGameMechanics] game].foodsCollected += 1;
}
- (void)update:(ccTime)delta
{
    // only execute the block, if the game is in 'running' mode
    if ([[GameMechanics sharedGameMechanics] gameState] == GameStateRunning)
    {
        [self updateRunningMode:delta];
    }
}

- (void)updateRunningMode:(ccTime)delta
{
    // apply background scroll speed
    float xVelocity = self.velocity.x;
    float backgroundScrollSpeedX = [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX];
    
    xVelocity -= backgroundScrollSpeedX;
    CGPoint combinedVelocity = ccp(xVelocity, self.velocity.y);
    // move the monster until it leaves the left edge of the screen
    if (self.position.x > (self.contentSize.width * (-1)))
    {
        [self setPosition:ccpAdd(self.position, ccpMult(combinedVelocity,delta))];
    }
}
@end