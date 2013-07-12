//
//  SlowMonster.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/18/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "HealthyFood.h"
#import "GameMechanics.h"

@implementation HealthyFood

- (id)initWithMonsterPicture
{
    self = [super initWithFile:@"healthy.png"];
    
    if (self)
    {        
        self.initialHitPoints = 1;
        self.animationFrames = [NSMutableArray array];
        [self scheduleUpdate];
    }
    
    return self;
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
//    [[GameMechanics sharedGameMechanics] game].enemiesKilled += 1;
    [[GameMechanics sharedGameMechanics] game].score += 1;
    [[GameMechanics sharedGameMechanics] game].fatness = [[GameMechanics sharedGameMechanics] game].fatness -= 20;
}

@end
