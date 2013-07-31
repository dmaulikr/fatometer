//
//  JumpWithoutCollectingFoods.m
//  Wild Food
//
//  Created by Shalin Shah on 7/31/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "JumpWithoutCollectingFoods.h"
#import "GameMechanics.h"
#import "GameplayLayer.h"
#import "Knight.h"

@implementation JumpWithoutCollectingFoods

- (id)init
{
    self = [super init];
    
    if (self)
    {
        temporaryjumps = 0;
        self.missionObjectives = [[NSMutableArray alloc] init];
        
        // available mission objectives need to be defined here, for mission generator
        jumpingTimes = [[MissionObjective alloc] initWithObjectiveType:MissionObjectiveTypeHigherIsBetter];
        [self.missionObjectives addObject:jumpingTimes];
        // the goal value will be set later on, either manually or by the mission generator
    }
    
    return self;
}

/*
 Here we need to restore any information, that is not persisted and loaded in the Superclass 'Mission'.
 */
- (id)initWithCoder:(NSCoder *)decoder
{
    // call the superclass, that initializes a mission from disk
    self = [super initWithCoder:decoder];
    // additionally store a reference to the 'runningDistance' objective in the instance variable.
    jumpingTimes = [self.missionObjectives objectAtIndex:0];
    
    return self;
}

- (void)missionStart:(Game *)game
{
    // capture the start distance
//    startDistance = game.meters;
}

- (void)generalGameUpdate:(Game *)game
{
    temporaryjumps = [[GameMechanics sharedGameMechanics] game].jumps;
    // check if we have reached the required distance
    if (temporaryjumps >= jumpingTimes.goalValue)
    {
        self.successfullyCompleted = TRUE;
    }
}


@end
