//
//  JumpWithoutCollectingFoods.h
//  Wild Food
//
//  Created by Shalin Shah on 7/31/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Mission.h"
#import "MissionObjective.h"

@interface JumpWithoutCollectingFoods : Mission
{
    // the current distance, when the mission started. Used to compare, how far the player has run since the mission start.
    MissionObjective *jumpingTimes;
    int temporaryjumps;
}

- (void)generalGameUpdate:(Game *)game;

@end
