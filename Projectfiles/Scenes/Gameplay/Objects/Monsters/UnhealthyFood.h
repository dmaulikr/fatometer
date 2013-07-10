//
//  GhostMonster.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "UnhealthyFood.h"
#import "Food.h"

@interface UnhealthyFood : Food

@property (nonatomic, assign) NSInteger hitPoints;
// velocity in pixels per second
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, strong) NSMutableArray *animationFrames;
@property (nonatomic, strong) CCAction *run;
@property (nonatomic, assign) NSInteger initialHitPoints;

@end