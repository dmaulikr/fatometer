//
//  DieAmountOfTimes.m
//  Wild Food
//
//  Created by Shalin Shah on 8/4/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "DieAmountOfTimes.h"
#import "GameMechanics.h"
#import "GameplayLayer.h"
#import "Knight.h"

// Die amount of times and keep going

@implementation DieAmountOfTimes

- (id)init
{
    self = [super init];
    
    if (self)
    {
        tempDeaths = 0;
        self.missionObjectives = [[NSMutableArray alloc] init];
        
        // available mission objectives need to be defined here, for mission generator
        dieingTimes = [[MissionObjective alloc] initWithObjectiveType:MissionObjectiveTypeHigherIsBetter];
        [self.missionObjectives addObject:dieingTimes];
        // the goal value will be set later on, either manually or by the mission generator
    }
    
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder
{
    // call the superclass, that initializes a mission from disk
    self = [super initWithCoder:decoder];
    // additionally store a reference to the 'runningDistance' objective in the instance variable.
    dieingTimes = [self.missionObjectives objectAtIndex:0];
    
    return self;
}

- (void)missionStart:(Game *)game
{
    // capture the start distance
    //    startDistance = game.meters;
}

- (void)generalGameUpdate:(Game *)game
{
    tempDeaths = [[GameMechanics sharedGameMechanics] game].deaths;
    // check if we have reached the required distance
    if (tempDeaths >= dieingTimes.goalValue)
    {
        self.successfullyCompleted = TRUE;
    }
}

@end
