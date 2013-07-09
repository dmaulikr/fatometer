//
//  Apples.h
//  Fat
//
//  Created by Shalin Shah on 7/9/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Food.h"

@interface Apples : Food

@property (nonatomic, assign) NSInteger hitPoints;
// velocity in pixels per second
@property (nonatomic, assign) CGPoint velocity;

@property (nonatomic, strong) NSMutableArray *animationFrames;
@property (nonatomic, strong) CCAction *run;
@property (nonatomic, assign) NSInteger initialHitPoints;

@end
