//
//  PauseScreen.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/10/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "PauseScreen.h"
#import "GameMechanics.h"
#import "StoreScreenScene.h"
#import "STYLES.h"
#import "MainMenuLayer.h"
#import "SimpleAudioEngine.h"


@interface PauseScreen()

- (void)resumeButtonPressed;
- (void)quitButtonPressed;
- (void)resetButtonPressed;

@end

@implementation PauseScreen

- (id)initWithGame:(Game *)game
{
    self = [super init];
    
    if (self)
    {
        // Preload Sound
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"select.mp3"];
        
        self.contentSize = [[CCDirector sharedDirector] winSize];
        // position of screen, animate to screen
        self.position = ccp(self.contentSize.width / 2, self.contentSize.height * 1.5);
        size = [[CCDirector sharedDirector] winSize];
        screenCenter = ccp(size.width/2, size.height/2);
        
        // add a background image node
//        backgroundNode = [[CCBackgroundColorNode alloc] init];
//        backgroundNode.backgroundColor = ccc4(255, 255, 255, 255);
//        backgroundNode.contentSize = self.contentSize;
//        [self addChild:backgroundNode];
        
        // set anchor points new, since we changed content size
        //self.anchorPoint = ccp(0.5, 0.5);
//        backgroundNode.anchorPoint = ccp(0.5, 0.5);
        
        CCSprite* background = [CCSprite spriteWithFile:@"pausebackground.png"];
        self.position = ccp(self.contentSize.width / 4, self.contentSize.height / 4);
        background.scale = 2;
        [self addChild:background z:-100000];
        
        // add title label
        CCSprite *pauseTitle = [CCSprite spriteWithFile:@"pause-title-hd.png"];
        pauseTitle.position = ccp(0,(self.contentSize.height/2.5)-10);
        [self addChild:pauseTitle];
        
        // add a resume button
        resumeMenuItem = [CCMenuItemImage itemWithNormalImage:@"play-button.png" selectedImage:@"play-button-down.png" target:self selector:@selector(resumeButtonPressed)];
        
        // add a reset button
        resetMenuItem = [CCMenuItemImage itemWithNormalImage:@"restart-button.png" selectedImage:@"restart-button-down.png" target:self selector:@selector(resetButtonPressed)];
        
        // add a quit button
        homeMenuItem = [CCMenuItemImage itemWithNormalImage:@"home-button.png" selectedImage:@"home-button-down.png" target:self selector:@selector(homeButtonPressed)];
        
        // add a store button
        storeMenuItem = [CCMenuItemImage itemWithNormalImage:@"store-button.png" selectedImage:@"store-button-down.png" target:self selector:@selector(storeButtonPressed)];

        menu = [CCMenu menuWithItems:resumeMenuItem, resetMenuItem, homeMenuItem, storeMenuItem, nil];
        [menu alignItemsHorizontally];
        menu.position = ccp(0, (self.contentSize.height/6)-10);
        [self addChild:menu];
        
        // This is for aligning the menu items vertically
        //        menu2 = [CCMenu menuWithItems:resetMenuItem, nil];
        //        [menu2 alignItemsHorizontally];
        //        menu2.position = ccp(0, -15);
        //        [self addChild:menu2];
        //
        //        menu3 = [CCMenu menuWithItems:quitMenuItem, nil];
        //        [menu3 alignItemsHorizontally];
        //        menu3.position = ccp(0, -95);
        //        [self addChild:menu3];
        
        // add a missions node
        missionNode = [[MissionsNode alloc] initWithMissions:game.missions];
        missionNode.contentSize = CGSizeMake(240.f, 120.f);
        missionNode.anchorPoint = ccp(0.5, 0.5);
        missionNode.position = ccp(0, -70);

        // we want to use the 9Patch background on the pause screen
        missionNode.usesScaleSpriteBackground = TRUE;
        [self addChild:missionNode];
    }
    
    return self;
}

- (void)homeButtonPressed
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1.0f scene:[GameplayLayer node]]];
    [[[GameMechanics sharedGameMechanics] gameScene] quit];
    NSLog(@"quit button pressed");
//    [[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
}

- (void)resetButtonPressed
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:1.0f scene:[GameplayLayer node]]];
    [[[GameMechanics sharedGameMechanics] gameScene] reset];
    NSLog(@"reset button pressed");
//    [[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
}

- (void)resumeButtonPressed
{
    [self hideAndResume];
    [self.delegate resumeButtonPressed:self];
//    [[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
}
- (void)storeButtonPressed
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1.0f scene:[StoreScreenScene node]]];
//    [[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
}

- (void)present
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:0.2f position:ccp(self.contentSize.width / 2, self.contentSize.height * 0.5)];
    [self runAction:move];
    [missionNode updateCheckmarks];
}

- (void)hideAndResume
{
    if (self.parent != nil)
    {
        // animate off screen
        CGPoint targetPosition = ccp(self.contentSize.width / 2, self.contentSize.height * 1.5);
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.2f position:targetPosition];
        
        CCCallBlock *removeFromParent = [[CCCallBlock alloc] initWithBlock:^{
            [self removeFromParentAndCleanup:TRUE];
            // resume the game
            [[GameMechanics sharedGameMechanics] setGameState:GameStateRunning];
        }];
        
        CCSequence *hideSequence = [CCSequence actions:move, removeFromParent, nil];
        [self runAction:hideSequence];
    }
}

@end