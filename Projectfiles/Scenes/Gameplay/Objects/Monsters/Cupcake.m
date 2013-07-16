//
//  Cupcake.m
//  Fat
//
//  Created by Shalin Shah on 7/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Cupcake.h"
#import "GameMechanics.h"


@implementation Cupcake

- (id)initWithMonsterPicture
{
    self = [super initWithFile:@"cupcake.png"];
    
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
    [[GameMechanics sharedGameMechanics] game].fatness = [[GameMechanics sharedGameMechanics] game].fatness += 3;
}



@end
