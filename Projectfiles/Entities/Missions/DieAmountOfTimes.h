//
//  DieAmountOfTimes.h
//  Wild Food
//
//  Created by Shalin Shah on 8/4/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Mission.h"
#import "MissionObjective.h"

@interface DieAmountOfTimes : Mission

{
    // the current distance, when the mission started. Used to compare, how far the player has run since the mission start.
    MissionObjective *dieingTimes;
    int tempDeaths;
}

- (void)generalGameUpdate:(Game *)game;


@end
