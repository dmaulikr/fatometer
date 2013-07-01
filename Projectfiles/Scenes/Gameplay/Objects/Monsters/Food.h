//
//  Monster.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/18/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "CCSprite.h"

@interface Food : CCSprite

{
    float fatness;
    bool healthy;
}

@property (nonatomic, assign) BOOL visible;

- (id)initWithMonsterPicture;
- (void)spawn;
- (void)gotCollected;

@property (nonatomic, assign) NSInteger hitPoints;
// velocity in pixels per second
@property (nonatomic, assign) CGPoint velocity;

@property (nonatomic, strong) NSMutableArray *animationFrames;
@property (nonatomic, strong) CCAction *run;
@property (nonatomic, assign) NSInteger initialHitPoints;

@end