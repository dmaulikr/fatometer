//
//  Knight.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "Knight.h"
#import "GameplayLayer.h"
#import "GameMechanics.h"

@implementation Knight

- (void)dealloc
{
    /*
     When our object is removed, we need to unregister from all notifications.
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithKnightPicture {
    self = [super initWithFile:@"animation_knight-1.png"];
    
    if (self)
    {
        // knight is initally not moving
        self.velocity = ccp(0,0);
        self.invincible = FALSE;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"animation_knight.plist"];
        
        // ************* RUNNING ANIMATION ********************
        
        animationFramesRun = [NSMutableArray array];
        
        for(int i = 1; i <= 4; ++i)
        {
            [animationFramesRun addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"animation_knight-%d.png", i]]];
        }
        
        //Create an animation from the set of frames you created earlier
        CCAnimation *running = [CCAnimation animationWithSpriteFrames: animationFramesRun delay:0.1f];
        
        //Create an action with the animation that can then be assigned to a sprite
        run = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:running]];
        
        
        // ************* STABBING ANIMATION ********************
        
        animationFramesStab = [NSMutableArray array];
        
        for (int i = 1; i <= 2; i++)
        {
            [animationFramesRun addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"animation_knight-stab-%d.png", i]]];
        }
        
        CCAnimation *stabbing = [CCAnimation animationWithSpriteFrames:animationFramesStab delay:0.5f];
        CCAction *stabAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:stabbing] times:1];
        
        CCFiniteTimeAction *startStab = [CCCallBlock actionWithBlock:^{
            // stop running animation
            self.stabbing = TRUE;
            [self stopAction:run];
        }];
        
        CCFiniteTimeAction *finishStab = [CCCallBlock actionWithBlock:^{
            self.stabbing = FALSE;
            // restart running animation
            [self runAction:run];
        }];
        
        stab = [CCSequence actions:startStab, stabAction, finishStab, nil];
        
        // run knight running animation
        [self runAction:run];
        
        [self scheduleUpdate];
        
        /**
         A Notification can be used to broadcast an information to all objects of a game, that are interested in it.
         Here we sign up for the 'GamePaused' and 'GameResumed' information, that is broadcasted by the GameMechanics class. Whenever the game pauses or resumes, we get informed and can react accordingly.
         **/
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePaused) name:@"GamePaused" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResumed) name:@"GameResumed" object:nil];
        
        fatness = 50;
    }
    
    return self;
}

- (void)gamePaused
{
    [self pauseSchedulerAndActions];
}

- (void)gameResumed
{
    [self resumeSchedulerAndActions];
}

- (void)jump
{
    // can only jump of the floor
    if (self.position.y == [[GameMechanics sharedGameMechanics] floorHeight])
    {
        self.velocity = ccp(self.velocity.x, 475.f);
    }
}

- (void)stab
{
    // animation needs to be either done (isDone) or run for the first time (stabDidRun)
    if ((stabDidRun == FALSE) || [stab isDone])
    {
        [self runAction:stab];
        stabDidRun = TRUE;
    }
}

- (void)gotHit
{
    if (self.invincible)
    {
        // if we are invincible at the moment, we cannot be hit
        return;
    }
    
    CCAction *blinkAction = [self getActionByTag:1000];
    
    
    if ( (blinkAction == nil) || [blinkAction isDone])
    {
        fatness = fatness - 2;
        fatness--;
        CCBlink *blink = [CCBlink actionWithDuration:1.5f blinks:5];
        blink.tag = 1000;
        [self runAction:blink];
    }
    
}

- (void)collect
{
    if (self.invincible)
    {
        // if we are invincible at the moment, we cannot be hit
        return;
    }
    
    CCAction *blinkAction = [self getActionByTag:1000];
    
    if ( (blinkAction == nil) || [blinkAction isDone])
    {
        fatness = fatness + 2;
        fatness++;
        self.hitPoints --;
        CCBlink *blink = [CCBlink actionWithDuration:1.5f blinks:5];
        blink.tag = 1000;
        [self runAction:blink];
    }
}

- (void)update:(ccTime)delta
{
    // only execute the block, if the game is in 'running' mode
    if ([[GameMechanics sharedGameMechanics] gameState] == GameStateRunning)
    {
        [self updateRunningMode:delta];
    }
    
    NSNumber *toolbarPointer = [NSNumber numberWithInteger:fatness];
    [[NSUserDefaults standardUserDefaults] setObject:toolbarPointer forKey:@"toolbarPointer"];
}

- (void)updateRunningMode:(ccTime)delta
{
    // flip the animation when moving backwards
    if (self.velocity.x < -50.f)
    {
        self.flipX = TRUE;
    }
    else if (self.velocity.x > 50.f)
    {
        self.flipX = FALSE;
    }
    
    // apply gravity
    CGPoint gravity = [[GameMechanics sharedGameMechanics] worldGravity];
    float xVelocity = self.velocity.x;
    float yVelocity = self.velocity.y;
    
    NSAssert(gravity.x <= 0, @"Currently only negative gravity is supported");
    // only apply gravity if the current velocity is not equal to the gravity velocity
    if (xVelocity > gravity.x)
    {
        xVelocity = self.velocity.x + (gravity.x * delta);
    }
    
    NSAssert(gravity.y <= 0, @"Currently only negative gravity is supported");
    // only apply gravity if the current velocity is not equal to the gravity velocity
    if (yVelocity > gravity.y)
    {
        yVelocity = self.velocity.y + (gravity.y * delta);
    }
    
    self.velocity = ccp(xVelocity, yVelocity);
    
    [self setPosition:ccpAdd(self.position, ccpMult(self.velocity,delta))];
    
    // ensure, that entity cannot move below the floor or out of screen boundaries
    if (self.position.y < [[GameMechanics sharedGameMechanics] floorHeight])
    {
        self.position = ccp(self.position.x, [[GameMechanics sharedGameMechanics] floorHeight]);
    }
    
    // check that knight does not leave left screen border
    if (self.position.x < 0)
    {
        self.position = ccp(0, self.position.y);
    }
    
    // check that knight does not leave right screen border
    CGSize sceneSize = [[[GameMechanics sharedGameMechanics] gameScene] contentSize];
    int rightBorder = sceneSize.width - self.contentSize.width;
    if (self.position.x > rightBorder) {
        self.position = ccp(rightBorder, self.position.y);
    }
    
    // calculate a hit zone
    CGPoint knightCenter = ccp(self.position.x + self.contentSize.width / 2, self.position.y + self.contentSize.height / 2);
    CGSize hitZoneSize = CGSizeMake(self.contentSize.width/2, self.contentSize.height/2);
    self.hitZone = CGRectMake(knightCenter.x - 0.5 * hitZoneSize.width, knightCenter.y - 0.5 * hitZoneSize.width, hitZoneSize.width, hitZoneSize.height);
}

- (void)draw
{
    [super draw];
    
#ifdef DEBUG
    // visualize the hit zone
    /*
     ccDrawColor4B(100, 0, 255, 255); //purple, values range from 0 to 255
     CGPoint origin = ccp(self.hitZone.origin.x - self.position.x, self.hitZone.origin.y - self.position.y);
     CGPoint destination = ccp(origin.x + self.hitZone.size.width, origin.y + self.hitZone.size.height);
     ccDrawRect(origin, destination);
     */
    
#endif
}

@end