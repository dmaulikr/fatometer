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

-(id)initWithKnightPicture:(NSString*)aPicture {
    
    NSString *imageName = [aPicture stringByAppendingString:@".png"];
    NSString *plistName = [aPicture stringByAppendingString:@".plist"];
    
    self = [super initWithFile:imageName];
    
    NSLog(@"%@ is the imagename", imageName);
    NSLog(@"%@ is the plistname", plistName);

    if (self)
    {
        // knight is initally not moving
        self.velocity = ccp(0,0);
        self.invincible = FALSE;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plistName];
        
        // ************* RUNNING ANIMATION ********************
        animationFramesRun = [NSMutableArray array];
        for(int i = 1; i <= 6; ++i) {
            [animationFramesRun addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"Level3-Run-hd_%d.png", i]]];
        }
        
        //Create an animation from the set of frames you created earlier
        CCAnimation *running = [CCAnimation animationWithSpriteFrames: animationFramesRun delay:0.1f];
        
        //Create an action with the animation that can then be assigned to a sprite
        run = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:running]];
        
        // run knight running animation
        [self runAction:run];
        [self scheduleUpdate];
        
        // Resizeing sprite (but this was before the fat guy came into play - when it was the knight image)
        
//        [self resizeSprite:self toWidth:80 toHeight:70];
//        if (IS_IPHONE_5 || IS_IPOD_5 || IS_IPOD || IS_IPHONE) {
//            [self resizeSprite:self toWidth:80 toHeight:70];
//            knightWidth = [self boundingBox].size.width; // calibrate collision detection
//        } else if (IS_IPAD) {
//            [self resizeSprite:self toWidth:150 toHeight:137];
//            knightWidth = [self boundingBox].size.width; // calibrate collision detection
//        } else if (IS_IPAD_RETINA) {
//            [self resizeSprite:self toWidth:200 toHeight:185];
//            knightWidth = [self boundingBox].size.width; // calibrate collision detection
//        }
        
        /**
         A Notification can be used to broadcast an information to all objects of a game, that are interested in it.
         Here we sign up for the 'GamePaused' and 'GameResumed' information, that is broadcasted by the GameMechanics class. Whenever the game pauses or resumes, we get informed and can react accordingly.
         **/
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePaused) name:@"GamePaused" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResumed) name:@"GameResumed" object:nil];
    }
    return self;
}

- (NSString*)fileNameForFatness:(int) fatness
{
    if (fatness < 20){
        return @"fatguyfredL1";
//        NSLog(@"Level 1 Fatness");
    } else if (fatness < 40) {
        return @"fatguyfredL2";
//        NSLog(@"Level 2 Fatness");
    } else if (fatness < 60) {
        return @"fatguyfredL3";
//        NSLog(@"Level 3 Fatness");
    } else if (fatness < 80) {
        return @"fatguyfredL4";
//        NSLog(@"Level 4 Fatness");
    } else if (fatness < 100) {
        return @"fatguyfredL5";
//        NSLog(@"Level 5 Fatness");
    }
    return nil;
}


-(void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height {
    sprite.scaleX = width / sprite.contentSize.width;
    sprite.scaleY = height / sprite.contentSize.height;
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
        if (IS_IPHONE_5 || IS_IPOD_5 || IS_IPOD || IS_IPHONE) {
            self.velocity = ccp(self.velocity.x, 475.f);
        } else if ([[CCDirector sharedDirector] winSizeInPixels].height == 768) {
            self.velocity = ccp(self.velocity.x, 675.f);
        } else if (IS_IPAD_RETINA) {
            self.velocity = ccp(self.velocity.x, 805.f);
        }
        [[GameMechanics sharedGameMechanics] game].jumps += 1;
    }
}
-(void)jumpLess
{
    // can only jump of the floor
    if (self.position.y == [[GameMechanics sharedGameMechanics] floorHeight])
    {
        self.velocity = ccp(self.velocity.x, 285.f);
        
        if (IS_IPHONE_5 || IS_IPOD_5 || IS_IPOD || IS_IPHONE) {
            self.velocity = ccp(self.velocity.x, 285.f);
        } else if (IS_IPAD) {
            self.velocity = ccp(self.velocity.x, 385.f);
        } else if (IS_IPAD_RETINA) {
            self.velocity = ccp(self.velocity.x, 485.f);
        }
        [[GameMechanics sharedGameMechanics] game].jumps += 1;
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

- (void)collect
{
    if (self.invincible)
    {
        //        pointerUpdate = nil;
    }
    
    CCAction *blinkAction = [self getActionByTag:1000];
    
    if ( (blinkAction == nil) || [blinkAction isDone])
    {
        //        self.hitPoints --;
        CCBlink *blink = [CCBlink actionWithDuration:1.5f blinks:5];
        blink.tag = 1000;
        [self runAction:blink];
    }
}

- (void)update:(ccTime)delta
{
//    if ([[GameMechanics sharedGameMechanics] game].fatness < 20) {
//        l1 = [NSString stringWithFormat:@"fatguyfredL1.png"];
//        l1_plist = [NSString stringWithFormat:@"fatguyfredL1.plist"];
//        animation = [NSString stringWithFormat:@"Level1-Run-hd"];
//    } else if ([[GameMechanics sharedGameMechanics] game].fatness < 40) {
//        l1 = [NSString stringWithFormat:@"fatguyfredL2.png"];
//        l1_plist = [NSString stringWithFormat:@"fatguyfredL2.plist"];
//        animation = [NSString stringWithFormat:@"Level2-Run-hd"];
//    } else if ([[GameMechanics sharedGameMechanics] game].fatness < 60) {
//        l1 = [NSString stringWithFormat:@"fatguyfredL3.png"];
//        l1_plist = [NSString stringWithFormat:@"fatguyfredL3.plist"];
//        animation = [NSString stringWithFormat:@"Level3-Run-hd"];
//    } else if ([[GameMechanics sharedGameMechanics] game].fatness < 80) {
//        l1 = [NSString stringWithFormat:@"fatguyfredL4.png"];
//        l1_plist = [NSString stringWithFormat:@"fatguyfredL4.plist"];
//        animation = [NSString stringWithFormat:@"Level4-Run-hd"];
//    } else if ([[GameMechanics sharedGameMechanics] game].fatness < 100) {
//        l1 = [NSString stringWithFormat:@"fatguyfredL5.png"];
//        l1_plist = [NSString stringWithFormat:@"fatguyfredL5.plist"];
//        animation = [NSString stringWithFormat:@"Level5-Run-hd"];
//    }
//    
    // only execute the block, if the game is in 'running' mode
    if ([[GameMechanics sharedGameMechanics] gameState] == GameStateRunning)
    {
        [self updateRunningMode:delta];
    }
}

- (void)updateRunningMode:(ccTime)delta
{
    // flip the animation when moving backwards
    //    if (self.velocity.x < -50.f)
    //    {
    //        self.flipX = TRUE;
    //    }
    //    else if (self.velocity.x > 50.f)
    //    {
    //        self.flipX = FALSE;
    //    }
    
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